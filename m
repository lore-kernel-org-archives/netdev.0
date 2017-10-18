From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v5 net-next 06/12] gtp: Use goto for exceptions in gtp_udp_encap_recv funcs
Date: Wed, 18 Oct 2017 13:10:12 -0700
Message-ID: <20171018201018.5692-7-tom@quantonium.net>
References: <20171018201018.5692-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:53453 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdJRULL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 16:11:11 -0400
Received: by mail-pf0-f193.google.com with SMTP id t188so4753137pfd.10
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 13:11:11 -0700 (PDT)
In-Reply-To: <20171018201018.5692-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate return logic to make it easier to extend.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index f2aac5d01143..00e5ea5cb935 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -234,23 +234,27 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 	struct pdp_ctx *pctx;
 
 	if (!pskb_may_pull(skb, hdrlen))
-		return -1;
+		goto drop;
 
 	gtp0 = (struct gtp0_header *)(skb->data + sizeof(struct udphdr));
 
 	if ((gtp0->flags >> 5) != GTP_V0)
-		return 1;
+		goto pass;
 
 	if (gtp0->type != GTP_TPDU)
-		return 1;
+		goto pass;
 
 	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
 	if (!pctx) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
-		return 1;
+		goto pass;
 	}
 
 	return gtp_rx(pctx, skb, hdrlen, gtp->role);
+drop:
+	return -1;
+pass:
+	return 1;
 }
 
 static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
@@ -261,15 +265,15 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 	struct pdp_ctx *pctx;
 
 	if (!pskb_may_pull(skb, hdrlen))
-		return -1;
+		goto drop;
 
 	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
 
 	if ((gtp1->flags >> 5) != GTP_V1)
-		return 1;
+		goto pass;
 
 	if (gtp1->type != GTP_TPDU)
-		return 1;
+		goto pass;
 
 	/* From 29.060: "This field shall be present if and only if any one or
 	 * more of the S, PN and E flags are set.".
@@ -282,17 +286,21 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 
 	/* Make sure the header is larger enough, including extensions. */
 	if (!pskb_may_pull(skb, hdrlen))
-		return -1;
+		goto drop;
 
 	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
 
 	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
 	if (!pctx) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
-		return 1;
+		goto drop;
 	}
 
 	return gtp_rx(pctx, skb, hdrlen, gtp->role);
+drop:
+	return -1;
+pass:
+	return 1;
 }
 
 static void gtp_encap_destroy(struct sock *sk)
-- 
2.11.0
