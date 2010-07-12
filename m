From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH v2] depca: fix leaks in depca_module_init()
Date: Mon, 12 Jul 2010 18:52:33 +0400
Message-ID: <20100712145233.GA30504@albatros>
References: <1278678986-7725-1-git-send-email-segooon@gmail.com>
 <20100711.181300.58435799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, jpirko@redhat.com,
	joe@perches.com, shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59794 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755814Ab0GLOxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 10:53:03 -0400
Content-Disposition: inline
In-Reply-To: <20100711.181300.58435799.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since some of xxx_register_driver() can return error we must unregister
already registered drivers.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/depca.c |   29 +++++++++++++++++++++++------
 1 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index bf66e9b..44c0694 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -2061,18 +2061,35 @@ static int depca_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 static int __init depca_module_init (void)
 {
-        int err = 0;
+	int err = 0;
 
 #ifdef CONFIG_MCA
-        err = mca_register_driver (&depca_mca_driver);
+	err = mca_register_driver(&depca_mca_driver);
+	if (err)
+		goto err;
 #endif
 #ifdef CONFIG_EISA
-        err |= eisa_driver_register (&depca_eisa_driver);
+	err = eisa_driver_register(&depca_eisa_driver);
+	if (err)
+		goto err_mca;
 #endif
-	err |= platform_driver_register (&depca_isa_driver);
-	depca_platform_probe ();
+	err = platform_driver_register(&depca_isa_driver);
+	if (err)
+		goto err_eisa;
 
-        return err;
+	depca_platform_probe();
+	return 0;
+
+err_eisa:
+#ifdef CONFIG_EISA
+	eisa_driver_unregister(&depca_eisa_driver);
+err_mca:
+#endif
+#ifdef CONFIG_MCA
+	mca_unregister_driver(&depca_mca_driver);
+err:
+#endif
+	return err;
 }
 
 static void __exit depca_module_exit (void)
-- 
1.7.0.4

