From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.22] cxgb3 - fix register to stop bc/mc traffic
Date: Mon, 25 Jun 2007 15:19:30 -0700
Message-ID: <20070625221930.19394.90772.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:5398 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbXFYWTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 18:19:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Use the right register to stop broadcast/multicast traffic. 

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/xgmac.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index b261be1..c302b1a 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -335,11 +335,11 @@ int t3_mac_set_mtu(struct cmac *mac, uns
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
@@ -347,11 +347,12 @@ int t3_mac_set_mtu(struct cmac *mac, uns
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
@@ -362,6 +363,7 @@ int t3_mac_set_mtu(struct cmac *mac, uns
 	 */
 	hwm = rx_fifo_hwm(mtu);
 	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
+	v = t3_read_reg(adap, A_XGM_RXFIFO_CFG + mac->offset);
 	v &= ~V_RXFIFOPAUSELWM(M_RXFIFOPAUSELWM);
 	v |= V_RXFIFOPAUSELWM(lwm / 8);
 	if (G_RXFIFOPAUSEHWM(v))

