From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v2 1/2] gtp: remove unnecessary rcu_read_lock
Date: Thu, 26 Jan 2017 16:21:48 +0100
Message-ID: <20170126152149.3284-2-aschultz@tpip.net>
References: <20170126152149.3284-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>,
        SF Markus Elfring <elfring@users.sourceforge.net>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:34498 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753134AbdAZPV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 10:21:56 -0500
In-Reply-To: <20170126152149.3284-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rcu read lock is hold by default in the ip input path. There
is no need to hold it twice in the socket recv decapsulate code path.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 24 ++++--------------------
 1 file changed, 4 insertions(+), 20 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 8b6810b..5c63a37 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -184,7 +184,6 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 			      sizeof(struct gtp0_header);
 	struct gtp0_header *gtp0;
 	struct pdp_ctx *pctx;
-	int ret = 0;
 
 	if (!pskb_may_pull(skb, hdrlen))
 		return -1;
@@ -197,26 +196,19 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
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
@@ -226,7 +218,6 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 			      sizeof(struct gtp1_header);
 	struct gtp1_header *gtp1;
 	struct pdp_ctx *pctx;
-	int ret = 0;
 
 	if (!pskb_may_pull(skb, hdrlen))
 		return -1;
@@ -254,26 +245,19 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 
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
