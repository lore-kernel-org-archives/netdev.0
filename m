From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 04/17] gtp: return error ptr in find pdp helpers
Date: Mon, 23 Jan 2017 12:56:53 +0100
Message-ID: <20170123115706.4354-5-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:34056 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750723AbdAWMGx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:53 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 60946b7..e95c856 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -114,7 +114,7 @@ static struct pdp_ctx *gtp0_pdp_find(struct gtp_dev *gtp, u64 tid)
 		    pdp->u.v0.tid == tid)
 			return pdp;
 	}
-	return NULL;
+	return ERR_PTR(-ENOENT);
 }
 
 /* Resolve a PDP context structure based on the 32bit TEI. */
@@ -130,7 +130,7 @@ static struct pdp_ctx *gtp1_pdp_find(struct gtp_dev *gtp, u32 tid)
 		    pdp->u.v1.i_tei == tid)
 			return pdp;
 	}
-	return NULL;
+	return ERR_PTR(-ENOENT);
 }
 
 /* Resolve a PDP context based on IPv4 address of MS. */
@@ -147,7 +147,7 @@ static struct pdp_ctx *ipv4_pdp_find(struct gtp_dev *gtp, __be32 ms_addr)
 			return pdp;
 	}
 
-	return NULL;
+	return ERR_PTR(-ENOENT);
 }
 
 static bool gtp_check_src_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
@@ -199,7 +199,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 
 	rcu_read_lock();
 	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
-	if (!pctx) {
+	if (IS_ERR(pctx)) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
 		ret = -1;
 		goto out_rcu;
@@ -256,7 +256,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 
 	rcu_read_lock();
 	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
-	if (!pctx) {
+	if (IS_ERR(pctx)) {
 		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
 		ret = -1;
 		goto out_rcu;
@@ -476,10 +476,10 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	 */
 	iph = ip_hdr(skb);
 	pctx = ipv4_pdp_find(gtp, iph->daddr);
-	if (!pctx) {
+	if (IS_ERR(pctx)) {
 		netdev_dbg(dev, "no PDP ctx found for %pI4, skip\n",
 			   &iph->daddr);
-		return -ENOENT;
+		return PTR_ERR(pctx);
 	}
 	netdev_dbg(dev, "found PDP context %p\n", pctx);
 
@@ -1085,8 +1085,8 @@ static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 	}
 
-	if (pctx == NULL)
-		return -ENOENT;
+	if (IS_ERR(pctx))
+		return PTR_ERR(pctx);
 
 	if (pctx->gtp_version == GTP_V0)
 		netdev_dbg(dev, "GTPv0-U: deleting tunnel id = %llx (pdp %p)\n",
@@ -1194,8 +1194,8 @@ static int gtp_genl_get_pdp(struct sk_buff *skb, struct genl_info *info)
 		pctx = ipv4_pdp_find(gtp, ip);
 	}
 
-	if (pctx == NULL) {
-		err = -ENOENT;
+	if (IS_ERR(pctx)) {
+		err = PTR_ERR(pctx);
 		goto err_unlock;
 	}
 
-- 
2.10.2
