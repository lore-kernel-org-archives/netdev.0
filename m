From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/2] e1000e: fix IPMI traffic
Date: Fri, 14 Nov 2008 08:45:23 -0800
Message-ID: <20081114164523.5342.71279.stgit@gitlost.lost>
References: <20081114164507.5342.19559.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:39833 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751653AbYKNQpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 11:45:41 -0500
In-Reply-To: <20081114164507.5342.19559.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some users reported that they have machines with BMCs enabled that cannot
receive IPMI traffic after e1000e is loaded.
http://marc.info/?l=e1000-devel&m=121909039127414&w=2
http://marc.info/?l=e1000-devel&m=121365543823387&w=2

This fixes the issue if they load with the new parameter = 0 by disabling
crc stripping, but leaves the performance feature on for most users.
Based on work done by Hong Zhang.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000e/e1000.h  |    5 +++++
 drivers/net/e1000e/netdev.c |   23 +++++++++++++++++++++--
 drivers/net/e1000e/param.c  |   25 +++++++++++++++++++++++++
 3 files changed, 51 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index c55de1c..c55fd6f 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -299,6 +299,7 @@ struct e1000_adapter {
 	unsigned long led_status;
 
 	unsigned int flags;
+	unsigned int flags2;
 	struct work_struct downshift_task;
 	struct work_struct update_phy_task;
 };
@@ -306,6 +307,7 @@ struct e1000_adapter {
 struct e1000_info {
 	enum e1000_mac_type	mac;
 	unsigned int		flags;
+	unsigned int            flags2;
 	u32			pba;
 	s32			(*get_variants)(struct e1000_adapter *);
 	struct e1000_mac_operations *mac_ops;
@@ -347,6 +349,9 @@ struct e1000_info {
 #define FLAG_RX_RESTART_NOW               (1 << 30)
 #define FLAG_MSI_TEST_FAILED              (1 << 31)
 
+/* CRC Stripping defines */
+#define FLAG2_CRC_STRIPPING               (1 << 0)
+
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
 #define E1000_GET_DESC(R, i, type)	(&(((struct type *)((R).desc))[i]))
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f6ebebb..91795f7 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -499,6 +499,10 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			goto next_desc;
 		}
 
+		/* adjust length to remove Ethernet CRC */
+		if (!(adapter->flags2 & FLAG2_CRC_STRIPPING))
+			length -= 4;
+
 		total_rx_bytes += length;
 		total_rx_packets++;
 
@@ -804,6 +808,10 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			pci_dma_sync_single_for_device(pdev, ps_page->dma,
 				PAGE_SIZE, PCI_DMA_FROMDEVICE);
 
+			/* remove the CRC */
+			if (!(adapter->flags2 & FLAG2_CRC_STRIPPING))
+				l1 -= 4;
+
 			skb_put(skb, l1);
 			goto copydone;
 		} /* if */
@@ -825,6 +833,12 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			skb->truesize += length;
 		}
 
+		/* strip the ethernet crc, problem is we're using pages now so
+		 * this whole operation can get a little cpu intensive
+		 */
+		if (!(adapter->flags2 & FLAG2_CRC_STRIPPING))
+			pskb_trim(skb, skb->len - 4);
+
 copydone:
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
@@ -2301,8 +2315,12 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	else
 		rctl |= E1000_RCTL_LPE;
 
-	/* Enable hardware CRC frame stripping */
-	rctl |= E1000_RCTL_SECRC;
+	/* Some systems expect that the CRC is included in SMBUS traffic. The
+	 * hardware strips the CRC before sending to both SMBUS (BMC) and to
+	 * host memory when this is enabled
+	 */
+	if (adapter->flags2 & FLAG2_CRC_STRIPPING)
+		rctl |= E1000_RCTL_SECRC;
 
 	/* Setup buffer sizes */
 	rctl &= ~E1000_RCTL_SZ_4096;
@@ -4766,6 +4784,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter->ei = ei;
 	adapter->pba = ei->pba;
 	adapter->flags = ei->flags;
+	adapter->flags2 = ei->flags2;
 	adapter->hw.adapter = adapter;
 	adapter->hw.mac.type = ei->mac;
 	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 77a3d72..e909f96 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -151,6 +151,16 @@ E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
  */
 E1000_PARAM(WriteProtectNVM, "Write-protect NVM [WARNING: disabling this can lead to corrupted NVM]");
 
+/*
+ * Enable CRC Stripping
+ *
+ * Valid Range: 0, 1
+ *
+ * Default Value: 1 (enabled)
+ */
+E1000_PARAM(CrcStripping, "Enable CRC Stripping, disable if your BMC needs " \
+                          "the CRC");
+
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
 	const char *name;
@@ -404,6 +414,21 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 				adapter->flags |= FLAG_SMART_POWER_DOWN;
 		}
 	}
+	{ /* CRC Stripping */
+		const struct e1000_option opt = {
+			.type = enable_option,
+			.name = "CRC Stripping",
+			.err  = "defaulting to enabled",
+			.def  = OPTION_ENABLED
+		};
+
+		if (num_CrcStripping > bd) {
+			unsigned int crc_stripping = CrcStripping[bd];
+			e1000_validate_option(&crc_stripping, &opt, adapter);
+			if (crc_stripping == OPTION_ENABLED)
+				adapter->flags2 |= FLAG2_CRC_STRIPPING;
+		}
+	}
 	{ /* Kumeran Lock Loss Workaround */
 		const struct e1000_option opt = {
 			.type = enable_option,

