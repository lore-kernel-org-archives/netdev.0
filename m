From: Brice Goglin <brice@myri.com>
Subject: Re: [BUILD_FAILURE] 2.6.27-git2 - allyesconfig on
	powerpc	selectsCONFIG_INTEL_IOATDMA=y
Date: Tue, 14 Oct 2008 11:12:30 +0200
Message-ID: <48F4627E.30300@myri.com>
References: <20081013101559.GA14372@linux.vnet.ibm.com>
	<20081013112631.GD29938@cs181140183.pp.htv.fi>
	<36D9DB17C6DE9E40B059440DB8D95F52066E2EAE@orsmsx418.amr.corp.intel.com>
	<48F391B9.1000206@myri.com>
	<20081013183503.GA28133@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev@ozlabs.org, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>, apw@shadowen.org,
	sam@ravnborg.org, Jeff Garzik <jgarzik@redhat.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20081013183503.GA28133@cs181140183.pp.htv.fi>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> But considering that igb is in a similar situation it would be nice if 
> all 3 drivers would handle it the same way.
>   

Jesse,
What do you think of the below patch?
I am not very familiar with Kconfig, but it seems to solve the problem.
If a Kconfig guru could double-check...
Brice


myri10ge: Add MYRI10GE_DCA instead of selecting INTEL_IOATDMA

Add a bool MYRI10GE_DCA defined to y if MYRI10GE and DCA are enabled, but
MYRI10GE isn't y while DCA=m. And thus remove the need to select INTEL_IOATDMA
when MYRI10GE is enabled, so that non-x86 architectures can build the myri10ge.

Signed-off-by: Brice Goglin <brice@myri.com>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e9d5294..0162d55 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2462,7 +2462,6 @@ config MYRI10GE
 	select FW_LOADER
 	select CRC32
 	select INET_LRO
-	select INTEL_IOATDMA
 	---help---
 	  This driver supports Myricom Myri-10G Dual Protocol interface in
 	  Ethernet mode. If the eeprom on your board is not recent enough,
@@ -2474,6 +2473,11 @@ config MYRI10GE
 	  To compile this driver as a module, choose M here. The module
 	  will be called myri10ge.
 
+config MYRI10GE_DCA
+	bool
+	default y
+	depends on MYRI10GE && DCA && !(MYRI10GE=y && DCA=m)
+
 config NETXEN_NIC
 	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
 	depends on PCI
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 6dce901..a9aebad 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -188,7 +188,7 @@ struct myri10ge_slice_state {
 	dma_addr_t fw_stats_bus;
 	int watchdog_tx_done;
 	int watchdog_tx_req;
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	int cached_dca_tag;
 	int cpu;
 	__be32 __iomem *dca_tag;
@@ -220,7 +220,7 @@ struct myri10ge_priv {
 	int msi_enabled;
 	int msix_enabled;
 	struct msix_entry *msix_vectors;
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	int dca_enabled;
 #endif
 	u32 link_state;
@@ -902,7 +902,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	struct myri10ge_slice_state *ss;
 	int i, status;
 	size_t bytes;
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	unsigned long dca_tag_off;
 #endif
 
@@ -1012,7 +1012,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	}
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
 
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_DCA_OFFSET, &cmd, 0);
 	dca_tag_off = cmd.data0;
 	for (i = 0; i < mgp->num_slices; i++) {
@@ -1051,7 +1051,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	return status;
 }
 
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 static void
 myri10ge_write_dca(struct myri10ge_slice_state *ss, int cpu, int tag)
 {
@@ -1505,7 +1505,7 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	struct net_device *netdev = ss->mgp->dev;
 	int work_done;
 
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	if (ss->mgp->dca_enabled)
 		myri10ge_update_dca(ss);
 #endif
@@ -1736,7 +1736,7 @@ static const char myri10ge_gstrings_main_stats[][ETH_GSTRING_LEN] = {
 	"tx_boundary", "WC", "irq", "MSI", "MSIX",
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "watchdog_resets",
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	"dca_capable_firmware", "dca_device_present",
 #endif
 	"link_changes", "link_up", "dropped_link_overflow",
@@ -1815,7 +1815,7 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 	data[i++] = (unsigned int)mgp->read_write_dma;
 	data[i++] = (unsigned int)mgp->serial_number;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	data[i++] = (unsigned int)(mgp->ss[0].dca_tag != NULL);
 	data[i++] = (unsigned int)(mgp->dca_enabled);
 #endif
@@ -3844,7 +3844,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&pdev->dev, "failed reset\n");
 		goto abort_with_slices;
 	}
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	myri10ge_setup_dca(mgp);
 #endif
 	pci_set_drvdata(pdev, mgp);
@@ -3948,7 +3948,7 @@ static void myri10ge_remove(struct pci_dev *pdev)
 	netdev = mgp->dev;
 	unregister_netdev(netdev);
 
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	myri10ge_teardown_dca(mgp);
 #endif
 	myri10ge_dummy_rdma(mgp, 0);
@@ -3993,7 +3993,7 @@ static struct pci_driver myri10ge_driver = {
 #endif
 };
 
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 static int
 myri10ge_notify_dca(struct notifier_block *nb, unsigned long event, void *p)
 {
@@ -4024,7 +4024,7 @@ static __init int myri10ge_init_module(void)
 		       myri10ge_driver.name, myri10ge_rss_hash);
 		myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_PORT;
 	}
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	dca_register_notify(&myri10ge_dca_notifier);
 #endif
 	if (myri10ge_max_slices > MYRI10GE_MAX_SLICES)
@@ -4037,7 +4037,7 @@ module_init(myri10ge_init_module);
 
 static __exit void myri10ge_cleanup_module(void)
 {
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	dca_unregister_notify(&myri10ge_dca_notifier);
 #endif
 	pci_unregister_driver(&myri10ge_driver);



-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
