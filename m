From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [AX25] kernel panic
Date: Tue, 25 Mar 2008 14:23:46 +0100
Message-ID: <47E8FCE2.6000308@free.fr>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local> <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:54043 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753956AbYCYNXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 09:23:50 -0400
In-Reply-To: <20080324205104.GA3721@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski wrote:
> On Sun, Mar 23, 2008 at 06:00:17PM +0100, Bernard Pidoux wrote:
> ...
>> Here is the result of your patch :
>>
>>
>> WARNING: at net/core/sock.c:1522 sock_def_write_space()
>> Pid: 3452, comm: mkiss Not tainted 2.6.24.3 #2
> ...
> 
> Thanks. Here is one more (to apply after the previous one).
> 
> Happy Holidays...
> Jarek P.
> 
> ---
> 
> diff -Nurp 2.6.24.3-with1/include/net/sock.h 2.6.24.3-with2/include/net/sock.h
> --- 2.6.24.3-with1/include/net/sock.h	2008-01-24 23:58:37.000000000 +0100
> +++ 2.6.24.3-with2/include/net/sock.h	2008-03-24 21:14:43.000000000 +0100
> @@ -263,6 +263,7 @@ struct sock {
>    	int			(*sk_backlog_rcv)(struct sock *sk,
>  						  struct sk_buff *skb);  
>  	void                    (*sk_destruct)(struct sock *sk);
> +	int			sk_ax25_debug;
>  };
>  
>  /*
> diff -Nurp 2.6.24.3-with1/net/ax25/af_ax25.c 2.6.24.3-with2/net/ax25/af_ax25.c
> --- 2.6.24.3-with1/net/ax25/af_ax25.c	2008-01-24 23:58:37.000000000 +0100
> +++ 2.6.24.3-with2/net/ax25/af_ax25.c	2008-03-23 00:53:51.000000000 +0100
> @@ -936,6 +936,7 @@ struct sock *ax25_make_new(struct sock *
>  	}
>  
>  	sk->sk_protinfo = ax25;
> +	sk->sk_ax25_debug = 1;
>  	ax25->sk    = sk;
>  
>  	return sk;
> diff -Nurp 2.6.24.3-with1/net/core/sock.c 2.6.24.3-with2/net/core/sock.c
> --- 2.6.24.3-with1/net/core/sock.c	2008-03-22 12:10:10.000000000 +0100
> +++ 2.6.24.3-with2/net/core/sock.c	2008-03-24 21:43:46.000000000 +0100
> @@ -1519,6 +1519,9 @@ static void sock_def_write_space(struct 
>  	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf) {
>  		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
>  			if (!sk->sk_socket || sk->sk_socket->sk != sk) {
> +				if (net_ratelimit())
> +					printk(KERN_INFO "sk_ax25_debug = %d, %p\n",
> +						 sk->sk_ax25_debug, sk->sk_socket);
>  				WARN_ON_ONCE(1);
>  				sk->sk_socket = NULL;
>  				sk->sk_sleep = NULL;
> 
> 

After applying this patch I did not see any sk_ax25_debug = 1 into 
/var/log/messages. It was always = 0.

  Mar 25 12:03:07 f6bvp-9 kernel: sk_ax25_debug = 0, c08de2e0
  Mar 25 12:11:55 f6bvp-9 kernel: sk_ax25_debug = 0, c08de2e0
  Mar 25 12:13:07 f6bvp-9 kernel: sk_ax25_debug = 0, c08de2e0
  Mar 25 12:16:39 f6bvp-9 kernel: sk_ax25_debug = 0, c08de040
  Mar 25 12:18:57 f6bvp-9 kernel: sk_ax25_debug = 0, c08de040
  Mar 25 12:23:12 f6bvp-9 kernel: sk_ax25_debug = 0, c08de580
  Mar 25 12:26:50 f6bvp-9 kernel: sk_ax25_debug = 0, c08de580
  Mar 25 12:32:34 f6bvp-9 kernel: sk_ax25_debug = 0, c08de040
  Mar 25 12:33:14 f6bvp-9 kernel: sk_ax25_debug = 0, c08de2e0
  Mar 25 12:33:57 f6bvp-9 kernel: sk_ax25_debug = 0, c08de040
  Mar 25 12:36:56 f6bvp-9 kernel: sk_ax25_debug = 0, c08de580
  Mar 25 12:43:16 f6bvp-9 kernel: sk_ax25_debug = 0, c08de580
  Mar 25 12:48:34 f6bvp-9 kernel: sk_ax25_debug = 0, c08de580
  Mar 25 12:48:57 f6bvp-9 kernel: sk_ax25_debug = 0, c08de040
  Mar 25 12:53:10 f6bvp-9 kernel: sk_ax25_debug = 0, c08de580
  Mar 25 13:00:31 f6bvp-9 kernel: sk_ax25_debug = 0, c08de2e0
  Mar 25 13:03:24 f6bvp-9 kernel: sk_ax25_debug = 0, c08de2e0
  Mar 25 13:03:56 f6bvp-9 kernel: sk_ax25_debug = 0, c08de040
  Mar 25 13:10:52 f6bvp-9 kernel: sk_ax25_debug = 0, c08de2e0
  Mar 25 13:13:22 f6bvp-9 kernel: sk_ax25_debug = 0, c08de040


Here is an extract of /var/log/kernel/warnings.log

  Mar 25 11:54:04 f6bvp-9 kernel: NET: Registered protocol family 3
  Mar 25 11:54:04 f6bvp-9 kernel: mkiss: AX.25 Multikiss, Hans Albas PE1AYX
  Mar 25 11:54:04 f6bvp-9 mkiss[3443]: starting
  Mar 25 11:54:04 f6bvp-9 kernel: mkiss: ax0: crc mode is auto.
  Mar 25 11:54:04 f6bvp-9 kernel: ADDRCONF(NETDEV_CHANGE): ax0: link 
becomes ready
  Mar 25 11:54:04 f6bvp-9 kernel: mkiss: ax1: crc mode is auto.
  Mar 25 11:54:04 f6bvp-9 kernel: ADDRCONF(NETDEV_CHANGE): ax1: link 
becomes ready
  Mar 25 11:54:05 f6bvp-9 mkiss[3455]: starting
  Mar 25 11:54:05 f6bvp-9 kernel: mkiss: ax2: crc mode is auto.
  Mar 25 11:54:05 f6bvp-9 kernel: ADDRCONF(NETDEV_CHANGE): ax2: link 
becomes ready
  Mar 25 11:54:05 f6bvp-9 kernel: mkiss: ax3: crc mode is auto.
  Mar 25 11:54:05 f6bvp-9 kernel: ADDRCONF(NETDEV_CHANGE): ax3: link 
becomes ready
  Mar 25 11:54:11 f6bvp-9 kdm_greet[3470]: Can't open default user face
  Mar 25 11:54:22 f6bvp-9 kernel: mkiss: ax4: crc mode is auto.
  Mar 25 11:54:22 f6bvp-9 kernel: ADDRCONF(NETDEV_CHANGE): ax4: link 
becomes ready
  Mar 25 11:54:22 f6bvp-9 kissattach[3510]: AX.25 port 4 bound to device ax4
  Mar 25 11:54:22 f6bvp-9 ax25ipd:  Current configuration:
  Mar 25 11:54:22 f6bvp-9 ax25ipd:   socket     udp on port 10093
  Mar 25 11:54:22 f6bvp-9 ax25ipd:   mode       tnc
  Mar 25 11:54:22 f6bvp-9 ax25ipd:   device     /dev/ttyq1
  Mar 25 11:54:22 f6bvp-9 ax25ipd:   speed      115200
  Mar 25 11:54:22 f6bvp-9 ax25ipd:   loglevel   2
  Mar 25 11:54:22 f6bvp-9 ax25ipd:  6 active routes.
  Mar 25 11:54:22 f6bvp-9 ax25ipd:   F6BVP-11     192.168.0.66    udp 
   10093   0
  Mar 25 11:54:22 f6bvp-9 ax25ipd:   F6BVP-10     192.168.0.66    udp 
   10093   1
  Mar 25 11:54:22 f6bvp-9 ax25ipd:   F6BVP-7      192.168.0.103   udp 
   10093   0
  Mar 25 11:54:22 f6bvp-9 ax25ipd:   F6BVP-6      192.168.0.103   udp 
   10093   1
  Mar 25 11:54:22 f6bvp-9 ax25ipd:   F6BVP-12     192.168.0.66    udp 
   10093   0
  Mar 25 11:54:22 f6bvp-9 ax25ipd:   VA2BBS       216.239.82.253  udp 
   10093   1       va2bbs.homeip.net
  Mar 25 11:54:22 f6bvp-9 ax25ipd:  0 parameters
  Mar 25 11:54:26 f6bvp-9 kernel: NET: Registered protocol family 6
  Mar 25 11:54:27 f6bvp-9 kernel: netromd uses obsolete 
(PF_INET,SOCK_PACKET)
  Mar 25 11:54:27 f6bvp-9 netromd[3553]: starting
  --
  Mar 25 12:03:07 f6bvp-9 kernel: sk_ax25_debug = 0, c08de2e0
  Mar 25 12:03:07 f6bvp-9 kernel: WARNING: at net/core/sock.c:1559 
sock_def_write_space()
  Mar 25 12:03:07 f6bvp-9 kernel: Pid: 3443, comm: mkiss Not tainted 
2.6.24.3 #3
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c010513a>] show_trace_log_lvl+0x1a/0x30
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c0105b52>] show_trace+0x12/0x20
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c01064ac>] dump_stack+0x6c/0x80
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c024d5d0>] 
sock_def_write_space+0x150/0x160
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c024d9ba>] sock_wfree+0x3a/0x40
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c024fb7d>] skb_release_all+0x4d/0xf0
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c024f32b>] __kfree_skb+0xb/0x90
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c024f3c9>] kfree_skb+0x19/0x30
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c8c79e03>] 
ax25_frames_acked+0x43/0x70 [ax25]
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c8c77a10>] 
ax25_check_iframes_acked+0x40/0x60 [ax25]
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c8c7946f>] 
ax25_std_frame_in+0x6af/0x890 [ax25]
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c8c76dba>] 
ax25_kiss_rcv+0x2ba/0x7b0 [ax25]
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c0254d44>] 
netif_receive_skb+0x244/0x2e0
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c02578b5>] process_backlog+0x75/0xe0
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c02573cb>] net_rx_action+0x12b/0x1d0
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c011d595>] __do_softirq+0x55/0xc0
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c011d647>] do_softirq+0x47/0x50
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c011d9f5>] local_bh_enable_ip+0x95/0xe0
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c02bac55>] _spin_unlock_bh+0x25/0x30
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c8c696b0>] 
mkiss_receive_buf+0x360/0x420 [mkiss]
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c020dfe7>] pty_write+0x47/0x60
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c020b5b2>] write_chan+0x222/0x330
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c0208c76>] tty_write+0x126/0x1b0
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c01728df>] vfs_write+0xaf/0x120
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c0172e2d>] sys_write+0x3d/0x70
  Mar 25 12:03:07 f6bvp-9 kernel:  [<c010412a>] sysenter_past_esp+0x5f/0xa5
  Mar 25 12:03:07 f6bvp-9 kernel:  =======================
  Mar 25 12:09:01 f6bvp-9 crond[3928]: (root) CMD ([ -d /var/lib/php ] 
&& find /var/lib/php/ -type f -mmin +$(/usr/lib/php/maxlifetime) -print0 
| xargs -r -0 rm)
  Mar 25 12:11:55 f6bvp-9 kernel: sk_ax25_debug = 0, c08de2e0
  Mar 25 12:13:07 f6bvp-9 kernel: sk_ax25_debug = 0, c08de2e0


I forgot to mention an obvious thing : since the WARN_ON_ONCE patch 
there is no more kernel panic. But you knew that of course.

Many thanks for your help.

I am prepared for the next step you probably want to explore.

If it is easier for you, to prepare a patch, I can upgrade to 2.6.24.4.

Best regards,

Bernard P.
