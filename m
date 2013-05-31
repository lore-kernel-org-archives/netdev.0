From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next 2/6] net/core: __hw_addr_unsync_one refcount leak  synced
Date: Thu, 30 May 2013 17:55:40 -0700
Message-ID: <1369961744-21460-3-git-send-email-fubar@us.ibm.com>
References: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:59741 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab3EaA4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 20:56:04 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 30 May 2013 18:56:02 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id DED5DC90049
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 20:55:58 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4V0txWP139286
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 20:55:59 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4V0tvQC012086
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 21:55:58 -0300
In-Reply-To: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
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
 net/core/dev_addr_lists.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

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
1.8.1.4
