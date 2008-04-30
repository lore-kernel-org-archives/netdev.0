From: Bruce Robson <bns_robson@hotmail.com>
Subject: [PATCH] drivers/net  EtherExpress 16 : IPv6 not working with this
 driver
Date: Wed, 30 Apr 2008 19:39:45 +0100
Message-ID: <4818BCF1.9030100@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Philip Blundell <philb@gnu.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bnsrobson.cjb.net ([82.69.45.180]:44637 "EHLO
	advance9.bnsrobson.cjb.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764200AbYD3TWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 15:22:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Robson <bns_robson@hotmail.com>

Corrects loading of multi-cast addresses.
Thereby allowing IPv6 neighbour discovery to work.

Signed-off-by: Bruce Robson <bns_robson@hotmail.com>

---

The driver sources file eexpress.c contains an approximately 30 line
function eexp_setup_filter used when loading multicast addresses.
There were 3 problems in this function
1)  It wrote the number of multicast addresses to the card instead
    of the number of bytes in the multicast addresses.
2)  When loading multiple multicast addresses it loaded the first
    one provided multiple times instead of loading each one once.
3)  The setting of pointer 'data' from 'dmi->dmi_addr' occured before
    the test for the error situation of 'dmi' being NULL.

There is some information on the Intel EtherExpress 16 at
http://www.intel.com/support/etherexpress/vintage/sb/cs-013500.htm
Datasheet for the Intel 82586 ethernet controller used by the card
http://www.datasheetcatalog.com/datasheets_pdf/8/2/5/8/82586.shtml


--- drivers/net/eexpress.c.000	2008-01-24 22:58:37.000000000 +0000
+++ drivers/net/eexpress.c	2008-04-30 00:17:51.000000000 +0100
@@ -201,9 +201,9 @@ static unsigned short start_code[] = {
 
 	0x0000,Cmd_MCast,
 	0x0076,                 /* link to next command */
 #define CONF_NR_MULTICAST 0x44
-	0x0000,                 /* number of multicast addresses */
+	0x0000,                 /* number of bytes in multicast address(es) */
 #define CONF_MULTICAST 0x46
 	0x0000, 0x0000, 0x0000, /* some addresses */
 	0x0000, 0x0000, 0x0000,
 	0x0000, 0x0000, 0x0000,
@@ -1568,9 +1568,9 @@ static void eexp_hw_init586(struct net_d
 }
 
 static void eexp_setup_filter(struct net_device *dev)
 {
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	unsigned short ioaddr = dev->base_addr;
 	int count = dev->mc_count;
 	int i;
 	if (count > 8) {
@@ -1579,19 +1579,20 @@ static void eexp_setup_filter(struct net
 		count = 8;
 	}
 
 	outw(CONF_NR_MULTICAST & ~31, ioaddr+SM_PTR);
-	outw(count, ioaddr+SHADOW(CONF_NR_MULTICAST));
-	for (i = 0; i < count; i++) {
-		unsigned short *data = (unsigned short *)dmi->dmi_addr;
+	outw(6*count, ioaddr+SHADOW(CONF_NR_MULTICAST));
+	for (i = 0, dmi = dev->mc_list; i < count; i++, dmi = dmi->next) {
+		unsigned short *data;
 		if (!dmi) {
 			printk(KERN_INFO "%s: too few multicast addresses\n", dev->name);
 			break;
 		}
 		if (dmi->dmi_addrlen != ETH_ALEN) {
 			printk(KERN_INFO "%s: invalid multicast address length given.\n", dev->name);
 			continue;
 		}
+		data = (unsigned short *)dmi->dmi_addr;
 		outw((CONF_MULTICAST+(6*i)) & ~31, ioaddr+SM_PTR);
 		outw(data[0], ioaddr+SHADOW(CONF_MULTICAST+(6*i)));
 		outw((CONF_MULTICAST+(6*i)+2) & ~31, ioaddr+SM_PTR);
 		outw(data[1], ioaddr+SHADOW(CONF_MULTICAST+(6*i)+2));
