From: Mikulas Patocka <mpatocka@redhat.com>
Subject: RCU error in networking (was: crash with bridge and inconsistent
 handling of NETDEV_TX_OK)
Date: Thu, 29 Apr 2010 18:14:11 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1004291811420.26080@hs20-bc2-1.build.redhat.com>
References: <20100420.181648.183008607.davem@davemloft.net>
 <Pine.LNX.4.64.1004202120180.29631@hs20-bc2-1.build.redhat.com>
 <20100420.182407.174368203.davem@davemloft.net> <20100420.190127.66303903.davem@davemloft.net>
 <Pine.LNX.4.64.1004210915220.11040@hs20-bc2-1.build.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30982 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932702Ab0D3RVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:21:54 -0400
In-Reply-To: <Pine.LNX.4.64.1004210915220.11040@hs20-bc2-1.build.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 21 Apr 2010, Mikulas Patocka wrote:

> 
> 
> On Tue, 20 Apr 2010, David Miller wrote:
> 
> > 
> > I looked more at your crash report.
> > 
> > You shouldn't even be in this code path for other reasons, namely
> > skb->next should be NULL.  But it's not in your case.  skb->next would
> > only be non-NULL for GSO frames, which we've established we should not
> > be seeing here.
> > 
> > Given that skb->next is non-NULL and the fraglists of this SKB are
> > corrupted (next pointer is 0x18), I think we're getting memory
> > corruption from somewhere else.  This also jives with the fact that
> > this is not readily reproducable.
> 
> The crash happened just a few days after I started to use the machine for 
> bridging. There were no unexplained crashes before. So I suspect that the 
> cause is bridging or tg3.
> 
> > The whole ->ndo_start_xmit() return value stuff is unrelated to this
> > issue, we shouldn't even be in this code path.  In fact, if reverting
> > that TX flags handling commit makes your crashes go away it would be a
> > huge surprise.
> 
> I thought that if some weird ->ndo_start_xmit() return values appeared, 
> this would lead to misunderstanding who owns the skb, using of already 
> deallocated skb and mentioned memory corruption. But I can't prove it.
> 
> Mikulas


BTW. when I enabled lockdep, I got this (2.6.34-rc5; the machine is no 
longer bridging, it has just a single interface):

Mikulas

===================================================
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
net/core/dev.c:1993 invoked rcu_dereference_check() without protection!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 0
2 locks held by ntpd/1462:
 #0:  (sk_lock-AF_INET){+.+.+.}, at: [<0000000000678d88>] 
udp_sendmsg+0x208/0x620
 #1:  (rcu_read_lock_bh){.+....}, at: [<00000000006305e0>] 
dev_queue_xmit+0x40/0x660

stack backtrace:
Call Trace:
 [000000000047bb88] lockdep_rcu_dereference+0x88/0xa0
 [0000000000630adc] dev_queue_xmit+0x53c/0x660
 [0000000000654e10] ip_finish_output+0x190/0x340
 [000000000065501c] ip_output+0x5c/0x80
 [0000000000655200] ip_local_out+0x20/0x40
 [0000000000655540] ip_push_pending_frames+0x320/0x3e0
 [0000000000676ec4] udp_push_pending_frames+0x164/0x440
 [0000000000678e60] udp_sendmsg+0x2e0/0x620
 [000000000068044c] inet_sendmsg+0x2c/0x60
 [000000000061cf24] sock_sendmsg+0x64/0xa0
 [000000000061d738] SyS_sendto+0x98/0xe0
 [000000000061b2b8] SyS_send+0x18/0x40
 [0000000000406054] linux_sparc_syscall32+0x34/0x40

