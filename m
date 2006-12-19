From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] via-velocity uses INET interfaces
Date: Mon, 18 Dec 2006 21:21:10 -0800
Message-ID: <20061218212110.45afff00.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet02.oracle.com ([141.146.126.229]:63706 "EHLO
	agminet02.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbWLSF2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 00:28:35 -0500
Received: from agminet01.oracle.com (agminet01.oracle.com [141.146.126.228])
	by agminet02.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id kBJ5SX8v014323
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 Dec 2006 23:28:33 -0600
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

via-velocity doesn't build when CONFIG_INET=n:

drivers/built-in.o: In function `velocity_unregister_notifier':
via-velocity.c:(.text+0xe9b46): undefined reference to `unregister_inetaddr_notifier'
drivers/built-in.o: In function `velocity_init_module':
via-velocity.c:(.init.text+0xa027): undefined reference to `register_inetaddr_notifier'

I wanted to make this change in drivers/net/Kconfig, but
this isn't legal kconfig language:

 config VIA_VELOCITY
        tristate "VIA Velocity support"
        depends on NET_PCI && PCI
+       depends on INET if PM
        select CRC32
        select CRC_CCITT
        select MII

so fix it in via-velocity.c instead.
Builds with all 4 combinations of CONFIG_NET & CONFIG_PM.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/via-velocity.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

--- linux-2620-rc1g4.orig/drivers/net/via-velocity.c
+++ linux-2620-rc1g4/drivers/net/via-velocity.c
@@ -265,15 +265,19 @@ static int velocity_set_media_mode(struc
 static int velocity_suspend(struct pci_dev *pdev, pm_message_t state);
 static int velocity_resume(struct pci_dev *pdev);
 
+static DEFINE_SPINLOCK(velocity_dev_list_lock);
+static LIST_HEAD(velocity_dev_list);
+
+#endif
+
+#if defined(CONFIG_PM) && defined(CONFIG_INET)
+
 static int velocity_netdev_event(struct notifier_block *nb, unsigned long notification, void *ptr);
 
 static struct notifier_block velocity_inetaddr_notifier = {
       .notifier_call	= velocity_netdev_event,
 };
 
-static DEFINE_SPINLOCK(velocity_dev_list_lock);
-static LIST_HEAD(velocity_dev_list);
-
 static void velocity_register_notifier(void)
 {
 	register_inetaddr_notifier(&velocity_inetaddr_notifier);
@@ -284,12 +288,12 @@ static void velocity_unregister_notifier
 	unregister_inetaddr_notifier(&velocity_inetaddr_notifier);
 }
 
-#else				/* CONFIG_PM */
+#else
 
 #define velocity_register_notifier()	do {} while (0)
 #define velocity_unregister_notifier()	do {} while (0)
 
-#endif				/* !CONFIG_PM */
+#endif
 
 /*
  *	Internal board variants. At the moment we have only one
@@ -3292,6 +3296,8 @@ static int velocity_resume(struct pci_de
 	return 0;
 }
 
+#ifdef CONFIG_INET
+
 static int velocity_netdev_event(struct notifier_block *nb, unsigned long notification, void *ptr)
 {
 	struct in_ifaddr *ifa = (struct in_ifaddr *) ptr;
@@ -3312,4 +3318,6 @@ static int velocity_netdev_event(struct 
 	}
 	return NOTIFY_DONE;
 }
+
+#endif
 #endif


---
