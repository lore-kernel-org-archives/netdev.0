From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 06/10] net/smc: longer delay for client link group removal
Date: Wed, 20 Sep 2017 13:58:09 +0200
Message-ID: <20170920115813.63745-7-ubraun@linux.vnet.ibm.com>
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40748 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751920AbdITL6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 07:58:32 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8KBsajv143262
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:31 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d3pkrvxar-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:31 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 20 Sep 2017 12:58:29 +0100
In-Reply-To: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Client link group creation always follows the server linkgroup creation.
If peer creates a new server link group, client has to create a new
client link group. If peer reuses a server link group for a new
connection, client has to reuse its client link group as well. This
patch introduces a longer delay for client link group removal to make
sure this link group still exists, once the peer decides to reuse a
server link group. This avoids out-of-sync conditions for link groups.
If already scheduled, modify the delay.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/smc_core.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 1a16d51e2330..20b66e79c5d6 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -25,8 +25,9 @@
 #include "smc_cdc.h"
 #include "smc_close.h"
 
-#define SMC_LGR_NUM_INCR	256
-#define SMC_LGR_FREE_DELAY	(600 * HZ)
+#define SMC_LGR_NUM_INCR		256
+#define SMC_LGR_FREE_DELAY_SERV		(600 * HZ)
+#define SMC_LGR_FREE_DELAY_CLNT		(SMC_LGR_FREE_DELAY_SERV + 10)
 
 static u32 smc_lgr_num;			/* unique link group number */
 
@@ -107,8 +108,15 @@ static void smc_lgr_unregister_conn(struct smc_connection *conn)
 		__smc_lgr_unregister_conn(conn);
 	}
 	write_unlock_bh(&lgr->conns_lock);
-	if (reduced && !lgr->conns_num)
-		schedule_delayed_work(&lgr->free_work, SMC_LGR_FREE_DELAY);
+	if (!reduced || lgr->conns_num)
+		return;
+	/* client link group creation always follows the server link group
+	 * creation. For client use a somewhat higher removal delay time,
+	 * otherwise there is a risk of out-of-sync link groups.
+	 */
+	mod_delayed_work(system_wq, &lgr->free_work,
+			 lgr->role == SMC_CLNT ? SMC_LGR_FREE_DELAY_CLNT :
+						 SMC_LGR_FREE_DELAY_SERV);
 }
 
 static void smc_lgr_free_work(struct work_struct *work)
-- 
2.13.5
