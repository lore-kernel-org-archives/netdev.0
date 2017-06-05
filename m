From: "Mario Molitor" <Mario_Molitor@web.de>
Subject: Stmmac: fix for hw timestamp of GMAC 3 unit
Date: Tue, 6 Jun 2017 00:11:39 +0200
Message-ID: <trinity-32054cc5-4d62-4e1d-a846-3c34dcf24545-1496700699842@3capp-webde-bap31>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary=rehcsed-ce166cb0-846c-4232-8d15-5ab54a7fc0cb
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--rehcsed-ce166cb0-846c-4232-8d15-5ab54a7fc0cb
Content-Type: text/plain; charset=UTF-8

Dear stmmac maintainer group,

I have found an problem in stmmac driver of linux kernel and I hope for a fix in the mainline kernel.
At the moment I have two patch files which fix this problem for me.
The problem seems created with the commit d2042052a0aa6a54f01a0c9e14243ec040b100e2 and ba1ffd74df74a9efa5290f87632a0ed55f1aa387 has breakage the functionality of GMAC3 unit.
I assume that these commits were only tested with a GMAC4 unit.
I have got seen this problem with execution of ptp4l daemon on system with linux 4.11 Kernel. 

===============================================================================
root@QuantumXsoc:~ ptp4l -f /etc/ptp.cfg -i eth0 -m
ptp4l[47.928]: selected /dev/ptp0 as PTP clock
ptp4l[47.937]: port 1: INITIALIZING to LISTENING on INITIALIZE
ptp4l[47.938]: port 0: INITIALIZING to LISTENING on INITIALIZE
ptp4l[47.938]: port 1: link up
[   48.282709] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
[   48.316316] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
[   48.340260] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
[   48.456738] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
ptp4l[48.457]: port 1: received DELAY_REQ without timestamp
[   48.488442] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
[   48.495599] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
ptp4l[48.489]: port 1: received SYNC without timestamp
....
================================================================================

I have found two kind of problems and for this two patches (based on the 4.11 kernel) which fix this problem.

1.) PTP_TCR_SNAPTYPSEL_1

The first problem was for my point of view the change of definition PTP_TCR_SNAPTYPSEL_1.  I think according the
CYCLON V documention only the bit 16 of snaptypesel should be set. (more information see Table 17-20 (cv_5v4.pdf) : Timestamp Snapshot Dependency on Register Bits)
I believe that the GMAC4 have another necessary definition.

( patch 0001-stmmac-fix-ptp-header-for-GMAC3-hw-timestamp.patch )
================================================================================================
>From 2d54d58dc8548d98572eb5fbfe488ec59b4c0ef5 Mon Sep 17 00:00:00 2001
From: Mario Molitor <mario_molitor@web.de>
Date: Mon, 5 Jun 2017 18:58:49 +0200
Subject: [PATCH 1/2] stmmac: fix ptp header for GMAC3 hw timestamp

According the CYCLON V documention only the bit 16 of snaptypesel should set.
(more information see Table 17-20 (cv_5v4.pdf) : Timestamp Snapshot Dependency on Register Bits)

fixed: d2042052a0aa6a54f01a0c9e14243ec040b100e2
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 15 ++++++++++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h  |  3 ++-
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4498a38..13a1ac9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -471,7 +471,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			/* PTP v1, UDP, any kind of event packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
 			/* take time stamp for all event messages */
-			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+			if (priv->plat->has_gmac4)
+				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
+			else
+				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
 
 			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
@@ -503,7 +506,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for all event messages */
-			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+			if (priv->plat->has_gmac4)
+				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
+			else
+				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
 
 			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
@@ -537,7 +543,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for all event messages */
-			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+			if (priv->plat->has_gmac4)
+				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
+			else
+				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
 
 			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
index 48fb72f..f4b31d6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
@@ -59,7 +59,8 @@
 /* Enable Snapshot for Messages Relevant to Master */
 #define	PTP_TCR_TSMSTRENA	BIT(15)
 /* Select PTP packets for Taking Snapshots */
-#define	PTP_TCR_SNAPTYPSEL_1	GENMASK(17, 16)
+#define	PTP_TCR_SNAPTYPSEL_1	BIT(16)
+#define	PTP_GMAC4_TCR_SNAPTYPSEL_1	GENMASK(17, 16)
 /* Enable MAC address for PTP Frame Filtering */
 #define	PTP_TCR_TSENMACADDR	BIT(18)
 
-- 
2.7.4
================================================================================================

2.) stmmac_get_rx_hwtstamp() and stmmac_get_tx_hwtstamp()

The second problem what i have got seen that the logic of timestamp available check was changed to a negative logic.
I have changed this in the function stmmac_get_rx_hwtstamp() and stmmac_get_tx_hwtstamp().
This changes fix the Problem with GMAC3, but to prevent a breakage of GMAC4 it is necessary to addapt the functions dwmac4_wrback_get_rx_timestamp_status() and dwmac4_wrback_get_tx_timestamp_status().
I have also change printout from info-level to the debug-level.

( patch 0002-stmmac-fix-for-hw-timestamp-of-GMAC3-unit.patch )
================================================================================================
>From ca39f10d78840192ffe801e42a813d8e4939c3e2 Mon Sep 17 00:00:00 2001
From: Mario Molitor <mario_molitor@web.de>
Date: Mon, 5 Jun 2017 19:10:23 +0200
Subject: [PATCH 2/2] stmmac: fix for hw timestamp of GMAC3 unit

1.) Bugfix of function stmmac_get_tx_hwtstamp.
    Corrected the tx timestamp available check (same as 4.8 and older)
    Change printout from info syslevel to debug.

2.) Bugfix of function stmmac_get_rx_hwtstamp.
    Corrected the rx timestamp available check (same as 4.8 and older)
    Change printout from info syslevel to debug.

    fixed: ba1ffd74df74a9efa5290f87632a0ed55f1aa387
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 11 +++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 10 +++++-----
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
index 843ec69..cd0c0ee 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
@@ -214,13 +214,13 @@ static int dwmac4_wrback_get_tx_timestamp_status(struct dma_desc *p)
 {
 	/* Context type from W/B descriptor must be zero */
 	if (le32_to_cpu(p->des3) & TDES3_CONTEXT_TYPE)
-		return -EINVAL;
+		return 0;
 
 	/* Tx Timestamp Status is 1 so des0 and des1'll have valid values */
 	if (le32_to_cpu(p->des3) & TDES3_TIMESTAMP_STATUS)
-		return 0;
+		return 1;
 
-	return 1;
+	return 0;
 }
 
 static inline u64 dwmac4_get_timestamp(void *desc, u32 ats)
@@ -282,7 +282,10 @@ static int dwmac4_wrback_get_rx_timestamp_status(void *desc, u32 ats)
 		}
 	}
 exit:
-	return ret;
+	if (likely(ret == 0))
+		return 1;
+	else 
+		return 0;
 }
 
 static void dwmac4_rd_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 13a1ac9..84561e0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -359,14 +359,14 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
 		return;
 
 	/* check tx tstamp status */
-	if (!priv->hw->desc->get_tx_timestamp_status(p)) {
+	if (priv->hw->desc->get_tx_timestamp_status(p)) {
 		/* get the valid tstamp */
 		ns = priv->hw->desc->get_timestamp(p, priv->adv_ts);
 
 		memset(&shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
 		shhwtstamp.hwtstamp = ns_to_ktime(ns);
 
-		netdev_info(priv->dev, "get valid TX hw timestamp %llu\n", ns);
+		netdev_dbg(priv->dev, "get valid TX hw timestamp %llu\n", ns);
 		/* pass tstamp to stack */
 		skb_tstamp_tx(skb, &shhwtstamp);
 	}
@@ -393,19 +393,19 @@ static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv, struct dma_desc *p,
 		return;
 
 	/* Check if timestamp is available */
-	if (!priv->hw->desc->get_rx_timestamp_status(p, priv->adv_ts)) {
+	if (priv->hw->desc->get_rx_timestamp_status(p, priv->adv_ts)) {
 		/* For GMAC4, the valid timestamp is from CTX next desc. */
 		if (priv->plat->has_gmac4)
 			ns = priv->hw->desc->get_timestamp(np, priv->adv_ts);
 		else
 			ns = priv->hw->desc->get_timestamp(p, priv->adv_ts);
 
-		netdev_info(priv->dev, "get valid RX hw timestamp %llu\n", ns);
+		netdev_dbg(priv->dev, "get valid RX hw timestamp %llu\n", ns);
 		shhwtstamp = skb_hwtstamps(skb);
 		memset(shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
 		shhwtstamp->hwtstamp = ns_to_ktime(ns);
 	} else  {
-		netdev_err(priv->dev, "cannot get RX hw timestamp\n");
+		netdev_dbg(priv->dev, "cannot get RX hw timestamp\n");
 	}
 }
 
-- 
2.7.4
================================================================================================

My problem is that I can't test this change with GMAC 4 unit, because I have only GMAC3 hardware.

I verified the operation only with Cyclone V SoC Development Kit. 
I look forward to receiving constructive comments and I hope I can help to fix this problem on the mainline kernel.
Best regards,
Mario Molitor
--rehcsed-ce166cb0-846c-4232-8d15-5ab54a7fc0cb
Content-Type: text/x-patch
Content-Disposition: attachment;
 filename=0001-stmmac-fix-ptp-header-for-GMAC3-hw-timestamp.patch

>From 2d54d58dc8548d98572eb5fbfe488ec59b4c0ef5 Mon Sep 17 00:00:00 2001
From: Mario Molitor <mario_molitor@web.de>
Date: Mon, 5 Jun 2017 18:58:49 +0200
Subject: [PATCH 1/2] stmmac: fix ptp header for GMAC3 hw timestamp

According the CYCLON V documention only the bit 16 of snaptypesel should set.
(more information see Table 17-20 (cv_5v4.pdf) : Timestamp Snapshot Dependency on Register Bits)

fixed: d2042052a0aa6a54f01a0c9e14243ec040b100e2
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 15 ++++++++++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h  |  3 ++-
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4498a38..13a1ac9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -471,7 +471,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			/* PTP v1, UDP, any kind of event packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
 			/* take time stamp for all event messages */
-			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+			if (priv->plat->has_gmac4)
+				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
+			else
+				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
 
 			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
@@ -503,7 +506,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for all event messages */
-			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+			if (priv->plat->has_gmac4)
+				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
+			else
+				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
 
 			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
@@ -537,7 +543,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for all event messages */
-			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+			if (priv->plat->has_gmac4)
+				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
+			else
+				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
 
 			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
index 48fb72f..f4b31d6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
@@ -59,7 +59,8 @@
 /* Enable Snapshot for Messages Relevant to Master */
 #define	PTP_TCR_TSMSTRENA	BIT(15)
 /* Select PTP packets for Taking Snapshots */
-#define	PTP_TCR_SNAPTYPSEL_1	GENMASK(17, 16)
+#define	PTP_TCR_SNAPTYPSEL_1	BIT(16)
+#define	PTP_GMAC4_TCR_SNAPTYPSEL_1	GENMASK(17, 16)
 /* Enable MAC address for PTP Frame Filtering */
 #define	PTP_TCR_TSENMACADDR	BIT(18)
 
-- 
2.7.4


--rehcsed-ce166cb0-846c-4232-8d15-5ab54a7fc0cb
Content-Type: text/x-patch
Content-Disposition: attachment;
 filename=0002-stmmac-fix-for-hw-timestamp-of-GMAC3-unit.patch

>From ca39f10d78840192ffe801e42a813d8e4939c3e2 Mon Sep 17 00:00:00 2001
From: Mario Molitor <mario_molitor@web.de>
Date: Mon, 5 Jun 2017 19:10:23 +0200
Subject: [PATCH 2/2] stmmac: fix for hw timestamp of GMAC3 unit

1.) Bugfix of function stmmac_get_tx_hwtstamp.
    Corrected the tx timestamp available check (same as 4.8 and older)
    Change printout from info syslevel to debug.

2.) Bugfix of function stmmac_get_rx_hwtstamp.
    Corrected the rx timestamp available check (same as 4.8 and older)
    Change printout from info syslevel to debug.

    fixed: ba1ffd74df74a9efa5290f87632a0ed55f1aa387
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 11 +++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 10 +++++-----
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
index 843ec69..cd0c0ee 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
@@ -214,13 +214,13 @@ static int dwmac4_wrback_get_tx_timestamp_status(struct dma_desc *p)
 {
 	/* Context type from W/B descriptor must be zero */
 	if (le32_to_cpu(p->des3) & TDES3_CONTEXT_TYPE)
-		return -EINVAL;
+		return 0;
 
 	/* Tx Timestamp Status is 1 so des0 and des1'll have valid values */
 	if (le32_to_cpu(p->des3) & TDES3_TIMESTAMP_STATUS)
-		return 0;
+		return 1;
 
-	return 1;
+	return 0;
 }
 
 static inline u64 dwmac4_get_timestamp(void *desc, u32 ats)
@@ -282,7 +282,10 @@ static int dwmac4_wrback_get_rx_timestamp_status(void *desc, u32 ats)
 		}
 	}
 exit:
-	return ret;
+	if (likely(ret == 0))
+		return 1;
+	else 
+		return 0;
 }
 
 static void dwmac4_rd_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 13a1ac9..84561e0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -359,14 +359,14 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
 		return;
 
 	/* check tx tstamp status */
-	if (!priv->hw->desc->get_tx_timestamp_status(p)) {
+	if (priv->hw->desc->get_tx_timestamp_status(p)) {
 		/* get the valid tstamp */
 		ns = priv->hw->desc->get_timestamp(p, priv->adv_ts);
 
 		memset(&shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
 		shhwtstamp.hwtstamp = ns_to_ktime(ns);
 
-		netdev_info(priv->dev, "get valid TX hw timestamp %llu\n", ns);
+		netdev_dbg(priv->dev, "get valid TX hw timestamp %llu\n", ns);
 		/* pass tstamp to stack */
 		skb_tstamp_tx(skb, &shhwtstamp);
 	}
@@ -393,19 +393,19 @@ static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv, struct dma_desc *p,
 		return;
 
 	/* Check if timestamp is available */
-	if (!priv->hw->desc->get_rx_timestamp_status(p, priv->adv_ts)) {
+	if (priv->hw->desc->get_rx_timestamp_status(p, priv->adv_ts)) {
 		/* For GMAC4, the valid timestamp is from CTX next desc. */
 		if (priv->plat->has_gmac4)
 			ns = priv->hw->desc->get_timestamp(np, priv->adv_ts);
 		else
 			ns = priv->hw->desc->get_timestamp(p, priv->adv_ts);
 
-		netdev_info(priv->dev, "get valid RX hw timestamp %llu\n", ns);
+		netdev_dbg(priv->dev, "get valid RX hw timestamp %llu\n", ns);
 		shhwtstamp = skb_hwtstamps(skb);
 		memset(shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
 		shhwtstamp->hwtstamp = ns_to_ktime(ns);
 	} else  {
-		netdev_err(priv->dev, "cannot get RX hw timestamp\n");
+		netdev_dbg(priv->dev, "cannot get RX hw timestamp\n");
 	}
 }
 
-- 
2.7.4


--rehcsed-ce166cb0-846c-4232-8d15-5ab54a7fc0cb--
