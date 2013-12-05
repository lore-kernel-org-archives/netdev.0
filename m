From: Fan Du <fan.du@windriver.com>
Subject: [PATCH RFC 3/5] {pktgen,xfrm} Construct skb dst for tunnel mode transformation
Date: Thu, 5 Dec 2013 15:57:17 +0800
Message-ID: <1386230239-31860-4-git-send-email-fan.du@windriver.com>
References: <1386230239-31860-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62074 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690Ab3LEH52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 02:57:28 -0500
In-Reply-To: <1386230239-31860-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPsec tunnel mode encapuslation needs to set outter ip header
with right protocol/ttl/id value with regard to skb->dst->child.

Looking up a rt in a standard way is absolutely wrong for every
packet transmission. In a simple way, construct a dst by setting
neccessary information to make tunnel mode encapuslation working.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/core/pktgen.c |   21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 3e0a00f..c30df28 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -388,7 +388,8 @@ struct pktgen_dev {
 
 #ifdef CONFIG_XFRM
 	__u32 spi;
-
+	struct dst_entry dst, child;
+	struct dst_ops dstops;
 #endif
 	char result[512];
 };
@@ -2485,6 +2486,11 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 
 
 #ifdef CONFIG_XFRM
+u32 pktgen_dst_metrics[RTAX_MAX + 1] = {
+
+	[RTAX_HOPLIMIT] = 0x5, /* Set a static hoplimit */
+};
+
 static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 {
 	struct xfrm_state *x = pkt_dev->flows[pkt_dev->curfl].x;
@@ -2493,6 +2499,8 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 	if (!x)
 		return 0;
 
+	if (x->props.mode == XFRM_MODE_TUNNEL)
+		__skb_dst_set_noref(skb, &pkt_dev->dst, true);
 
 	spin_lock(&x->lock);
 
@@ -3547,7 +3555,16 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 		goto out2;
 	}
 #ifdef CONFIG_XFRM
-
+	/* xfrm tunnel mode needs additional dst to extract
+	 * outter ip header ttl/id field, here creat a phony one.
+	 * instead of looking for a valid rt, which definitely hurting
+	 * performance under such circumstance.
+	 */
+	pkt_dev->dstops.family = AF_INET;
+	pkt_dev->child.dev = pkt_dev->odev;
+	dst_init_metrics(&pkt_dev->child, pktgen_dst_metrics, false);
+	pkt_dev->dst.child = &pkt_dev->child;
+	pkt_dev->dst.ops = &pkt_dev->dstops;
 #endif
 
 	return add_dev_to_thread(t, pkt_dev);
-- 
1.7.9.5
