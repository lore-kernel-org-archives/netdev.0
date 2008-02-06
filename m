From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/17] [IPV4]: Remove ifa != NULL check.
Date: Wed,  6 Feb 2008 13:53:21 +0300
Message-ID: <1202295217-22769-1-git-send-email-den@openvz.org>
References: <47A99196.2030105@sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:53979 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757394AbYBFKxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 05:53:14 -0500
In-Reply-To: <47A99196.2030105@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a callback registered to inet address notifiers chains.
The check is useless as:
- ifa is always != NULL
- similar checks are abscent in all other notifiers.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 drivers/net/via-velocity.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 8c9fb82..7ff4509 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -3460,21 +3460,19 @@ static int velocity_resume(struct pci_dev *pdev)
 static int velocity_netdev_event(struct notifier_block *nb, unsigned long notification, void *ptr)
 {
 	struct in_ifaddr *ifa = (struct in_ifaddr *) ptr;
+	struct net_device *dev = ifa->ifa_dev->dev;
+	struct velocity_info *vptr;
+	unsigned long flags;
 
-	if (ifa) {
-		struct net_device *dev = ifa->ifa_dev->dev;
-		struct velocity_info *vptr;
-		unsigned long flags;
-
-		spin_lock_irqsave(&velocity_dev_list_lock, flags);
-		list_for_each_entry(vptr, &velocity_dev_list, list) {
-			if (vptr->dev == dev) {
-				velocity_get_ip(vptr);
-				break;
-			}
+	spin_lock_irqsave(&velocity_dev_list_lock, flags);
+	list_for_each_entry(vptr, &velocity_dev_list, list) {
+		if (vptr->dev == dev) {
+			velocity_get_ip(vptr);
+			break;
 		}
-		spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
 	}
+	spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
+
 	return NOTIFY_DONE;
 }
 
-- 
1.5.3.rc5

