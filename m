From: Nathan Lynch <ntl@pobox.com>
Subject: [PATCH] ehea: use get_zeroed_page for alignment-sensitive allocation
Date: Mon, 22 Dec 2008 12:42:11 -0600
Message-ID: <20081222184211.GV6958@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes.hering@linux.vnet.ibm.com, linuxppc-dev@ozlabs.org,
	raisch@de.ibm.com, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, osstklei@de.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-sasl-fastnet.sasl.smtp.pobox.com ([207.106.133.19]:59390 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbYLVSmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 13:42:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With slub debug enabled, I see the following errors and crash with
2.6.28-rc9:

IBM eHEA ethernet device driver (Release EHEA_0095)
ehea: Error in ehea_h_register_rpage_mr: not on pageboundary
ehea: Error in ehea_reg_mr_section: register_rpage_mr failed
ehea: Error in ehea_reg_kernel_mr: registering mr failed
ehea: Error in ehea_setup_ports: creating MR failed
ehea 23c00100.lhea: setup_ports failed
Unable to handle kernel paging request for data at address 0x6b6b6b6b6b6bbdcb
Faulting instruction address: 0xd000000000064a24
cpu 0x0: Vector: 300 (Data Access) at [c0000000740e7190]
    pc: d000000000064a24: .ehea_update_firmware_handles+0x84/0x47c [ehea]
    lr: d00000000006df34: .ehea_probe_adapter+0x35c/0x39c [ehea]
    sp: c0000000740e7410
   msr: 8000000000009032
   dar: 6b6b6b6b6b6bbdcb
 dsisr: 40000000
  current = 0xc000000074233780
  paca    = 0xc0000000008a3300
    pid   = 2046, comm = modprobe
enter ? for help
[c0000000740e74f0] d00000000006df34 .ehea_probe_adapter+0x35c/0x39c [ehea]
[c0000000740e75a0] c00000000041d5a4 .of_platform_device_probe+0x78/0xb0
[c0000000740e7630] c0000000002d8b38 .driver_probe_device+0x13c/0x200
[c0000000740e76c0] c0000000002d8c90 .__driver_attach+0x94/0xd8
[c0000000740e7750] c0000000002d7d64 .bus_for_each_dev+0x80/0xd8
[c0000000740e7800] c0000000002d889c .driver_attach+0x28/0x40
[c0000000740e7880] c0000000002d8340 .bus_add_driver+0xd4/0x284
[c0000000740e7920] c0000000002d90a0 .driver_register+0xc4/0x198
[c0000000740e79d0] c00000000041d45c .of_register_driver+0x4c/0x60
[c0000000740e7a50] c000000000020ef8 .ibmebus_register_driver+0x30/0x4c
[c0000000740e7ae0] d00000000006e108 .ehea_module_init+0x194/0x208c [ehea]
[c0000000740e7b90] c000000000009028 .do_one_initcall+0x90/0x1ac
[c0000000740e7d90] c00000000008619c .sys_init_module+0xc4/0x200
[c0000000740e7e30] c0000000000084ac syscall_exit+0x0/0x40

(When slub debug is disabled it works fine.)

PAGE_SIZE allocations via slab are not guaranteed to be page-aligned;
use get_zeroed_page for the 'pt' buffer (I don't really know what this
is, only that it is passed to firmware and that the first error
message complains about its alignment).  This allows the system to
boot.

Signed-off-by: Nathan Lynch <ntl@pobox.com>
---
 drivers/net/ehea/ehea_qmr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

By the way, there are several other kzalloc(PAGE_SIZE) call sites in
this driver; are they also making assumptions about alignment?

diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index 9d00687..b7b0937 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -893,7 +893,7 @@ int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 
 	unsigned long top;
 
-	pt = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	pt = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!pt) {
 		ehea_error("no mem");
 		ret = -ENOMEM;
@@ -937,7 +937,7 @@ int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 	mr->adapter = adapter;
 	ret = 0;
 out:
-	kfree(pt);
+	free_page((unsigned long)pt);
 	return ret;
 }
 
-- 
1.5.5

