From: arno@natisbad.org (Arnaud Ebalard)
Subject: [PATCH] XFRM,IPv6: initialize ip6_dst_blackhole_ops.kmem_cachep
Date: Tue, 23 Sep 2008 18:21:46 +0200
Message-ID: <87prmuvnmt.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux?=
	 =?utf-8?B?5piO?= <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:41179 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbYIWQXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 12:23:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

With the switch to a default value of 1 for xfrm_larval_drop in commit
28faa979746b2352cd78a376bf9f52db953bda46 (ipsec: Make xfrm_larval_drop
default to 1), what seems to be a bug manage to surface on one of my
test box running today's net-next (*).

When xfrm_tmpl_resolve() returns -EAGAIN in __xfrm_lookup(), the caller
is returned -EREMOTE and is expected to install a blackhole route. For
IPv6, the call to dst_alloc(&ip6_dst_blackhole_ops) performed by
ip6_dst_blackhole() produces the error provided below, because
kmem_cachep attribute seems to be uninitialized. This does not happen
when xfrm_larval_drop is set to 0.

The patch below againt today's net-next fixes the issue but I am unable
to tell if it is the best way (or even a decent way) to do it.

Note that I am able to reproduce the issue on current 2.6.27-rc7 by
forcing xfrm_larval_drop to 1. The patch below solves the problem,
i.e. this may be a candidate for 2.6.27-rc8 (if correct).

I may have missed something. Comments welcome.

Cheers,

a+

(*): with the small MIGRATE patch David commented some days ago applied
     on top of it. No interaction expected.



From: Arnaud Ebalard <arno@natisbad.org>
Date: Tue, 23 Sep 2008 16:59:04 +0200
Subject: [PATCH] XFRM,IPv6: initialize ip6_dst_blackhole_ops.kmem_cachep

ip6_dst_blackhole_ops.kmem_cachep is not expected to be NULL (i.e. to
be initialized) when dst_alloc() is called from ip6_dst_blackhole().
Otherwise, it results in the following (xfrm_larval_drop is now set to
1 by default): 

[   78.697642] Unable to handle kernel paging request for data at address 0x0000004c
[   78.703449] Faulting instruction address: 0xc0097f54
[   78.786896] Oops: Kernel access of bad area, sig: 11 [#1]
[   78.792791] PowerMac
[   78.798383] Modules linked in: btusb usbhid bluetooth b43 mac80211 cfg80211 ehci_hcd ohci_hcd sungem sungem_phy usbcore ssb
[   78.804263] NIP: c0097f54 LR: c0334a28 CTR: c002d430
[   78.809997] REGS: eef19ad0 TRAP: 0300   Not tainted  (2.6.27-rc5)
[   78.815743] MSR: 00001032 <ME,IR,DR>  CR: 22242482  XER: 20000000
[   78.821550] DAR: 0000004c, DSISR: 40000000
[   78.827278] TASK = eef0df40[3035] 'mip6d' THREAD: eef18000
[   78.827408] GPR00: 00001032 eef19b80 eef0df40 00000000 00008020 eef19c30 00000001 00000000 
[   78.833249] GPR08: eee5101c c05a5c10 ef9ad500 00000000 24242422 1005787c 00000000 1004f960 
[   78.839151] GPR16: 00000000 10024e90 10050040 48030018 0fe44150 00000000 00000000 eef19c30 
[   78.845046] GPR24: eef19e44 00000000 eef19bf8 efb37c14 eef19bf8 00008020 00009032 c0596064 
[   78.856671] NIP [c0097f54] kmem_cache_alloc+0x20/0x94
[   78.862581] LR [c0334a28] dst_alloc+0x40/0xc4
[   78.868451] Call Trace:
[   78.874252] [eef19b80] [c03c1810] ip6_dst_lookup_tail+0x1c8/0x1dc (unreliable)
[   78.880222] [eef19ba0] [c0334a28] dst_alloc+0x40/0xc4
[   78.886164] [eef19bb0] [c03cd698] ip6_dst_blackhole+0x28/0x1cc
[   78.892090] [eef19be0] [c03d9be8] rawv6_sendmsg+0x75c/0xc88
[   78.897999] [eef19cb0] [c038bca4] inet_sendmsg+0x4c/0x78
[   78.903907] [eef19cd0] [c03207c8] sock_sendmsg+0xac/0xe4
[   78.909734] [eef19db0] [c03209e4] sys_sendmsg+0x1e4/0x2a0
[   78.915540] [eef19f00] [c03220a8] sys_socketcall+0xfc/0x210
[   78.921406] [eef19f40] [c0014b3c] ret_from_syscall+0x0/0x38
[   78.927295] --- Exception: c01 at 0xfe2d730
[   78.927297]     LR = 0xfe2d71c
[   78.939019] Instruction dump:
[   78.944835] 91640018 9144001c 900a0000 4bffff44 9421ffe0 7c0802a6 bf810010 7c9d2378 
[   78.950694] 90010024 7fc000a6 57c0045e 7c000124 <83e3004c> 8383005c 2f9f0000 419e0050 
[   78.956464] ---[ end trace 05fa1ed7972487a1 ]---

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 net/ipv6/route.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 776871e..f4385a6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2708,6 +2708,8 @@ int __init ip6_route_init(void)
 	if (ret)
 		goto out_kmem_cache;
 
+	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops_template.kmem_cachep;
+
 	/* Registering of the loopback is done before this portion of code,
 	 * the loopback reference in rt6_info will not be taken, do it
 	 * manually for init_net */
-- 
1.5.6.3






