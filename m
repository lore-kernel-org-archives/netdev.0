From: divy@chelsio.com
Subject: [PATCH 3/5] cxgb3 - Fix direct XAUI support
Date: Wed, 30 May 2007 10:01:39 -0700
Message-ID: <20070530170139.22825.65387.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:8924 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756543AbXE3RBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 13:01:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Check all lanes for link status on direct XAUI cards.
Don't assume that direct XAUI always uses XGMAC 1.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/ael1002.c |   10 ++++++++--
 drivers/net/cxgb3/regs.h    |    2 ++
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
index 73a41e6..ee140e6 100644
--- a/drivers/net/cxgb3/ael1002.c
+++ b/drivers/net/cxgb3/ael1002.c
@@ -219,7 +219,13 @@ static int xaui_direct_get_link_status(s
 		unsigned int status;
 
 		status = t3_read_reg(phy->adapter,
-				     XGM_REG(A_XGM_SERDES_STAT0, phy->addr));
+				     XGM_REG(A_XGM_SERDES_STAT0, phy->addr)) |
+		    t3_read_reg(phy->adapter,
+				XGM_REG(A_XGM_SERDES_STAT1, phy->addr)) |
+		    t3_read_reg(phy->adapter,
+				XGM_REG(A_XGM_SERDES_STAT2, phy->addr)) |
+		    t3_read_reg(phy->adapter,
+				XGM_REG(A_XGM_SERDES_STAT3, phy->addr));
 		*link_ok = !(status & F_LOWSIG0);
 	}
 	if (speed)
@@ -247,5 +253,5 @@ static struct cphy_ops xaui_direct_ops =
 void t3_xaui_direct_phy_prep(struct cphy *phy, struct adapter *adapter,
 			     int phy_addr, const struct mdio_ops *mdio_ops)
 {
-	cphy_init(phy, adapter, 1, &xaui_direct_ops, mdio_ops);
+	cphy_init(phy, adapter, phy_addr, &xaui_direct_ops, mdio_ops);
 }
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index e5a5534..bf9d6be 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -2128,6 +2128,8 @@
 #define F_RESETPLL01    V_RESETPLL01(1U)
 
 #define A_XGM_SERDES_STAT0 0x8f0
+#define A_XGM_SERDES_STAT1 0x8f4
+#define A_XGM_SERDES_STAT2 0x8f8
 
 #define S_LOWSIG0    0
 #define V_LOWSIG0(x) ((x) << S_LOWSIG0)
