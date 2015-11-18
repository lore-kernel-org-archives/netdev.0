From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 06/14] mlx5: add busy polling support
Date: Wed, 18 Nov 2015 06:30:55 -0800
Message-ID: <1447857063-618-7-git-send-email-edumazet@google.com>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33356 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932841AbbKROb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:31:29 -0500
Received: by pabfh17 with SMTP id fh17so48243005pab.0
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 06:31:29 -0800 (PST)
In-Reply-To: <1447857063-618-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is now easy to add busy polling support to a NAPI driver,
with very little impact on normal input path.

This patch serves as a reference implementation.

Note:

A followup patch will add proper napi_complete_done() in mlx5,
so that LINUX_MIB_BUSYPOLLRXPACKETS snmp counter is properly handled.

Tested:

Normal TCP_RR results without busy polling :

lpk51:~# echo 0 >/proc/sys/net/core/busy_read
lpk52:~# echo 0 >/proc/sys/net/core/busy_read

lpk51:~# ./netperf -H 192.168.4.52 -t TCP_RR -l 10
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.4.52 () port 0 AF_INET : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    53509.49
16384  87380

Now enable busy polling :

lpk51:~# echo 70 >/proc/sys/net/core/busy_read
lpk52:~# echo 70 >/proc/sys/net/core/busy_read

lpk51:~# ./netperf -H 192.168.4.52 -t TCP_RR -l 10
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.4.52 () port 0 AF_INET : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    97530.92
16384  87380

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 6 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 2 ++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 1e52db32c73d..ffb1f9c1b973 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -982,6 +982,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	mlx5e_build_channeltc_to_txq_map(priv, ix);
 
 	netif_napi_add(netdev, &c->napi, mlx5e_napi_poll, 64);
+	napi_hash_add(&c->napi);
 
 	err = mlx5e_open_tx_cqs(c, cparam);
 	if (err)
@@ -1020,6 +1021,7 @@ err_close_tx_cqs:
 
 err_napi_del:
 	netif_napi_del(&c->napi);
+	napi_hash_del(&c->napi);
 	kfree(c);
 
 	return err;
@@ -1033,6 +1035,10 @@ static void mlx5e_close_channel(struct mlx5e_channel *c)
 	mlx5e_close_cq(&c->rq.cq);
 	mlx5e_close_tx_cqs(c);
 	netif_napi_del(&c->napi);
+
+	napi_hash_del(&c->napi);
+	synchronize_rcu();
+
 	kfree(c);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index cf0098596e85..54800c61a563 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -33,6 +33,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/tcp.h>
+#include <net/busy_poll.h>
 #include "en.h"
 
 static inline int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq,
@@ -242,6 +243,7 @@ bool mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 		wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
 		skb            = rq->skb[wqe_counter];
 		prefetch(skb->data);
+		skb_mark_napi_id(skb, cq->napi);
 		rq->skb[wqe_counter] = NULL;
 
 		dma_unmap_single(rq->pdev,
-- 
2.6.0.rc2.230.g3dd15c0
