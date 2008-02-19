From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/17 net-2.6.26] [IPV4]: Remove ifa != NULL check.
Date: Tue, 19 Feb 2008 10:31:21 +0300
Message-ID: <1203406297-32725-1-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:55555 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755438AbYBSHbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 02:31:16 -0500
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a callback registered to inet address notifier chain.
The check is useless as:
- ifa is always != NULL
- similar checks are abscent in all other notifiers.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 drivers/net/via-velocity.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index cc0addb..c50fdee 100644
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

