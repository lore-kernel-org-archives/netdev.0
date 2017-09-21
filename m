From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH net 6/9] net/smc: longer delay for client link group removal
Date: Thu, 21 Sep 2017 09:16:31 +0200
Message-ID: <20170921071634.16883-7-ubraun@linux.vnet.ibm.com>
References: <20170921071634.16883-1-ubraun@linux.vnet.ibm.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170921071634.16883-1-ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Client link group creation always follows the server linkgroup creation.
If peer creates a new server link group, client has to create a new
client link group. If peer reuses a server link group for a new
connection, client has to reuse its client link group as well. This
patch introduces a longer delay for client link group removal to make
sure this link group still exists, once the peer decides to reuse a
server link group. This avoids out-of-sync conditions for link groups.
If already scheduled, modify the delay.

Signed-off-by: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
