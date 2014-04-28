From: clsoto@linux.vnet.ibm.com
Subject: [PATCH 1/1] mlx4: mlx4_core failed to load if use_prio argument is used
Date: Mon, 28 Apr 2014 13:33:31 -0500
Message-ID: <20140428183435.728801290@linux.vnet.ibm.com>
References: <20140428183330.201681971@linux.vnet.ibm.com>
Cc: clsoto@linux.vnet.ibm.com, brking@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [32.97.110.57] ([32.97.110.57]:32925 "HELO
	jupiter1-lp2.austin.ibm.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S933019AbaD1Tb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:31:28 -0400
Content-Disposition: inline; filename=mlx4_load_fail_use_prio.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

doing insmod mlx4_core.ko use_prio=1 will fail to load and will produce
this stack trace:
Call Trace:
 [c0000000f777f1f0] [d0000000008b110c] .mlx4_bitmap_init+0x7c/0xe0 [mlx4_core]
 [c0000000f777f270] [d0000000008ccca4] .mlx4_init_qp_table+0x1a4/0x400 [mlx4_core]
 [c0000000f777f310] [d0000000008c1ba4] .mlx4_setup_hca+0x454/0x680 [mlx4_core]
 [c0000000f777f3e0] [d0000000008c28fc] .__mlx4_init_one+0xb2c/0x11a0 [mlx4_core]
 [c0000000f777f4e0] [c00000000042e6f0] .local_pci_probe+0x60/0xb0
 [c0000000f777f570] [c00000000042e9d8] .pci_device_probe+0x198/0x1a0
 [c0000000f777f620] [c0000000004cc730] .driver_probe_device+0xd0/0x450
 [c0000000f777f6b0] [c0000000004ccc3c] .__driver_attach+0xfc/0x100
 [c0000000f777f740] [c0000000004c99a4] .bus_for_each_dev+0x84/0xf0
 [c0000000f777f7e0] [c0000000004cbf24] .driver_attach+0x24/0x40
 [c0000000f777f850] [c0000000004cb8c8] .bus_add_driver+0x298/0x3b0
 [c0000000f777f8f0] [c0000000004cd5bc] .driver_register+0x8c/0x170
 [c0000000f777f970] [c00000000042e424] .__pci_register_driver+0x44/0x60
 [c0000000f777f9e0] [d0000000008d7fc4] .mlx4_init+0x154/0x1b0 [mlx4_core]
 [c0000000f777fa70] [c00000000000bfa4] .do_one_initcall+0x144/0x1f0
 [c0000000f777fb60] [c000000000144a10] .load_module+0x1c00/0x21a0
 [c0000000f777fd30] [c0000000001451b0] .SyS_finit_module+0xb0/0x100
 [c0000000f777fe30] [c000000000009efc] syscall_exit+0x0/0x7c
 Instruction dump:
 7863e8c2 3929dbd8 7c6307b4 7d2918ae 7d290774 4bffffac 7888bfe3 39200000
 40e2ffbc 3d42fff1 892ab182 69290001 <0b090000> 2fa90000 39200000 41feffa0
 ---[ end trace 09b5aa84365cea39 ]---
 mlx4_core 0001:00:00.0: Failed to initialize queue pair table, aborting.
 mlx4_core: probe of 0001:00:00.0 failed with error -12

Using the argument use_prio will increase the number of reserved qps and then 
it will increase the size of the bitmap too big that kzalloc fails. 

Signed-off-by: Carol Soto <clsoto@linux.vnet.ibm.com>

---
 drivers/net/ethernet/mellanox/mlx4/main.c |    7 -------
 include/linux/mlx4/device.h               |    1 -
 2 files changed, 8 deletions(-)

Index: b/drivers/net/ethernet/mellanox/mlx4/main.c
===================================================================
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -132,11 +132,6 @@ MODULE_PARM_DESC(log_num_vlan, "Log2 max
 /* Log2 max number of VLANs per ETH port (0-7) */
 #define MLX4_LOG_NUM_VLANS 7
 
-static bool use_prio;
-module_param_named(use_prio, use_prio, bool, 0444);
-MODULE_PARM_DESC(use_prio, "Enable steering by VLAN priority on ETH ports "
-		  "(0/1, default 0)");
-
 int log_mtts_per_seg = ilog2(MLX4_MTT_ENTRY_PER_SEG);
 module_param_named(log_mtts_per_seg, log_mtts_per_seg, int, 0444);
 MODULE_PARM_DESC(log_mtts_per_seg, "Log2 number of MTT entries per segment (1-7)");
@@ -296,7 +291,6 @@ static int mlx4_dev_cap(struct mlx4_dev 
 
 	dev->caps.log_num_macs  = log_num_mac;
 	dev->caps.log_num_vlans = MLX4_LOG_NUM_VLANS;
-	dev->caps.log_num_prios = use_prio ? 3 : 0;
 
 	for (i = 1; i <= dev->caps.num_ports; ++i) {
 		dev->caps.port_type[i] = MLX4_PORT_TYPE_NONE;
@@ -366,7 +360,6 @@ static int mlx4_dev_cap(struct mlx4_dev 
 		dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FC_ADDR] =
 		(1 << dev->caps.log_num_macs) *
 		(1 << dev->caps.log_num_vlans) *
-		(1 << dev->caps.log_num_prios) *
 		dev->caps.num_ports;
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FC_EXCH] = MLX4_NUM_FEXCH;
 
Index: b/include/linux/mlx4/device.h
===================================================================
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -449,7 +449,6 @@ struct mlx4_caps {
 	int                     reserved_qps_base[MLX4_NUM_QP_REGION];
 	int                     log_num_macs;
 	int                     log_num_vlans;
-	int                     log_num_prios;
 	enum mlx4_port_type	port_type[MLX4_MAX_PORTS + 1];
 	u8			supported_type[MLX4_MAX_PORTS + 1];
 	u8                      suggested_type[MLX4_MAX_PORTS + 1];

-- 
