From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 4/5] gtp: remove unnecessary rcu_read_lock
Date: Tue, 24 Jan 2017 18:24:01 +0100
Message-ID: <20170124172402.12096-5-aschultz@tpip.net>
References: <20170124172402.12096-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:59538 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750764AbdAXRYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 12:24:09 -0500
In-Reply-To: <20170124172402.12096-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rcu read lock is hold by default in the ip input path. There
is no need to hold it twice in the socket recv decapsulate code path.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 24 ++++--------------------
 1 file changed, 4 insertions(+), 20 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 72dd1ba..912721e 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -183,7 +183,6 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 			      sizeof(struct gtp0_header);
 	struct gtp0_header *gtp0;
 	struct pdp_ctx *pctx;
-	int ret = 0;
 
 	if (!pskb_may_pull(skb, hdrlen))
 		return -1;
@@ -196,26 +195,19 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 	if (gtp0->type != GTP_TPDU)
 		return 1;
 
-	rcu_read_lock();
 	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
 	if (!pctx) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
-		ret = -1;
-		goto out_rcu;
+		return -1;
 	}
 
 	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
 		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
-		ret = -1;
-		goto out_rcu;
+		return -1;
 	}
-	rcu_read_unlock();
 
 	/* Get rid of the GTP + UDP headers. */
 	return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
-out_rcu:
-	rcu_read_unlock();
-	return ret;
 }
 
 static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
@@ -225,7 +217,6 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 			      sizeof(struct gtp1_header);
 	struct gtp1_header *gtp1;
 	struct pdp_ctx *pctx;
-	int ret = 0;
 
 	if (!pskb_may_pull(skb, hdrlen))
 		return -1;
@@ -253,26 +244,19 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 
 	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
 
-	rcu_read_lock();
 	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
 	if (!pctx) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
-		ret = -1;
-		goto out_rcu;
+		return -1;
 	}
 
 	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
 		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
-		ret = -1;
-		goto out_rcu;
+		return -1;
 	}
-	rcu_read_unlock();
 
 	/* Get rid of the GTP + UDP headers. */
 	return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
-out_rcu:
-	rcu_read_unlock();
-	return ret;
 }
 
 static void gtp_encap_disable(struct gtp_dev *gtp)
-- 
2.10.2
