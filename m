From: Paul Mackerras <paulus@samba.org>
Subject: [paulus@samba.org: [PATCH] ppp: handle kmalloc failures and convert to using kzalloc]
Date: Tue, 15 Aug 2006 20:19:40 +1000
Message-ID: <17633.40892.560487.785@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="eirAWswkje"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:31976 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S965360AbWHOKTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 06:19:46 -0400
To: netdev@vger.kernel.org, takis@issaris.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--eirAWswkje
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit

Oops, forgot to cc netdev and Panagiotis Issaris...


--eirAWswkje
Content-Type: message/rfc822
Content-Description: forwarded message
Content-Transfer-Encoding: 7bit

MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Message-ID: <17633.40802.488566.572582@cargo.ozlabs.ibm.com>
X-Mailer: VM 7.19 under Emacs 21.4.1
From: Paul Mackerras <paulus@samba.org>
To: akpm@osdl.org, davem@davemloft.net
Subject: [PATCH] ppp: handle kmalloc failures and convert to using kzalloc
Date: Tue, 15 Aug 2006 20:18:10 +1000

From: Panagiotis Issaris <takis@issaris.org>

The PPP code contains two kmalloc()s followed by memset()s without
handling a possible memory allocation failure.  (Suggested by Joe
Perches).

And furthermore, conversions from kmalloc+memset to kzalloc.

[akpm@osdl.org: fix error-path leak]
[akpm@osdl.org: cleanups]
[paulus@samba.org: don't add useless printk and cardmap_destroy calls]
Signed-off-by: Panagiotis Issaris <takis@issaris.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Paul Mackerras <paulus@samba.org>
---
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 0ec6e9d..c872f7c 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
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
@@ -2454,11 +2452,16 @@ #endif /* CONFIG_PPP_MULTILINK */
 	}
 
 	atomic_inc(&ppp_unit_count);
-	cardmap_set(&all_ppp_units, unit, ppp);
+	ret = cardmap_set(&all_ppp_units, unit, ppp);
+	if (ret != 0)
+		goto out3;
+
 	mutex_unlock(&all_ppp_mutex);
 	*retp = 0;
 	return ppp;
 
+out3:
+	atomic_dec(&ppp_unit_count);
 out2:
 	mutex_unlock(&all_ppp_mutex);
 	free_netdev(dev);
@@ -2695,7 +2698,7 @@ static void *cardmap_get(struct cardmap 
 	return NULL;
 }
 
-static void cardmap_set(struct cardmap **pmap, unsigned int nr, void *ptr)
+static int cardmap_set(struct cardmap **pmap, unsigned int nr, void *ptr)
 {
 	struct cardmap *p;
 	int i;
@@ -2704,8 +2707,9 @@ static void cardmap_set(struct cardmap *
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
@@ -2719,8 +2723,9 @@ static void cardmap_set(struct cardmap *
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
@@ -2735,6 +2740,9 @@ static void cardmap_set(struct cardmap *
 		set_bit(i, &p->inuse);
 	else
 		clear_bit(i, &p->inuse);
+	return 0;
+ enomem:
+	return -ENOMEM;
 }
 
 static unsigned int cardmap_find_first_free(struct cardmap *map)

--eirAWswkje--
