From: Gao feng <omarapazanadi@gmail.com>
Subject: [PATCH v3] vsock: fix missing cleanup when misc_register failed
Date: Sun, 18 Oct 2015 23:35:56 +0800
Message-ID: <1445182556-24073-1-git-send-email-omarapazanadi@gmail.com>
Cc: Gao feng <omarapazanadi@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36681 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbbJRPgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 11:36:06 -0400
Received: by pacfv9 with SMTP id fv9so68658393pac.3
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 08:36:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reset transport and unlock if misc_register failed.

Signed-off-by: Gao feng <omarapazanadi@gmail.com>
---
 net/vmw_vsock/af_vsock.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index df5fc6b..00e8a34 100644
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
+err_deregister_misc:
 	misc_deregister(&vsock_device);
+err_reset_transport:
 	transport = NULL;
 err_busy:
 	mutex_unlock(&vsock_register_mutex);
-- 
2.4.3
