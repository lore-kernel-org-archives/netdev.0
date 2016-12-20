From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: mlx4: Bug in XDP_TX + 16 rx-queues
Date: Tue, 20 Dec 2016 10:31:17 -0800
Message-ID: <20161220183117.GA63721@kafai-mba.local>
References: <20161219233709.GA29858@kafai-mba.local>
 <a586ecb7-e290-8c70-714b-2eea0b94c7fb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47904 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1765183AbcLTSb2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 13:31:28 -0500
Content-Disposition: inline
In-Reply-To: <a586ecb7-e290-8c70-714b-2eea0b94c7fb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 20, 2016 at 02:02:05PM +0200, Tariq Toukan wrote:
> Thanks Martin, nice catch!
>
>
> On 20/12/2016 1:37 AM, Martin KaFai Lau wrote:
> >Hi Tariq,
> >
> >On Sat, Dec 17, 2016 at 02:18:03AM -0800, Martin KaFai Lau wrote:
> >>Hi All,
> >>
> >>I have been debugging with XDP_TX and 16 rx-queues.
> >>
> >>1) When 16 rx-queues is used and an XDP prog is doing XDP_TX,
> >>it seems that the packet cannot be XDP_TX out if the pkt
> >>is received from some particular CPUs (/rx-queues).
> >>
> >>2) If 8 rx-queues is used, it does not have problem.
> >>
> >>3) The 16 rx-queues problem also went away after reverting these
> >>two patches:
> >>15fca2c8eb41 net/mlx4_en: Add ethtool statistics for XDP cases
> >>67f8b1dcb9ee net/mlx4_en: Refactor the XDP forwarding rings scheme
> >>
> >After taking a closer look at 67f8b1dcb9ee ("net/mlx4_en: Refactor the XDP forwarding rings scheme")
> >and armed with the fact that '>8 rx-queues does not work', I have
> >made the attached change that fixed the issue.
> >
> >Making change in mlx4_en_fill_qp_context() could be an easier fix
> >but I think this change will be easier for discussion purpose.
> >
> >I don't want to lie that I know anything about how this variable
> >works in CX3.  If this change makes sense, I can cook up a diff.
> >Otherwise, can you shed some light on what could be happening
> >and hopefully can lead to a diff?
> >
> >Thanks
> >--Martin
> >
> >
> >diff --git i/drivers/net/ethernet/mellanox/mlx4/en_netdev.c w/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> >index bcd955339058..b3bfb987e493 100644
> >--- i/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> >+++ w/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> >@@ -1638,10 +1638,10 @@ int mlx4_en_start_port(struct net_device *dev)
> >
> >  	/* Configure tx cq's and rings */
> >  	for (t = 0 ; t < MLX4_EN_NUM_TX_TYPES; t++) {
> >-		u8 num_tx_rings_p_up = t == TX ? priv->num_tx_rings_p_up : 1;
> The bug lies in this line.
> Number of rings per UP in case of TX_XDP should be priv->tx_ring_num[TX_XDP
> ], not 1.
> Please try the following fix.
> I can prepare and send it once the window opens again.
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index bcd955339058..edbe200ac2fa 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1638,7 +1638,8 @@ int mlx4_en_start_port(struct net_device *dev)
>
>         /* Configure tx cq's and rings */
>         for (t = 0 ; t < MLX4_EN_NUM_TX_TYPES; t++) {
> -               u8 num_tx_rings_p_up = t == TX ? priv->num_tx_rings_p_up :
> 1;
> +               u8 num_tx_rings_p_up = t == TX ?
> +                       priv->num_tx_rings_p_up : priv->tx_ring_num[t];
>
>                 for (i = 0; i < priv->tx_ring_num[t]; i++) {
>                         /* Configure cq */
>
Thanks for confirming the bug is related to the user_prio argument.

I have some questions:

1. Just to confirm the intention of the change.  Your change is essentially
   always passing 0 to the user_prio parameter for the TX_XDP type by
   doing (i / priv->tx_ring_num[t])?  If yes, would it be clearer to
   always pass 0 instead?

   And yes, it also works in our test.  Please post an offical patch
   if it is the fix.

2. Can you explain a little on how does the user_prio affect
   the tx behavior?  e.g. What is the difference between
   different user_prio like 0, 1, 2...etc?

3. Mostly a follow up on (2).
   In mlx4_en_get_profile(), num_tx_rings_p_up (of the struct mlx4_en_profile)
   depends on mlx4_low_memory_profile() and number of cpu.  Does these
   similar bounds apply to the 'u8 num_tx_rings_p_up' here for
   TX_XDP type?

Thanks,
Martin

> >-
> >  		for (i = 0; i < priv->tx_ring_num[t]; i++) {
> >  			/* Configure cq */
> >+			int user_prio;
> >+
> >  			cq = priv->tx_cq[t][i];
> >  			err = mlx4_en_activate_cq(priv, cq, i);
> >  			if (err) {
> >@@ -1660,9 +1660,14 @@ int mlx4_en_start_port(struct net_device *dev)
> >
> >  			/* Configure ring */
> >  			tx_ring = priv->tx_ring[t][i];
> >+			if (t != TX_XDP)
> >+				user_prio = i / priv->num_tx_rings_p_up;
> >+			else
> >+				user_prio = i & 0x07;
> >+
> >  			err = mlx4_en_activate_tx_ring(priv, tx_ring,
> >  						       cq->mcq.cqn,
> >-						       i / num_tx_rings_p_up);
> >+						       user_prio);
> >  			if (err) {
> >  				en_err(priv, "Failed allocating Tx ring\n");
> >  				mlx4_en_deactivate_cq(priv, cq);
> Regards,
> Tariq Toukan.
