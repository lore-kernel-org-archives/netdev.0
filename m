From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 10/12] s390/qeth: reject multicast rxip addresses
Date: Tue, 15 Aug 2017 17:02:48 +0200
Message-ID: <20170815150250.67158-11-jwi@linux.vnet.ibm.com>
References: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:36249 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752687AbdHOPDR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:03:17 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7FExNub034123
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:16 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2cbsfatw6q-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:16 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 15 Aug 2017 16:03:14 +0100
In-Reply-To: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kittipon Meesompop <kmeesomp@linux.vnet.ibm.com>

There exist different commands to add unicast and multicast addresses on
the OSA card. rxip addresses are always set as unicast addresses and
thus just unicast addresses should be allowed.

Adding a multicast address now fails and a grace message is generated.

Signed-off-by: Kittipon Meesompop <kmeesomp@linux.vnet.ibm.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_sys.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index f2f94f59e0fa..2000ef190e94 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -895,9 +895,26 @@ static ssize_t qeth_l3_dev_rxip_add4_show(struct device *dev,
 static int qeth_l3_parse_rxipe(const char *buf, enum qeth_prot_versions proto,
 		 u8 *addr)
 {
+	__be32 ipv4_addr;
+	struct in6_addr ipv6_addr;
+
 	if (qeth_l3_string_to_ipaddr(buf, proto, addr)) {
 		return -EINVAL;
 	}
+	if (proto == QETH_PROT_IPV4) {
+		memcpy(&ipv4_addr, addr, sizeof(ipv4_addr));
+		if (ipv4_is_multicast(ipv4_addr)) {
+			QETH_DBF_MESSAGE(2, "multicast rxip not supported.\n");
+			return -EINVAL;
+		}
+	} else if (proto == QETH_PROT_IPV6) {
+		memcpy(&ipv6_addr, addr, sizeof(ipv6_addr));
+		if (ipv6_addr_is_multicast(&ipv6_addr)) {
+			QETH_DBF_MESSAGE(2, "multicast rxip not supported.\n");
+			return -EINVAL;
+		}
+	}
+
 	return 0;
 }
 
-- 
2.11.2
