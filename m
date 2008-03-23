From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [AX25] kernel panic
Date: Sun, 23 Mar 2008 18:00:17 +0100
Message-ID: <47E68CA1.2040904@free.fr>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:52384 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753516AbYCWRA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 13:00:28 -0400
In-Reply-To: <20080322113620.GA3213@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski wrote:
> On Thu, Mar 20, 2008 at 11:58:35PM +0100, Bernard Pidoux wrote:
> ...
>> BUG: spinlock bad magic on CPU#0, swapper/0
>> BUG: unable to handle kernel paging request at virtual address 6b6b6c2f
>> printing eip: c01e730b *pde = 00000000
>> Oops: 0000 [#1] SMP
> ...
>> Pid: 0, comm: swapper Not tainted (2.6.24.3 #8)
>> EIP: 0060:[<c01e730b>] EFLAGS: 00010002 CPU: 0
>> EIP is at spin_bug+0xdb/0xf0
> ...
> 
> Hi,
> 
> Bernard, could you try this debugging patch?
> 
> Thanks,
> Jarek P.
> 
> ---
> 
> diff -Nurp 2.6.24.3-/net/core/sock.c 2.6.24.3+/net/core/sock.c
> --- 2.6.24.3-/net/core/sock.c	2008-01-24 23:58:37.000000000 +0100
> +++ 2.6.24.3+/net/core/sock.c	2008-03-22 12:10:10.000000000 +0100
> @@ -1517,14 +1517,21 @@ static void sock_def_write_space(struct 
>  	 * progress.  --DaveM
>  	 */
>  	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf) {
> -		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> +		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
> +			if (!sk->sk_socket || sk->sk_socket->sk != sk) {
> +				WARN_ON_ONCE(1);
> +				sk->sk_socket = NULL;
> +				sk->sk_sleep = NULL;
> +				goto out;
> +			}
>  			wake_up_interruptible(sk->sk_sleep);
> +		}
>  
>  		/* Should agree with poll, otherwise some programs break */
>  		if (sock_writeable(sk))
>  			sk_wake_async(sk, 2, POLL_OUT);
>  	}
> -
> +out:
>  	read_unlock(&sk->sk_callback_lock);
>  }
>

Hi Jarek,

Here is the result of your patch :


WARNING: at net/core/sock.c:1522 sock_def_write_space()
Pid: 3452, comm: mkiss Not tainted 2.6.24.3 #2
  [<c010513a>] show_trace_log_lvl+0x1a/0x30
  [<c0105b52>] show_trace+0x12/0x20
  [<c01064ac>] dump_stack+0x6c/0x80
  [<c024d54b>] sock_def_write_space+0x10b/0x120
  [<c024d93a>] sock_wfree+0x3a/0x40
  [<c024fafd>] skb_release_all+0x4d/0xf0
  [<c024f2ab>] __kfree_skb+0xb/0x90
  [<c024f349>] kfree_skb+0x19/0x30
  [<c8cb5e37>] ax_xmit+0xf7/0x360 [mkiss]
  [<c0255367>] dev_hard_start_xmit+0x207/0x270
  [<c02657f4>] __qdisc_run+0x54/0x1a0
  [<c0257bac>] dev_queue_xmit+0x25c/0x330
  [<c8cc8a77>] ax25_queue_xmit+0x47/0x70 [ax25]
  [<c8cc8b65>] ax25_transmit_buffer+0xc5/0x110 [ax25]
  [<c8cc8c2d>] ax25_send_iframe+0x7d/0x110 [ax25]
  [<c8cc8d70>] ax25_kick+0xb0/0x1b0 [ax25]
  [<c8cc9e29>] ax25_std_frame_in+0x69/0x890 [ax25]
  [<c8cc7dba>] ax25_kiss_rcv+0x2ba/0x7b0 [ax25]
  [<c0254cc4>] netif_receive_skb+0x244/0x2e0
  [<c0257835>] process_backlog+0x75/0xe0
  [<c025734b>] net_rx_action+0x12b/0x1d0
  [<c011d595>] __do_softirq+0x55/0xc0
  [<c011d647>] do_softirq+0x47/0x50
  [<c011d9f5>] local_bh_enable_ip+0x95/0xe0
  [<c02babe5>] _spin_unlock_bh+0x25/0x30
  [<c8cb56b0>] mkiss_receive_buf+0x360/0x420 [mkiss]
  [<c020dfe7>] pty_write+0x47/0x60
  [<c020b5b2>] write_chan+0x222/0x330
  [<c0208c76>] tty_write+0x126/0x1b0
  [<c01728df>] vfs_write+0xaf/0x120
  [<c0172e2d>] sys_write+0x3d/0x70
  [<c010412a>] sysenter_past_esp+0x5f/0xa5
  =======================


Happy Easter,


Bernard Pidoux


