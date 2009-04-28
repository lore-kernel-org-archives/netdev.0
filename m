From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 5/6] igb: Enable SCTP checksum offloading
Date: Tue, 28 Apr 2009 01:36:13 -0700
Message-ID: <20090428083613.32417.12646.stgit@localhost.localdomain>
References: <20090428083445.32417.77682.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:57624
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751633AbZD1Ige (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:36:34 -0400
In-Reply-To: <20090428083445.32417.77682.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Originally from: Vlad Yasevich <vladislav.yasevich@hp.com>

This patch, both the driver portion and the sctp code was
modified by Jesse Brandeburg and is

Copyright(c) 2009 Intel Corporation.

Thanks go to Vlad for starting this work.

Intel 82576 chipset supports SCTP checksum offloading.  This
patch enables this functionality in the driver.  A new NETIF
feature is introduced for SCTP checksum offload.  If the driver
supports CRC32c checksum, it can set this feature flag.  The
hardware can offload both transmit and receive.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.h   |    1 +
 drivers/net/igb/e1000_defines.h |    1 +
 drivers/net/igb/igb_ethtool.c   |   12 +++++++++---
 drivers/net/igb/igb_main.c      |   21 ++++++++++++++++++++-
 4 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index eaf9770..0f16aba 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -130,6 +130,7 @@ struct e1000_adv_tx_context_desc {
 #define E1000_ADVTXD_MACLEN_SHIFT    9  /* Adv ctxt desc mac len shift */
 #define E1000_ADVTXD_TUCMD_IPV4    0x00000400  /* IP Packet Type: 1=IPv4 */
 #define E1000_ADVTXD_TUCMD_L4T_TCP 0x00000800  /* L4 Packet TYPE of TCP */
+#define E1000_ADVTXD_TUCMD_L4T_SCTP 0x00001000 /* L4 packet TYPE of SCTP */
 /* IPSec Encrypt Enable for ESP */
 #define E1000_ADVTXD_L4LEN_SHIFT     8  /* Adv ctxt L4LEN shift */
 #define E1000_ADVTXD_MSS_SHIFT      16  /* Adv ctxt MSS shift */
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 65acbba..3bda3db 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -291,6 +291,7 @@
 /* Receive Checksum Control */
 #define E1000_RXCSUM_IPOFL     0x00000100   /* IPv4 checksum offload */
 #define E1000_RXCSUM_TUOFL     0x00000200   /* TCP / UDP checksum offload */
+#define E1000_RXCSUM_CRCOFL    0x00000800   /* CRC32 offload enable */
 #define E1000_RXCSUM_PCSD      0x00002000   /* packet checksum disabled */
 
 /* Header split receive */
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 27eae49..b1367ce 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -293,10 +293,16 @@ static u32 igb_get_tx_csum(struct net_device *netdev)
 
 static int igb_set_tx_csum(struct net_device *netdev, u32 data)
 {
-	if (data)
+	struct igb_adapter *adapter = netdev_priv(netdev);
+
+	if (data) {
 		netdev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-	else
-		netdev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
+		if (adapter->hw.mac.type == e1000_82576)
+			netdev->features |= NETIF_F_SCTP_CSUM;
+	} else {
+		netdev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+		                      NETIF_F_SCTP_CSUM);
+	}
 
 	return 0;
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f7f8612..bca7e9f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1345,6 +1345,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
+	if (adapter->hw.mac.type == e1000_82576)
+		netdev->features |= NETIF_F_SCTP_CSUM;
+
 	adapter->en_mng_pt = igb_enable_mng_pass_thru(&adapter->hw);
 
 	/* before reading the NVM, reset the controller to put the device in a
@@ -2249,6 +2252,10 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	/* Don't need to set TUOFL or IPOFL, they default to 1 */
 	if (!adapter->rx_csum)
 		rxcsum &= ~(E1000_RXCSUM_TUOFL | E1000_RXCSUM_IPOFL);
+	else if (adapter->hw.mac.type == e1000_82576)
+		/* Enable Receive Checksum Offload for SCTP */
+		rxcsum |= E1000_RXCSUM_CRCOFL;
+
 	wr32(E1000_RXCSUM, rxcsum);
 
 	/* Set the default pool for the PF's first queue */
@@ -3064,11 +3071,15 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
 				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+				else if (ip_hdr(skb)->protocol == IPPROTO_SCTP)
+					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_SCTP;
 				break;
 			case cpu_to_be16(ETH_P_IPV6):
 				/* XXX what about other V6 headers?? */
 				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+				else if (ipv6_hdr(skb)->nexthdr == IPPROTO_SCTP)
+					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_SCTP;
 				break;
 			default:
 				if (unlikely(net_ratelimit()))
@@ -4449,14 +4460,22 @@ static inline void igb_rx_checksum_adv(struct igb_adapter *adapter,
 	/* TCP/UDP checksum error bit is set */
 	if (status_err &
 	    (E1000_RXDEXT_STATERR_TCPE | E1000_RXDEXT_STATERR_IPE)) {
+		/*
+		 * work around errata with sctp packets where the TCPE aka
+		 * L4E bit is set incorrectly on 64 byte (60 byte w/o crc)
+		 * packets, (aka let the stack check the crc32c)
+		 */
+		if (!((adapter->hw.mac.type == e1000_82576) &&
+		      (skb->len == 60)))
+			adapter->hw_csum_err++;
 		/* let the stack verify checksum errors */
-		adapter->hw_csum_err++;
 		return;
 	}
 	/* It must be a TCP or UDP packet with a valid checksum */
 	if (status_err & (E1000_RXD_STAT_TCPCS | E1000_RXD_STAT_UDPCS))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+	dev_dbg(&adapter->pdev->dev, "cksum success: bits %08X\n", status_err);
 	adapter->hw_csum_good++;
 }
 

