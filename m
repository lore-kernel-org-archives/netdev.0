From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net v2] fix return of iptunnel_xmit
Date: Thu,  8 Oct 2015 12:11:54 +0200
Message-ID: <1444299114-21345-1-git-send-email-aschultz@tpip.net>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:45583 "EHLO mail.tpip.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752412AbbJHKMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 06:12:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All users of iptunnel_xmit expect the return value to be the error
code from ip_output_local, but currently the return value is length
of the send data on success or zero on error.
Change iptunnel_xmit returns to match the callers expectation.

This bug was introduced when the ip_tunnel_core code was refactored.

Fixes: 0e6fbc5b6c6218987c93b8c7ca60cf786062899d
Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
Change in v2:
 - remove unused variable pkt_len

---
 net/ipv4/ip_tunnel_core.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 84dce6a..c167c4a 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -52,9 +52,7 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
 		  __u8 tos, __u8 ttl, __be16 df, bool xnet)
 {
-	int pkt_len = skb->len - skb_inner_network_offset(skb);
 	struct iphdr *iph;
-	int err;
 
 	skb_scrub_packet(skb, xnet);
 
@@ -79,10 +77,7 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	__ip_select_ident(dev_net(rt->dst.dev), iph,
 			  skb_shinfo(skb)->gso_segs ?: 1);
 
-	err = ip_local_out_sk(sk, skb);
-	if (unlikely(net_xmit_eval(err)))
-		pkt_len = 0;
-	return pkt_len;
+	return ip_local_out_sk(sk, skb);
 }
 EXPORT_SYMBOL_GPL(iptunnel_xmit);
 
-- 
2.1.4
