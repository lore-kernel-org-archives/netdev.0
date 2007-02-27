From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: Handle disabled preemption in gfp_any()
Date: Tue, 27 Feb 2007 18:48:19 +0100
Message-ID: <45E46EE3.9040802@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050100020503080108040907"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36582 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbXB0RsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 12:48:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050100020503080108040907
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------050100020503080108040907
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: Handle disabled preemption in gfp_any()

ctnetlink uses netlink_unicast from an atomic_notifier_chain
(which is called within a RCU read side critical section)
without holding further locks. netlink_unicast calls netlink_trim
with the result of gfp_any() for the gfp flags, which are passed
down to pskb_expand_header. gfp_any() only checks for softirq
context and returns GFP_KERNEL, resulting in this warning:

BUG: sleeping function called from invalid context at mm/slab.c:3032
in_atomic():1, irqs_disabled():0
no locks held by rmmod/7010.

Call Trace:
 [<ffffffff8109467f>] debug_show_held_locks+0x9/0xb
 [<ffffffff8100b0b4>] __might_sleep+0xd9/0xdb
 [<ffffffff810b5082>] __kmalloc+0x68/0x110
 [<ffffffff811ba8f2>] pskb_expand_head+0x4d/0x13b
 [<ffffffff81053147>] netlink_broadcast+0xa5/0x2e0
 [<ffffffff881cd1d7>] :nfnetlink:nfnetlink_send+0x83/0x8a
 [<ffffffff8834f6a6>] :nf_conntrack_netlink:ctnetlink_conntrack_event+0x94c/0x96a
 [<ffffffff810624d6>] notifier_call_chain+0x29/0x3e
 [<ffffffff8106251d>] atomic_notifier_call_chain+0x32/0x60
 [<ffffffff881d266d>] :nf_conntrack:destroy_conntrack+0xa5/0x1d3
 [<ffffffff881d194e>] :nf_conntrack:nf_ct_cleanup+0x8c/0x12c
 [<ffffffff881d4614>] :nf_conntrack:kill_l3proto+0x0/0x13
 [<ffffffff881d482a>] :nf_conntrack:nf_conntrack_l3proto_unregister+0x90/0x94
 [<ffffffff883551b3>] :nf_conntrack_ipv4:nf_conntrack_l3proto_ipv4_fini+0x2b/0x5d
 [<ffffffff8109d44f>] sys_delete_module+0x1b5/0x1e6
 [<ffffffff8105f245>] trace_hardirqs_on_thunk+0x35/0x37
 [<ffffffff8105911e>] system_call+0x7e/0x83

Since netlink_unicast is supposed to be callable from within RCU
read side critical sections, make gfp_any() check for in_atomic()
instead of in_softirq().

Additionally nfnetlink_send needs to use gfp_any() as well for the
call to netlink_broadcast).

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8ab095fd967d4a0443d869b69325cf97ebad5397
tree 2952a1f3afecb0d8b2f745cdbd42aadbaafe3948
parent 511b0c36b2df2df67ec0a95564999964bc81c494
author Patrick McHardy <kaber@trash.net> Tue, 27 Feb 2007 18:47:29 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 27 Feb 2007 18:47:29 +0100

 include/net/sock.h        |    2 +-
 net/netfilter/nfnetlink.c |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 03684e7..2c7d60c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1278,7 +1278,7 @@ static inline int sock_writeable(const s
 
 static inline gfp_t gfp_any(void)
 {
-	return in_softirq() ? GFP_ATOMIC : GFP_KERNEL;
+	return in_atomic() ? GFP_ATOMIC : GFP_KERNEL;
 }
 
 static inline long sock_rcvtimeo(const struct sock *sk, int noblock)
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 1febe2e..22d8e1a 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -181,13 +181,12 @@ EXPORT_SYMBOL_GPL(nfnetlink_has_listener
 
 int nfnetlink_send(struct sk_buff *skb, u32 pid, unsigned group, int echo)
 {
-	gfp_t allocation = in_interrupt() ? GFP_ATOMIC : GFP_KERNEL;
 	int err = 0;
 
 	NETLINK_CB(skb).dst_group = group;
 	if (echo)
 		atomic_inc(&skb->users);
-	netlink_broadcast(nfnl, skb, pid, group, allocation);
+	netlink_broadcast(nfnl, skb, pid, group, gfp_any());
 	if (echo)
 		err = netlink_unicast(nfnl, skb, pid, MSG_DONTWAIT);
 

--------------050100020503080108040907--
