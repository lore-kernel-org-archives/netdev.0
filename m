From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [nicstar] using dev_alloc_skb() (reported by "Johnston, Jayme" <Jayme.Johnston@siemens.com>)
Date: Wed, 07 Apr 2004 08:11:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404071211.i37CB3gK020805@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

the nicstar driver has typically used alloc_skb() to get its i/o buffers.
since these buffers are likely to be passed to the network stack at some
point it should probably be using dev_alloc_skb().  this patches fixes
a crash during pppoatm operation when an unchecked skb_push() operates on
a buffer returned by the nicstar.

please apply to 2.6 and 2.4 kernels (and if at all possible could
i get this in the soon to be released 2.4.26 kernel?)

thanks!

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1331.3.2 -> 1.1331.3.3
#	drivers/atm/nicstar.c	1.14    -> 1.15   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/04/06	chas@relax.cmf.nrl.navy.mil	1.1331.3.3
# [ATM]: [nicstar] using dev_alloc_skb() (reported by "Johnston, Jayme" <Jayme.Johnston@siemens.com>)
# --------------------------------------------
#
diff -Nru a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
--- a/drivers/atm/nicstar.c	Wed Apr  7 08:02:14 2004
+++ b/drivers/atm/nicstar.c	Wed Apr  7 08:02:14 2004
@@ -760,7 +760,7 @@
    for (j = 0; j < NUM_HB; j++)
    {
       struct sk_buff *hb;
-      hb = alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
+      hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
       if (hb == NULL)
       {
          printk("nicstar%d: can't allocate %dth of %d huge buffers.\n",
@@ -780,7 +780,7 @@
    for (j = 0; j < NUM_LB; j++)
    {
       struct sk_buff *lb;
-      lb = alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
+      lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
       if (lb == NULL)
       {
          printk("nicstar%d: can't allocate %dth of %d large buffers.\n",
@@ -816,7 +816,7 @@
    for (j = 0; j < NUM_SB; j++)
    {
       struct sk_buff *sb;
-      sb = alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
+      sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
       if (sb == NULL)
       {
          printk("nicstar%d: can't allocate %dth of %d small buffers.\n",
@@ -1318,7 +1318,7 @@
              card->index);
       for (i = 0; i < card->sbnr.min; i++)
       {
-         sb = alloc_skb(NS_SMSKBSIZE, GFP_ATOMIC);
+         sb = dev_alloc_skb(NS_SMSKBSIZE);
          if (sb == NULL)
          {
             writel(readl(card->membase + CFG) & ~NS_CFG_EFBIE, card->membase + CFG);
@@ -1344,7 +1344,7 @@
              card->index);
       for (i = 0; i < card->lbnr.min; i++)
       {
-         lb = alloc_skb(NS_LGSKBSIZE, GFP_ATOMIC);
+         lb = dev_alloc_skb(NS_LGSKBSIZE);
          if (lb == NULL)
          {
             writel(readl(card->membase + CFG) & ~NS_CFG_EFBIE, card->membase + CFG);
@@ -2167,7 +2167,7 @@
       cell = skb->data;
       for (i = ns_rsqe_cellcount(rsqe); i; i--)
       {
-         if ((sb = alloc_skb(NS_SMSKBSIZE, GFP_ATOMIC)) == NULL)
+         if ((sb = dev_alloc_skb(NS_SMSKBSIZE)) == NULL)
          {
             printk("nicstar%d: Can't allocate buffers for aal0.\n",
                    card->index);
@@ -2399,7 +2399,7 @@
          if (hb == NULL)		/* No buffers in the queue */
          {
 
-            hb = alloc_skb(NS_HBUFSIZE, GFP_ATOMIC);
+            hb = dev_alloc_skb(NS_HBUFSIZE);
             if (hb == NULL)
             {
                printk("nicstar%d: Out of huge buffers.\n", card->index);
@@ -2413,7 +2413,7 @@
             else if (card->hbpool.count < card->hbnr.min)
 	    {
                struct sk_buff *new_hb;
-               if ((new_hb = alloc_skb(NS_HBUFSIZE, GFP_ATOMIC)) != NULL)
+               if ((new_hb = dev_alloc_skb(NS_HBUFSIZE)) != NULL)
                {
                   skb_queue_tail(&card->hbpool.queue, new_hb);
                   card->hbpool.count++;
@@ -2424,14 +2424,14 @@
          if (--card->hbpool.count < card->hbnr.min)
          {
             struct sk_buff *new_hb;
-            if ((new_hb = alloc_skb(NS_HBUFSIZE, GFP_ATOMIC)) != NULL)
+            if ((new_hb = dev_alloc_skb(NS_HBUFSIZE)) != NULL)
             {
                skb_queue_tail(&card->hbpool.queue, new_hb);
                card->hbpool.count++;
             }
             if (card->hbpool.count < card->hbnr.min)
 	    {
-               if ((new_hb = alloc_skb(NS_HBUFSIZE, GFP_ATOMIC)) != NULL)
+               if ((new_hb = dev_alloc_skb(NS_HBUFSIZE)) != NULL)
                {
                   skb_queue_tail(&card->hbpool.queue, new_hb);
                   card->hbpool.count++;
@@ -2513,7 +2513,7 @@
 
    do
    {
-      sb = alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
+      sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
       if (sb == NULL)
          break;
       skb_queue_tail(&card->sbpool.queue, sb);
@@ -2536,7 +2536,7 @@
 
    do
    {
-      lb = alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
+      lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
       if (lb == NULL)
          break;
       skb_queue_tail(&card->lbpool.queue, lb);
@@ -2555,7 +2555,7 @@
 
    while (card->hbpool.count < card->hbnr.init)
    {
-      hb = alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
+      hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
       if (hb == NULL)
          break;
       skb_queue_tail(&card->hbpool.queue, hb);
@@ -2627,7 +2627,7 @@
    if (card->sbfqc < card->sbnr.init)
    {
       struct sk_buff *new_sb;
-      if ((new_sb = alloc_skb(NS_SMSKBSIZE, GFP_ATOMIC)) != NULL)
+      if ((new_sb = dev_alloc_skb(NS_SMSKBSIZE)) != NULL)
       {
          skb_queue_tail(&card->sbpool.queue, new_sb);
          skb_reserve(new_sb, NS_AAL0_HEADER);
@@ -2639,7 +2639,7 @@
 #endif /* NS_USE_DESTRUCTORS */
    {
       struct sk_buff *new_sb;
-      if ((new_sb = alloc_skb(NS_SMSKBSIZE, GFP_ATOMIC)) != NULL)
+      if ((new_sb = dev_alloc_skb(NS_SMSKBSIZE)) != NULL)
       {
          skb_queue_tail(&card->sbpool.queue, new_sb);
          skb_reserve(new_sb, NS_AAL0_HEADER);
@@ -2660,7 +2660,7 @@
    if (card->lbfqc < card->lbnr.init)
    {
       struct sk_buff *new_lb;
-      if ((new_lb = alloc_skb(NS_LGSKBSIZE, GFP_ATOMIC)) != NULL)
+      if ((new_lb = dev_alloc_skb(NS_LGSKBSIZE)) != NULL)
       {
          skb_queue_tail(&card->lbpool.queue, new_lb);
          skb_reserve(new_lb, NS_SMBUFSIZE);
@@ -2672,7 +2672,7 @@
 #endif /* NS_USE_DESTRUCTORS */
    {
       struct sk_buff *new_lb;
-      if ((new_lb = alloc_skb(NS_LGSKBSIZE, GFP_ATOMIC)) != NULL)
+      if ((new_lb = dev_alloc_skb(NS_LGSKBSIZE)) != NULL)
       {
          skb_queue_tail(&card->lbpool.queue, new_lb);
          skb_reserve(new_lb, NS_SMBUFSIZE);
@@ -2866,7 +2866,7 @@
 	       {
                   struct sk_buff *sb;
 
-                  sb = alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
+                  sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
                   if (sb == NULL)
                      return -ENOMEM;
                   skb_queue_tail(&card->sbpool.queue, sb);
@@ -2880,7 +2880,7 @@
 	       {
                   struct sk_buff *lb;
 
-                  lb = alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
+                  lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
                   if (lb == NULL)
                      return -ENOMEM;
                   skb_queue_tail(&card->lbpool.queue, lb);
@@ -2909,7 +2909,7 @@
                {
                   struct sk_buff *hb;
 
-                  hb = alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
+                  hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
                   if (hb == NULL)
                      return -ENOMEM;
                   ns_grab_int_lock(card, flags);
