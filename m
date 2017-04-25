From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [RFC PATCH] netxen_nic: null-terminate serial number string in netxen_check_options()
Date: Tue, 25 Apr 2017 09:42:29 +0200
Message-ID: <20170425074229.28267-1-jmarchan@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Manish Chopra <manish.chopra@cavium.com>,
        Rahul Verma <rahul.verma@cavium.com>,
        Dept-GELinuxNICDev@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47936 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1176123AbdDYHmd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 03:42:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The serial_num string in netxen_check_options() is not always properly
null-terminated. I couldn't find the documention on the serial number
format and I suspect a proper integer to string conversion is in
order, but this patch a least prevents the out-of-bound access.

It solves the following kasan warning:
[   36.127074] ==================================================================
[   36.168472] BUG: KASAN: stack-out-of-bounds in strnlen+0x38/0x60 at addr ffff8800360e7a50
[   36.216956] Read of size 1 by task kworker/0:1/188
[   36.244451] page:ffffea0000d839c0 count:0 mapcount:0 mapping:          (null) index:0x2
[   36.291475] page flags: 0x1fffff00000000()
[   36.314980] page dumped because: kasan: bad access detected
[   36.348117] CPU: 0 PID: 188 Comm: kworker/0:1 Not tainted 3.10.0-650.el7.test.kasan.x86_64 #1
[   36.397065] Hardware name: HP ProLiant DL585 G7, BIOS A16 03/19/2012
[   36.434443] Workqueue: events work_for_cpu_fn
[   36.459452]  ffff8800360e7a30 00000000e4708e04 ffff8800360e7538 ffffffffb37748bf
[   36.503442]  ffff8800360e75c0 ffffffffb2f4a7e7 ffff8800360d8948 0000000600000007
[   36.546616]  ffff8800360d8950 0000000000000086 ffffffffb3782086 0000000000000004
[   36.589439] Call Trace:
[   36.603611]  [<ffffffffb37748bf>] dump_stack+0x19/0x1b
[   36.633970]  [<ffffffffb2f4a7e7>] kasan_report_error+0x507/0x540
[   36.668472]  [<ffffffffb3782086>] ? _raw_spin_unlock_irqrestore+0x36/0x80
[   36.708967]  [<ffffffffb2f4ae48>] kasan_report+0x58/0x60
[   36.740311]  [<ffffffffb2d5bf00>] ? cpu_clock+0x10/0x20
[   36.771532]  [<ffffffffb3182e68>] ? strnlen+0x38/0x60
[   36.800430]  [<ffffffffb2f48e6d>] __asan_load1+0x4d/0x50
[   36.831977]  [<ffffffffb3182e68>] strnlen+0x38/0x60
[   36.859995]  [<ffffffffb3186e4f>] string.isra.7+0x3f/0x130
[   36.891531]  [<ffffffffb3189b60>] vsnprintf+0x620/0xd70
[   36.922997]  [<ffffffffb2eba659>] ? __free_pages_ok+0xe9/0x160
[   36.956467]  [<ffffffffb3189540>] ? pointer.isra.19+0x780/0x780
[   36.991095]  [<ffffffffb2ce6ecf>] ? vprintk_emit+0x12f/0x730
[   37.023440]  [<ffffffffb318a2bd>] vscnprintf+0xd/0x40
[   37.053146]  [<ffffffffb2ce6efd>] vprintk_emit+0x15d/0x730
[   37.084983]  [<ffffffffc01afea1>] ? netxen_setup_minidump+0x621/0x780 [netxen_nic]
[   37.129435]  [<ffffffffb2ce784e>] vprintk_default+0x3e/0x60
[   37.161962]  [<ffffffffb376f32a>] printk+0xa1/0xc8
[   37.189446]  [<ffffffffb376f289>] ? panic+0x28d/0x28d
[   37.219447]  [<ffffffffc01a0014>] netxen_start_firmware+0x1124/0x1170 [netxen_nic]
[   37.262989]  [<ffffffffc019eef0>] ? netxen_show_diag_mode+0x50/0x50 [netxen_nic]
[   37.306968]  [<ffffffffc019a960>] ? netxen_nic_hw_write_wx_2M+0x180/0x180 [netxen_nic]
[   37.352621]  [<ffffffffc019a9dc>] ? netxen_nic_hw_read_wx_2M+0x7c/0x180 [netxen_nic]
[   37.397967]  [<ffffffffc01a2863>] netxen_nic_probe+0x6f3/0x15f0 [netxen_nic]
[   37.439351]  [<ffffffffb2c5a3c7>] ? native_sched_clock+0xf7/0x190
[   37.474980]  [<ffffffffb2daf726>] ? mark_lock+0xd6/0x860
[   37.505439]  [<ffffffffc01a2170>] ? netxen_nic_open+0xc0/0xc0 [netxen_nic]
[   37.545988]  [<ffffffffb3782086>] ? _raw_spin_unlock_irqrestore+0x36/0x80
[   37.584974]  [<ffffffffb2db01e7>] ? trace_hardirqs_on_caller+0x187/0x2b0
[   37.625444]  [<ffffffffb2db031d>] ? trace_hardirqs_on+0xd/0x10
[   37.658978]  [<ffffffffb37820a9>] ? _raw_spin_unlock_irqrestore+0x59/0x80
[   37.698937]  [<ffffffffc01a2170>] ? netxen_nic_open+0xc0/0xc0 [netxen_nic]
[   37.738975]  [<ffffffffb31edffa>] local_pci_probe+0x7a/0xd0
[   37.771447]  [<ffffffffb2d21d4f>] ? process_one_work+0x36f/0xb80
[   37.806447]  [<ffffffffb31edf80>] ? pci_device_shutdown+0xa0/0xa0
[   37.841483]  [<ffffffffb2d1a3dc>] work_for_cpu_fn+0x2c/0x50
[   37.873443]  [<ffffffffb2d21df6>] process_one_work+0x416/0xb80
[   37.908116]  [<ffffffffb2d21d4f>] ? process_one_work+0x36f/0xb80
[   37.943456]  [<ffffffffb2d219e0>] ? flush_delayed_work+0x80/0x80
[   37.977968]  [<ffffffffb2d1b2d3>] ? move_linked_works+0x83/0xb0
[   38.013461]  [<ffffffffb2d2292c>] worker_thread+0x3cc/0x580
[   38.045479]  [<ffffffffb2d22560>] ? process_one_work+0xb80/0xb80
[   38.081445]  [<ffffffffb2d2fcce>] kthread+0x16e/0x180
[   38.110450]  [<ffffffffb2d2fb60>] ? flush_kthread_work+0x280/0x280
[   38.145996]  [<ffffffffb2c5a589>] ? sched_clock+0x9/0x10
[   38.177466]  [<ffffffffb2d48bc9>] ? finish_task_switch+0x59/0x200
[   38.212477]  [<ffffffffb2d2fb60>] ? flush_kthread_work+0x280/0x280
[   38.248158]  [<ffffffffb3792b98>] ret_from_fork+0x58/0x90
[   38.279982]  [<ffffffffb2d2fb60>] ? flush_kthread_work+0x280/0x280
[   38.315480] Memory state around the buggy address:
[   38.344557]  ffff8800360e7900: 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1 04 f4
[   38.386125]  ffff8800360e7980: f4 f4 f2 f2 f2 f2 04 f4 f4 f4 f2 f2 f2 f2 00 00
[   38.428978] >ffff8800360e7a00: 00 00 f2 f2 f2 f2 00 00 00 00 f3 f3 f3 f3 00 00
[   38.470442]                                                  ^
[   38.505984]  ffff8800360e7a80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   38.547465]  ffff8800360e7b00: 00 00 00 00 00 f1 f1 f1 f1 04 f4 f4 f4 f2 f2 f2
[   38.590467] ==================================================================

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 827de83..4d9cefc 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -842,7 +842,7 @@ netxen_check_options(struct netxen_adapter *adapter)
 {
 	u32 fw_major, fw_minor, fw_build, prev_fw_version;
 	char brd_name[NETXEN_MAX_SHORT_NAME];
-	char serial_num[32];
+	char serial_num[33];
 	int i, offset, val, err;
 	__le32 *ptr32;
 	struct pci_dev *pdev = adapter->pdev;
@@ -861,6 +861,7 @@ netxen_check_options(struct netxen_adapter *adapter)
 		ptr32[i] = cpu_to_le32(val);
 		offset += sizeof(u32);
 	}
+	serial_num[32] = 0;
 
 	fw_major = NXRD32(adapter, NETXEN_FW_VERSION_MAJOR);
 	fw_minor = NXRD32(adapter, NETXEN_FW_VERSION_MINOR);
-- 
2.9.3
