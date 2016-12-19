From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: mlx4: Bug in XDP_TX + 16 rx-queues
Date: Mon, 19 Dec 2016 15:37:09 -0800
Message-ID: <20161219233709.GA29858@kafai-mba.local>
References: <20161217101803.GB8732@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45973 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753250AbcLSXhT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 18:37:19 -0500
Content-Disposition: inline
In-Reply-To: <20161217101803.GB8732@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tariq,

On Sat, Dec 17, 2016 at 02:18:03AM -0800, Martin KaFai Lau wrote:
> Hi All,
>
> I have been debugging with XDP_TX and 16 rx-queues.
>
> 1) When 16 rx-queues is used and an XDP prog is doing XDP_TX,
> it seems that the packet cannot be XDP_TX out if the pkt
> is received from some particular CPUs (/rx-queues).
>
> 2) If 8 rx-queues is used, it does not have problem.
>
> 3) The 16 rx-queues problem also went away after reverting these
> two patches:
> 15fca2c8eb41 net/mlx4_en: Add ethtool statistics for XDP cases
> 67f8b1dcb9ee net/mlx4_en: Refactor the XDP forwarding rings scheme
>
After taking a closer look at 67f8b1dcb9ee ("net/mlx4_en: Refactor the XDP forwarding rings scheme")
and armed with the fact that '>8 rx-queues does not work', I have
made the attached change that fixed the issue.

Making change in mlx4_en_fill_qp_context() could be an easier fix
but I think this change will be easier for discussion purpose.

I don't want to lie that I know anything about how this variable
works in CX3.  If this change makes sense, I can cook up a diff.
Otherwise, can you shed some light on what could be happening
and hopefully can lead to a diff?

Thanks
--Martin


diff --git i/drivers/net/ethernet/mellanox/mlx4/en_netdev.c w/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index bcd955339058..b3bfb987e493 100644
--- i/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ w/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1638,10 +1638,10 @@ int mlx4_en_start_port(struct net_device *dev)

 	/* Configure tx cq's and rings */
 	for (t = 0 ; t < MLX4_EN_NUM_TX_TYPES; t++) {
-		u8 num_tx_rings_p_up = t == TX ? priv->num_tx_rings_p_up : 1;
-
 		for (i = 0; i < priv->tx_ring_num[t]; i++) {
 			/* Configure cq */
+			int user_prio;
+
 			cq = priv->tx_cq[t][i];
 			err = mlx4_en_activate_cq(priv, cq, i);
 			if (err) {
@@ -1660,9 +1660,14 @@ int mlx4_en_start_port(struct net_device *dev)

 			/* Configure ring */
 			tx_ring = priv->tx_ring[t][i];
+			if (t != TX_XDP)
+				user_prio = i / priv->num_tx_rings_p_up;
+			else
+				user_prio = i & 0x07;
+
 			err = mlx4_en_activate_tx_ring(priv, tx_ring,
 						       cq->mcq.cqn,
-						       i / num_tx_rings_p_up);
+						       user_prio);
 			if (err) {
 				en_err(priv, "Failed allocating Tx ring\n");
 				mlx4_en_deactivate_cq(priv, cq);
