From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Wed, 30 Nov 2016 12:38:10 +0100
Message-ID: <20161130123810.581ba21f@redhat.com>
References: <20140903165943.372b897b@redhat.com>
        <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
        <20161116131609.4e5726b4@redhat.com>
        <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
        <20161116234022.2bad179b@redhat.com>
        <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117091638.5fab8494@redhat.com>
        <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117144248.23500001@redhat.com>
        <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117155753.17b76f5a@redhat.com>
        <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117193021.580589ae@redhat.com>
        <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161121170351.50a09ee1@redhat.com>
        <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
        <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/wlHn2ICSB2V+Z0uPjbBqMQk"
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, brouer@redhat.com,
        Achiad Shochat <achiad@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37990 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753383AbcK3LiW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 06:38:22 -0500
In-Reply-To: <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/wlHn2ICSB2V+Z0uPjbBqMQk
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


I've played with a somewhat similar patch (from Achiad Shochat) for
mlx5 (attached).  While it gives huge improvements, the problem I ran
into was that; TX performance became a function of the TX completion
time/interrupt and could easily be throttled if configured too
high/slow.

Can your patch be affected by this too?

Adjustable via:
 ethtool -C mlx5p2 tx-usecs 16 tx-frames 32
 

On Mon, 28 Nov 2016 22:58:36 -0800 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> I have a WIP, that increases pktgen rate by 75 % on mlx4 when bulking is
> not used.
> 
> lpaa23:~# echo 0 >/sys/class/net/eth0/doorbell_opt 
> lpaa23:~# sar -n DEV 1 10|grep eth0
[...]
> Average:         eth0      9.50 5707925.60      0.99 585285.69      0.00      0.00      0.50
> lpaa23:~# echo 1 >/sys/class/net/eth0/doorbell_opt 
> lpaa23:~# sar -n DEV 1 10|grep eth0
[...]
> Average:         eth0      2.40 9985214.90      0.31 1023874.60      0.00      0.00      0.50

These +75% number is pktgen without "burst", and definitely show that
your patch activate xmit_more.
What is the pps performance number when using pktgen "burst" option?


> And about 11 % improvement on an mono-flow UDP_STREAM test.
> 
> skb_set_owner_w() is now the most consuming function.
> 
> 
> lpaa23:~# ./udpsnd -4 -H 10.246.7.152 -d 2 &
> [1] 13696
> lpaa23:~# echo 0 >/sys/class/net/eth0/doorbell_opt
> lpaa23:~# sar -n DEV 1 10|grep eth0
[...]
> Average:         eth0      9.00 1307380.50      1.00 308356.18      0.00      0.00      0.50
> lpaa23:~# echo 3 >/sys/class/net/eth0/doorbell_opt
> lpaa23:~# sar -n DEV 1 10|grep eth0
[...]
> Average:         eth0      3.10 1459558.20      0.44 344267.57      0.00      0.00      0.50

The +11% number seems consistent with my perf observations that approx
12% was "fakely" spend on the xmit spin_lock.


[...]
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 4b597dca5c52..affebb435679 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
[...]
> -static inline bool mlx4_en_is_tx_ring_full(struct mlx4_en_tx_ring *ring)
> +static inline bool mlx4_en_is_tx_ring_full(const struct mlx4_en_tx_ring *ring)
>  {
> -	return ring->prod - ring->cons > ring->full_size;
> +	return READ_ONCE(ring->prod) - READ_ONCE(ring->cons) > ring->full_size;
>  }
[...]

> @@ -1033,6 +1058,14 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>  	}
>  	send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
>  
> +	/* Doorbell avoidance : We can omit doorbell if we know a TX completion
> +	 * will happen shortly.
> +	 */
> +	if (send_doorbell &&
> +	    dev->doorbell_opt &&
> +	    (s32)(READ_ONCE(ring->prod_bell) - READ_ONCE(ring->ncons)) > 0)

It would be nice with a function call with an appropriate name, instead
of an open-coded queue size check.  I'm also confused by the "ncons" name.

> +		send_doorbell = false;
> +
[...]

> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 574bcbb1b38f..c3fd0deda198 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -280,6 +280,7 @@ struct mlx4_en_tx_ring {
>  	 */
>  	u32			last_nr_txbb;
>  	u32			cons;
> +	u32			ncons;

Maybe we can find a better name than "ncons" ?

>  	unsigned long		wake_queue;
>  	struct netdev_queue	*tx_queue;
>  	u32			(*free_tx_desc)(struct mlx4_en_priv *priv,
> @@ -290,6 +291,7 @@ struct mlx4_en_tx_ring {
>  
>  	/* cache line used and dirtied in mlx4_en_xmit() */
>  	u32			prod ____cacheline_aligned_in_smp;
> +	u32			prod_bell;

Good descriptive variable name.

>  	unsigned int		tx_dropped;
>  	unsigned long		bytes;
>  	unsigned long		packets;


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--MP_/wlHn2ICSB2V+Z0uPjbBqMQk
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=net_mlx5e__force_tx_skb_bulking.patch

Return-Path: tariqt@mellanox.com
Received: from zmta04.collab.prod.int.phx2.redhat.com (LHLO
 zmta04.collab.prod.int.phx2.redhat.com) (10.5.81.11) by
 zmail22.collab.prod.int.phx2.redhat.com with LMTP; Wed, 17 Aug 2016
 05:21:47 -0400 (EDT)
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by zmta04.collab.prod.int.phx2.redhat.com (Postfix) with ESMTP id B23B4DA128
	for <jbrouer@mail.corp.redhat.com>; Wed, 17 Aug 2016 05:21:47 -0400 (EDT)
Received: from mx1.redhat.com (ext-mx01.extmail.prod.ext.phx2.redhat.com [10.5.110.25])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u7H9LlWp015796
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <brouer@redhat.com>; Wed, 17 Aug 2016 05:21:47 -0400
Received: from mellanox.co.il (mail-il-dmz.mellanox.com [193.47.165.129])
	by mx1.redhat.com (Postfix) with ESMTP id B3ADB8122E
	for <brouer@redhat.com>; Wed, 17 Aug 2016 09:21:45 +0000 (UTC)
Received: from Internal Mail-Server by MTLPINE1 (envelope-from tariqt@mellanox.com)
	with ESMTPS (AES256-SHA encrypted); 17 Aug 2016 12:15:03 +0300
Received: from dev-l-vrt-206.mtl.labs.mlnx (dev-l-vrt-206.mtl.labs.mlnx [10.134.206.1])
	by labmailer.mlnx (8.13.8/8.13.8) with ESMTP id u7H9F31D010642;
	Wed, 17 Aug 2016 12:15:03 +0300
From: Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Achiad Shochat <achiad@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH] net/mlx5e: force tx skb bulking
Date: Wed, 17 Aug 2016 12:14:51 +0300
Message-Id: <1471425291-1782-1-git-send-email-tariqt@mellanox.com>
X-Greylist: Delayed for 00:06:41 by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 17 Aug 2016 09:21:46 +0000 (UTC)
X-Greylist: inspected by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 17 Aug 2016 09:21:46 +0000 (UTC) for IP:'193.47.165.129' DOMAIN:'mail-il-dmz.mellanox.com' HELO:'mellanox.co.il' FROM:'tariqt@mellanox.com' RCPT:''
X-RedHat-Spam-Score: 0.251  (BAYES_50,RP_MATCHES_RCVD,SPF_HELO_PASS,SPF_PASS,UNPARSEABLE_RELAY) 193.47.165.129 mail-il-dmz.mellanox.com 193.47.165.129 mail-il-dmz.mellanox.com <tariqt@mellanox.com>
X-Scanned-By: MIMEDefang 2.68 on 10.5.11.23
X-Scanned-By: MIMEDefang 2.78 on 10.5.110.25

From: Achiad Shochat <achiad@mellanox.com>

To improve SW message rate in case HW is faster.
Heuristically detect cases where the message rate is high and there
is still no skb bulking and if so, stops the txq for a while trying
to force the bulking.

Change-Id: Icb925135e69b030943cb4666117c47d1cc04da97
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h    | 5 +++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 9 ++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 74edd01..78a0661 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -394,6 +394,10 @@ enum {
 	MLX5E_SQ_STATE_TX_TIMEOUT,
 };
 
+enum {
+	MLX5E_SQ_STOP_ONCE,
+};
+
 struct mlx5e_ico_wqe_info {
 	u8  opcode;
 	u8  num_wqebbs;
@@ -403,6 +407,7 @@ struct mlx5e_sq {
 	/* data path */
 
 	/* dirtied @completion */
+	unsigned long              flags;
 	u16                        cc;
 	u32                        dma_fifo_cc;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index e073bf59..034eef0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -351,8 +351,10 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP))
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
-	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM))) {
+	if (test_bit(MLX5E_SQ_STOP_ONCE, &sq->flags) ||
+	    unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM))) {
 		netif_tx_stop_queue(sq->txq);
+		clear_bit(MLX5E_SQ_STOP_ONCE, &sq->flags);
 		sq->stats.stopped++;
 	}
 
@@ -429,6 +431,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 	u32 dma_fifo_cc;
 	u32 nbytes;
 	u16 npkts;
+	u16 ncqes;
 	u16 sqcc;
 	int i;
 
@@ -439,6 +442,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 
 	npkts = 0;
 	nbytes = 0;
+	ncqes = 0;
 
 	/* sq->cc must be updated only after mlx5_cqwq_update_db_record(),
 	 * otherwise a cq overrun may occur
@@ -458,6 +462,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 			break;
 
 		mlx5_cqwq_pop(&cq->wq);
+		ncqes++;
 
 		wqe_counter = be16_to_cpu(cqe->wqe_counter);
 
@@ -508,6 +513,8 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 
 	sq->dma_fifo_cc = dma_fifo_cc;
 	sq->cc = sqcc;
+	if ((npkts > 7) && ((npkts >> (ilog2(ncqes))) < 8))
+		set_bit(MLX5E_SQ_STOP_ONCE, &sq->flags);
 
 	netdev_tx_completed_queue(sq->txq, npkts, nbytes);
 
-- 
1.8.3.1


--MP_/wlHn2ICSB2V+Z0uPjbBqMQk--
