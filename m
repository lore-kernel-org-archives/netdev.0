From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] trivial -- skfp_probe should be static
Date: Wed, 15 Oct 2003 12:23:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015122348.6453c0f0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

skfp_probe used to be called from Space.c but isn't any more.
Therefore it no longer needs to be global.  All the calls to insert_device()
pass skfp_probe as a second arg, so just use it directly.

Jeff, this also is janitor type stuff, so just put it in net-2.5-exp

diff -Nru a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
--- a/drivers/net/skfp/skfddi.c	Wed Oct 15 12:19:23 2003
+++ b/drivers/net/skfp/skfddi.c	Wed Oct 15 12:19:23 2003
@@ -106,14 +106,9 @@
 #include	"h/smtstate.h"
 
 
-// Define global routines
-int skfp_probe(struct net_device *dev);
-
-
 // Define module-wide (static) routines
 static struct net_device *alloc_device(struct net_device *dev, u_long iobase);
-static struct net_device *insert_device(struct net_device *dev,
-				    int (*init) (struct net_device *));
+static struct net_device *insert_device(struct net_device *dev);
 static int fddi_dev_index(unsigned char *s);
 static void init_dev(struct net_device *dev, u_long iobase);
 static void link_modules(struct net_device *dev, struct net_device *tmp);
@@ -259,7 +254,7 @@
  *   initialized and the board resources are read and stored in
  *   the device structure.
  */
-int skfp_probe(struct net_device *dev)
+static int skfp_probe(struct net_device *dev)
 {
 	int i;			/* used in for loops */
 	struct pci_dev *pdev = NULL;	/* PCI device structure */
@@ -453,7 +448,7 @@
 	num_fddi = fddi_dev_index(dev->name);
 	if (loading_module) {
 		num_fddi++;
-		dev = insert_device(dev, skfp_probe);
+		dev = insert_device(dev);
 		return dev;
 	}
 	while (1) {
@@ -484,7 +479,7 @@
 				     (dev->base_addr != 0)) && !fixed) ||
 	    new_dev) {
 		num_fddi++;	/* New device */
-		dev = insert_device(dev, skfp_probe);
+		dev = insert_device(dev);
 	}
 	if (dev) {
 		if (!dev->priv) {
@@ -550,8 +545,7 @@
  * one up. If memory could not be allocated, print an error message.
  *
 ************************/
-static struct net_device *insert_device(struct net_device *dev,
-				    int (*init) (struct net_device *))
+static struct net_device *insert_device(struct net_device *dev)
 {
 	struct net_device *new;
 	int len;
@@ -566,7 +560,7 @@
 	} else {
 		memset((char *) new, 0, len);
 		new->priv = (struct s_smc *) (new + 1);
-		new->init = init;	/* initialisation routine */
+		new->init = skfp_probe;
 		if (!loading_module) {
 			new->next = dev->next;
 			dev->next = new;
@@ -2545,7 +2539,7 @@
 {
 	struct net_device *p;
 
-	if ((mdev = insert_device(NULL, skfp_probe)) == NULL)
+	if ((mdev = insert_device(NULL)) == NULL)
 		return -ENOMEM;
 
 	for (p = mdev; p != NULL; p = ((struct s_smc *)p->priv)->os.next_module) {
