From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 1/1] NET: wan/x25_asy, move lapb_unregister to x25_asy_close_tty
Date: Thu, 25 Nov 2010 00:54:54 +0100
Message-ID: <1290642894-4577-1-git-send-email-jslaby@suse.cz>
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	Andrew Hendry <andrew.hendry@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We register lapb when tty is created, but unregister it only when the
device is UP. So move the lapb_unregister to x25_asy_close_tty after
the device is down.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Reported-by: Sergey Lapin <slapin@ossfans.org>
Cc: Andrew Hendry <andrew.hendry@gmail.com>
---
 drivers/net/wan/x25_asy.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 66cda25..24297b2 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -498,7 +498,6 @@ norbuff:
 static int x25_asy_close(struct net_device *dev)
 {
 	struct x25_asy *sl = netdev_priv(dev);
-	int err;
 
 	spin_lock(&sl->lock);
 	if (sl->tty)
@@ -507,10 +506,6 @@ static int x25_asy_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	sl->rcount = 0;
 	sl->xleft  = 0;
-	err = lapb_unregister(dev);
-	if (err != LAPB_OK)
-		printk(KERN_ERR "x25_asy_close: lapb_unregister error -%d\n",
-			err);
 	spin_unlock(&sl->lock);
 	return 0;
 }
@@ -595,6 +590,7 @@ static int x25_asy_open_tty(struct tty_struct *tty)
 static void x25_asy_close_tty(struct tty_struct *tty)
 {
 	struct x25_asy *sl = tty->disc_data;
+	int err;
 
 	/* First make sure we're connected. */
 	if (!sl || sl->magic != X25_ASY_MAGIC)
@@ -605,6 +601,11 @@ static void x25_asy_close_tty(struct tty_struct *tty)
 		dev_close(sl->dev);
 	rtnl_unlock();
 
+	err = lapb_unregister(sl->dev);
+	if (err != LAPB_OK)
+		printk(KERN_ERR "x25_asy_close: lapb_unregister error -%d\n",
+			err);
+
 	tty->disc_data = NULL;
 	sl->tty = NULL;
 	x25_asy_free(sl);
-- 
1.7.3.1
