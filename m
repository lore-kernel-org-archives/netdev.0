From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 04/12] s390/qeth: simplify fragment type selection
Date: Tue, 15 Aug 2017 17:02:42 +0200
Message-ID: <20170815150250.67158-5-jwi@linux.vnet.ibm.com>
References: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40056 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752623AbdHOPDI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:03:08 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7FExLDo114500
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:07 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2cbvw5t572-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:07 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 15 Aug 2017 16:03:06 +0100
In-Reply-To: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve readability of the code that determines a buffer element's
fragment type, and reduce the number of cases down from 5 to 3.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 4792cabb862e..3623ba23ff0b 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3918,23 +3918,16 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 		buffer->element[element].addr = data;
 		buffer->element[element].length = length_here;
 		length -= length_here;
-		if (!length) {
-			if (first_lap)
-				if (skb_shinfo(skb)->nr_frags)
-					buffer->element[element].eflags =
-						SBAL_EFLAGS_FIRST_FRAG;
-				else
-					buffer->element[element].eflags = 0;
-			else
-				buffer->element[element].eflags =
-				    SBAL_EFLAGS_MIDDLE_FRAG;
-		} else {
-			if (first_lap)
+		if (first_lap) {
+			if (length || skb_is_nonlinear(skb))
+				/* skb needs additional elements */
 				buffer->element[element].eflags =
-				    SBAL_EFLAGS_FIRST_FRAG;
+					SBAL_EFLAGS_FIRST_FRAG;
 			else
-				buffer->element[element].eflags =
-				    SBAL_EFLAGS_MIDDLE_FRAG;
+				buffer->element[element].eflags = 0;
+		} else {
+			buffer->element[element].eflags =
+				SBAL_EFLAGS_MIDDLE_FRAG;
 		}
 		data += length_here;
 		element++;
-- 
2.11.2
