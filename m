From: akpm@linux-foundation.org
Subject: [patch 5/5] IPv6 to Intel EtherExpress 16 fails - multicast problems
Date: Fri, 02 May 2008 13:40:53 -0700
Message-ID: <200805022040.m42KesxY013686@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	bns_robson@hotmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49993 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933823AbYEBUle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 16:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Robson <bns_robson@hotmail.com>

Taken from http://bugzilla.kernel.org/show_bug.cgi?id=10577

I was unable to access a computer containing an Intel EtherExpress 16 network
card using IPv6.

I traced this to failure of neighbour discovery.  When I used an "ip -6 neigh
add" command, on the computer attempting access, to insert a binding between
the IPv6 address of the computer with the Intel EtherExpress 16 network card
and the card's ethernet address, I was able to access that computer using
IPv6.

Neighbour discovery requires working multicast.  The driver sources file
eexpress.c contains an approximately 30 line function eexp_setup_filter used
when loading multicast addresses.

I found 3 problems in this function

1) It wrote the number of multicast addresses to the card instead of the
    number of bytes in the multicast addresses.

2) When loading multiple multicast addresses it loaded the first one
    provided multiple times instead of loading each one once.

3) The setting of pointer 'data' from 'dmi->dmi_addr' occured before the
    test for the error situation of 'dmi' being NULL.

Correcting these problems allows the computer with the Intel EtherExpress 16
network card to found by IPv6 neighbour discovery.

p.s. There is some information on the Intel EtherExpress 16 at
http://www.intel.com/support/etherexpress/vintage/sb/cs-013500.htm
Datasheet for the Intel 82586 ethernet controller used by the card
http://www.datasheetcatalog.com/datasheets_pdf/8/2/5/8/82586.shtml

Signed-off-by: Bruce Robson <bns_robson@hotmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/eexpress.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff -puN drivers/net/eexpress.c~ipv6-to-intel-etherexpress-16-fails-multicast-problems drivers/net/eexpress.c
--- a/drivers/net/eexpress.c~ipv6-to-intel-etherexpress-16-fails-multicast-problems
+++ a/drivers/net/eexpress.c
@@ -202,7 +202,7 @@ static unsigned short start_code[] = {
 	0x0000,Cmd_MCast,
 	0x0076,                 /* link to next command */
 #define CONF_NR_MULTICAST 0x44
-	0x0000,                 /* number of multicast addresses */
+	0x0000,                 /* number of bytes in multicast address(es) */
 #define CONF_MULTICAST 0x46
 	0x0000, 0x0000, 0x0000, /* some addresses */
 	0x0000, 0x0000, 0x0000,
@@ -1569,7 +1569,7 @@ static void eexp_hw_init586(struct net_d
 
 static void eexp_setup_filter(struct net_device *dev)
 {
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	unsigned short ioaddr = dev->base_addr;
 	int count = dev->mc_count;
 	int i;
@@ -1580,9 +1580,9 @@ static void eexp_setup_filter(struct net
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
@@ -1591,6 +1591,7 @@ static void eexp_setup_filter(struct net
 			printk(KERN_INFO "%s: invalid multicast address length given.\n", dev->name);
 			continue;
 		}
+		data = (unsigned short *)dmi->dmi_addr;
 		outw((CONF_MULTICAST+(6*i)) & ~31, ioaddr+SM_PTR);
 		outw(data[0], ioaddr+SHADOW(CONF_MULTICAST+(6*i)));
 		outw((CONF_MULTICAST+(6*i)+2) & ~31, ioaddr+SM_PTR);
_
