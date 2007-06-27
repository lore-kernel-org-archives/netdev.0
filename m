From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 27 Jun 2007 03:34:38 -0400
Message-ID: <20070627073438.GA18760@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:50146 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753442AbXF0Hek (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 03:34:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/au1000_eth.c  |    2 +-
 drivers/net/cxgb3/xgmac.c |    8 +++++---
 drivers/net/s2io.c        |   16 +++++++++-------
 3 files changed, 15 insertions(+), 11 deletions(-)

Divy Le Ray (1):
      cxgb3 - fix register to stop bc/mc traffic

Olaf Hering (1):
      2.6.22: ERROR: "__ucmpdi2" [drivers/net/s2io.ko] undefined!

Ralf Baechle (1):
      au1000_eth: Fix warnings.

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index c39ab80..c27cfce 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -34,7 +34,7 @@
  *
  *
  */
-
+#include <linux/dma-mapping.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index b261be1..c302b1a 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -335,11 +335,11 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 	hwm = min(hwm, MAC_RXFIFO_SIZE - 8192);
 	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
 
-	v = t3_read_reg(adap, A_XGM_RXFIFO_CFG + mac->offset);
 	if (adap->params.rev == T3_REV_B2 &&
 	    (t3_read_reg(adap, A_XGM_RX_CTRL + mac->offset) & F_RXEN)) {
 		disable_exact_filters(mac);
-		t3_set_reg_field(adap, A_XGM_RXFIFO_CFG + mac->offset,
+		v = t3_read_reg(adap, A_XGM_RX_CFG + mac->offset);
+		t3_set_reg_field(adap, A_XGM_RX_CFG + mac->offset,
 				 F_ENHASHMCAST | F_COPYALLFRAMES, F_DISBCAST);
 
 		/* drain rx FIFO */
@@ -347,11 +347,12 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 				    A_XGM_RX_MAX_PKT_SIZE_ERR_CNT +
 				    mac->offset,
 				    1 << 31, 1, 20, 5)) {
-			t3_write_reg(adap, A_XGM_RXFIFO_CFG + mac->offset, v);
+			t3_write_reg(adap, A_XGM_RX_CFG + mac->offset, v);
 			enable_exact_filters(mac);
 			return -EIO;
 		}
 		t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
+		t3_write_reg(adap, A_XGM_RX_CFG + mac->offset, v);
 		enable_exact_filters(mac);
 	} else
 		t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
@@ -362,6 +363,7 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 	 */
 	hwm = rx_fifo_hwm(mtu);
 	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
+	v = t3_read_reg(adap, A_XGM_RXFIFO_CFG + mac->offset);
 	v &= ~V_RXFIFOPAUSELWM(M_RXFIFOPAUSELWM);
 	v |= V_RXFIFOPAUSELWM(lwm / 8);
 	if (G_RXFIFOPAUSEHWM(v))
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index c6ba3de..09078ff 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2868,6 +2868,7 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 	struct tx_curr_get_info get_info, put_info;
 	struct sk_buff *skb;
 	struct TxD *txdlp;
+	u8 err_mask;
 
 	get_info = fifo_data->tx_curr_get_info;
 	memcpy(&put_info, &fifo_data->tx_curr_put_info, sizeof(put_info));
@@ -2886,8 +2887,8 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 			}
 
 			/* update t_code statistics */
-			err >>= 48;
-			switch(err) {
+			err_mask = err >> 48;
+			switch(err_mask) {
 				case 2:
 					nic->mac_control.stats_info->sw_stat.
 							tx_buf_abort_cnt++;
@@ -6805,6 +6806,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 	u16 l3_csum, l4_csum;
 	unsigned long long err = rxdp->Control_1 & RXD_T_CODE;
 	struct lro *lro;
+	u8 err_mask;
 
 	skb->dev = dev;
 
@@ -6813,8 +6815,8 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		if (err & 0x1) {
 			sp->mac_control.stats_info->sw_stat.parity_err_cnt++;
 		}
-		err >>= 48;
-		switch(err) {
+		err_mask = err >> 48;
+		switch(err_mask) {
 			case 1:
 				sp->mac_control.stats_info->sw_stat.
 				rx_parity_err_cnt++;
@@ -6867,9 +6869,9 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		* Note that in this case, since checksum will be incorrect,
 		* stack will validate the same.
 		*/
-		if (err != 0x5) {
-			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
-				dev->name, err);
+		if (err_mask != 0x5) {
+			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%x\n",
+				dev->name, err_mask);
 			sp->stats.rx_crc_errors++;
 			sp->mac_control.stats_info->sw_stat.mem_freed 
 				+= skb->truesize;
