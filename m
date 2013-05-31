From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH v2 net 2/6] net/core: __hw_addr_unsync_one "from" address not marked synced
Date: Fri, 31 May 2013 14:57:27 -0700
Message-ID: <1370037451-29466-3-git-send-email-fubar@us.ibm.com>
References: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:48885 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755323Ab3EaV5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 17:57:52 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 31 May 2013 15:57:51 -0600
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 6215038C801A
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 17:57:48 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4VLvmQJ175116
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 17:57:48 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4VLvmKq025601
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 18:57:48 -0300
In-Reply-To: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	When an address is added to a subordinate interface (the "to"
list), the address entry in the "from" list is not marked "synced" as
the entry added to the "to" list is.

	When performing the unsync operation (e.g., dev_mc_unsync),
__hw_addr_unsync_one calls __hw_addr_del_entry with the "synced"
parameter set to true for the case when the address reference is being
released from the "from" list.  This causes a test inside to fail,
with the result being that the reference count on the "from" address
is not properly decremeted and the address on the "from" list will
never be freed.

	Correct this by having __hw_addr_unsync_one call the
__hw_addr_del_entry function with the "sync" flag set to false for the
"remove from the from list" case.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>

---
 net/core/dev_addr_lists.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 1f919d9..c858e81 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -160,7 +160,8 @@ static void __hw_addr_unsync_one(struct netdev_hw_addr_list *to_list,
 	if (err)
 		return;
 	ha->sync_cnt--;
-	__hw_addr_del_entry(from_list, ha, false, true);
+	/* address on from list is not marked synced */
+	__hw_addr_del_entry(from_list, ha, false, false);
 }
 
 static int __hw_addr_sync_multiple(struct netdev_hw_addr_list *to_list,
-- 
1.7.1
