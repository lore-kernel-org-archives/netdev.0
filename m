From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH net 9/9] net/smc: no close wait in case of process shut down
Date: Thu, 21 Sep 2017 09:16:34 +0200
Message-ID: <20170921071634.16883-10-ubraun@linux.vnet.ibm.com>
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

Usually socket closing is delayed if there is still data available in
the send buffer to be transmitted. If a process is killed, the delay
should be avoided.

Signed-off-by: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 net/smc/smc_close.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/smc/smc_close.c b/net/smc/smc_close.c
index 5201bc103bd8..f0d16fb825f7 100644
--- a/net/smc/smc_close.c
+++ b/net/smc/smc_close.c
@@ -174,15 +174,15 @@ int smc_close_active(struct smc_sock *smc)
 {
 	struct smc_cdc_conn_state_flags *txflags =
 		&smc->conn.local_tx_ctrl.conn_state_flags;
-	long timeout = SMC_MAX_STREAM_WAIT_TIMEOUT;
 	struct smc_connection *conn = &smc->conn;
 	struct sock *sk = &smc->sk;
 	int old_state;
+	long timeout;
 	int rc = 0;
 
-	if (sock_flag(sk, SOCK_LINGER) &&
-	    !(current->flags & PF_EXITING))
-		timeout = sk->sk_lingertime;
+	timeout = current->flags & PF_EXITING ?
+		  0 : sock_flag(sk, SOCK_LINGER) ?
+		      sk->sk_lingertime : SMC_MAX_STREAM_WAIT_TIMEOUT;
 
 again:
 	old_state = sk->sk_state;
@@ -413,13 +413,14 @@ void smc_close_sock_put_work(struct work_struct *work)
 int smc_close_shutdown_write(struct smc_sock *smc)
 {
 	struct smc_connection *conn = &smc->conn;
-	long timeout = SMC_MAX_STREAM_WAIT_TIMEOUT;
 	struct sock *sk = &smc->sk;
 	int old_state;
+	long timeout;
 	int rc = 0;
 
-	if (sock_flag(sk, SOCK_LINGER))
-		timeout = sk->sk_lingertime;
+	timeout = current->flags & PF_EXITING ?
+		  0 : sock_flag(sk, SOCK_LINGER) ?
+		      sk->sk_lingertime : SMC_MAX_STREAM_WAIT_TIMEOUT;
 
 again:
 	old_state = sk->sk_state;
-- 
2.13.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
