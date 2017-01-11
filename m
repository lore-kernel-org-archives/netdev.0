From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 12/13] s390/qeth: fix retrieval of vipa and proxy-arp addresses
Date: Wed, 11 Jan 2017 12:55:59 +0100
Message-ID: <20170111115600.4524-13-ubraun@linux.vnet.ibm.com>
References: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49988 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S937567AbdAKL4Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 06:56:25 -0500
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0BBrjn7062705
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 06:56:24 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27wf08w426-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 06:56:24 -0500
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 11 Jan 2017 11:56:21 -0000
In-Reply-To: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qeth devices in layer3 mode need a separate handling of vipa and proxy-arp
addresses. vipa and proxy-arp addresses processed by qeth can be read from
userspace. Introduced with commit 5f78e29ceebf ("qeth: optimize IP handling
in rx_mode callback") the retrieval of vipa and proxy-arp addresses is
broken, if more than one vipa or proxy-arp address are set.

The qeth code used local variable "int i" for 2 different purposes. This
patch now spends 2 separate local variables of type "int".
While touching these functions hash_for_each_safe() is converted to
hash_for_each(), since there is no removal of hash entries.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_sys.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index 3cd4d9f..05e9471 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -689,15 +689,15 @@ static ssize_t qeth_l3_dev_vipa_add_show(char *buf, struct qeth_card *card,
 			enum qeth_prot_versions proto)
 {
 	struct qeth_ipaddr *ipaddr;
-	struct hlist_node  *tmp;
 	char addr_str[40];
+	int str_len = 0;
 	int entry_len; /* length of 1 entry string, differs between v4 and v6 */
-	int i = 0;
+	int i;
 
 	entry_len = (proto == QETH_PROT_IPV4)? 12 : 40;
 	entry_len += 2; /* \n + terminator */
 	spin_lock_bh(&card->ip_lock);
-	hash_for_each_safe(card->ip_htable, i, tmp, ipaddr, hnode) {
+	hash_for_each(card->ip_htable, i, ipaddr, hnode) {
 		if (ipaddr->proto != proto)
 			continue;
 		if (ipaddr->type != QETH_IP_TYPE_VIPA)
@@ -705,16 +705,17 @@ static ssize_t qeth_l3_dev_vipa_add_show(char *buf, struct qeth_card *card,
 		/* String must not be longer than PAGE_SIZE. So we check if
 		 * string length gets near PAGE_SIZE. Then we can savely display
 		 * the next IPv6 address (worst case, compared to IPv4) */
-		if ((PAGE_SIZE - i) <= entry_len)
+		if ((PAGE_SIZE - str_len) <= entry_len)
 			break;
 		qeth_l3_ipaddr_to_string(proto, (const u8 *)&ipaddr->u,
 			addr_str);
-		i += snprintf(buf + i, PAGE_SIZE - i, "%s\n", addr_str);
+		str_len += snprintf(buf + str_len, PAGE_SIZE - str_len, "%s\n",
+				    addr_str);
 	}
 	spin_unlock_bh(&card->ip_lock);
-	i += snprintf(buf + i, PAGE_SIZE - i, "\n");
+	str_len += snprintf(buf + str_len, PAGE_SIZE - str_len, "\n");
 
-	return i;
+	return str_len;
 }
 
 static ssize_t qeth_l3_dev_vipa_add4_show(struct device *dev,
@@ -851,15 +852,15 @@ static ssize_t qeth_l3_dev_rxip_add_show(char *buf, struct qeth_card *card,
 		       enum qeth_prot_versions proto)
 {
 	struct qeth_ipaddr *ipaddr;
-	struct hlist_node *tmp;
 	char addr_str[40];
+	int str_len = 0;
 	int entry_len; /* length of 1 entry string, differs between v4 and v6 */
-	int i = 0;
+	int i;
 
 	entry_len = (proto == QETH_PROT_IPV4)? 12 : 40;
 	entry_len += 2; /* \n + terminator */
 	spin_lock_bh(&card->ip_lock);
-	hash_for_each_safe(card->ip_htable, i, tmp, ipaddr, hnode) {
+	hash_for_each(card->ip_htable, i, ipaddr, hnode) {
 		if (ipaddr->proto != proto)
 			continue;
 		if (ipaddr->type != QETH_IP_TYPE_RXIP)
@@ -867,16 +868,17 @@ static ssize_t qeth_l3_dev_rxip_add_show(char *buf, struct qeth_card *card,
 		/* String must not be longer than PAGE_SIZE. So we check if
 		 * string length gets near PAGE_SIZE. Then we can savely display
 		 * the next IPv6 address (worst case, compared to IPv4) */
-		if ((PAGE_SIZE - i) <= entry_len)
+		if ((PAGE_SIZE - str_len) <= entry_len)
 			break;
 		qeth_l3_ipaddr_to_string(proto, (const u8 *)&ipaddr->u,
 			addr_str);
-		i += snprintf(buf + i, PAGE_SIZE - i, "%s\n", addr_str);
+		str_len += snprintf(buf + str_len, PAGE_SIZE - str_len, "%s\n",
+				    addr_str);
 	}
 	spin_unlock_bh(&card->ip_lock);
-	i += snprintf(buf + i, PAGE_SIZE - i, "\n");
+	str_len += snprintf(buf + str_len, PAGE_SIZE - str_len, "\n");
 
-	return i;
+	return str_len;
 }
 
 static ssize_t qeth_l3_dev_rxip_add4_show(struct device *dev,
-- 
2.8.4
