From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [patch] qeth: fix uaccess handling and get rid of unused variable
Date: Thu, 28 Dec 2006 13:05:36 +0100
Message-ID: <20061228120536.GA9790@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:49626 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274AbWL1MFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Dec 2006 07:05:40 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kBSC5cPP138560
	for <netdev@vger.kernel.org>; Thu, 28 Dec 2006 12:05:38 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBSC5cWr1732786
	for <netdev@vger.kernel.org>; Thu, 28 Dec 2006 12:05:38 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBSC5bhc007004
	for <netdev@vger.kernel.org>; Thu, 28 Dec 2006 12:05:37 GMT
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Frank Pavlic <fpavlic@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>

[patch] qeth: fix uaccess handling and get rid of unused variable

drivers/s390/net/qeth_main.c: In function `qeth_process_inbound_buffer':
drivers/s390/net/qeth_main.c:2563: warning: unused variable `vlan_addr'

include/asm/uaccess.h: In function `qeth_do_ioctl':
drivers/s390/net/qeth_main.c:4847: warning:
 ignoring return value of `copy_to_user'
drivers/s390/net/qeth_main.c:4849: warning:
 ignoring return value of `copy_to_user'
drivers/s390/net/qeth_main.c:4996: warning:
 ignoring return value of `copy_to_user'

Cc: Frank Pavlic <fpavlic@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 drivers/s390/net/qeth_main.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

Index: linux-2.6/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6/drivers/s390/net/qeth_main.c
@@ -2560,7 +2560,6 @@ qeth_process_inbound_buffer(struct qeth_
 	int offset;
 	int rxrc;
 	__u16 vlan_tag = 0;
-	__u16 *vlan_addr;
 
 	/* get first element of current buffer */
 	element = (struct qdio_buffer_element *)&buf->buffer->element[0];
@@ -4844,9 +4843,11 @@ qeth_arp_query(struct qeth_card *card, c
 			   "(0x%x/%d)\n",
 			   QETH_CARD_IFNAME(card), qeth_arp_get_error_cause(&rc),
 			   tmp, tmp);
-		copy_to_user(udata, qinfo.udata, 4);
+		if (copy_to_user(udata, qinfo.udata, 4))
+			rc = -EFAULT;
 	} else {
-		copy_to_user(udata, qinfo.udata, qinfo.udata_len);
+		if (copy_to_user(udata, qinfo.udata, qinfo.udata_len))
+			rc = -EFAULT;
 	}
 	kfree(qinfo.udata);
 	return rc;
@@ -4992,8 +4993,10 @@ qeth_snmp_command(struct qeth_card *card
 	if (rc)
 		PRINT_WARN("SNMP command failed on %s: (0x%x)\n",
 			   QETH_CARD_IFNAME(card), rc);
-	 else
-		copy_to_user(udata, qinfo.udata, qinfo.udata_len);
+	else {
+		if (copy_to_user(udata, qinfo.udata, qinfo.udata_len))
+			rc = -EFAULT;
+	}
 
 	kfree(ureq);
 	kfree(qinfo.udata);
