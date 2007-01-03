From: Paul Moore <paul.moore@hp.com>
Subject: Re: selinux networking: sleeping functin called from invalid context in 2.6.20-rc[12]
Date: Wed, 3 Jan 2007 15:46:31 -0500
Message-ID: <200701031546.32582.paul.moore@hp.com>
References: <20061224162511.eaac4a89.akpm@osdl.org> <200701021625.24694.paul.moore@hp.com> <20070102.153754.08319614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: adam@yggdrasil.com, akpm@osdl.org, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:43682 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932101AbXACUqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 15:46:42 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20070102.153754.08319614.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, January 2 2007 6:37 pm, David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Tue, 2 Jan 2007 16:25:24 -0500
>
> > I'm sorry I just saw this mail (mail not sent directly to me get
> > shuffled off to a folder).  I agree with your patch, I think
> > dropping and then re-taking the RCU lock is the best way to go,
> > although I'm curious to see what others have to say.
>
> I think this is fine too.

[NOTE: dropped linux-kernel as I think this discussion is now strictly related 
to socket locking so netdev is probably the best list]

I've been looking some more at Adam's and Ingo's patches for this as well as a 
recent bug against a FC test kernel:

 * https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=220966

For those who don't follow the link here is the meat of the bug report:

****
[ INFO: soft-safe -> soft-unsafe lock order detected ]
2.6.19-1.2891.fc7 #1
------------------------------------------------------
cupsd/1884 [HC0[0]:SC0[1]:HE1:SE0] is trying to acquire:
 (&ssec->nlbl_lock){--..}, at: [<c04cec37>]
selinux_netlbl_socket_setsid+0xbb/0x123

and this task is already holding:
 (af_callback_keys + sk->sk_family#3){-.-+}, at: [<c05daa1c>]
inet_accept+0x70/0xb5
which would create a new lock dependency:
 (af_callback_keys + sk->sk_family#3){-.-+} -> (&ssec->nlbl_lock){--..}

but this new dependency connects a soft-irq-safe lock:
 (af_callback_keys + sk->sk_family#3){-.-+}
... which became soft-irq-safe at:
 [<c043fff1>] __lock_acquire+0x37d/0x9f8
 [<c044094d>] lock_acquire+0x56/0x6f
 [<c05fbdb6>] _read_lock_bh+0x30/0x3d
 [<c04c687e>] selinux_socket_sock_rcv_skb+0xbd/0x252
 [<c05d0645>] tcp_v4_rcv+0x37a/0x909
 [<c05b7593>] ip_local_deliver+0x185/0x22e
 [<c05b73d6>] ip_rcv+0x418/0x450
 [<c059ae9c>] netif_receive_skb+0x2db/0x35a
 [<c059c85f>] process_backlog+0x95/0xf6
 [<c059ca46>] net_rx_action+0xa1/0x1a8
 [<c042bf5a>] __do_softirq+0x6f/0xe2
 [<c04063a1>] do_softirq+0x61/0xc7
 [<ffffffff>] 0xffffffff

to a soft-irq-unsafe lock:
 (&ssec->nlbl_lock){--..}
... which became soft-irq-unsafe at:
...  [<c044007d>] __lock_acquire+0x409/0x9f8
 [<c044094d>] lock_acquire+0x56/0x6f
 [<c05fbc89>] _spin_lock+0x2b/0x38
 [<c04cec37>] selinux_netlbl_socket_setsid+0xbb/0x123
 [<c04d0c92>] selinux_netlbl_socket_post_create+0x2d/0x2f
 [<c04c807b>] selinux_socket_post_create+0x156/0x15c
 [<c059213c>] __sock_create+0x179/0x1b2
 [<c05921ae>] sock_create+0x1a/0x1f
 [<c0592435>] sys_socket+0x1b/0x3c
 [<c0592cba>] sys_socketcall+0x77/0x241
 [<c0404050>] syscall_call+0x7/0xb
 [<ffffffff>] 0xffffffff
****

This makes me believe that Ingo's patch (which I see is now in Linus' and 
Andrew's trees) is the way to go and not the lock re-order approach in Adam's 
patch.  I'm going to continue to look into this, almost more for my own 
education than anything else, but I thought I would mention this lock 
dependency message as it seemed relevant to the discussion.

-- 
paul moore
linux security @ hp
