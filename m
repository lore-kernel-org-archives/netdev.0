From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net v2 2/4] cxgb4 : Fix build failure in cxgb4 when ipv6 is disabled/not in-built
Date: Tue, 14 Oct 2014 20:07:22 -0700
Message-ID: <1413342444-16388-3-git-send-email-anish@chelsio.com>
References: <1413342444-16388-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hch@infradead.org, jbottomley@parallels.com,
	kxie@chelsio.com, manojmalviya@chelsio.com, hariprasad@chelsio.com,
	leedom@chelsio.com, swise@opengridcomputing.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1413342444-16388-1-git-send-email-anish@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cxgb4 ipv6 does not guard against ipv6 being disabled, or the standard
ipv6 module vs inbuilt tri-state issue. This was fixed for cxgb4i & iw_cxgb4
but missed for cxgb4.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/Kconfig            | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 8 ++++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index c3ce9df..ac6473f 100644
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
index 411acf0..3f60070 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4369,6 +4369,7 @@ EXPORT_SYMBOL(cxgb4_unregister_uld);
  * success (true) if it belongs otherwise failure (false).
  * Called with rcu_read_lock() held.
  */
+#if IS_ENABLED(CONFIG_IPV6)
 static bool cxgb4_netdev(const struct net_device *netdev)
 {
 	struct adapter *adap;
@@ -4529,6 +4530,7 @@ static void update_clip(const struct adapter *adap)
 	}
 	rcu_read_unlock();
 }
+#endif /* IS_ENABLED(CONFIG_IPV6) */
 
 /**
  *	cxgb_up - enable the adapter
@@ -4575,7 +4577,9 @@ static int cxgb_up(struct adapter *adap)
 	t4_intr_enable(adap);
 	adap->flags |= FULL_INIT_DONE;
 	notify_ulds(adap, CXGB4_STATE_UP);
+#if IS_ENABLED(CONFIG_IPV6)
 	update_clip(adap);
+#endif
  out:
 	return err;
  irq_err:
@@ -6869,14 +6873,18 @@ static int __init cxgb4_init_module(void)
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

