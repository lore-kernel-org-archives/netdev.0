From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 12 Feb 2008 13:24:50 +0000
Message-ID: <20080212132450.GA11561@ff.dom.local>
References: <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:32278 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756515AbYBLNRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 08:17:38 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2766260wah.23
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2008 05:17:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47B17BCD.2070903@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2008 at 10:58:21AM +0000, James Chapman wrote:
...
> Here is a trace from when we had _bh locks.

Very nice...

...But since it's quite long, and if you don't know all these paths
this could take some time, maybe one question: so if lockdep got these
locks right (sometimes it can be wrong when the same structures are
nested), then it seems some problem is with this place below. This
lock is taken for writing with softirqs enabled here, and IMHO it
would be interesting to test if changing this is enough for lockdep.
It seems this is in ip4_datagram_connect() during sk_dst_reset() or
sk_dst_set(). So maybe you could try with local_bh_disable/enable()
around them (or maybe some better idea)? Anyway, I'll try to learn
this more in the meantime.

Jarek P.

> Feb  5 16:26:32  to a soft-irq-unsafe lock:
> Feb  5 16:26:32  (&sk->sk_dst_lock){----}
> Feb  5 16:26:32  ... which became soft-irq-unsafe at:
> Feb  5 16:26:32  ...  [<c014e02e>] mark_held_locks+0x5e/0x80
> Feb  5 16:26:32  [<c014ed92>] __lock_acquire+0x6a2/0x10a0
> Feb  5 16:26:32  [<c010f5b0>] save_stack_trace+0x20/0x40
> Feb  5 16:26:32  [<c014c524>] add_lock_to_list+0x44/0xb0
> Feb  5 16:26:32  [<c03dea29>] __udp_lib_get_port+0x19/0x200
> Feb  5 16:26:32  [<c014f735>] __lock_acquire+0x1045/0x10a0
> Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
> Feb  5 16:26:32  [<c03db0a3>] ip4_datagram_connect+0x53/0x380
> Feb  5 16:26:32  [<c040418a>] _write_lock+0x2a/0x40
> Feb  5 16:26:32  [<c03db0a3>] ip4_datagram_connect+0x53/0x380
> Feb  5 16:26:32  [<c03db0a3>] ip4_datagram_connect+0x53/0x380
> Feb  5 16:26:32  [<c014e1c5>] trace_hardirqs_on+0xc5/0x170
> Feb  5 16:26:32  [<c0132317>] local_bh_enable_ip+0xa7/0x120
> Feb  5 16:26:32  [<c014e1c5>] trace_hardirqs_on+0xc5/0x170
> Feb  5 16:26:32  [<c040414f>] _spin_lock_bh+0x2f/0x40
> Feb  5 16:26:32  [<c03e4d55>] inet_dgram_connect+0x35/0x80
> Feb  5 16:26:32  [<c038ec52>] sys_connect+0x82/0xd0
> Feb  5 16:26:32  [<c01455df>] down_read_trylock+0x4f/0x60
> Feb  5 16:26:32  [<c011fe9c>] do_page_fault+0xfc/0x940
> Feb  5 16:26:32  [<c0404024>] _spin_unlock+0x14/0x20
> Feb  5 16:26:32  [<c03905f8>] sys_socketcall+0x98/0x280
> Feb  5 16:26:32  [<c014e1c5>] trace_hardirqs_on+0xc5/0x170
> Feb  5 16:26:32  [<c02a86ba>] copy_to_user+0x3a/0x70
> Feb  5 16:26:32  [<c0108417>] restore_nocheck+0x12/0x15
> Feb  5 16:26:32  [<c01083aa>] syscall_call+0x7/0xb
> Feb  5 16:26:32  [<ffffffff>] 0xffffffff
