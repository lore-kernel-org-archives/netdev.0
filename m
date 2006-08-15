From: akpm@osdl.org
Subject: [patch 03/13] ppp: handle kmalloc() failures
Date: Mon, 14 Aug 2006 23:03:38 -0700
Message-ID: <200608150603.k7F63chF012930@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, takis@issaris.org,
	paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44691 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965163AbWHOGDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:03:48 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Panagiotis Issaris <takis@issaris.org>

The PPP code contains two kmalloc()s followed by memset()s without handling a
possible memory allocation failure.  (Suggested by Joe Perches).

And furthermore, conversions from kmalloc+memset to kzalloc.

[akpm@osdl.org: fix error-path leak]
[akpm@osdl.org: cleanups]
Signed-off-by: Panagiotis Issaris <takis@issaris.org>
Cc: Paul Mackerras <paulus@samba.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/ppp_generic.c |   33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff -puN drivers/net/ppp_generic.c~ppp-handle-kmalloc-failures drivers/net/ppp_generic.c
--- a/drivers/net/ppp_generic.c~ppp-handle-kmalloc-failures
+++ a/drivers/net/ppp_generic.c
@@ -192,7 +192,7 @@ struct cardmap {
 	void *ptr[CARDMAP_WIDTH];
 };
 static void *cardmap_get(struct cardmap *map, unsigned int nr);
-static void cardmap_set(struct cardmap **map, unsigned int nr, void *ptr);
+static int cardmap_set(struct cardmap **map, unsigned int nr, void *ptr);
 static unsigned int cardmap_find_first_free(struct cardmap *map);
 static void cardmap_destroy(struct cardmap **map);
 
@@ -1995,10 +1995,9 @@ ppp_register_channel(struct ppp_channel 
 {
 	struct channel *pch;
 
-	pch = kmalloc(sizeof(struct channel), GFP_KERNEL);
+	pch = kzalloc(sizeof(struct channel), GFP_KERNEL);
 	if (pch == 0)
 		return -ENOMEM;
-	memset(pch, 0, sizeof(struct channel));
 	pch->ppp = NULL;
 	pch->chan = chan;
 	chan->ppp = pch;
@@ -2408,13 +2407,12 @@ ppp_create_interface(int unit, int *retp
 	int ret = -ENOMEM;
 	int i;
 
-	ppp = kmalloc(sizeof(struct ppp), GFP_KERNEL);
+	ppp = kzalloc(sizeof(struct ppp), GFP_KERNEL);
 	if (!ppp)
 		goto out;
 	dev = alloc_netdev(0, "", ppp_setup);
 	if (!dev)
 		goto out1;
-	memset(ppp, 0, sizeof(struct ppp));
 
 	ppp->mru = PPP_MRU;
 	init_ppp_file(&ppp->file, INTERFACE);
@@ -2454,11 +2452,18 @@ ppp_create_interface(int unit, int *retp
 	}
 
 	atomic_inc(&ppp_unit_count);
-	cardmap_set(&all_ppp_units, unit, ppp);
+	ret = cardmap_set(&all_ppp_units, unit, ppp);
+	if (ret != 0) {
+		printk(KERN_ERR "PPP: couldn't set cardmap\n");
+		goto out3;
+	}
+
 	mutex_unlock(&all_ppp_mutex);
 	*retp = 0;
 	return ppp;
 
+out3:
+	atomic_dec(&ppp_unit_count);
 out2:
 	mutex_unlock(&all_ppp_mutex);
 	free_netdev(dev);
@@ -2695,7 +2700,7 @@ static void *cardmap_get(struct cardmap 
 	return NULL;
 }
 
-static void cardmap_set(struct cardmap **pmap, unsigned int nr, void *ptr)
+static int cardmap_set(struct cardmap **pmap, unsigned int nr, void *ptr)
 {
 	struct cardmap *p;
 	int i;
@@ -2704,8 +2709,9 @@ static void cardmap_set(struct cardmap *
 	if (p == NULL || (nr >> p->shift) >= CARDMAP_WIDTH) {
 		do {
 			/* need a new top level */
-			struct cardmap *np = kmalloc(sizeof(*np), GFP_KERNEL);
-			memset(np, 0, sizeof(*np));
+			struct cardmap *np = kzalloc(sizeof(*np), GFP_KERNEL);
+			if (!np)
+				goto enomem;
 			np->ptr[0] = p;
 			if (p != NULL) {
 				np->shift = p->shift + CARDMAP_ORDER;
@@ -2719,8 +2725,9 @@ static void cardmap_set(struct cardmap *
 	while (p->shift > 0) {
 		i = (nr >> p->shift) & CARDMAP_MASK;
 		if (p->ptr[i] == NULL) {
-			struct cardmap *np = kmalloc(sizeof(*np), GFP_KERNEL);
-			memset(np, 0, sizeof(*np));
+			struct cardmap *np = kzalloc(sizeof(*np), GFP_KERNEL);
+			if (!np)
+				goto enomem;
 			np->shift = p->shift - CARDMAP_ORDER;
 			np->parent = p;
 			p->ptr[i] = np;
@@ -2735,6 +2742,10 @@ static void cardmap_set(struct cardmap *
 		set_bit(i, &p->inuse);
 	else
 		clear_bit(i, &p->inuse);
+	return 0;
+enomem:
+	cardmap_destroy(pmap);
+	return -ENOMEM;
 }
 
 static unsigned int cardmap_find_first_free(struct cardmap *map)
_
