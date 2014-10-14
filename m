From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net 2/4] cxgb4 : Fix build failure in cxgb4 when ipv6 is disabled/not in-built
Date: Tue, 14 Oct 2014 15:13:09 -0700
Message-ID: <1413324791-12104-3-git-send-email-anish@chelsio.com>
References: <1413324791-12104-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	kxie@chelsio.com, manojmalviya@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43763
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932583AbaJNWNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 18:13:47 -0400
In-Reply-To: <1413324791-12104-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/Kconfig            | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 8 ++++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index c3ce9df0041a..ac6473f75eb9 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -68,7 +68,7 @@ config CHELSIO_T3
 
 config CHELSIO_T4
 	tristate "Chelsio Communications T4/T5 Ethernet support"
-	depends on PCI
+	depends on PCI && (IPV6 || IPV6=n)
 	select FW_LOADER
 	select MDIO
 	---help---
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6222a42f7a2a..ff9fb1629815 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4359,6 +4359,7 @@ EXPORT_SYMBOL(cxgb4_unregister_uld);
  * success (true) if it belongs otherwise failure (false).
  * Called with rcu_read_lock() held.
  */
+#if IS_ENABLED(CONFIG_IPV6)
 static bool cxgb4_netdev(const struct net_device *netdev)
 {
 	struct adapter *adap;
@@ -4519,6 +4520,7 @@ static void update_clip(const struct adapter *adap)
 	}
 	rcu_read_unlock();
 }
+#endif /* IS_ENABLED(CONFIG_IPV6) */
 
 /**
  *	cxgb_up - enable the adapter
@@ -4565,7 +4567,9 @@ static int cxgb_up(struct adapter *adap)
 	t4_intr_enable(adap);
 	adap->flags |= FULL_INIT_DONE;
 	notify_ulds(adap, CXGB4_STATE_UP);
+#if IS_ENABLED(CONFIG_IPV6)
 	update_clip(adap);
+#endif
  out:
 	return err;
  irq_err:
@@ -6855,14 +6859,18 @@ static int __init cxgb4_init_module(void)
 	if (ret < 0)
 		debugfs_remove(cxgb4_debugfs_root);
 
+#if IS_ENABLED(CONFIG_IPV6)
 	register_inet6addr_notifier(&cxgb4_inet6addr_notifier);
+#endif
 
 	return ret;
 }
 
 static void __exit cxgb4_cleanup_module(void)
 {
+#if IS_ENABLED(CONFIG_IPV6)
 	unregister_inet6addr_notifier(&cxgb4_inet6addr_notifier);
+#endif
 	pci_unregister_driver(&cxgb4_driver);
 	debugfs_remove(cxgb4_debugfs_root);  /* NULL ok */
 }
-- 
2.1.2
