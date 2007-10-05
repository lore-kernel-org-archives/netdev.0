From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 3/5] qeth: avoid duplicate deletion of multicast addresses
Date: Fri, 05 Oct 2007 16:45:46 +0200
Message-ID: <20071005144823.506771000@linux.vnet.ibm.com>
References: <20071005144543.448852000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:52948 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762010AbXJEOs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 10:48:27 -0400
Content-Disposition: inline; filename=709-qeth-multicast.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

if qeth_set_multicast_list() is performed on 2 CPUs in parallel,
card->ip_list may end corrupted.
Solution: In function __qeth_delete_all_mc()
          remove card->ip_list entry before invoking 
          qeth_deregister_addr_entry(). Thus a 2nd invocation of
          qeth_set_multicast_list() cannot try to remove the
          same entry twice.

Signed-off-by Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/qeth_main.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_main.c
@@ -820,14 +820,15 @@ __qeth_delete_all_mc(struct qeth_card *c
 again:
 	list_for_each_entry_safe(addr, tmp, &card->ip_list, entry) {
 		if (addr->is_multicast) {
+			list_del(&addr->entry);
 			spin_unlock_irqrestore(&card->ip_lock, *flags);
 			rc = qeth_deregister_addr_entry(card, addr);
 			spin_lock_irqsave(&card->ip_lock, *flags);
 			if (!rc) {
-				list_del(&addr->entry);
 				kfree(addr);
 				goto again;
-			}
+			} else
+				list_add(&addr->entry, &card->ip_list);
 		}
 	}
 }

-- 
