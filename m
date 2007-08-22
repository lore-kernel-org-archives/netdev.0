From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH 1/1] net/core: Fix crash in dev_mc_sync()/dev_mc_unsync()
Date: Wed, 22 Aug 2007 15:21:04 +0200
Message-ID: <46CC3840.7050300@bull.net>
References: <20070821162922.149199466@frecb000701.frec.bull.fr> <20070821163129.377666902@frecb000701.frec.bull.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070503060207070101070909"
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:39725 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762190AbXHVNWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 09:22:39 -0400
In-Reply-To: <20070821163129.377666902@frecb000701.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070503060207070101070909
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed

Oops, don't use the previous version of the patch:
the change in dev_mc_unsync() was not correct.
Sorry.

This one is a lot better (it compiles and runs). :)

Benjamin
-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com

--------------070503060207070101070909
Content-Transfer-Encoding: 7bit
Content-Type: text/x-patch;
 name="Fix-crash-in-dev_mc_sync.patch"
Content-Disposition: inline;
 filename="Fix-crash-in-dev_mc_sync.patch"

From: benjamin.thery@bull.net
Subject: net/core: Fix crash in dev_mc_sync()/dev_mc_unsync()

This patch fixes a crash that may occur when the routine dev_mc_sync()
deletes an address from the list it is currently going through. It 
saves the pointer to the next element before deleting the current one.
The problem may also exist in dev_mc_unsync().

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/core/dev_mcast.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

Index: linux-2.6.23-rc2/net/core/dev_mcast.c
===================================================================
--- linux-2.6.23-rc2.orig/net/core/dev_mcast.c
+++ linux-2.6.23-rc2/net/core/dev_mcast.c
@@ -116,11 +116,13 @@ int dev_mc_add(struct net_device *dev, v
  */
 int dev_mc_sync(struct net_device *to, struct net_device *from)
 {
-	struct dev_addr_list *da;
+	struct dev_addr_list *da, *next;
 	int err = 0;
 
 	netif_tx_lock_bh(to);
-	for (da = from->mc_list; da != NULL; da = da->next) {
+	da = from->mc_list;
+	while (da != NULL) {
+		next = da->next;
 		if (!da->da_synced) {
 			err = __dev_addr_add(&to->mc_list, &to->mc_count,
 					     da->da_addr, da->da_addrlen, 0);
@@ -134,6 +136,7 @@ int dev_mc_sync(struct net_device *to, s
 			__dev_addr_delete(&from->mc_list, &from->mc_count,
 					  da->da_addr, da->da_addrlen, 0);
 		}
+		da = next;
 	}
 	if (!err)
 		__dev_set_rx_mode(to);
@@ -156,12 +159,14 @@ EXPORT_SYMBOL(dev_mc_sync);
  */
 void dev_mc_unsync(struct net_device *to, struct net_device *from)
 {
-	struct dev_addr_list *da;
+	struct dev_addr_list *da, *next;
 
 	netif_tx_lock_bh(from);
 	netif_tx_lock_bh(to);
 
-	for (da = from->mc_list; da != NULL; da = da->next) {
+	da = from->mc_list;
+	while (da != NULL) {
+		next = da->next;
 		if (!da->da_synced)
 			continue;
 		__dev_addr_delete(&to->mc_list, &to->mc_count,
@@ -169,6 +174,7 @@ void dev_mc_unsync(struct net_device *to
 		da->da_synced = 0;
 		__dev_addr_delete(&from->mc_list, &from->mc_count,
 				  da->da_addr, da->da_addrlen, 0);
+		da = next;
 	}
 	__dev_set_rx_mode(to);
 

--------------070503060207070101070909--
