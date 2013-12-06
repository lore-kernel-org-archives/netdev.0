From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 3/5] {pktgen,xfrm} Construct skb dst for tunnel mode transformation
Date: Fri, 6 Dec 2013 17:53:32 +0800
Message-ID: <1386323614-5077-4-git-send-email-fan.du@windriver.com>
References: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50713 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757230Ab3LFJxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:53:42 -0500
In-Reply-To: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPsec tunnel mode encapuslation needs to set outter ip header
with right protocol/ttl/id value with regard to skb->dst->child.

Looking up a rt in a standard way is absolutely wrong for every
packet transmission. In a simple way, construct a dst by setting
neccessary information to make tunnel mode encapuslation working.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
v2:
 -Point dst->child into dst itself to save space.
---
 net/core/pktgen.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 717e0b7..2f4f90c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -388,6 +388,8 @@ struct pktgen_dev {
 
 #ifdef CONFIG_XFRM
 	__u32 spi;
+	struct dst_entry dst;
+	struct dst_ops dstops;
 #endif
 	char result[512];
 };
@@ -2484,6 +2486,11 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 
 
 #ifdef CONFIG_XFRM
+u32 pktgen_dst_metrics[RTAX_MAX + 1] = {
+
+	[RTAX_HOPLIMIT] = 0x5, /* Set a static hoplimit */
+};
+
 static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 {
 	struct xfrm_state *x = pkt_dev->flows[pkt_dev->curfl].x;
@@ -2492,6 +2499,9 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 	if (!x)
 		return 0;
 
+	if (x->props.mode == XFRM_MODE_TUNNEL)
+		__skb_dst_set_noref(skb, &pkt_dev->dst, true);
+
 	spin_lock(&x->lock);
 
 	err = x->outer_mode->output(x, skb);
@@ -3545,6 +3555,16 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 		goto out2;
 	}
 #ifdef CONFIG_XFRM
+	/* xfrm tunnel mode needs additional dst to extract outter
+	 * ip header protocol/ttl/id field, here creat a phony one.
+	 * instead of looking for a valid rt, which definitely hurting
+	 * performance under such circumstance.
+	 */
+	pkt_dev->dstops.family = AF_INET;
+	pkt_dev->dst.dev = pkt_dev->odev;
+	dst_init_metrics(&pkt_dev->dst, pktgen_dst_metrics, false);
+	pkt_dev->dst.child = &pkt_dev->dst;
+	pkt_dev->dst.ops = &pkt_dev->dstops;
 #endif
 
 	return add_dev_to_thread(t, pkt_dev);
-- 
1.7.9.5
