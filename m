From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax: fix oops in wimax_dev_get_by_genl_info() when looking up non-wimax iface
Date: Thu, 12 Feb 2009 15:04:52 -0800
Message-ID: <1234479892-23695-1-git-send-email-inaky@linux.intel.com>
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:11613 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759261AbZBLXEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 18:04:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a non-wimax interface is looked up by the stack, a bad pointer is
returned when the looked-up interface is not found in the list (of
registered WiMAX interfaces). This causes an oops in the caller when
trying to use the pointer.

Fix by properly setting the pointer to NULL if we don't exit from the
list_for_each() with a found entry.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/id-table.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/wimax/id-table.c b/net/wimax/id-table.c
index 5e685f7..72273ab 100644
--- a/net/wimax/id-table.c
+++ b/net/wimax/id-table.c
@@ -94,12 +94,13 @@ struct wimax_dev *wimax_dev_get_by_genl_info(
 	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node) {
 		if (wimax_dev->net_dev->ifindex == ifindex) {
 			dev_hold(wimax_dev->net_dev);
-			break;
+			goto found;
 		}
 	}
-	if (wimax_dev == NULL)
-		d_printf(1, NULL, "wimax: no devices found with ifindex %d\n",
-			 ifindex);
+	wimax_dev = NULL;
+	d_printf(1, NULL, "wimax: no devices found with ifindex %d\n",
+		 ifindex);
+found:
 	spin_unlock(&wimax_id_table_lock);
 	d_fnend(3, NULL, "(info %p ifindex %d) = %p\n",
 		info, ifindex, wimax_dev);
-- 
1.5.6.5

