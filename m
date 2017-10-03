From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 net-next 06/12] qed: Add LL2 slowpath handling
Date: Tue, 3 Oct 2017 16:26:32 +0300
Message-ID: <20171003132632.GB25829@mtr-leonro.local>
References: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
 <1507020902-4952-7-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="f2QGlHpHGjS2mn6Y"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1507020902-4952-7-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--f2QGlHpHGjS2mn6Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 03, 2017 at 11:54:56AM +0300, Michal Kalderon wrote:
> For iWARP unaligned MPA flow, a slowpath event of flushing an
> MPA connection that entered an unaligned state is required.
> The flush ramrod is received on the ll2 queue, and a pre-registered
> callback function is called to handle the flush event.
>
> Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/qlogic/qed/qed_ll2.c | 40 +++++++++++++++++++++++++++++--
>  include/linux/qed/qed_ll2_if.h            |  5 ++++
>  2 files changed, 43 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
> index 8eb9645..047f556 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
> @@ -423,6 +423,41 @@ static void qed_ll2_rxq_parse_reg(struct qed_hwfn *p_hwfn,
>  }
>
>  static int
> +qed_ll2_handle_slowpath(struct qed_hwfn *p_hwfn,
> +			struct qed_ll2_info *p_ll2_conn,
> +			union core_rx_cqe_union *p_cqe,
> +			unsigned long *p_lock_flags)
> +{
> +	struct qed_ll2_rx_queue *p_rx = &p_ll2_conn->rx_queue;
> +	struct core_rx_slow_path_cqe *sp_cqe;
> +
> +	sp_cqe = &p_cqe->rx_cqe_sp;
> +	if (sp_cqe->ramrod_cmd_id != CORE_RAMROD_RX_QUEUE_FLUSH) {
> +		DP_NOTICE(p_hwfn,
> +			  "LL2 - unexpected Rx CQE slowpath ramrod_cmd_id:%d\n",
> +			  sp_cqe->ramrod_cmd_id);
> +		return -EINVAL;
> +	}
> +
> +	if (!p_ll2_conn->cbs.slowpath_cb) {
> +		DP_NOTICE(p_hwfn,
> +			  "LL2 - received RX_QUEUE_FLUSH but no callback was provided\n");
> +		return -EINVAL;
> +	}
> +
> +	spin_unlock_irqrestore(&p_rx->lock, *p_lock_flags);

Interesting, you are unlock the lock which was taken in upper layer.
It is not actual error, but chances to have such error are pretty high
(for example, after refactoring).

> +
> +	p_ll2_conn->cbs.slowpath_cb(p_ll2_conn->cbs.cookie,
> +				    p_ll2_conn->my_id,
> +				    le32_to_cpu(sp_cqe->opaque_data.data[0]),
> +				    le32_to_cpu(sp_cqe->opaque_data.data[1]));
> +
> +	spin_lock_irqsave(&p_rx->lock, *p_lock_flags);
> +
> +	return 0;
> +}
> +
> +static int
>  qed_ll2_rxq_handle_completion(struct qed_hwfn *p_hwfn,
>  			      struct qed_ll2_info *p_ll2_conn,
>  			      union core_rx_cqe_union *p_cqe,
> @@ -495,8 +530,8 @@ static int qed_ll2_rxq_completion(struct qed_hwfn *p_hwfn, void *cookie)
>
>  		switch (cqe->rx_cqe_sp.type) {
>  		case CORE_RX_CQE_TYPE_SLOW_PATH:
> -			DP_NOTICE(p_hwfn, "LL2 - unexpected Rx CQE slowpath\n");
> -			rc = -EINVAL;
> +			rc = qed_ll2_handle_slowpath(p_hwfn, p_ll2_conn,
> +						     cqe, &flags);
>  			break;
>  		case CORE_RX_CQE_TYPE_GSI_OFFLOAD:
>  		case CORE_RX_CQE_TYPE_REGULAR:
> @@ -1214,6 +1249,7 @@ static int qed_ll2_acquire_connection_tx(struct qed_hwfn *p_hwfn,
>  	p_ll2_info->cbs.rx_release_cb = cbs->rx_release_cb;
>  	p_ll2_info->cbs.tx_comp_cb = cbs->tx_comp_cb;
>  	p_ll2_info->cbs.tx_release_cb = cbs->tx_release_cb;
> +	p_ll2_info->cbs.slowpath_cb = cbs->slowpath_cb;
>  	p_ll2_info->cbs.cookie = cbs->cookie;
>
>  	return 0;
> diff --git a/include/linux/qed/qed_ll2_if.h b/include/linux/qed/qed_ll2_if.h
> index 95fdf02..e755954 100644
> --- a/include/linux/qed/qed_ll2_if.h
> +++ b/include/linux/qed/qed_ll2_if.h
> @@ -151,11 +151,16 @@ struct qed_ll2_comp_rx_data {
>  				     dma_addr_t first_frag_addr,
>  				     bool b_last_fragment, bool b_last_packet);
>
> +typedef
> +void (*qed_ll2_slowpath_cb)(void *cxt, u8 connection_handle,
> +			    u32 opaque_data_0, u32 opaque_data_1);
> +
>  struct qed_ll2_cbs {
>  	qed_ll2_complete_rx_packet_cb rx_comp_cb;
>  	qed_ll2_release_rx_packet_cb rx_release_cb;
>  	qed_ll2_complete_tx_packet_cb tx_comp_cb;
>  	qed_ll2_release_tx_packet_cb tx_release_cb;
> +	qed_ll2_slowpath_cb slowpath_cb;
>  	void *cookie;
>  };
>
> --
> 1.8.3.1
>

--f2QGlHpHGjS2mn6Y
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnTkAgACgkQ5GN7iDZy
WKdBGQ/9HC9cbuj1NgbkVCUy7s2zJ6dSg/9TxCfoeMn2Dnq93UgzmXbzSmhrkdsW
8WqMeKiMrfYlKven1FD4keJzoqaoxoAkKD37YPm/8iJHAhugIfrih0g3qhnXYcv0
AMEEZ5uPghFoS1j7a3hweY944OfBP3MPtN+Q+05Mxys1+Y6b61o7GHrv2puePCPK
ZE/z22N8MGCSjWO/8gtSU2dmeC3NTYvyuyIVXcHmLGi8nPjujx0jkkwzA4rDUF0K
DrRTlhwWxwcdpGNk1JIhgVRNezsit4jezV4eEN3ik8f6SIBi0H0pQs7kkwJcLTeW
vyy+iXUWfw4weWx2E4AT75R7NiE2Er0Ysr/7w0USmUa0G/AFX3kyzY6+bIh0IJXQ
6JoEOkZsJnFhaFkU0NdkI3IOH2MpftEMrE3d6PgWBUgn6b3+2RDi6ax1tG2qLmVs
Qu9/AlLrpENBx0iV8Gp30sj67RBcrA9+By+9YWnuGxLe4wHTLuo2dGEo2oUGZCGS
Hg4duQgfX8vZIW6majMQMPBvLbngbpRWUfPQl67nETaaAyfuX0pKg7LO/E4WBXij
kVa5N1szaRrVJjUA28Lht3XHE/+b0IJDlbcVNwxzHHJVXbLFSDqEKcP48PF7wtj4
xhEqZ4RuHUm/w+CtrdYeVUa+qgBptLZ6U6zN0Tx3K4FJw0K2nX0=
=dBVw
-----END PGP SIGNATURE-----

--f2QGlHpHGjS2mn6Y--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
