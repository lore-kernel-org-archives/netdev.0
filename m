From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] genetlink: Optimize and one bug fix in genl_generate_id()
Date: Thu, 15 Oct 2009 11:25:07 +0530
Message-ID: <20091015055507.30128.60763.sendpatchset@localhost.localdomain>
References: <20091015055453.30128.12160.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:57988 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287AbZJOF4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 01:56:06 -0400
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp02.au.ibm.com (8.14.3/8.13.1) with ESMTP id n9F5qsBZ005415
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:52:54 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9F5qikP1458358
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:52:44 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9F5tH4B031367
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:55:18 +1100
In-Reply-To: <20091015055453.30128.12160.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

1. GENL_MIN_ID is a valid id -> no need to start at
   GENL_MIN_ID + 1.
2. Avoid going through the ids two times: If we start at
   GENL_MIN_ID+1 (*or bigger*) and all ids are over!, the
   code iterates through the list twice (*or lesser*).
3. Simplify code - no need to start at idx=0 which gets
   reset to GENL_MIN_ID.

Patch on net-next-2.6. Reboot test shows that first id
passed to genl_register_family was 16, next two were
GENL_ID_GENERATE and genl_generate_id returned 17 & 18
(user level testing of same code shows expected values
across entire range of MIN/MAX).

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
diff -ruNp org/net/netlink/genetlink.c new/net/netlink/genetlink.c
--- org/net/netlink/genetlink.c	2009-10-12 13:57:38.000000000 +0530
+++ new/net/netlink/genetlink.c	2009-10-12 13:57:59.000000000 +0530
@@ -97,25 +97,17 @@ static struct genl_ops *genl_get_cmd(u8 
 */
 static inline u16 genl_generate_id(void)
 {
-	static u16 id_gen_idx;
-	int overflowed = 0;
+	static u16 id_gen_idx = GENL_MIN_ID;
+	int i;
 
-	do {
-		if (id_gen_idx == 0)
+	for (i = 0; i <= GENL_MAX_ID - GENL_MIN_ID; i++) {
+		if (!genl_family_find_byid(id_gen_idx))
+			return id_gen_idx;
+		if (++id_gen_idx > GENL_MAX_ID)
 			id_gen_idx = GENL_MIN_ID;
+	}
 
-		if (++id_gen_idx > GENL_MAX_ID) {
-			if (!overflowed) {
-				overflowed = 1;
-				id_gen_idx = 0;
-				continue;
-			} else
-				return 0;
-		}
-
-	} while (genl_family_find_byid(id_gen_idx));
-
-	return id_gen_idx;
+	return 0;
 }
 
 static struct genl_multicast_group notify_grp;
