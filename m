From: Oussama Ghorbel <ghorbel@pivasoftware.com>
Subject: [PATCH] sit: generate icmpv6 error when receiving icmpv4 error
Date: Fri, 22 Nov 2013 16:23:20 +0100
Message-ID: <1385133800-1562-1-git-send-email-ghorbel@pivasoftware.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oussama Ghorbel <ou.ghorbel@gmail.com>,
	Oussama Ghorbel <ghorbel@pivasoftware.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Send icmpv6 error with type "destination unreachable" and code
"address unreachable" when receiving icmpv4 error and sufficient
data bytes are available
This patch enhances the compliance of sit tunnel with section 3.4 of
rfc 4213

Signed-off-by: Oussama Ghorbel <ghorbel@pivasoftware.com>
---
 net/ipv6/sit.c |   44 ++++++++++++++++++++++++++++++++++++++------
 1 file changed, 38 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 21b25dd..0146c86 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -478,14 +478,44 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 	dev_put(dev);
 }
 
+/* Generate icmpv6 with type/code ICMPV6_DEST_UNREACH/ICMPV6_ADDR_UNREACH
+ * if sufficient data bytes are available
+ */
+static int ipip6_err_gen_icmpv6_unreach(struct sk_buff *skb)
+{
+	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	struct rt6_info *rt;
+	struct sk_buff *skb2;
+
+	if (!pskb_may_pull(skb, iph->ihl * 4 + sizeof(struct ipv6hdr) + 8))
+		return 1;
+
+	skb2 = skb_clone(skb, GFP_ATOMIC);
+
+	if (!skb2)
+		return 1;
+
+	skb_dst_drop(skb2);
+	skb_pull(skb2, iph->ihl * 4);
+	skb_reset_network_header(skb2);
+
+	rt = rt6_lookup(dev_net(skb->dev), &ipv6_hdr(skb2)->saddr, NULL, 0, 0);
+
+	if (rt && rt->dst.dev)
+		skb2->dev = rt->dst.dev;
+
+	icmpv6_send(skb2, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0);
+
+	if (rt)
+		ip6_rt_put(rt);
+
+	kfree_skb(skb2);
+
+	return 0;
+}
 
 static int ipip6_err(struct sk_buff *skb, u32 info)
 {
-
-/* All the routers (except for Linux) return only
-   8 bytes of packet payload. It means, that precise relaying of
-   ICMP in the real Internet is absolutely infeasible.
- */
 	const struct iphdr *iph = (const struct iphdr *)skb->data;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
@@ -500,7 +530,6 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 	case ICMP_DEST_UNREACH:
 		switch (code) {
 		case ICMP_SR_FAILED:
-		case ICMP_PORT_UNREACH:
 			/* Impossible event. */
 			return 0;
 		default:
@@ -545,6 +574,9 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 		goto out;
 
 	err = 0;
+	if (!ipip6_err_gen_icmpv6_unreach(skb))
+		goto out;
+
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
 		goto out;
 
-- 
1.7.9.5
