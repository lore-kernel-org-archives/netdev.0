From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: [PATCH 4/4] slip: remove dead code within the slip initialization
Date: Wed, 13 Jul 2011 11:47:38 +0400
Message-ID: <CAKh5naaqpjwaUUwJEkpN4g9iyQeUtZFn+XnCED4R=Ovo_hJ59A@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: matvejchikov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:47387 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab1GMHr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 03:47:58 -0400
Received: by qyk9 with SMTP id 9so3248563qyk.19
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 00:47:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This following code contains a dead "if (dev).." block:
        ...
        for (i = 0; i < slip_maxdev; i++) {
                dev = slip_devs[i];
                if (dev == NULL)
                        break;
        }
        /* Sorry, too many, all slots in use */
        if (i >= slip_maxdev)
                return NULL;

        if (dev) {
                sl = netdev_priv(dev);
                if (test_bit(SLF_INUSE, &sl->flags)) {
                        unregister_netdevice(dev);
                        dev = NULL;
                        slip_devs[i] = NULL;
                }
         }
        ...
The reason is that the code starting with "if (dev).." is never called as
when we found an empty slot (dev == NULL) we break the loop and "if (dev).."
not works eiter the loop ends and we get out with "i >= slip_maxdev".

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---
 drivers/net/slip.c |   24 ++++++------------------
 1 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 6f97c59..11c9ab3 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -723,6 +723,7 @@ static void sl_sync(void)
 static struct slip *sl_alloc(dev_t line)
 {
 	int i;
+	char name[IFNAMSIZ];
 	struct net_device *dev = NULL;
 	struct slip       *sl;

@@ -735,25 +736,12 @@ static struct slip *sl_alloc(dev_t line)
 	if (i >= slip_maxdev)
 		return NULL;

-	if (dev) {
-		sl = netdev_priv(dev);
-		if (test_bit(SLF_INUSE, &sl->flags)) {
-			unregister_netdevice(dev);
-			dev = NULL;
-			slip_devs[i] = NULL;
-		}
-	}
-
-	if (!dev) {
-		char name[IFNAMSIZ];
-		sprintf(name, "sl%d", i);
-
-		dev = alloc_netdev(sizeof(*sl), name, sl_setup);
-		if (!dev)
-			return NULL;
-		dev->base_addr  = i;
-	}
+	sprintf(name, "sl%d", i);
+	dev = alloc_netdev(sizeof(*sl), name, sl_setup);
+	if (!dev)
+		return NULL;

+	dev->base_addr  = i;
 	sl = netdev_priv(dev);

 	/* Initialize channel control data */
-- 
1.7.6
