From: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] airo: Make /sys/bus/pci/drivers/airo/{,un}bind work
Date: Fri, 16 Mar 2007 12:44:40 +0100
Message-ID: <45FA8328.7030300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: breed-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The way airo.c keeps track of all its devices is complicated and buggy
as well (del_airo_dev forgets to free the memory add_airo_dev allocates).
It's cleaner to use the standard list primitives.
While we're at it, it's not necessary to put PCI cards in the list, because
the kernel already keeps track of them. We can take advantage of it and
use the .remove callback as it was meant to be.
This makes /sys/bus/pci/drivers/airo/{,un}bind work.

Signed-off-by: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 0d5b433..254f285 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -1145,6 +1145,7 @@ static void airo_networks_free(struct airo_info *ai);
 struct airo_info {
 	struct net_device_stats	stats;
 	struct net_device             *dev;
+	struct list_head              dev_list;
 	/* Note, we can have MAX_FIDS outstanding.  FIDs are 16-bits, so we
 	   use the high bit to mark whether it is in use. */
 #define MAX_FIDS 6
@@ -2360,6 +2361,21 @@ static int airo_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static LIST_HEAD(airo_devices);
+
+static void add_airo_dev(struct airo_info *ai)
+{
+	/* Upper layers already keep track of PCI devices,
+	 * so we only need to remember our non-PCI cards. */
+	if (!ai->pci)
+		list_add_tail(&ai->dev_list, &airo_devices);
+}
+
+static void del_airo_dev(struct airo_info *ai)
+{
+	if (!ai->pci)
+		list_del(&ai->dev_list);
+}
 
 static int airo_close(struct net_device *dev) {
 	struct airo_info *ai = dev->priv;
@@ -2381,8 +2397,6 @@ static int airo_close(struct net_device *dev) {
 	return 0;
 }
 
-static void del_airo_dev( struct net_device *dev );
-
 void stop_airo_card( struct net_device *dev, int freeres )
 {
 	struct airo_info *ai = dev->priv;
@@ -2434,14 +2448,12 @@ void stop_airo_card( struct net_device *dev, int freeres )
 		}
         }
 	crypto_free_cipher(ai->tfm);
-	del_airo_dev( dev );
+	del_airo_dev(ai);
 	free_netdev( dev );
 }
 
 EXPORT_SYMBOL(stop_airo_card);
 
-static int add_airo_dev( struct net_device *dev );
-
 static int wll_header_parse(struct sk_buff *skb, unsigned char *haddr)
 {
 	memcpy(haddr, skb->mac.raw + 10, ETH_ALEN);
@@ -2814,12 +2826,10 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	if (IS_ERR(ai->airo_thread_task))
 		goto err_out_free;
 	ai->tfm = NULL;
-	rc = add_airo_dev( dev );
-	if (rc)
-		goto err_out_thr;
+	add_airo_dev(ai);
 
 	if (airo_networks_allocate (ai))
-		goto err_out_unlink;
+		goto err_out_thr;
 	airo_networks_initialize (ai);
 
 	/* The Airo-specific entries in the device structure. */
@@ -2935,9 +2945,8 @@ err_out_irq:
 	free_irq(dev->irq, dev);
 err_out_nets:
 	airo_networks_free(ai);
-err_out_unlink:
-	del_airo_dev(dev);
 err_out_thr:
+	del_airo_dev(ai);
 	set_bit(JOB_DIE, &ai->jobs);
 	kthread_stop(ai->airo_thread_task);
 err_out_free:
@@ -5536,11 +5545,6 @@ static int proc_close( struct inode *inode, struct file *file )
 	return 0;
 }
 
-static struct net_device_list {
-	struct net_device *dev;
-	struct net_device_list *next;
-} *airo_devices;
-
 /* Since the card doesn't automatically switch to the right WEP mode,
    we will make it do it.  If the card isn't associated, every secs we
    will switch WEP modes to see if that will help.  If the card is
@@ -5583,26 +5587,6 @@ static void timer_func( struct net_device *dev ) {
 	apriv->expires = RUN_AT(HZ*3);
 }
 
-static int add_airo_dev( struct net_device *dev ) {
-	struct net_device_list *node = kmalloc( sizeof( *node ), GFP_KERNEL );
-	if ( !node )
-		return -ENOMEM;
-
-	node->dev = dev;
-	node->next = airo_devices;
-	airo_devices = node;
-
-	return 0;
-}
-
-static void del_airo_dev( struct net_device *dev ) {
-	struct net_device_list **p = &airo_devices;
-	while( *p && ( (*p)->dev != dev ) )
-		p = &(*p)->next;
-	if ( *p && (*p)->dev == dev )
-		*p = (*p)->next;
-}
-
 #ifdef CONFIG_PCI
 static int __devinit airo_pci_probe(struct pci_dev *pdev,
 				    const struct pci_device_id *pent)
@@ -5626,6 +5610,10 @@ static int __devinit airo_pci_probe(struct pci_dev *pdev,
 
 static void __devexit airo_pci_remove(struct pci_dev *pdev)
 {
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	airo_print_info(dev->name, "Unregistering...");
+	stop_airo_card(dev, 1);
 }
 
 static int airo_pci_suspend(struct pci_dev *pdev, pm_message_t state)
@@ -5751,9 +5739,11 @@ static int __init airo_init_module( void )
 
 static void __exit airo_cleanup_module( void )
 {
-	while( airo_devices ) {
-		airo_print_info(airo_devices->dev->name, "Unregistering...\n");
-		stop_airo_card( airo_devices->dev, 1 );
+	struct airo_info *ai;
+	while(!list_empty(&airo_devices)) {
+		ai = list_entry(airo_devices.next, struct airo_info, dev_list);
+		airo_print_info(ai->dev->name, "Unregistering...");
+		stop_airo_card(ai->dev, 1);
 	}
 #ifdef CONFIG_PCI
 	pci_unregister_driver(&airo_driver);
