From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Fix calculation of number of TX header descriptors
Date: Mon, 16 Oct 2017 10:02:11 -0500
Message-ID: <1508166131-5141-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:39678 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753139AbdJPPCS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 11:02:18 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9GExw96135447
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 11:02:17 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dmuqdadgt-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 11:02:17 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Mon, 16 Oct 2017 11:02:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch correctly sets the number of additional header descriptors
that will be sent in an indirect SCRQ entry.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index cb8182f..c66abd4 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1093,11 +1093,12 @@ static int build_hdr_data(u8 hdr_field, struct sk_buff *skb,
  * places them in a descriptor array, scrq_arr
  */
 
-static void create_hdr_descs(u8 hdr_field, u8 *hdr_data, int len, int *hdr_len,
-			     union sub_crq *scrq_arr)
+static int create_hdr_descs(u8 hdr_field, u8 *hdr_data, int len, int *hdr_len,
+			    union sub_crq *scrq_arr)
 {
 	union sub_crq hdr_desc;
 	int tmp_len = len;
+	int num_descs = 0;
 	u8 *data, *cur;
 	int tmp;
 
@@ -1126,7 +1127,10 @@ static void create_hdr_descs(u8 hdr_field, u8 *hdr_data, int len, int *hdr_len,
 		tmp_len -= tmp;
 		*scrq_arr = hdr_desc;
 		scrq_arr++;
+		num_descs++;
 	}
+
+	return num_descs;
 }
 
 /**
@@ -1144,16 +1148,12 @@ static void build_hdr_descs_arr(struct ibmvnic_tx_buff *txbuff,
 				int *num_entries, u8 hdr_field)
 {
 	int hdr_len[3] = {0, 0, 0};
-	int tot_len, len;
+	int tot_len;
 	u8 *hdr_data = txbuff->hdr_data;
 
 	tot_len = build_hdr_data(hdr_field, txbuff->skb, hdr_len,
 				 txbuff->hdr_data);
-	len = tot_len;
-	len -= 24;
-	if (len > 0)
-		num_entries += len % 29 ? len / 29 + 1 : len / 29;
-	create_hdr_descs(hdr_field, hdr_data, tot_len, hdr_len,
+	*num_entries += create_hdr_descs(hdr_field, hdr_data, tot_len, hdr_len,
 			 txbuff->indir_arr + 1);
 }
 
-- 
2.7.4
