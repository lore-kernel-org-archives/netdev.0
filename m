From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] net: more timeouts that reach -1
Date: Wed, 25 Feb 2009 12:15:57 +0100
Message-ID: <49A5286D.80304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:28945 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760728AbZBYLQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 06:16:01 -0500
Received: by qw-out-2122.google.com with SMTP id 5so2637772qwi.37
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 03:15:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These were not previously reported by me.
------------------------------>8-------------8<---------------------------------
with while (timeout-- > 0); timeout reaches -1 after the loop, so the tests
below are off by one.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/arm/ks8695net.c |    2 +-
 drivers/net/jme.c           |    3 ++-
 drivers/net/ucc_geth_mii.c  |    2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 1cf2f94..f3a1274 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -560,7 +560,7 @@ ks8695_reset(struct ks8695_priv *ksp)
 		msleep(1);
 	}
 
-	if (reset_timeout == 0) {
+	if (reset_timeout < 0) {
 		dev_crit(ksp->dev,
 			 "Timeout waiting for DMA engines to reset\n");
 		/* And blithely carry on */
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 08b3405..0173ed0 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -957,7 +957,8 @@ jme_process_receive(struct jme_adapter *jme, int limit)
 		goto out_inc;
 
 	i = atomic_read(&rxring->next_to_clean);
-	while (limit-- > 0) {
+	while (limit > 0) {
+		limit--;
 		rxdesc = rxring->desc;
 		rxdesc += i;
 
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 5463591..7b1b46c 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -123,7 +123,7 @@ static int uec_mdio_reset(struct mii_bus *bus)
 
 	mutex_unlock(&bus->mdio_lock);
 
-	if (timeout <= 0) {
+	if (timeout < 0) {
 		printk(KERN_ERR "%s: The MII Bus is stuck!\n", bus->name);
 		return -EBUSY;
 	}
