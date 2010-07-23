From: frank.blaschka@de.ibm.com
Subject: [patch 7/8] [PATCH] qeth: Use memdup_user when user data is immediately copied into the allocated region.
Date: Fri, 23 Jul 2010 11:15:09 +0200
Message-ID: <20100723091550.566471000@de.ibm.com>
References: <20100723091502.678949000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Julia Lawall <julia@diku.dk>,
	Andrew Morton <akpm@linux-foundation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:35626 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561Ab0GWJPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 05:15:53 -0400
Content-Disposition: inline; filename=618-qeth-memdup-user.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
position p;
identifier l1,l2;
@@

-  to = \(kmalloc@p\|kzalloc@p\)(size,flag);
+  to = memdup_user(from,size);
   if (
-      to==NULL
+      IS_ERR(to)
                 || ...) {
   <+... when != goto l1;
-  -ENOMEM
+  PTR_ERR(to)
   ...+>
   }
-  if (copy_from_user(to, from, size) != 0) {
-    <+... when != goto l2;
-    -EFAULT
-    ...+>
-  }
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-07-22 10:22:37.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-07-22 10:22:37.000000000 +0200
@@ -3748,15 +3748,10 @@ int qeth_snmp_command(struct qeth_card *
 	/* skip 4 bytes (data_len struct member) to get req_len */
 	if (copy_from_user(&req_len, udata + sizeof(int), sizeof(int)))
 		return -EFAULT;
-	ureq = kmalloc(req_len+sizeof(struct qeth_snmp_ureq_hdr), GFP_KERNEL);
-	if (!ureq) {
+	ureq = memdup_user(udata, req_len + sizeof(struct qeth_snmp_ureq_hdr));
+	if (IS_ERR(ureq)) {
 		QETH_CARD_TEXT(card, 2, "snmpnome");
-		return -ENOMEM;
-	}
-	if (copy_from_user(ureq, udata,
-			req_len + sizeof(struct qeth_snmp_ureq_hdr))) {
-		kfree(ureq);
-		return -EFAULT;
+		return PTR_ERR(ureq);
 	}
 	qinfo.udata_len = ureq->hdr.data_len;
 	qinfo.udata = kzalloc(qinfo.udata_len, GFP_KERNEL);

