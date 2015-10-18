From: Gao feng <omarapazanadi@gmail.com>
Subject: [PATCH v2] vsock: fix missing cleanup when misc_register failed
Date: Sun, 18 Oct 2015 22:27:42 +0800
Message-ID: <1445178462-19856-1-git-send-email-omarapazanadi@gmail.com>
Cc: Gao feng <omarapazanadi@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33036 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020AbbJRO1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 10:27:49 -0400
Received: by pabrc13 with SMTP id rc13so164702072pab.0
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 07:27:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reset transport and unlock if misc_register failed.

Signed-off-by: Gao feng <omarapazanadi@gmail.com>
---
 net/vmw_vsock/af_vsock.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index df5fc6b..598e045 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1948,13 +1948,13 @@ int __vsock_core_init(const struct vsock_transport *t, struct module *owner)
 	err = misc_register(&vsock_device);
 	if (err) {
 		pr_err("Failed to register misc device\n");
-		return -ENOENT;
+		goto err_reset_transport;
 	}
 
 	err = proto_register(&vsock_proto, 1);	/* we want our slab */
 	if (err) {
 		pr_err("Cannot register vsock protocol\n");
-		goto err_misc_deregister;
+		goto err_deregister_misc;
 	}
 
 	err = sock_register(&vsock_family_ops);
@@ -1969,8 +1969,9 @@ int __vsock_core_init(const struct vsock_transport *t, struct module *owner)
 
 err_unregister_proto:
 	proto_unregister(&vsock_proto);
-err_misc_deregister:
+err_undegister_misc:
 	misc_deregister(&vsock_device);
+err_reset_transport:
 	transport = NULL;
 err_busy:
 	mutex_unlock(&vsock_register_mutex);
-- 
2.4.3
