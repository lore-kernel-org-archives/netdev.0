From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net] msi: free msi_desc entry only after we've released the kobject
Date: Mon, 16 Sep 2013 19:09:56 +0200
Message-ID: <1379351396-6458-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Bjorn Helgaas <bhelgaas@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40375 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751025Ab3IPRJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 13:09:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we first do kobject_put(&entry->kobj) and the kfree(entry),
however kobject_put() doesn't guarantee us that it was the last reference
and that the kobj isn't used currently by someone else, so after we
kfree(entry) with the struct kobject - other users will begin using the
freed memory, instead of the actual kobject.

Fix this by using the kobject->release callback, which is called last when
the kobject is indeed not used and is cleaned up - it's msi_kobj_release(),
which can do the kfree(entry) safely (kobject_put/cleanup doesn't use the
kobj itself after ->release() was called, so we're safe).

Also, in case we've failed to create the sysfs directories - just kfree()
it - cause we don't have the kobjects attached.

CC: Neil Horman <nhorman@tuxdriver.com>
CC: Russell King <rmk+kernel@arm.linux.org.uk>
CC: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    This patch is really an RFC, and I don't know for sure how to correctly
    fix it, however it seems to work. Sorry if I've done something horribly
    wrong, it really seems to work ok :).
    
    I've hit the bug with the recent CONFIG_DEBUG_KOBJECT_RELEASE - it basically
    delays the cleanup a bit - so that the chances are a lot higher even for
    one user to hit it.
    
    Or, maybe, it will be better to just add an kobject helper
    kobject_wait_cleanup(), which will return only after it's indeed free? I'm
    really not sure.

 drivers/pci/msi.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index b35f93c..6eabf93 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -395,6 +395,7 @@ static void free_msi_irqs(struct pci_dev *dev)
 			if (list_is_last(&entry->list, &dev->msi_list))
 				iounmap(entry->mask_base);
 		}
+		list_del(&entry->list);
 
 		/*
 		 * Its possible that we get into this path
@@ -405,10 +406,9 @@ static void free_msi_irqs(struct pci_dev *dev)
 		if (entry->kobj.parent) {
 			kobject_del(&entry->kobj);
 			kobject_put(&entry->kobj);
+		} else {
+			kfree(entry);
 		}
-
-		list_del(&entry->list);
-		kfree(entry);
 	}
 }
 
@@ -531,6 +531,7 @@ static void msi_kobj_release(struct kobject *kobj)
 	struct msi_desc *entry = to_msi_desc(kobj);
 
 	pci_dev_put(entry->dev);
+	kfree(entry);
 }
 
 static struct kobj_type msi_irq_ktype = {
-- 
1.8.4
