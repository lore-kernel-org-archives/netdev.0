From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] be2net: bug fix on returning an invalid nic descriptor
Date: Thu, 23 May 2013 09:58:22 +0800
Message-ID: <1369274302-8118-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>
To: sathya.perla@emulex.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:48229 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757215Ab3EWB63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 21:58:29 -0400
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Thu, 23 May 2013 07:24:12 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 6B4EF394004E
	for <netdev@vger.kernel.org>; Thu, 23 May 2013 07:28:25 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4N1wJ3n62586990
	for <netdev@vger.kernel.org>; Thu, 23 May 2013 07:28:19 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4N1wN3l032660
	for <netdev@vger.kernel.org>; Thu, 23 May 2013 01:58:23 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function be_get_nic_desc(), it will go through the descriptor array
returned from f/w. By comparing the desc_type field, it determines whether
there is a nic descriptor in the array or not. In the case of no nic
descriptor, this function should return NULL.

The code may return an invalide descriptor, when there is no nic descriptor
in the array and the desc_count is less than MAX_RESOURCE_DESC. In this case,
even there is no nic descriptor, it will still return the lase descriptor
since the i doesn't equal to MAX_RESOURCE_DESC.

This patch fix this issue by returning the descriptor when find it and return
NULL for other cases.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
Reviewed-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Reviewed-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index fd7b547..a236ecd 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2976,22 +2976,17 @@ static struct be_nic_resource_desc *be_get_nic_desc(u8 *buf, u32 desc_count,
 	for (i = 0; i < desc_count; i++) {
 		desc->desc_len = desc->desc_len ? : RESOURCE_DESC_SIZE;
 		if (((void *)desc + desc->desc_len) >
-		    (void *)(buf + max_buf_size)) {
-			desc = NULL;
-			break;
-		}
+		    (void *)(buf + max_buf_size))
+			return NULL;
 
 		if (desc->desc_type == NIC_RESOURCE_DESC_TYPE_V0 ||
 		    desc->desc_type == NIC_RESOURCE_DESC_TYPE_V1)
-			break;
+			return desc;
 
 		desc = (void *)desc + desc->desc_len;
 	}
 
-	if (!desc || i == MAX_RESOURCE_DESC)
-		return NULL;
-
-	return desc;
+	return NULL;
 }
 
 /* Uses Mbox */
-- 
1.7.1
