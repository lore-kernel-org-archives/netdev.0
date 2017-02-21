From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH 6/9] dpaa_eth: enable Rx checksum offload
Date: Tue, 21 Feb 2017 13:52:51 +0200
Message-ID: <1487677974-13678-7-git-send-email-madalin.bucur@nxp.com>
References: <1487677974-13678-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
        <camelia.groza@nxp.com>, <linuxppc-dev@lists.ozlabs.org>,
        Madalin Bucur <madalin.bucur@nxp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0067.outbound.protection.outlook.com ([104.47.38.67]:32735
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752252AbdBULxy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 06:53:54 -0500
In-Reply-To: <1487677974-13678-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the FMan HW parser L4CV flag to offload Rx checksumming.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 29 ++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index e19181f..a7a595c 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -137,6 +137,13 @@ MODULE_PARM_DESC(tx_timeout, "The Tx timeout in ms");
 /* L4 Type field: TCP */
 #define FM_L4_PARSE_RESULT_TCP	0x20
 
+/* FD status field indicating whether the FM Parser has attempted to validate
+ * the L4 csum of the frame.
+ * Note that having this bit set doesn't necessarily imply that the checksum
+ * is valid. One would have to check the parse results to find that out.
+ */
+#define FM_FD_STAT_L4CV         0x00000004
+
 #define DPAA_SGT_MAX_ENTRIES 16 /* maximum number of entries in SG Table */
 #define DPAA_BUFF_RELEASE_MAX 8 /* maximum number of buffers released at once */
 
@@ -235,6 +242,7 @@ static int dpaa_netdev_init(struct net_device *net_dev,
 	 * For conformity, we'll still declare GSO explicitly.
 	 */
 	net_dev->features |= NETIF_F_GSO;
+	net_dev->features |= NETIF_F_RXCSUM;
 
 	net_dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 	/* we do not want shared skbs on TX */
@@ -1526,6 +1534,23 @@ static struct sk_buff *dpaa_cleanup_tx_fd(const struct dpaa_priv *priv,
 	return skb;
 }
 
+static u8 rx_csum_offload(const struct dpaa_priv *priv, const struct qm_fd *fd)
+{
+	/* The parser has run and performed L4 checksum validation.
+	 * We know there were no parser errors (and implicitly no
+	 * L4 csum error), otherwise we wouldn't be here.
+	 */
+	if ((priv->net_dev->features & NETIF_F_RXCSUM) &&
+	    (be32_to_cpu(fd->status) & FM_FD_STAT_L4CV))
+		return CHECKSUM_UNNECESSARY;
+
+	/* We're here because either the parser didn't run or the L4 checksum
+	 * was not verified. This may include the case of a UDP frame with
+	 * checksum zero or an L4 proto other than TCP/UDP
+	 */
+	return CHECKSUM_NONE;
+}
+
 /* Build a linear skb around the received buffer.
  * We are guaranteed there is enough room at the end of the data buffer to
  * accommodate the shared info area of the skb.
@@ -1556,7 +1581,7 @@ static struct sk_buff *contig_fd_to_skb(const struct dpaa_priv *priv,
 	skb_reserve(skb, fd_off);
 	skb_put(skb, qm_fd_get_length(fd));
 
-	skb->ip_summed = CHECKSUM_NONE;
+	skb->ip_summed = rx_csum_offload(priv, fd);
 
 	return skb;
 
@@ -1616,7 +1641,7 @@ static struct sk_buff *sg_fd_to_skb(const struct dpaa_priv *priv,
 			if (WARN_ON(unlikely(!skb)))
 				goto free_buffers;
 
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = rx_csum_offload(priv, fd);
 
 			/* Make sure forwarded skbs will have enough space
 			 * on Tx, if extra headers are added.
-- 
2.1.0
