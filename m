From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH] i825xx: fix paging fault on znet_probe()
Date: Sun, 2 Sep 2012 15:25:46 +0800
Message-ID: <20120902072546.GA20290@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37022 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755154Ab2IBH0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2012 03:26:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In znet_probe(), strncmp() may access beyond 0x100000 and
trigger the below oops in kvm.  Fix it by limiting the loop
under 0x100000-8. I suspect the limit could be further decreased
to 0x100000-sizeof(struct netidblk), however no datasheet at hand..

[    3.744312] BUG: unable to handle kernel paging request at 80100000
[    3.746145] IP: [<8119d12a>] strncmp+0xc/0x20
[    3.747446] *pde = 01d10067 *pte = 00100160 
[    3.747493] Oops: 0000 [#1] DEBUG_PAGEALLOC
[    3.747493] Pid: 1, comm: swapper Not tainted 3.6.0-rc1-00018-g57bfc0a #73 Bochs Bochs
[    3.747493] EIP: 0060:[<8119d12a>] EFLAGS: 00010206 CPU: 0
[    3.747493] EIP is at strncmp+0xc/0x20
[    3.747493] EAX: 800fff4e EBX: 00000006 ECX: 00000006 EDX: 814d2bb9
[    3.747493] ESI: 80100000 EDI: 814d2bba EBP: 8e03dfa0 ESP: 8e03df98
[    3.747493]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
[    3.747493] CR0: 8005003b CR2: 80100000 CR3: 016f7000 CR4: 00000690
[    3.747493] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[    3.747493] DR6: ffff0ff0 DR7: 00000400
[    3.747493] Process swapper (pid: 1, ti=8e03c000 task=8e040000 task.ti=8e03c000)
[    3.747493] Stack:
[    3.747493]  800fffff 00000000 8e03dfb4 816a1376 00000006 816a134a 00000000 8e03dfd0
[    3.747493]  816819b5 816ed1c0 8e03dfe4 00000006 00000123 816ed604 8e03dfe4 81681b29
[    3.747493]  00000000 81681a5b 00000000 00000000 8134e542 00000000 00000000 00000000
[    3.747493] Call Trace:
[    3.747493]  [<816a1376>] znet_probe+0x2c/0x26b                             
[    3.747493]  [<816a134a>] ? dnet_driver_init+0xf/0xf                        
[    3.747493]  [<816819b5>] do_one_initcall+0x6a/0x110                        
[    3.747493]  [<81681b29>] kernel_init+0xce/0x14b                            

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 drivers/net/ethernet/i825xx/znet.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--- linux.orig/drivers/net/ethernet/i825xx/znet.c	2012-05-24 19:03:06.928430941 +0800
+++ linux/drivers/net/ethernet/i825xx/znet.c	2012-09-02 15:14:24.943249546 +0800
@@ -139,8 +139,11 @@ struct znet_private {
 /* Only one can be built-in;-> */
 static struct net_device *znet_dev;
 
+#define NETIDBLK_MAGIC		"NETIDBLK"
+#define NETIDBLK_MAGIC_SIZE	8
+
 struct netidblk {
-	char magic[8];		/* The magic number (string) "NETIDBLK" */
+	char magic[NETIDBLK_MAGIC_SIZE];	/* The magic number (string) "NETIDBLK" */
 	unsigned char netid[8]; /* The physical station address */
 	char nettype, globalopt;
 	char vendor[8];		/* The machine vendor and product name. */
@@ -373,14 +376,16 @@ static int __init znet_probe (void)
 	struct znet_private *znet;
 	struct net_device *dev;
 	char *p;
+	char *plast = phys_to_virt(0x100000 - NETIDBLK_MAGIC_SIZE);
 	int err = -ENOMEM;
 
 	/* This code scans the region 0xf0000 to 0xfffff for a "NETIDBLK". */
-	for(p = (char *)phys_to_virt(0xf0000); p < (char *)phys_to_virt(0x100000); p++)
-		if (*p == 'N'  &&  strncmp(p, "NETIDBLK", 8) == 0)
+	for(p = (char *)phys_to_virt(0xf0000); p <= plast; p++)
+		if (*p == 'N' &&
+		    strncmp(p, NETIDBLK_MAGIC, NETIDBLK_MAGIC_SIZE) == 0)
 			break;
 
-	if (p >= (char *)phys_to_virt(0x100000)) {
+	if (p > plast) {
 		if (znet_debug > 1)
 			printk(KERN_INFO "No Z-Note ethernet adaptor found.\n");
 		return -ENODEV;
