From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kmalloc warning in mlx4_buddy_init.
Date: Wed, 15 May 2013 07:15:42 -0700
Message-ID: <1368627342.4519.29.camel@edumazet-glaptop>
References: <20130515082348.GO3658@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@purestorage.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Robin Holt <holt@sgi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130515082348.GO3658@sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-15 at 03:23 -0500, Robin Holt wrote:
> Roland,
> 
> We are seeing the following when booting on a large system.
> 
> [  171.399023] mlx4_core 0004:01:00.0: irq 2410 for MSI/MSI-X
> [  171.406560] ------------[ cut here ]------------
> [  171.411734] WARNING: at mm/slab_common.c:376 kmalloc_slab+0x71/0x90()
> [  171.418919] Modules linked in: mlx4_core(+) sg lpc_ich mfd_core shpchp pci_hotplug ehci_pci ehci_hcd ioatdma i2c_i801 igb dca i2c_algo_bit i2c_core ptp pps_core mperf processor thermal_sys hwmon usbcore usb_common ext4 jbd2 crc16 sd_mod crc_t10dif qla2xxx scsi_transport_fc scsi_tgt megaraid_sas ahci libahci isci libsas libata scsi_transport_sas scsi_mod button dm_mirror dm_region_hash dm_log dm_mod gru(O) xvma(O)
> [  171.460377] CPU: 48 PID: 2561 Comm: kworker/48:1 Tainted: G        W  O 3.10.0-rc1-uv-hz100-rja+ #3
> [  171.470473] Hardware name: SGI UV2000/ROMLEY, BIOS SGI UV 2000/3000 series BIOS 01/15/2013
> [  171.479720] Workqueue: events work_for_cpu_fn
> [  171.484597]  0000000000000178 ffff8867bb0f5ba8 ffffffff814a873c ffff8867bb0f5be8
> [  171.492897]  ffffffff81045a7b 000080d0000080d0 0000000000200000 ffff88679bc7cb80
> [  171.501205]  0000000000000000 00000000000082d0 0000000000000000 ffff8867bb0f5bf8
> [  171.509502] Call Trace:
> [  171.512266]  [<ffffffff814a873c>] dump_stack+0x19/0x1d
> [  171.518007]  [<ffffffff81045a7b>] warn_slowpath_common+0x6b/0xa0
> [  171.524711]  [<ffffffff81045ac5>] warn_slowpath_null+0x15/0x20
> [  171.531230]  [<ffffffff811258c1>] kmalloc_slab+0x71/0x90
> [  171.537176]  [<ffffffff81152e10>] __kmalloc+0x30/0x220
> [  171.542989]  [<ffffffffa03a9f4b>] ? mlx4_buddy_init+0xdb/0x1d0 [mlx4_core]
> [  171.550699]  [<ffffffffa03a9f4b>] mlx4_buddy_init+0xdb/0x1d0 [mlx4_core]
> [  171.558183]  [<ffffffffa03aa0ef>] mlx4_init_mr_table+0xaf/0x130 [mlx4_core]
> [  171.565964]  [<ffffffffa03a3c48>] mlx4_setup_hca+0x158/0x5a0 [mlx4_core]
> [  171.573446]  [<ffffffffa03a5b90>] __mlx4_init_one+0x720/0x9c0 [mlx4_core]
> [  171.581030]  [<ffffffffa03a5e7c>] mlx4_init_one+0x2c/0x60 [mlx4_core]
> [  171.588232]  [<ffffffff8128c599>] local_pci_probe+0x49/0x80
> [  171.594458]  [<ffffffff810606f3>] work_for_cpu_fn+0x13/0x20
> [  171.600692]  [<ffffffff81064114>] process_one_work+0x194/0x3d0
> [  171.607200]  [<ffffffff81065464>] worker_thread+0x2c4/0x410
> [  171.613421]  [<ffffffff810651a0>] ? manage_workers+0x190/0x190
> [  171.619940]  [<ffffffff8106aee6>] kthread+0xc6/0xd0
> [  171.625392]  [<ffffffff8106ae20>] ? kthread_freezable_should_stop+0x70/0x70
> [  171.633182]  [<ffffffff814b42ec>] ret_from_fork+0x7c/0xb0
> [  171.639204]  [<ffffffff8106ae20>] ? kthread_freezable_should_stop+0x70/0x70
> [  171.646976] ---[ end trace 822f6d487f108023 ]---
> [  171.715920] mlx4_core 0004:01:00.0: command 0xc failed: fw status = 0x40
> [  171.723888] mlx4_core: Initializing 0007:02:00.0
> 
> This looks to be a kmalloc larger than MAX_ORDER.  Not sure which of the two
> kcallocs in mlx4_buddy_init.

Same problem here, its a real old problem that I mentioned.

I usually use following hack to reduce the allocation size by 50%

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c
b/drivers/net/ethernet/mellanox/mlx4/main.c
index 0d32a82..b22f116 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -126,7 +126,7 @@ static int log_num_vlan;
 module_param_named(log_num_vlan, log_num_vlan, int, 0444);
 MODULE_PARM_DESC(log_num_vlan, "Log2 max number of VLANs per ETH port
(0-7)");
 /* Log2 max number of VLANs per ETH port (0-7) */
-#define MLX4_LOG_NUM_VLANS 7
+#define MLX4_LOG_NUM_VLANS 6
 
 static bool use_prio;
 module_param_named(use_prio, use_prio, bool, 0444);
