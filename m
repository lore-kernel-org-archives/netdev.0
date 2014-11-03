From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6: do xfrm transform after nat if necessary
Date: Mon, 3 Nov 2014 12:53:03 +0800
Message-ID: <54570A2F.2070206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:33121 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750834AbaKCEzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 23:55:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



In function nf_nat_ipv6_out, after nat is done, nf_xfrm_me_harder()
will be called to look up xfrm dst.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/ip6_output.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 8e950c2..742a845 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -124,6 +124,14 @@ static int ip6_finish_output2(struct sk_buff *skb)
 
 static int ip6_finish_output(struct sk_buff *skb)
 {
+#if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
+	/* Just like ipv4, policy lookup after nat yielded a new policy */
+	if (skb_dst(skb)->xfrm != NULL) {
+		IP6CB(skb)->flags |= IP6SKB_REROUTED;
+		return dst_output(skb);
+	}
+#endif
+
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
 	    dst_allfrag(skb_dst(skb)) ||
 	    (IP6CB(skb)->frag_max_size && skb->len > IP6CB(skb)->frag_max_size))
-- 
1.8.3.1
