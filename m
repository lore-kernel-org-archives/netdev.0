From: Asias He <asias@redhat.com>
Subject: [PATCH] VSOCK: Fix misc device registration
Date: Wed, 24 Apr 2013 14:33:52 +0800
Message-ID: <1366785232-15653-1-git-send-email-asias@redhat.com>
Cc: Asias He <asias@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy King <acking@vmware.com>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When we call vsock_core_init to init VSOCK the second time,
vsock_device.minor still points to the old dynamically allocated minor
number. misc_register will allocate it for us successfully as if we were
asking for a static one. However, when other user call misc_register to
allocate a dynamic minor number, it will give the one used by
vsock_core_init(), causing this:

  [  405.470687] WARNING: at fs/sysfs/dir.c:536 sysfs_add_one+0xcc/0xf0()
  [  405.470689] Hardware name: OptiPlex 790
  [  405.470690] sysfs: cannot create duplicate filename '/dev/char/10:54'

Always set vsock_device.minor to MISC_DYNAMIC_MINOR before we
register.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andy King <acking@vmware.com>
Cc: Dmitry Torokhov <dtor@vmware.com>
Cc: Reilly Grant <grantr@vmware.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Asias He <asias@redhat.com>
---
 net/vmw_vsock/af_vsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 7f93e2a..4b4db18 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1932,7 +1932,6 @@ static const struct file_operations vsock_device_ops = {
 
 static struct miscdevice vsock_device = {
 	.name		= "vsock",
-	.minor		= MISC_DYNAMIC_MINOR,
 	.fops		= &vsock_device_ops,
 };
 
@@ -1942,6 +1941,7 @@ static int __vsock_core_init(void)
 
 	vsock_init_tables();
 
+	vsock_device.minor = MISC_DYNAMIC_MINOR;
 	err = misc_register(&vsock_device);
 	if (err) {
 		pr_err("Failed to register misc device\n");
-- 
1.8.1.4
