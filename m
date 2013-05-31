From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH v2 net 3/6] net/core: __hw_addr_sync_one / _multiple broken
Date: Fri, 31 May 2013 14:57:28 -0700
Message-ID: <1370037451-29466-4-git-send-email-fubar@us.ibm.com>
References: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:60915 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017Ab3EaV5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 17:57:55 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 31 May 2013 17:57:54 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 3AB0EC90044
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 17:57:50 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4VLvo7m290778
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 17:57:50 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4VLvnXM025655
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 18:57:50 -0300
In-Reply-To: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Currently, __hw_addr_sync_one is called in a loop by
__hw_addr_sync_multiple to sync each of a "from" device's hw addresses
to a "to" device.  __hw_addr_sync_one calls __hw_addr_add_ex to attempt
to add each address.  __hw_addr_add_ex is called with global=false, and
sync=true.

	__hw_addr_add_ex checks to see if the new address matches an
address already on the list.  If so, it tests global and sync.  In this
case, sync=true, and it then checks if the address is already synced,
and if so, returns 0.

	This 0 return causes __hw_addr_sync_one to increment the sync_cnt
and refcount for the "from" list's address entry, even though the address
is already synced and has a reference and sync_cnt.  This will cause
the sync_cnt and refcount to increment without bound every time an
addresses is added to the "from" device and synced to the "to" device.

	The fix here has two parts:

	First, when __hw_addr_add_ex finds the address already exists
and is synced, return -EEXIST instead of 0.

	Second, __hw_addr_sync_one checks the error return for -EEXIST,
and if so, it (a) does not add a refcount/sync_cnt, and (b) returns 0
itself so that __hw_addr_sync_multiple will not return an error.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>

---
 net/core/dev_addr_lists.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index c858e81..8e2c2ef 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -67,7 +67,7 @@ static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
 			}
 			if (sync) {
 				if (ha->synced)
-					return 0;
+					return -EEXIST;
 				else
 					ha->synced = true;
 			}
@@ -140,10 +140,13 @@ static int __hw_addr_sync_one(struct netdev_hw_addr_list *to_list,
 
 	err = __hw_addr_add_ex(to_list, ha->addr, addr_len, ha->type,
 			       false, true);
-	if (err)
+	if (err && err != -EEXIST)
 		return err;
-	ha->sync_cnt++;
-	ha->refcount++;
+
+	if (!err) {
+		ha->sync_cnt++;
+		ha->refcount++;
+	}
 
 	return 0;
 }
-- 
1.7.1
