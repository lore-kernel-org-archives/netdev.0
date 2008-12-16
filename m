From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH] net: ppp_generic - use idr technique instead of cardmaps
Date: Tue, 16 Dec 2008 22:20:00 +0300
Message-ID: <20081216192000.GF26390@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:5956 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbYLPTUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 14:20:04 -0500
Received: by fg-out-1718.google.com with SMTP id 19so1458345fgg.17
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 11:20:02 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is an attempt to convert cardmaps into ird.
I would really appreciate any feedback.

I've tested ird under qemu (by some hacks not real ppp connection)
so real loadings could reveal problems with the patch - review
carefully please. (i'm not subcribed for netdev list CC me).

Any comments are _quite_ welcome! Paul?

---
From: Cyrill Gorcunov <gorcunov@openvz.org>
Date: Tue, 16 Dec 2008 19:39:08 +0300
Subject: [PATCH] net: ppp_generic - use idr technique instead of cardmaps

Use idr technique instead of own implemented cardmaps.
It saves us a number of lines and gives an ability
to use library functions.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 drivers/net/ppp_generic.c |  183 ++++++++++++---------------------------------
 1 files changed, 48 insertions(+), 135 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 1f4ca2b..293e1c4 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -27,6 +27,7 @@
 #include <linux/kmod.h>
 #include <linux/init.h>
 #include <linux/list.h>
+#include <linux/idr.h>
 #include <linux/netdevice.h>
 #include <linux/poll.h>
 #include <linux/ppp_defs.h>
@@ -171,35 +172,13 @@ struct channel {
  */
 
 /*
- * A cardmap represents a mapping from unsigned integers to pointers,
- * and provides a fast "find lowest unused number" operation.
- * It uses a broad (32-way) tree with a bitmap at each level.
- * It is designed to be space-efficient for small numbers of entries
- * and time-efficient for large numbers of entries.
- */
-#define CARDMAP_ORDER	5
-#define CARDMAP_WIDTH	(1U << CARDMAP_ORDER)
-#define CARDMAP_MASK	(CARDMAP_WIDTH - 1)
-
-struct cardmap {
-	int shift;
-	unsigned long inuse;
-	struct cardmap *parent;
-	void *ptr[CARDMAP_WIDTH];
-};
-static void *cardmap_get(struct cardmap *map, unsigned int nr);
-static int cardmap_set(struct cardmap **map, unsigned int nr, void *ptr);
-static unsigned int cardmap_find_first_free(struct cardmap *map);
-static void cardmap_destroy(struct cardmap **map);
-
-/*
  * all_ppp_mutex protects the all_ppp_units mapping.
  * It also ensures that finding a ppp unit in the all_ppp_units map
  * and updating its file.refcnt field is atomic.
  */
 static DEFINE_MUTEX(all_ppp_mutex);
-static struct cardmap *all_ppp_units;
 static atomic_t ppp_unit_count = ATOMIC_INIT(0);
+static struct idr ppp_units_idr;
 
 /*
  * all_channels_lock protects all_channels and last_channel_index,
@@ -268,6 +247,9 @@ static struct channel *ppp_find_channel(int unit);
 static int ppp_connect_channel(struct channel *pch, int unit);
 static int ppp_disconnect_channel(struct channel *pch);
 static void ppp_destroy_channel(struct channel *pch);
+static int unit_get(struct idr *p, void *ptr);
+static void unit_put(struct idr *p, int n);
+static void *unit_find(struct idr *p, int n);
 
 static struct class *ppp_class;
 
@@ -859,6 +841,8 @@ static int __init ppp_init(void)
 		device_create(ppp_class, NULL, MKDEV(PPP_MAJOR, 0), "ppp");
 	}
 
+	idr_init(&ppp_units_idr);
+
 out:
 	if (err)
 		printk(KERN_ERR "failed to register PPP device (%d)\n", err);
@@ -2431,10 +2415,22 @@ ppp_create_interface(int unit, int *retp)
 
 	ret = -EEXIST;
 	mutex_lock(&all_ppp_mutex);
-	if (unit < 0)
-		unit = cardmap_find_first_free(all_ppp_units);
-	else if (cardmap_get(all_ppp_units, unit) != NULL)
-		goto out2;	/* unit already exists */
+
+	if (unit < 0) {
+		unit = unit_get(&ppp_units_idr, ppp);
+		if (unit < 0) {
+			*retp = unit;
+			goto out2;
+		}
+	} else {
+		if (unit_find(&ppp_units_idr, unit))
+			goto out2; /* unit already exists */
+		else {
+			/* darn, someone is cheatting us? */
+			*retp = -EINVAL;
+			goto out2;
+		}
+	}
 
 	/* Initialize the new ppp unit */
 	ppp->file.index = unit;
@@ -2442,23 +2438,18 @@ ppp_create_interface(int unit, int *retp)
 
 	ret = register_netdev(dev);
 	if (ret != 0) {
+		unit_put(&ppp_units_idr, unit);
 		printk(KERN_ERR "PPP: couldn't register device %s (%d)\n",
 		       dev->name, ret);
 		goto out2;
 	}
 
 	atomic_inc(&ppp_unit_count);
-	ret = cardmap_set(&all_ppp_units, unit, ppp);
-	if (ret != 0)
-		goto out3;
-
 	mutex_unlock(&all_ppp_mutex);
+
 	*retp = 0;
 	return ppp;
 
-out3:
-	atomic_dec(&ppp_unit_count);
-	unregister_netdev(dev);
 out2:
 	mutex_unlock(&all_ppp_mutex);
 	free_netdev(dev);
@@ -2500,7 +2491,7 @@ static void ppp_shutdown_interface(struct ppp *ppp)
 		unregister_netdev(dev);
 		free_netdev(dev);
 	}
-	cardmap_set(&all_ppp_units, ppp->file.index, NULL);
+	unit_put(&ppp_units_idr, ppp->file.index);
 	ppp->file.dead = 1;
 	ppp->owner = NULL;
 	wake_up_interruptible(&ppp->file.rwait);
@@ -2554,7 +2545,7 @@ static void ppp_destroy_interface(struct ppp *ppp)
 static struct ppp *
 ppp_find_unit(int unit)
 {
-	return cardmap_get(all_ppp_units, unit);
+	return unit_find(&ppp_units_idr, unit);
 }
 
 /*
@@ -2672,123 +2663,45 @@ static void __exit ppp_cleanup(void)
 	/* should never happen */
 	if (atomic_read(&ppp_unit_count) || atomic_read(&channel_count))
 		printk(KERN_ERR "PPP: removing module but units remain!\n");
-	cardmap_destroy(&all_ppp_units);
 	unregister_chrdev(PPP_MAJOR, "ppp");
 	device_destroy(ppp_class, MKDEV(PPP_MAJOR, 0));
 	class_destroy(ppp_class);
+	idr_destroy(&ppp_units_idr);
 }
 
 /*
- * Cardmap implementation.
+ * Units handling. Caller must protect concurrent access
+ * by holding all_ppp_mutex
  */
-static void *cardmap_get(struct cardmap *map, unsigned int nr)
+
+/* get new free unit number and associate pointer with it */
+static int unit_get(struct idr *p, void *ptr)
 {
-	struct cardmap *p;
-	int i;
+	int unit, err;
 
-	for (p = map; p != NULL; ) {
-		if ((i = nr >> p->shift) >= CARDMAP_WIDTH)
-			return NULL;
-		if (p->shift == 0)
-			return p->ptr[i];
-		nr &= ~(CARDMAP_MASK << p->shift);
-		p = p->ptr[i];
+again:
+	if (idr_pre_get(p, GFP_KERNEL) == 0) {
+		printk(KERN_ERR "Out of memory expanding drawable idr\n");
+		return -ENOMEM;
 	}
-	return NULL;
-}
 
-static int cardmap_set(struct cardmap **pmap, unsigned int nr, void *ptr)
-{
-	struct cardmap *p;
-	int i;
+	err = idr_get_new_above(p, ptr, 0, &unit);
+	if (err == -EAGAIN)
+		goto again;
 
-	p = *pmap;
-	if (p == NULL || (nr >> p->shift) >= CARDMAP_WIDTH) {
-		do {
-			/* need a new top level */
-			struct cardmap *np = kzalloc(sizeof(*np), GFP_KERNEL);
-			if (!np)
-				goto enomem;
-			np->ptr[0] = p;
-			if (p != NULL) {
-				np->shift = p->shift + CARDMAP_ORDER;
-				p->parent = np;
-			} else
-				np->shift = 0;
-			p = np;
-		} while ((nr >> p->shift) >= CARDMAP_WIDTH);
-		*pmap = p;
-	}
-	while (p->shift > 0) {
-		i = (nr >> p->shift) & CARDMAP_MASK;
-		if (p->ptr[i] == NULL) {
-			struct cardmap *np = kzalloc(sizeof(*np), GFP_KERNEL);
-			if (!np)
-				goto enomem;
-			np->shift = p->shift - CARDMAP_ORDER;
-			np->parent = p;
-			p->ptr[i] = np;
-		}
-		if (ptr == NULL)
-			clear_bit(i, &p->inuse);
-		p = p->ptr[i];
-	}
-	i = nr & CARDMAP_MASK;
-	p->ptr[i] = ptr;
-	if (ptr != NULL)
-		set_bit(i, &p->inuse);
-	else
-		clear_bit(i, &p->inuse);
-	return 0;
- enomem:
-	return -ENOMEM;
+	return unit;
 }
 
-static unsigned int cardmap_find_first_free(struct cardmap *map)
+/* put unit number back to a pool */
+static void unit_put(struct idr *p, int n)
 {
-	struct cardmap *p;
-	unsigned int nr = 0;
-	int i;
-
-	if ((p = map) == NULL)
-		return 0;
-	for (;;) {
-		i = find_first_zero_bit(&p->inuse, CARDMAP_WIDTH);
-		if (i >= CARDMAP_WIDTH) {
-			if (p->parent == NULL)
-				return CARDMAP_WIDTH << p->shift;
-			p = p->parent;
-			i = (nr >> p->shift) & CARDMAP_MASK;
-			set_bit(i, &p->inuse);
-			continue;
-		}
-		nr = (nr & (~CARDMAP_MASK << p->shift)) | (i << p->shift);
-		if (p->shift == 0 || p->ptr[i] == NULL)
-			return nr;
-		p = p->ptr[i];
-	}
+	idr_remove(p, n);
 }
 
-static void cardmap_destroy(struct cardmap **pmap)
+/* get pointer associated with the number */
+static void *unit_find(struct idr *p, int n)
 {
-	struct cardmap *p, *np;
-	int i;
-
-	for (p = *pmap; p != NULL; p = np) {
-		if (p->shift != 0) {
-			for (i = 0; i < CARDMAP_WIDTH; ++i)
-				if (p->ptr[i] != NULL)
-					break;
-			if (i < CARDMAP_WIDTH) {
-				np = p->ptr[i];
-				p->ptr[i] = NULL;
-				continue;
-			}
-		}
-		np = p->parent;
-		kfree(p);
-	}
-	*pmap = NULL;
+	return idr_find(p, n);
 }
 
 /* Module/initialization stuff */
-- 
1.6.0.4.603.gbc9c0

