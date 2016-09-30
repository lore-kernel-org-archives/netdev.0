From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] cxgb4: unexport cxgb4_dcb_enabled
Date: Fri, 30 Sep 2016 18:15:33 +0200
Message-ID: <20160930161544.41614-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>,
        Nicholas Bellinger <nab@linux-iscsi.org>,
        Varun Prakash <varun@chelsio.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A recent cleanup marked cxgb4_dcb_enabled as 'static', which is correct, but this ignored
how the symbol is also exported. In addition, the export can be compiled out when modules
are disabled, causing a harmless compiler warning in configurations for which it is not
used at all:

drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:282:12: error: 'cxgb4_dcb_enabled' defined but not used [-Werror=unused-function]

This removes the export and moves the function into the correct #ifdef so we only build
it when there are users.

Fixes: 50935857f878 ("cxgb4: mark symbols static where possible")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c8a5c434ad2c..59f3772eb49d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -277,11 +277,9 @@ static void dcb_tx_queue_prio_enable(struct net_device *dev, int enable)
 			txq->dcb_prio = value;
 	}
 }
-#endif /* CONFIG_CHELSIO_T4_DCB */
 
 static int cxgb4_dcb_enabled(const struct net_device *dev)
 {
-#ifdef CONFIG_CHELSIO_T4_DCB
 	struct port_info *pi = netdev_priv(dev);
 
 	if (!pi->dcb.enabled)
@@ -289,11 +287,8 @@ static int cxgb4_dcb_enabled(const struct net_device *dev)
 
 	return ((pi->dcb.state == CXGB4_DCB_STATE_FW_ALLSYNCED) ||
 		(pi->dcb.state == CXGB4_DCB_STATE_HOST));
-#else
-	return 0;
-#endif
 }
-EXPORT_SYMBOL(cxgb4_dcb_enabled);
+#endif /* CONFIG_CHELSIO_T4_DCB */
 
 void t4_os_link_changed(struct adapter *adapter, int port_id, int link_stat)
 {
-- 
2.9.0
