From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv4 net-next 5/8] {pktgen, xfrm} Construct skb dst for tunnel mode transformation
Date: Fri, 3 Jan 2014 11:18:31 +0800
Message-ID: <1388719114-26244-6-git-send-email-fan.du@windriver.com>
References: <1388719114-26244-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35182 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679AbaACDSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 22:18:47 -0500
In-Reply-To: <1388719114-26244-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPsec tunnel mode encapuslation needs to set outter ip header
with right protocol/ttl/id value with regard to skb->dst->child.

Looking up a rt in a standard way is absolutely wrong for every
packet transmission. In a simple way, construct a dst by setting
neccessary information to make tunnel mode encapuslation working.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/core/pktgen.c |   28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8bc4ddd..628f7c5 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -390,6 +390,8 @@ struct pktgen_dev {
 	__u8	ipsmode;		/* IPSEC mode (config) */
 	__u8	ipsproto;		/* IPSEC type (config) */
 	__u32	spi;
+	struct dst_entry dst;
+	struct dst_ops dstops;
 #endif
 	char result[512];
 };
@@ -2487,6 +2489,11 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 
 
 #ifdef CONFIG_XFRM
+u32 pktgen_dst_metrics[RTAX_MAX + 1] = {
+
+	[RTAX_HOPLIMIT] = 0x5, /* Set a static hoplimit */
+};
+
 static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 {
 	struct xfrm_state *x = pkt_dev->flows[pkt_dev->curfl].x;
@@ -2497,10 +2504,18 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 		return 0;
 	/* XXX: we dont support tunnel mode for now until
 	 * we resolve the dst issue */
-	if (x->props.mode != XFRM_MODE_TRANSPORT)
+	if ((x->props.mode != XFRM_MODE_TRANSPORT) && (pkt_dev->spi == 0))
 		return 0;
 
+	/* But when user specify an valid SPI, transformation
+	 * supports both transport/tunnel mode + ESP/AH type.
+	 */
+	if ((x->props.mode == XFRM_MODE_TUNNEL) && (pkt_dev->spi != 0))
+		skb->_skb_refdst = (unsigned long)&pkt_dev->dst | SKB_DST_NOREF;
+
+	rcu_read_lock_bh();
 	err = x->outer_mode->output(x, skb);
+	rcu_read_unlock_bh();
 	if (err) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEMODEERROR);
 		goto error;
@@ -3557,6 +3572,17 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 #ifdef CONFIG_XFRM
 	pkt_dev->ipsmode = XFRM_MODE_TRANSPORT;
 	pkt_dev->ipsproto = IPPROTO_ESP;
+
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
