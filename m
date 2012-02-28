From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] mlx4: prevent the device from being removed concurrently
Date: Tue, 28 Feb 2012 15:36:16 -0300
Message-ID: <1330454176-17768-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	davem@davemloft.net, roland@purestorage.com,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:42532 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965107Ab2B1Sgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 13:36:32 -0500
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Tue, 28 Feb 2012 15:36:25 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a EEH happens, the catas poll code will try to restart the device,
removing it and adding it back again. The EEH code will try to do the
same. One of the threads ends up accessing memory that was freed by the
other thread and we get a crash.

The EEH backtrace:

<4>Call Trace:
<4>[c00000007fff3ae0] [c000000000015374] .show_stack+0x74/0x1c0 (unreliable)
<4>[c00000007fff3b90] [c00000000005d6d4] .eeh_dn_check_failure+0x2f4/0x320
<4>[c00000007fff3c50] [c00000000005d76c] .eeh_check_failure+0x6c/0x100
<4>[c00000007fff3cd0] [d00000000335165c] .poll_catas+0x25c/0x280 [mlx4_core]
<4>[c00000007fff3d70] [c00000000009add0] .run_timer_softirq+0x1b0/0x450
<4>[c00000007fff3ea0] [c000000000090c80] .__do_softirq+0x110/0x2a0
<4>[c00000007fff3f90] [c000000000021ca8] .call_do_softirq+0x14/0x24
<4>[c000000000afb910] [c000000000011288] .do_softirq+0xf8/0x130
<4>[c000000000afb9b0] [c000000000090914] .irq_exit+0xb4/0xc0
<4>[c000000000afba30] [c00000000001e024] .timer_interrupt+0x124/0x290
<4>[c000000000afbad0] [c0000000000039a4] decrementer_common+0x124/0x180
<4>--- Exception: 901 at .arch_local_irq_restore+0x54/0x60
<4>    LR = .cpu_idle+0x170/0x210
<4>[c000000000afbdc0] [c000000000017874] .cpu_idle+0x164/0x210 (unreliable)
<4>[c000000000afbe70] [c00000000000b2a8] .rest_init+0x88/0xa0
<4>[c000000000afbef0] [c000000000970ae8] .start_kernel+0x458/0x478
<4>[c000000000afbf90] [c000000000009670] .start_here_common+0x1c/0x2c
<3>mlx4_core 0000:01:00.0: Internal error detected:
<3>mlx4_core 0000:01:00.0:   buf[00]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[01]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[02]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[03]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[04]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[05]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[06]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[07]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[08]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[09]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[0a]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[0b]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[0c]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[0d]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[0e]: ffffffff
<3>mlx4_core 0000:01:00.0:   buf[0f]: ffffffff
<6>EEH: Detected PCI bus error on device 0000:01:00.0
<4>EEH: This PCI device has failed 1 times in the last hour:
<4>EEH: Bus location=U78AB.001.WZSGL60-P1-C4-T1 driver=mlx4_core pci addr=0000:01:00.0
<4>EEH: Device location=U78AB.001.WZSGL60-P1-C4-T1 driver=mlx4_core pci addr=0000:01:00.0

The crash stack trace:

Unable to handle kernel paging request for data at address 0x00000000
Faulting instruction address: 0xc000000000176a54
[c000000072d835c0] c000000000176c48 .__vunmap+0x38/0x120
[c000000072d83660] c00000000003f4e8 .__iounmap+0x38/0x60
[c000000072d836d0] d00000000335124c .mlx4_stop_catas_poll+0x3c/0xd0 [mlx4_core]
[c000000072d83760] d0000000033572dc .mlx4_unregister_device+0x2c/0xe0 [mlx4_core]
[c000000072d83800] d000000003357b68 .mlx4_remove_one+0x48/0x1f0 [mlx4_core]
[c000000072d838a0] c0000000003d3228 .pci_device_remove+0x48/0x90
[c000000072d83920] c0000000004731a0 .__device_release_driver+0x80/0x100
[c000000072d839b0] c0000000004733a0 .device_release_driver+0x30/0x60
[c000000072d83a40] c000000000472228 .bus_remove_device+0x128/0x180
[c000000072d83ad0] c00000000046fd84 .device_del+0x154/0x240
[c000000072d83b70] c00000000046fe88 .device_unregister+0x18/0x30
[c000000072d83bf0] c0000000003ccac0 .pci_stop_bus_device+0xc0/0xe0
[c000000072d83c80] c0000000003ccbbc .pci_remove_bus_device+0x2c/0x120
[c000000072d83d20] c00000000005fb68 .pcibios_remove_pci_devices+0x88/0xc0
[c000000072d83db0] c00000000005e388 .eeh_reset_device+0x48/0x180
[c000000072d83e50] c00000000005e790 .handle_eeh_events+0x2d0/0x440
[c000000072d83f00] c00000000005ee78 .eeh_event_handler+0x138/0x1c0
[c000000072d83f90] c000000000021e6c .kernel_thread+0x54/0x70

Adding a mutex in the remove code will prevent this crash.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 678558b..28279dc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -136,6 +136,8 @@ module_param_array(port_type_array, int, &arr_argc, 0444);
 MODULE_PARM_DESC(port_type_array, "Array of port types: HW_DEFAULT (0) is default "
 				"1 for IB, 2 for Ethernet");
 
+static DEFINE_MUTEX(remove_mutex);
+
 struct mlx4_port_config {
 	struct list_head list;
 	enum mlx4_port_type port_type[MLX4_MAX_PORTS + 1];
@@ -1939,10 +1941,15 @@ static int __devinit mlx4_init_one(struct pci_dev *pdev,
 
 static void mlx4_remove_one(struct pci_dev *pdev)
 {
-	struct mlx4_dev  *dev  = pci_get_drvdata(pdev);
-	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_dev *dev;
+	struct mlx4_priv *priv;
 	int p;
 
+	mutex_lock(&remove_mutex);
+
+	dev  = pci_get_drvdata(pdev);
+	priv = mlx4_priv(dev);
+
 	if (dev) {
 		/* in SRIOV it is not allowed to unload the pf's
 		 * driver while there are alive vf's */
@@ -1999,6 +2006,8 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
 	}
+
+	mutex_unlock(&remove_mutex);
 }
 
 int mlx4_restart_one(struct pci_dev *pdev)
-- 
1.7.4.4
