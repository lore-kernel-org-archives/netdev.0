From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH net-next 02/10] net/smc: shorten local bufsize variables
Date: Fri, 28 Jul 2017 13:56:14 +0200
Message-ID: <20170728115622.17247-3-ubraun@linux.vnet.ibm.com>
References: <20170728115622.17247-1-ubraun@linux.vnet.ibm.com>
Cc: hch-jcswGhMUV9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170728115622.17247-1-ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Initiate the coming rework of SMC buffer handling with this
small code cleanup. No functional changes here.

Signed-off-by: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 net/smc/smc_core.c | 54 +++++++++++++++++++++++++-----------------------------
 1 file changed, 25 insertions(+), 29 deletions(-)

diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 3ac09a629ea1..6159488cb94b 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -508,25 +508,25 @@ int smc_sndbuf_create(struct smc_sock *smc)
 {
 	struct smc_connection *conn = &smc->conn;
 	struct smc_link_group *lgr = conn->lgr;
-	int tmp_bufsize, tmp_bufsize_short;
 	struct smc_buf_desc *sndbuf_desc;
+	int bufsize, bufsize_short;
 	int rc;
 
 	/* use socket send buffer size (w/o overhead) as start value */
-	for (tmp_bufsize_short = smc_compress_bufsize(smc->sk.sk_sndbuf / 2);
-	     tmp_bufsize_short >= 0; tmp_bufsize_short--) {
-		tmp_bufsize = smc_uncompress_bufsize(tmp_bufsize_short);
+	for (bufsize_short = smc_compress_bufsize(smc->sk.sk_sndbuf / 2);
+	     bufsize_short >= 0; bufsize_short--) {
+		bufsize = smc_uncompress_bufsize(bufsize_short);
 		/* check for reusable sndbuf_slot in the link group */
-		sndbuf_desc = smc_sndbuf_get_slot(lgr, tmp_bufsize_short);
+		sndbuf_desc = smc_sndbuf_get_slot(lgr, bufsize_short);
 		if (sndbuf_desc) {
-			memset(sndbuf_desc->cpu_addr, 0, tmp_bufsize);
+			memset(sndbuf_desc->cpu_addr, 0, bufsize);
 			break; /* found reusable slot */
 		}
 		/* try to alloc a new send buffer */
 		sndbuf_desc = kzalloc(sizeof(*sndbuf_desc), GFP_KERNEL);
 		if (!sndbuf_desc)
 			break; /* give up with -ENOMEM */
-		sndbuf_desc->cpu_addr = kzalloc(tmp_bufsize,
+		sndbuf_desc->cpu_addr = kzalloc(bufsize,
 						GFP_KERNEL | __GFP_NOWARN |
 						__GFP_NOMEMALLOC |
 						__GFP_NORETRY);
@@ -539,8 +539,7 @@ int smc_sndbuf_create(struct smc_sock *smc)
 			continue;
 		}
 		rc = smc_ib_buf_map(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
-				    tmp_bufsize, sndbuf_desc,
-				    DMA_TO_DEVICE);
+				    bufsize, sndbuf_desc, DMA_TO_DEVICE);
 		if (rc) {
 			kfree(sndbuf_desc->cpu_addr);
 			kfree(sndbuf_desc);
@@ -549,16 +548,15 @@ int smc_sndbuf_create(struct smc_sock *smc)
 		}
 		sndbuf_desc->used = 1;
 		write_lock_bh(&lgr->sndbufs_lock);
-		list_add(&sndbuf_desc->list,
-			 &lgr->sndbufs[tmp_bufsize_short]);
+		list_add(&sndbuf_desc->list, &lgr->sndbufs[bufsize_short]);
 		write_unlock_bh(&lgr->sndbufs_lock);
 		break;
 	}
 	if (sndbuf_desc && sndbuf_desc->cpu_addr) {
 		conn->sndbuf_desc = sndbuf_desc;
-		conn->sndbuf_size = tmp_bufsize;
-		smc->sk.sk_sndbuf = tmp_bufsize * 2;
-		atomic_set(&conn->sndbuf_space, tmp_bufsize);
+		conn->sndbuf_size = bufsize;
+		smc->sk.sk_sndbuf = bufsize * 2;
+		atomic_set(&conn->sndbuf_space, bufsize);
 		return 0;
 	} else {
 		return -ENOMEM;
@@ -574,25 +572,25 @@ int smc_rmb_create(struct smc_sock *smc)
 {
 	struct smc_connection *conn = &smc->conn;
 	struct smc_link_group *lgr = conn->lgr;
-	int tmp_bufsize, tmp_bufsize_short;
 	struct smc_buf_desc *rmb_desc;
+	int bufsize, bufsize_short;
 	int rc;
 
 	/* use socket recv buffer size (w/o overhead) as start value */
-	for (tmp_bufsize_short = smc_compress_bufsize(smc->sk.sk_rcvbuf / 2);
-	     tmp_bufsize_short >= 0; tmp_bufsize_short--) {
-		tmp_bufsize = smc_uncompress_bufsize(tmp_bufsize_short);
+	for (bufsize_short = smc_compress_bufsize(smc->sk.sk_rcvbuf / 2);
+	     bufsize_short >= 0; bufsize_short--) {
+		bufsize = smc_uncompress_bufsize(bufsize_short);
 		/* check for reusable rmb_slot in the link group */
-		rmb_desc = smc_rmb_get_slot(lgr, tmp_bufsize_short);
+		rmb_desc = smc_rmb_get_slot(lgr, bufsize_short);
 		if (rmb_desc) {
-			memset(rmb_desc->cpu_addr, 0, tmp_bufsize);
+			memset(rmb_desc->cpu_addr, 0, bufsize);
 			break; /* found reusable slot */
 		}
 		/* try to alloc a new RMB */
 		rmb_desc = kzalloc(sizeof(*rmb_desc), GFP_KERNEL);
 		if (!rmb_desc)
 			break; /* give up with -ENOMEM */
-		rmb_desc->cpu_addr = kzalloc(tmp_bufsize,
+		rmb_desc->cpu_addr = kzalloc(bufsize,
 					     GFP_KERNEL | __GFP_NOWARN |
 					     __GFP_NOMEMALLOC |
 					     __GFP_NORETRY);
@@ -605,8 +603,7 @@ int smc_rmb_create(struct smc_sock *smc)
 			continue;
 		}
 		rc = smc_ib_buf_map(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
-				    tmp_bufsize, rmb_desc,
-				    DMA_FROM_DEVICE);
+				    bufsize, rmb_desc, DMA_FROM_DEVICE);
 		if (rc) {
 			kfree(rmb_desc->cpu_addr);
 			kfree(rmb_desc);
@@ -617,18 +614,17 @@ int smc_rmb_create(struct smc_sock *smc)
 			lgr->lnk[SMC_SINGLE_LINK].roce_pd->unsafe_global_rkey;
 		rmb_desc->used = 1;
 		write_lock_bh(&lgr->rmbs_lock);
-		list_add(&rmb_desc->list,
-			 &lgr->rmbs[tmp_bufsize_short]);
+		list_add(&rmb_desc->list, &lgr->rmbs[bufsize_short]);
 		write_unlock_bh(&lgr->rmbs_lock);
 		break;
 	}
 	if (rmb_desc && rmb_desc->cpu_addr) {
 		conn->rmb_desc = rmb_desc;
-		conn->rmbe_size = tmp_bufsize;
-		conn->rmbe_size_short = tmp_bufsize_short;
-		smc->sk.sk_rcvbuf = tmp_bufsize * 2;
+		conn->rmbe_size = bufsize;
+		conn->rmbe_size_short = bufsize_short;
+		smc->sk.sk_rcvbuf = bufsize * 2;
 		atomic_set(&conn->bytes_to_rcv, 0);
-		conn->rmbe_update_limit = smc_rmb_wnd_update_limit(tmp_bufsize);
+		conn->rmbe_update_limit = smc_rmb_wnd_update_limit(bufsize);
 		return 0;
 	} else {
 		return -ENOMEM;
-- 
2.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
