From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][4 of 7][ATM]: change atm address functions to use list_add
Date: Tue, 18 Jan 2005 14:08:14 -0500
Message-ID: <200501181908.j0IJ8Efe022365@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/07 15:04:51-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: change atm address functions to use list_add
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/resources.c
#   2005/01/07 15:04:34-05:00 chas@relax.cmf.nrl.navy.mil +1 -0
#   [ATM]: change atm address functions to use list_add
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/addr.c
#   2005/01/07 15:04:33-05:00 chas@relax.cmf.nrl.navy.mil +43 -50
#   [ATM]: change atm address functions to use list_add
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# include/linux/atmdev.h
#   2005/01/07 15:04:33-05:00 chas@relax.cmf.nrl.navy.mil +2 -2
#   [ATM]: change atm address functions to use list_add
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	2005-01-14 08:43:06 -05:00
+++ b/include/linux/atmdev.h	2005-01-14 08:43:06 -05:00
@@ -313,7 +313,7 @@
 
 struct atm_dev_addr {
 	struct sockaddr_atmsvc addr;	/* ATM address */
-	struct atm_dev_addr *next;	/* next address */
+	struct list_head entry;		/* next address */
 };
 
 struct atm_dev {
@@ -325,7 +325,7 @@
 	void		*dev_data;	/* per-device data */
 	void		*phy_data;	/* private PHY date */
 	unsigned long	flags;		/* device flags (ATM_DF_*) */
-	struct atm_dev_addr *local;	/* local ATM addresses */
+	struct list_head local;		/* local ATM addresses */
 	unsigned char	esi[ESI_LEN];	/* ESI ("MAC" addr) */
 	struct atm_cirange ci_range;	/* VPI/VCI range */
 	struct k_atm_dev_stats stats;	/* statistics */
diff -Nru a/net/atm/addr.c b/net/atm/addr.c
--- a/net/atm/addr.c	2005-01-14 08:43:06 -05:00
+++ b/net/atm/addr.c	2005-01-14 08:43:06 -05:00
@@ -2,7 +2,6 @@
 
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
 
-
 #include <linux/atm.h>
 #include <linux/atmdev.h>
 #include <linux/sched.h>
@@ -11,127 +10,121 @@
 #include "signaling.h"
 #include "addr.h"
 
-
 static int check_addr(struct sockaddr_atmsvc *addr)
 {
 	int i;
 
-	if (addr->sas_family != AF_ATMSVC) return -EAFNOSUPPORT;
+	if (addr->sas_family != AF_ATMSVC)
+		return -EAFNOSUPPORT;
 	if (!*addr->sas_addr.pub)
 		return *addr->sas_addr.prv ? 0 : -EINVAL;
-	for (i = 1; i < ATM_E164_LEN+1; i++) /* make sure it's \0-terminated */
-		if (!addr->sas_addr.pub[i]) return 0;
+	for (i = 1; i < ATM_E164_LEN + 1; i++)	/* make sure it's \0-terminated */
+		if (!addr->sas_addr.pub[i])
+			return 0;
 	return -EINVAL;
 }
 
-
-static int identical(struct sockaddr_atmsvc *a,struct sockaddr_atmsvc *b)
+static int identical(struct sockaddr_atmsvc *a, struct sockaddr_atmsvc *b)
 {
 	if (*a->sas_addr.prv)
-		if (memcmp(a->sas_addr.prv,b->sas_addr.prv,ATM_ESA_LEN))
+		if (memcmp(a->sas_addr.prv, b->sas_addr.prv, ATM_ESA_LEN))
 			return 0;
-	if (!*a->sas_addr.pub) return !*b->sas_addr.pub;
-	if (!*b->sas_addr.pub) return 0;
-	return !strcmp(a->sas_addr.pub,b->sas_addr.pub);
+	if (!*a->sas_addr.pub)
+		return !*b->sas_addr.pub;
+	if (!*b->sas_addr.pub)
+		return 0;
+	return !strcmp(a->sas_addr.pub, b->sas_addr.pub);
 }
 
-
 static void notify_sigd(struct atm_dev *dev)
 {
 	struct sockaddr_atmpvc pvc;
 
 	pvc.sap_addr.itf = dev->number;
-	sigd_enq(NULL,as_itf_notify,NULL,&pvc,NULL);
+	sigd_enq(NULL, as_itf_notify, NULL, &pvc, NULL);
 }
 
-
 void atm_reset_addr(struct atm_dev *dev)
 {
 	unsigned long flags;
-	struct atm_dev_addr *this;
+	struct atm_dev_addr *this, *p;
 
 	spin_lock_irqsave(&dev->lock, flags);
-	while (dev->local) {
-		this = dev->local;
-		dev->local = this->next;
-		kfree(this);
-	}
+	list_for_each_entry_safe(this, p, &dev->local, entry)
+	    kfree(this);
 	spin_unlock_irqrestore(&dev->lock, flags);
 	notify_sigd(dev);
 }
 
-
-int atm_add_addr(struct atm_dev *dev,struct sockaddr_atmsvc *addr)
+int atm_add_addr(struct atm_dev *dev, struct sockaddr_atmsvc *addr)
 {
 	unsigned long flags;
-	struct atm_dev_addr **walk;
+	struct atm_dev_addr *this;
 	int error;
 
 	error = check_addr(addr);
 	if (error)
 		return error;
 	spin_lock_irqsave(&dev->lock, flags);
-	for (walk = &dev->local; *walk; walk = &(*walk)->next)
-		if (identical(&(*walk)->addr,addr)) {
+	list_for_each_entry(this, &dev->local, entry) {
+		if (identical(&this->addr, addr)) {
 			spin_unlock_irqrestore(&dev->lock, flags);
 			return -EEXIST;
 		}
-	*walk = kmalloc(sizeof(struct atm_dev_addr), GFP_ATOMIC);
-	if (!*walk) {
+	}
+	this = kmalloc(sizeof(struct atm_dev_addr), GFP_ATOMIC);
+	if (!this) {
 		spin_unlock_irqrestore(&dev->lock, flags);
 		return -ENOMEM;
 	}
-	(*walk)->addr = *addr;
-	(*walk)->next = NULL;
+	this->addr = *addr;
+	list_add(&this->entry, &dev->local);
 	spin_unlock_irqrestore(&dev->lock, flags);
 	notify_sigd(dev);
 	return 0;
 }
 
-
-int atm_del_addr(struct atm_dev *dev,struct sockaddr_atmsvc *addr)
+int atm_del_addr(struct atm_dev *dev, struct sockaddr_atmsvc *addr)
 {
 	unsigned long flags;
-	struct atm_dev_addr **walk,*this;
+	struct atm_dev_addr *this;
 	int error;
 
 	error = check_addr(addr);
 	if (error)
 		return error;
 	spin_lock_irqsave(&dev->lock, flags);
-	for (walk = &dev->local; *walk; walk = &(*walk)->next)
-		if (identical(&(*walk)->addr,addr)) break;
-	if (!*walk) {
-		spin_unlock_irqrestore(&dev->lock, flags);
-		return -ENOENT;
+	list_for_each_entry(this, &dev->local, entry) {
+		if (identical(&this->addr, addr)) {
+			list_del(&this->entry);
+			spin_unlock_irqrestore(&dev->lock, flags);
+			kfree(this);
+			notify_sigd(dev);
+			return 0;
+		}
 	}
-	this = *walk;
-	*walk = this->next;
-	kfree(this);
 	spin_unlock_irqrestore(&dev->lock, flags);
-	notify_sigd(dev);
-	return 0;
+	return -ENOENT;
 }
 
-
-int atm_get_addr(struct atm_dev *dev,struct sockaddr_atmsvc __user *buf,int size)
+int atm_get_addr(struct atm_dev *dev, struct sockaddr_atmsvc __user * buf,
+		 int size)
 {
 	unsigned long flags;
-	struct atm_dev_addr *walk;
+	struct atm_dev_addr *this;
 	int total = 0, error;
 	struct sockaddr_atmsvc *tmp_buf, *tmp_bufp;
 
-
 	spin_lock_irqsave(&dev->lock, flags);
-	for (walk = dev->local; walk; walk = walk->next)
-		total += sizeof(struct sockaddr_atmsvc);
+	list_for_each_entry(this, &dev->local, entry)
+	    total += sizeof(struct sockaddr_atmsvc);
 	tmp_buf = tmp_bufp = kmalloc(total, GFP_ATOMIC);
 	if (!tmp_buf) {
 		spin_unlock_irqrestore(&dev->lock, flags);
 		return -ENOMEM;
 	}
-	for (walk = dev->local; walk; walk = walk->next)
-		memcpy(tmp_bufp++, &walk->addr, sizeof(struct sockaddr_atmsvc));
+	list_for_each_entry(this, &dev->local, entry)
+	    memcpy(tmp_bufp++, &this->addr, sizeof(struct sockaddr_atmsvc));
 	spin_unlock_irqrestore(&dev->lock, flags);
 	error = total > size ? -E2BIG : total;
 	if (copy_to_user(buf, tmp_buf, total < size ? total : size))
diff -Nru a/net/atm/resources.c b/net/atm/resources.c
--- a/net/atm/resources.c	2005-01-14 08:43:06 -05:00
+++ b/net/atm/resources.c	2005-01-14 08:43:06 -05:00
@@ -38,6 +38,7 @@
 	dev->signal = ATM_PHY_SIG_UNKNOWN;
 	dev->link_rate = ATM_OC3_PCR;
 	spin_lock_init(&dev->lock);
+	INIT_LIST_HEAD(&dev->local);
 
 	return dev;
 }
