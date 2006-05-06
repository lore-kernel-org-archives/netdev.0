From: Simon Kelley <simon@thekelleys.org.uk>
Subject: [PATCH] fix IP-over-ATM and ARP interaction.
Date: Sat, 06 May 2006 17:13:29 +0100
Message-ID: <E1FcPPN-0004xi-00@thekelleys.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpc1-cmbg4-0-0-cust914.cmbg.cable.ntl.com ([81.98.247.147]:48652
	"EHLO thekelleys.org.uk") by vger.kernel.org with ESMTP
	id S1750907AbWEFQNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 12:13:44 -0400
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The classical IP over ATM code maintains its own IPv4 <-> <ATM stuff>
ARP table, using the standard neighbour-table code. The
neigh_table_init function adds this neighbour table to a linked 
list of all neighbor tables which is used by the functions 
neigh_delete() neigh_add() and neightbl_set(), all called by 
the netlink code.

Once the ATM neighbour table is added to the list, there are two tables 
with family == AF_INET there, and  ARP entries sent via netlink go into 
the first table with matching family. This is indeterminate and often wrong.

To see the bug, on a kernel with CLIP enabled, create a standard IPv4
ARP entry by pinging an unused address on a local subnet. Then attempt
to complete that entry by doing

ip neigh replace <ip address> lladdr <some mac address> nud reachable

Looking at the ARP tables by using 

ip neigh show

will reveal two ARP entries for the same address. One of these can be
found in /proc/net/arp, and the other in /proc/net/atm/arp.

This patch adds a new function, neigh_table_init_no_netlink() which
does everything the neigh_table_init() does, except add the table to
the netlink all-arp-tables chain. In addition neigh_table_init() has a
check that all tables on the chain have a distinct address family.
The init call in clip.c is changed to call neigh_table_init_no_netlink().

Since ATM ARP tables are rather more complicated than can currently be
handled by the available rtattrs in the netlink protocol, no
functionality is lost by this patch, and non-ATM ARP manipulation via
netlink is rescued. A more complete solution would involve a rtattr for 
ATM ARP entries and some way for the netlink code to give neigh_add 
and friends more information than just address family with which to find 
the correct ARP table.

Signed-off-by: Simon Kelley <simon@thekelleys.org.uk>
 

-- 

diff -Naur linux-2.6.16.11.orig/include/net/neighbour.h linux-2.6.16.11/include/net/neighbour.h
--- linux-2.6.16.11.orig/include/net/neighbour.h	2006-04-24 21:20:24.000000000 +0100
+++ linux-2.6.16.11/include/net/neighbour.h	2006-05-04 20:09:17.000000000 +0100
@@ -211,6 +211,7 @@
 #define NEIGH_UPDATE_F_ADMIN			0x80000000
 
 extern void			neigh_table_init(struct neigh_table *tbl);
+extern void			neigh_table_init_no_netlink(struct neigh_table *tbl);
 extern int			neigh_table_clear(struct neigh_table *tbl);
 extern struct neighbour *	neigh_lookup(struct neigh_table *tbl,
 					     const void *pkey,
diff -Naur linux-2.6.16.11.orig/net/atm/clip.c linux-2.6.16.11/net/atm/clip.c
--- linux-2.6.16.11.orig/net/atm/clip.c	2006-04-24 21:20:24.000000000 +0100
+++ linux-2.6.16.11/net/atm/clip.c	2006-05-04 20:10:00.000000000 +0100
@@ -995,7 +995,7 @@
 
 static int __init atm_clip_init(void)
 {
-	neigh_table_init(&clip_tbl);
+	neigh_table_init_no_netlink(&clip_tbl);
 
 	clip_tbl_hook = &clip_tbl;
 	register_atm_ioctl(&clip_ioctl_ops);
diff -Naur linux-2.6.16.11.orig/net/core/neighbour.c linux-2.6.16.11/net/core/neighbour.c
--- linux-2.6.16.11.orig/net/core/neighbour.c	2006-04-24 21:20:24.000000000 +0100
+++ linux-2.6.16.11/net/core/neighbour.c	2006-05-04 20:07:55.000000000 +0100
@@ -1322,8 +1322,7 @@
 	kfree(parms);
 }
 
-
-void neigh_table_init(struct neigh_table *tbl)
+void neigh_table_init_no_netlink(struct neigh_table *tbl)
 {
 	unsigned long now = jiffies;
 	unsigned long phsize;
@@ -1381,10 +1380,19 @@
 
 	tbl->last_flush = now;
 	tbl->last_rand	= now + tbl->parms.reachable_time * 20;
-	write_lock(&neigh_tbl_lock);
-	tbl->next	= neigh_tables;
-	neigh_tables	= tbl;
-	write_unlock(&neigh_tbl_lock);
+}
+
+void neigh_table_init(struct neigh_table *tbl)
+{
+  struct neigh_table *tmp;
+
+  neigh_table_init_no_netlink(tbl);
+  write_lock(&neigh_tbl_lock);
+  for (tmp = neigh_tables; tmp; tmp = tmp->next)
+        BUG_ON(tmp->family == tbl->family);
+  tbl->next	= neigh_tables;
+  neigh_tables	= tbl;
+  write_unlock(&neigh_tbl_lock);
 }
 
 int neigh_table_clear(struct neigh_table *tbl)
@@ -2655,6 +2663,7 @@
 EXPORT_SYMBOL(neigh_resolve_output);
 EXPORT_SYMBOL(neigh_table_clear);
 EXPORT_SYMBOL(neigh_table_init);
+EXPORT_SYMBOL(neigh_table_init_no_netlink);
 EXPORT_SYMBOL(neigh_update);
 EXPORT_SYMBOL(neigh_update_hhs);
 EXPORT_SYMBOL(pneigh_enqueue);

