From: Joe Perches <joe@perches.com>
Subject: Re: [net] ixgbe: fix registration order of driver and DCA
 nofitication
Date: Wed, 03 Apr 2013 20:11:12 -0700
Message-ID: <1365045072.5248.1.camel@joe-AO722>
References: <1365043854-8443-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jakub Kicinski <jakub.kicinski@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	stable <stable@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1365043854-8443-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-04-03 at 19:50 -0700, Jeff Kirsher wrote:
> From: Jakub Kicinski <jakub.kicinski@intel.com>
> 
> ixgbe_notify_dca cannot be called before driver registration
> because it expects driver's klist_devices to be allocated and
> initialized. While on it make sure debugfs files are removed
> when registration fails.

Why not take out a bunch of these #ifdef CONFIG_DEBUG_FS at
the same time?  Something like:

 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  5 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 17 +++++++----------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index a8e10cf..ca93238 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -740,6 +740,11 @@ extern void ixgbe_dbg_adapter_init(struct ixgbe_adapter *adapter);
 extern void ixgbe_dbg_adapter_exit(struct ixgbe_adapter *adapter);
 extern void ixgbe_dbg_init(void);
 extern void ixgbe_dbg_exit(void);
+#else
+static inline void ixgbe_dbg_adapter_init(struct ixgbe_adapter *adapter) {}
+static inline void ixgbe_dbg_adapter_exit(struct ixgbe_adapter *adapter) {}
+static inline void ixgbe_dbg_init(void) {}
+static inline void ixgbe_dbg_exit(void) {}
 #endif /* CONFIG_DEBUG_FS */
 static inline struct netdev_queue *txring_txq(const struct ixgbe_ring *ring)
 {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e56a3d1..06cd8cd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7575,9 +7575,7 @@ skip_sriov:
 		e_err(probe, "failed to allocate sysfs resources\n");
 #endif /* CONFIG_IXGBE_HWMON */
 
-#ifdef CONFIG_DEBUG_FS
 	ixgbe_dbg_adapter_init(adapter);
-#endif /* CONFIG_DEBUG_FS */
 
 	return 0;
 
@@ -7613,9 +7611,7 @@ static void ixgbe_remove(struct pci_dev *pdev)
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
 
-#ifdef CONFIG_DEBUG_FS
 	ixgbe_dbg_adapter_exit(adapter);
-#endif /*CONFIG_DEBUG_FS */
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	cancel_work_sync(&adapter->service_task);
@@ -7878,16 +7874,19 @@ static int __init ixgbe_init_module(void)
 	pr_info("%s - version %s\n", ixgbe_driver_string, ixgbe_driver_version);
 	pr_info("%s\n", ixgbe_copyright);
 
-#ifdef CONFIG_DEBUG_FS
 	ixgbe_dbg_init();
-#endif /* CONFIG_DEBUG_FS */
+
+	ret = pci_register_driver(&ixgbe_driver);
+	if (ret) {
+		ixgbe_dbg_exit();
+		return ret;
+	}
 
 #ifdef CONFIG_IXGBE_DCA
 	dca_register_notify(&dca_notifier);
 #endif
 
-	ret = pci_register_driver(&ixgbe_driver);
-	return ret;
+	return 0;
 }
 
 module_init(ixgbe_init_module);
@@ -7905,9 +7904,7 @@ static void __exit ixgbe_exit_module(void)
 #endif
 	pci_unregister_driver(&ixgbe_driver);
 
-#ifdef CONFIG_DEBUG_FS
 	ixgbe_dbg_exit();
-#endif /* CONFIG_DEBUG_FS */
 
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
