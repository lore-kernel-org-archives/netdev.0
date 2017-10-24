From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] vsock: always call vsock_init_tables()
Date: Tue, 24 Oct 2017 15:30:37 -0700
Message-ID: <20171024223037.4856-1-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Jorgen Hansen <jhansen@vmware.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:46227 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751535AbdJXWa5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 18:30:57 -0400
Received: by mail-pg0-f68.google.com with SMTP id k7so15691880pga.3
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 15:30:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although CONFIG_VSOCKETS_DIAG depends on CONFIG_VSOCKETS,
vsock_init_tables() is not always called, it is called only
if other modules call its caller. Therefore if we only
enable CONFIG_VSOCKETS_DIAG, it would crash kernel on uninitialized
vsock_bind_table.

This patch fixes it by moving vsock_init_tables() to its own
module_init().

Fixes: 413a4317aca7 ("VSOCK: add sock_diag interface")
Reported-by: syzkaller bot
Cc: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Jorgen Hansen <jhansen@vmware.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/vmw_vsock/af_vsock.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 98359c19522f..5d28abf87fbf 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -195,7 +195,7 @@ static int vsock_auto_bind(struct vsock_sock *vsk)
 	return __vsock_bind(sk, &local_addr);
 }
 
-static void vsock_init_tables(void)
+static int __init vsock_init_tables(void)
 {
 	int i;
 
@@ -204,6 +204,7 @@ static void vsock_init_tables(void)
 
 	for (i = 0; i < ARRAY_SIZE(vsock_connected_table); i++)
 		INIT_LIST_HEAD(&vsock_connected_table[i]);
+	return 0;
 }
 
 static void __vsock_insert_bound(struct list_head *list,
@@ -1957,8 +1958,6 @@ int __vsock_core_init(const struct vsock_transport *t, struct module *owner)
 	vsock_proto.owner = owner;
 	transport = t;
 
-	vsock_init_tables();
-
 	vsock_device.minor = MISC_DYNAMIC_MINOR;
 	err = misc_register(&vsock_device);
 	if (err) {
@@ -2019,6 +2018,8 @@ const struct vsock_transport *vsock_core_get_transport(void)
 }
 EXPORT_SYMBOL_GPL(vsock_core_get_transport);
 
+module_init(vsock_init_tables);
+
 MODULE_AUTHOR("VMware, Inc.");
 MODULE_DESCRIPTION("VMware Virtual Socket Family");
 MODULE_VERSION("1.0.2.0-k");
-- 
2.13.0
