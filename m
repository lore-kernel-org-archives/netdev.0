From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH linux-2.6.32.y] sctp: unbalanced rcu lock in ip_queue_xmit()
Date: Fri,  8 Nov 2013 11:13:55 +0100
Message-ID: <1383905635-20444-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: eric.dumazet@gmail.com, ben@decadent.org.uk, w@1wt.eu,
	stable@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:33713 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819Ab3KHKQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 05:16:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bug was introduced by commit b8710128e201 ("inet: add RCU protection to
inet->opt") (it's a backport of upstream commit f6d8bd051c39).

In SCTP case, packet is already routed, hence we jump to the label
'packet_routed', but without rcu_read_lock(). After this label,
rcu_read_unlock() is called unconditionally.

Spotted-by: Guo Fengtian <fengtian.guo@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ip_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7dde039374e4..2cd69e3497ad 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -320,13 +320,13 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 	/* Skip all of this if the packet is already routed,
 	 * f.e. by something like SCTP.
 	 */
+	rcu_read_lock();
 	rt = skb_rtable(skb);
 	if (rt != NULL)
 		goto packet_routed;
 
 	/* Make sure we can route this packet. */
 	rt = (struct rtable *)__sk_dst_check(sk, 0);
-	rcu_read_lock();
 	inet_opt = rcu_dereference(inet->inet_opt);
 	if (rt == NULL) {
 		__be32 daddr;
-- 
1.8.4.1
