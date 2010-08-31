From: Joe Perches <joe@perches.com>
Subject: [PATCH] drivers/net/pch_gbe: Use bool not unsigned char
Date: Tue, 31 Aug 2010 10:25:14 -0700
Message-ID: <1283275514.1797.36.camel@Joe-Laptop>
References: <4C763A67.5040107@dsn.okisemi.com>
	 <4C7D0E7A.5060309@dsn.okisemi.com>  <1283271009.1797.28.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sam Ravnborg <sam@ravnborg.org>,
	LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283271009.1797.28.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Perhaps this is clearer.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pch_gbe/pch_gbe.h      |    6 +++---
 drivers/net/pch_gbe/pch_gbe_main.c |   33 +++++++++++++++++----------------
 2 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe.h b/drivers/net/pch_gbe/pch_gbe.h
index a615ddc..a2b2c55 100644
--- a/drivers/net/pch_gbe/pch_gbe.h
+++ b/drivers/net/pch_gbe/pch_gbe.h
@@ -638,9 +638,9 @@ struct pch_gbe_adapter {
 	struct pch_gbe_rx_ring *rx_ring;
 	unsigned long rx_buffer_len;
 	unsigned long tx_queue_len;
-	unsigned char rx_csum;
-	unsigned char tx_csum;
-	unsigned char have_msi;
+	bool rx_csum;
+	bool tx_csum;
+	bool have_msi;
 };
 
 /**
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 264f275..8195702 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -711,7 +711,7 @@ static void pch_gbe_setup_rctl(struct pch_gbe_adapter *adapter)
 
 	tcpip = ioread32(&hw->reg->TCPIP_ACC);
 
-	if (adapter->rx_csum == true) {
+	if (adapter->rx_csum) {
 		tcpip &= ~PCH_GBE_RX_TCPIPACC_OFF;
 		tcpip |= PCH_GBE_RX_TCPIPACC_EN;
 	} else {
@@ -1005,7 +1005,7 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 	frame_ctrl = 0;
 	if (unlikely(skb->len < PCH_GBE_SHORT_PKT))
 		frame_ctrl |= PCH_GBE_TXD_CTRL_APAD;
-	if (unlikely(adapter->tx_csum == false))
+	if (unlikely(!adapter->tx_csum))
 		frame_ctrl |= PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
 
 	/* Performs checksum processing */
@@ -1013,7 +1013,7 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 	 * It is because the hardware accelerator does not support a checksum,
 	 * when the received data size is less than 64 bytes.
 	 */
-	if ((skb->len < PCH_GBE_SHORT_PKT) && (adapter->tx_csum == true)) {
+	if ((skb->len < PCH_GBE_SHORT_PKT) && (adapter->tx_csum)) {
 		frame_ctrl |= PCH_GBE_TXD_CTRL_APAD |
 			      PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
 		if (skb->protocol == htons(ETH_P_IP)) {
@@ -1161,7 +1161,7 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
 		pr_err("Rx descriptor is empty\n");
 		int_en = ioread32(&hw->reg->INT_EN);
 		iowrite32((int_en & ~PCH_GBE_INT_RX_DSC_EMP), &hw->reg->INT_EN);
-		if (hw->mac.tx_fc_enable == true) {
+		if (hw->mac.tx_fc_enable) {
 			/* Set Pause packet */
 			pch_gbe_mac_set_pause_packet(hw);
 		}
@@ -1296,7 +1296,7 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
  *	true:  Cleaned the descriptor
  *	false: Not cleaned the descriptor
  */
-static unsigned char
+static bool
 pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 		 struct pch_gbe_tx_ring *tx_ring)
 {
@@ -1305,7 +1305,7 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 	struct sk_buff *skb;
 	unsigned int i;
 	unsigned int cleaned_count = 0;
-	unsigned char cleaned = false;
+	bool cleaned = false;
 
 	FUNC_ENTER();
 	pr_debug("next_to_clean : %d\n", tx_ring->next_to_clean);
@@ -1394,7 +1394,7 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
  *	true:  Cleaned the descriptor
  *	false: Not cleaned the descriptor
  */
-static unsigned char
+static bool
 pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 		 struct pch_gbe_rx_ring *rx_ring,
 		 int *work_done, int work_to_do)
@@ -1407,7 +1407,7 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 	unsigned char tmp_packet[ETH_HLEN];
 	unsigned int i;
 	unsigned int cleaned_count = 0;
-	unsigned char cleaned = false;
+	bool cleaned = false;
 	struct sk_buff *skb;
 	u8 dma_status;
 	u16 gbec_status;
@@ -1462,7 +1462,7 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 			length = (rx_desc->rx_words_eob) - 3 - 2;
 
 			/* Decide the data conversion method */
-			if (adapter->rx_csum != true) {
+			if (!adapter->rx_csum) {
 				/* [Header:14][payload] */
 				skb_padding_flag = 0;
 				skb_copy_flag = 1;
@@ -2131,8 +2131,8 @@ static void pch_gbe_tx_timeout(struct net_device *netdev)
  * @napi:    Pointer of polling device struct
  * @budget:  The maximum number of a packet
  * Returns
- *	0:  Exit the polling mode
- *	1:  Continue the polling mode
+ *	false:  Exit the polling mode
+ *	true:   Continue the polling mode
  */
 static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 {
@@ -2140,15 +2140,15 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 	    container_of(napi, struct pch_gbe_adapter, napi);
 	struct net_device *netdev = adapter->netdev;
 	int work_done = 0;
-	int poll_end_flag = 0;
-	int cleaned = 0;
+	bool poll_end_flag = false;
+	bool cleaned = false;
 
 	FUNC_ENTER();
 	pr_debug("budget : %d\n", budget);
 
 	/* Keep link state information with original netdev */
 	if (!netif_carrier_ok(netdev)) {
-		poll_end_flag = 1;
+		poll_end_flag = true;
 	} else {
 		cleaned = pch_gbe_clean_tx(adapter, adapter->tx_ring);
 		pch_gbe_clean_rx(adapter, adapter->rx_ring, &work_done, budget);
@@ -2159,16 +2159,17 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 		 * exit the polling mode
 		 */
 		if ((work_done < budget) || !netif_running(netdev))
-			poll_end_flag = 1;
+			poll_end_flag = true;
 	}
 
-	if (poll_end_flag == 1) {
+	if (poll_end_flag) {
 		napi_complete(napi);
 		pch_gbe_irq_enable(adapter);
 	}
 
 	pr_debug("poll_end_flag : %d  work_done : %d  budget : %d\n",
 		 poll_end_flag, work_done, budget);
+
 	return work_done;
 }
 
