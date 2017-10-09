From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH] thunderbolt: Initialize Thunderbolt bus earlier
Date: Mon,  9 Oct 2017 16:22:34 +0300
Message-ID: <20171009132234.65540-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        kernel test robot <fengguang.wu@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 0day kbuild robot reports following crash:

  BUG: unable to handle kernel NULL pointer dereference at 00000004
  IP: tb_property_find+0xe/0x41
  *pde = 00000000
  Oops: 0000 [#1]
  CPU: 0 PID: 1 Comm: swapper Not tainted 4.14.0-rc1-00741-ge69b6c0 #412
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
  task: 89c80000 task.stack: 89c7c000
  EIP: tb_property_find+0xe/0x41
  EFLAGS: 00210246 CPU: 0
  EAX: 00000000 EBX: 7a368f47 ECX: 00000044 EDX: 7a368f47
  ESI: 8851d340 EDI: 7a368f47 EBP: 89c7df0c ESP: 89c7defc
   DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
  CR0: 80050033 CR2: 00000004 CR3: 027a2000 CR4: 00000690
  Call Trace:
   tb_register_property_dir+0x49/0xb9
   ? cdc_mbim_driver_init+0x1b/0x1b
   tbnet_init+0x77/0x9f
   ? cdc_mbim_driver_init+0x1b/0x1b
   do_one_initcall+0x7e/0x145
   ? parse_args+0x10c/0x1b3
   ? kernel_init_freeable+0xbe/0x159
   kernel_init_freeable+0xd1/0x159
   ? rest_init+0x110/0x110
   kernel_init+0xd/0xd0
   ret_from_fork+0x19/0x30

The reason is that both Thunderbolt bus and thunderbolt-net are build
into the kernel image, and the latter is linked first because
drivers/net comes before drivers/thunderbolt. Since both use
module_init() thunderbolt-net ends up calling Thunderbolt bus functions
too early triggering the above crash.

Fix this by moving Thunderbolt bus initialization to happen earlier to
make sure all the data structures are ready when Thunderbolt service
drivers are initialized. To be on the safe side also add a check for
properly initialized xdomain_property_dir to tb_register_property_dir().

Reported-by: kernel test robot <fengguang.wu@intel.com>
Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
---
Hi David,

This fixes a crash introduced in the Thunderbolt networking patches, so I'm
wondering could you take this to your net-next as well?

Thanks.

 drivers/thunderbolt/nhi.c     | 2 +-
 drivers/thunderbolt/xdomain.c | 3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/thunderbolt/nhi.c b/drivers/thunderbolt/nhi.c
index 0e79eebfcbb7..419a7a90bce0 100644
--- a/drivers/thunderbolt/nhi.c
+++ b/drivers/thunderbolt/nhi.c
@@ -1144,5 +1144,5 @@ static void __exit nhi_unload(void)
 	tb_domain_exit();
 }
 
-module_init(nhi_init);
+fs_initcall(nhi_init);
 module_exit(nhi_unload);
diff --git a/drivers/thunderbolt/xdomain.c b/drivers/thunderbolt/xdomain.c
index f2d06f6f7be9..138027537d29 100644
--- a/drivers/thunderbolt/xdomain.c
+++ b/drivers/thunderbolt/xdomain.c
@@ -1487,6 +1487,9 @@ int tb_register_property_dir(const char *key, struct tb_property_dir *dir)
 {
 	int ret;
 
+	if (WARN_ON(!xdomain_property_dir))
+		return -EAGAIN;
+
 	if (!key || strlen(key) > 8)
 		return -EINVAL;
 
-- 
2.14.2
