From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 23/39] pcmcia: deprecate CS_OUT_OF_RESOURCE
Date: Mon, 18 Aug 2008 20:53:14 +0200
Message-ID: <1219085610-12289-23-git-send-email-linux@dominikbrodowski.net>
References: <20080818185025.GA11647@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:35892 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760846AbYHRSyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2008 14:54:02 -0400
In-Reply-To: <20080818185025.GA11647@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CS_OUT_OF_RESOURCE was almost only used to note -ENOMEM situations.
Therefore, use -ENOMEM explicitely, and also print out warnings.

CC: netdev@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/smc91c92_cs.c |    4 +-
 drivers/pcmcia/cistpl.c          |   43 +++++++++++++++++++++++--------------
 drivers/pcmcia/pcmcia_resource.c |    2 +-
 drivers/pcmcia/rsrc_nonstatic.c  |   32 ++++++++++++++++-----------
 include/pcmcia/cs.h              |    2 +-
 5 files changed, 50 insertions(+), 33 deletions(-)

diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index e508b47..191788d 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -488,7 +488,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 
     cfg_mem = kmalloc(sizeof(struct smc_cfg_mem), GFP_KERNEL);
     if (!cfg_mem)
-        return CS_OUT_OF_RESOURCE;
+	    return -ENOMEM;
 
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
@@ -687,7 +687,7 @@ static int smc_setup(struct pcmcia_device *link)
 
     cfg_mem = kmalloc(sizeof(struct smc_cfg_mem), GFP_KERNEL);
     if (!cfg_mem)
-	return CS_OUT_OF_RESOURCE;
+	    return -ENOMEM;
 
     tuple = &cfg_mem->tuple;
     parse = &cfg_mem->parse;
diff --git a/drivers/pcmcia/cistpl.c b/drivers/pcmcia/cistpl.c
index eb182c6..180252b 100644
--- a/drivers/pcmcia/cistpl.c
+++ b/drivers/pcmcia/cistpl.c
@@ -352,7 +352,9 @@ int verify_cis_cache(struct pcmcia_socket *s)
 
 	buf = kmalloc(256, GFP_KERNEL);
 	if (buf == NULL)
-		return -1;
+		dev_printk(KERN_WARNING, &s->dev,
+			   "no memory for verifying CIS\n");
+		return -ENOMEM;
 	list_for_each_entry(cis, &s->cis_cache, node) {
 		int len = cis->len;
 
@@ -384,15 +386,19 @@ int verify_cis_cache(struct pcmcia_socket *s)
 int pcmcia_replace_cis(struct pcmcia_socket *s,
 		       const u8 *data, const size_t len)
 {
-    if (len > CISTPL_MAX_CIS_SIZE)
-	return CS_BAD_SIZE;
-    kfree(s->fake_cis);
-    s->fake_cis = kmalloc(len, GFP_KERNEL);
-    if (s->fake_cis == NULL)
-	return CS_OUT_OF_RESOURCE;
-    s->fake_cis_len = len;
-    memcpy(s->fake_cis, data, len);
-    return 0;
+	if (len > CISTPL_MAX_CIS_SIZE) {
+		dev_printk(KERN_WARNING, &s->dev, "replacement CIS too big\n");
+		return -EINVAL;
+	}
+	kfree(s->fake_cis);
+	s->fake_cis = kmalloc(len, GFP_KERNEL);
+	if (s->fake_cis == NULL) {
+		dev_printk(KERN_WARNING, &s->dev, "no memory to replace CIS\n");
+		return -ENOMEM;
+	}
+	s->fake_cis_len = len;
+	memcpy(s->fake_cis, data, len);
+	return 0;
 }
 EXPORT_SYMBOL(pcmcia_replace_cis);
 
@@ -1411,8 +1417,10 @@ int pccard_read_tuple(struct pcmcia_socket *s, unsigned int function, cisdata_t
     int ret;
 
     buf = kmalloc(256, GFP_KERNEL);
-    if (buf == NULL)
-	return CS_OUT_OF_RESOURCE;
+    if (buf == NULL) {
+	    dev_printk(KERN_WARNING, &s->dev, "no memory to read tuple\n");
+	    return -ENOMEM;
+    }
     tuple.DesiredTuple = code;
     tuple.Attributes = TUPLE_RETURN_COMMON;
     ret = pccard_get_first_tuple(s, function, &tuple);
@@ -1450,12 +1458,15 @@ int pccard_validate_cis(struct pcmcia_socket *s, unsigned int function, unsigned
 	return CS_BAD_HANDLE;
 
     tuple = kmalloc(sizeof(*tuple), GFP_KERNEL);
-    if (tuple == NULL)
-	return CS_OUT_OF_RESOURCE;
+    if (tuple == NULL) {
+	    dev_printk(KERN_WARNING, &s->dev, "no memory to validate CIS\n");
+	    return -ENOMEM;
+    }
     p = kmalloc(sizeof(*p), GFP_KERNEL);
     if (p == NULL) {
-	kfree(tuple);
-	return CS_OUT_OF_RESOURCE;
+	    kfree(tuple);
+	    dev_printk(KERN_WARNING, &s->dev, "no memory to validate CIS\n");
+	    return -ENOMEM;
     }
 
     count = reserved = 0;
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 78a81e8..9115747 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -778,7 +778,7 @@ int pcmcia_request_window(struct pcmcia_device **p_dev, win_req_t *req, window_h
 	for (w = 0; w < MAX_WIN; w++)
 		if (!(s->state & SOCKET_WIN_REQ(w))) break;
 	if (w == MAX_WIN)
-		return CS_OUT_OF_RESOURCE;
+		return CS_IN_USE;
 
 	win = &s->win[w];
 	win->magic = WINDOW_MAGIC;
diff --git a/drivers/pcmcia/rsrc_nonstatic.c b/drivers/pcmcia/rsrc_nonstatic.c
index 6b417e1..aecf755 100644
--- a/drivers/pcmcia/rsrc_nonstatic.c
+++ b/drivers/pcmcia/rsrc_nonstatic.c
@@ -122,19 +122,22 @@ static void free_region(struct resource *res)
 
 static int add_interval(struct resource_map *map, u_long base, u_long num)
 {
-    struct resource_map *p, *q;
+	struct resource_map *p, *q;
 
-    for (p = map; ; p = p->next) {
-	if ((p != map) && (p->base+p->num-1 >= base))
-	    return -1;
-	if ((p->next == map) || (p->next->base > base+num-1))
-	    break;
-    }
-    q = kmalloc(sizeof(struct resource_map), GFP_KERNEL);
-    if (!q) return CS_OUT_OF_RESOURCE;
-    q->base = base; q->num = num;
-    q->next = p->next; p->next = q;
-    return 0;
+	for (p = map; ; p = p->next) {
+		if ((p != map) && (p->base+p->num-1 >= base))
+			return -1;
+		if ((p->next == map) || (p->next->base > base+num-1))
+			break;
+	}
+	q = kmalloc(sizeof(struct resource_map), GFP_KERNEL);
+	if (!q) {
+		printk(KERN_WARNING "out of memory to update resources\n");
+		return -ENOMEM;
+	}
+	q->base = base; q->num = num;
+	q->next = p->next; p->next = q;
+	return 0;
 }
 
 /*====================================================================*/
@@ -166,7 +169,10 @@ static int sub_interval(struct resource_map *map, u_long base, u_long num)
 	    } else {
 		/* Split the block into two pieces */
 		p = kmalloc(sizeof(struct resource_map), GFP_KERNEL);
-		if (!p) return CS_OUT_OF_RESOURCE;
+		if (!p) {
+		    printk(KERN_WARNING "out of memory to update resources\n");
+		    return -ENOMEM;
+		}
 		p->base = base+num;
 		p->num = q->base+q->num - p->base;
 		q->num = base - q->base;
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index 695baf6..9e6916c 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -316,7 +316,7 @@ typedef struct error_info_t {
 #define CS_CONFIGURATION_LOCKED	0x1d
 #define CS_IN_USE		0x1e
 #define CS_NO_MORE_ITEMS	0x1f
-#define CS_OUT_OF_RESOURCE	0x20
+#define CS_OUT_OF_RESOURCE	-ENOMEM
 #define CS_BAD_HANDLE		0x21
 
 #define CS_BAD_TUPLE		0x40
-- 
1.5.4.3

