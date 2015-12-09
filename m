From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 16/18] stmmac: do not perform zero-copy for rx frames
Date: Wed, 9 Dec 2015 09:37:52 +0100
Message-ID: <1449650274-14896-17-git-send-email-peppe.cavallaro@st.com>
References: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:41844 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753373AbbLII2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 03:28:44 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id tB98DiVq006894
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2015 09:28:43 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1yjw8vkqdb-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 09:28:43 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4FD9534
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:28:06 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A2BF44F64
	for <netdev@vger.kernel.org>; Wed,  9 Dec 2015 08:28:41 +0000 (GMT)
In-Reply-To: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to allow this driver to copy tiny frames during the reception
process. This is giving more stability while stressing the driver on STi
embedded systems.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   67 ++++++++++++++++-----
 1 files changed, 52 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6b83213..d68775a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -98,6 +98,10 @@ static int buf_sz = DEFAULT_BUFSIZE;
 module_param(buf_sz, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(buf_sz, "DMA buffer size");
 
+static int minrx = 256;
+module_param(minrx, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(minrx, "Copy only tiny-frames");
+
 static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
 				      NETIF_MSG_LINK | NETIF_MSG_IFUP |
 				      NETIF_MSG_IFDOWN | NETIF_MSG_TIMER);
@@ -147,6 +151,8 @@ static void stmmac_verify_args(void)
 		pause = PAUSE_TIME;
 	if (eee_timer < 0)
 		eee_timer = STMMAC_DEFAULT_LPI_TIMER;
+	if (minrx < 0)
+		minrx = ETH_FRAME_LEN;
 }
 
 /**
@@ -2198,8 +2204,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 			struct sk_buff *skb;
 
 			skb = netdev_alloc_skb_ip_align(priv->dev, bfsize);
-
-			if (unlikely(skb == NULL))
+			if (unlikely(!skb))
 				break;
 
 			priv->rx_skbuff[entry] = skb;
@@ -2322,23 +2327,52 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 					pr_debug("\tframe size %d, COE: %d\n",
 						 frame_len, status);
 			}
-			skb = priv->rx_skbuff[entry];
-			if (unlikely(!skb)) {
-				pr_err("%s: Inconsistent Rx descriptor chain\n",
-				       priv->dev->name);
-				priv->dev->stats.rx_dropped++;
-				break;
+
+			if (unlikely(frame_len < minrx)) {
+				skb = netdev_alloc_skb_ip_align(priv->dev,
+								frame_len);
+				if (unlikely(!skb)) {
+					if (net_ratelimit())
+						dev_warn(priv->device,
+							 "packet dropped\n");
+					priv->dev->stats.rx_dropped++;
+					break;
+				}
+
+				dma_sync_single_for_cpu(priv->device,
+							priv->rx_skbuff_dma
+							[entry], frame_len,
+							DMA_FROM_DEVICE);
+				skb_copy_to_linear_data(skb,
+							priv->
+							rx_skbuff[entry]->data,
+							frame_len);
+
+				skb_put(skb, frame_len);
+				dma_sync_single_for_device(priv->device,
+							   priv->rx_skbuff_dma
+							   [entry], frame_len,
+							   DMA_FROM_DEVICE);
+			} else {
+				skb = priv->rx_skbuff[entry];
+				if (unlikely(!skb)) {
+					pr_err("%s: Inconsistent Rx chain\n",
+					       priv->dev->name);
+					priv->dev->stats.rx_dropped++;
+					break;
+				}
+				prefetch(skb->data - NET_IP_ALIGN);
+				priv->rx_skbuff[entry] = NULL;
+
+				skb_put(skb, frame_len);
+				dma_unmap_single(priv->device,
+						 priv->rx_skbuff_dma[entry],
+						 priv->dma_buf_sz,
+						 DMA_FROM_DEVICE);
 			}
-			prefetch(skb->data - NET_IP_ALIGN);
-			priv->rx_skbuff[entry] = NULL;
 
 			stmmac_get_rx_hwtstamp(priv, entry, skb);
 
-			skb_put(skb, frame_len);
-			dma_unmap_single(priv->device,
-					 priv->rx_skbuff_dma[entry],
-					 priv->dma_buf_sz, DMA_FROM_DEVICE);
-
 			if (netif_msg_pktdata(priv)) {
 				pr_debug("frame received (%dbytes)", frame_len);
 				print_pkt(skb->data, frame_len);
@@ -3235,6 +3269,9 @@ static int __init stmmac_cmdline_opt(char *str)
 		} else if (!strncmp(opt, "chain_mode:", 11)) {
 			if (kstrtoint(opt + 11, 0, &chain_mode))
 				goto err;
+		} else if (!strncmp(opt, "minrx:", 6)) {
+			if (kstrtoint(opt + 6, 0, &minrx))
+				goto err;
 		}
 	}
 	return 0;
-- 
1.7.4.4
