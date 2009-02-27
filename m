From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH v2] net: more timeouts that reach -1
Date: Fri, 27 Feb 2009 16:16:18 +0100
Message-ID: <49A803C2.4070702@gmail.com>
References: <49A5286D.80304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:11102 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbZB0PQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 10:16:21 -0500
Received: by yw-out-2324.google.com with SMTP id 5so843998ywh.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 07:16:19 -0800 (PST)
In-Reply-To: <49A5286D.80304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin wrote:
> These were not previously reported by me.
> ------------------------------>8-------------8<---------------------------------
> with while (timeout-- > 0); timeout reaches -1 after the loop, so the tests
> below are off by one.


I just noticed that in drivers/net/ucc_geth_mii.c after my patch this still
won't give an err, because timeout is unsigned
------------------------------>8-------------8<---------------------------------
with while (timeout-- > 0); timeout reaches -1 after the loop, so the tests
below are off by one. also don't do an '< 0' test on an unsigned.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
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
index 5463591..0ada4ed 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -107,7 +107,7 @@ int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 static int uec_mdio_reset(struct mii_bus *bus)
 {
 	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
-	unsigned int timeout = PHY_INIT_TIMEOUT;
+	int timeout = PHY_INIT_TIMEOUT;
 
 	mutex_lock(&bus->mdio_lock);
 
@@ -123,7 +123,7 @@ static int uec_mdio_reset(struct mii_bus *bus)
 
 	mutex_unlock(&bus->mdio_lock);
 
-	if (timeout <= 0) {
+	if (timeout < 0) {
 		printk(KERN_ERR "%s: The MII Bus is stuck!\n", bus->name);
 		return -EBUSY;
 	}

