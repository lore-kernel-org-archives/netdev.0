From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 29/41] CAPI: Clean up capiminors_lock
Date: Mon,  8 Feb 2010 21:12:33 +0100
Message-ID: <58614af3fac044b20683a4d3789b33c5337b586c.1265659936.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a plain spin lock for capiminors_lock, drop inconsistent irqsafe
acquisitions (it's only used in process context anyway).

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index cf5e996..0b264b4 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -149,7 +149,7 @@ static LIST_HEAD(capidev_list);
 
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 
-static DEFINE_RWLOCK(capiminors_lock);
+static DEFINE_SPINLOCK(capiminors_lock);
 static struct capiminor **capiminors;
 
 static struct tty_driver *capinc_tty_driver;
@@ -218,7 +218,6 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 	struct capiminor *mp;
 	struct device *dev;
 	unsigned int minor;
-	unsigned long flags;
 
 	mp = kzalloc(sizeof(*mp), GFP_KERNEL);
   	if (!mp) {
@@ -242,13 +241,13 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 	mp->port.ops = &capiminor_port_ops;
 
 	/* Allocate the least unused minor number. */
-	write_lock_irqsave(&capiminors_lock, flags);
+	spin_lock(&capiminors_lock);
 	for (minor = 0; minor < capi_ttyminors; minor++)
 		if (!capiminors[minor]) {
 			capiminors[minor] = mp;
 			break;
 		}
-	write_unlock_irqrestore(&capiminors_lock, flags);
+	spin_unlock(&capiminors_lock);
 
 	if (minor == capi_ttyminors) {
 		printk(KERN_NOTICE "capi: out of minors\n");
@@ -264,9 +263,9 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 	return mp;
 
 err_out2:
-	write_lock_irqsave(&capiminors_lock, flags);
+	spin_lock(&capiminors_lock);
 	capiminors[minor] = NULL;
-	write_unlock_irqrestore(&capiminors_lock, flags);
+	spin_unlock(&capiminors_lock);
 
 err_out1:
 	kfree(mp);
@@ -288,11 +287,11 @@ static struct capiminor *capiminor_get(unsigned int minor)
 {
 	struct capiminor *mp;
 
-	read_lock(&capiminors_lock);
+	spin_lock(&capiminors_lock);
 	mp = capiminors[minor];
 	if (mp)
 		kref_get(&mp->kref);
-	read_unlock(&capiminors_lock);
+	spin_unlock(&capiminors_lock);
 
 	return mp;
 }
@@ -304,13 +303,11 @@ static inline void capiminor_put(struct capiminor *mp)
 
 static void capiminor_free(struct capiminor *mp)
 {
-	unsigned long flags;
-
 	tty_unregister_device(capinc_tty_driver, mp->minor);
 
-	write_lock_irqsave(&capiminors_lock, flags);
+	spin_lock(&capiminors_lock);
 	capiminors[mp->minor] = NULL;
-	write_unlock_irqrestore(&capiminors_lock, flags);
+	spin_unlock(&capiminors_lock);
 
 	capiminor_put(mp);
 }
-- 
1.6.0.2
