From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] qede: fix CONFIG_INFINIBAND_QEDR=m build error
Date: Thu, 13 Oct 2016 08:50:21 +0000
Message-ID: <BL2PR07MB23069C99213F4E89A7DC162A8DDC0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20161012103340.978726-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
        "everest-linux-l2@qlogic.com" <everest-linux-l2@qlogic.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        "Amrani, Ram" <Ram.Amrani@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0059.outbound.protection.outlook.com ([104.47.34.59]:55346
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752777AbcJMJYh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 05:24:37 -0400
In-Reply-To: <20161012103340.978726-1-arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  config INFINIBAND_QEDR
> -	tristate "QLogic qede RoCE sources [debug]"
> +	bool "QLogic qede RoCE sources [debug]"

Given that the qedr submission is going to turn this back into a tristate,
are you certain this is a good thing [from compilation coverage perspective=
]?

> -		if (cond)
> +		if (IS_ENABLED(CONFIG_INFINIBAND_QEDR) && cond)
>			qed_rdma_dpm_bar(p_hwfn, p_ptt);

Why not simply fix the qed_roce.h empty implementation?

> -#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
>  	/* Roce CNQ each requires: 1 status block + 1 CNQ. We divide the
>  	 * status blocks equally between L2 / RoCE but with consideration as
>  	 * to how many l2 queues / cnqs we have
>  	 */
> -	if (p_hwfn->hw_info.personality =3D=3D QED_PCI_ETH_ROCE) {
> +	if (IS_ENABLED(CONFIG_INFINIBAND_QEDR) &&
> +	    p_hwfn->hw_info.personality =3D=3D QED_PCI_ETH_ROCE) {
>  		num_features++;
>=20
>  		feat_num[QED_RDMA_CNQ] =3D
>  			min_t(u32, RESC_NUM(p_hwfn, QED_SB) /
> num_features,
>  			      RESC_NUM(p_hwfn, QED_RDMA_CNQ_RAM));
>  	}
> -#endif

Is there any non-cosmetic gain here?
I would gain that having the comment under the #ifdef is more meaningful
than having the check in the actual condition.

> -#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
> +	if (!IS_ENABLED(CONFIG_INFINIBAND_QEDR))
> +		return 0;
> +
>  	num_l2_queues =3D 0;
>  	for_each_hwfn(cdev, i)
>  		num_l2_queues +=3D FEAT_NUM(&cdev->hwfns[i],
> QED_PF_L2_QUE); @@ -738,7 +736,6 @@ static int
> qed_slowpath_setup_int(struct qed_dev *cdev,
>  	DP_VERBOSE(cdev, QED_MSG_RDMA, "roce_msix_cnt=3D%d
> roce_msix_base=3D%d\n",
>  		   cdev->int_params.rdma_msix_cnt,
>  		   cdev->int_params.rdma_msix_base);
> -#endif

While I don't mind, you could have argued is that we're not
removing enough, not too much.
I.e., perhaps the rdma_msix_* fields should also have been
ifdef-ed instead. [in which case this solution would not have worked]

> -#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
> -	params->rdma_pf_params.num_qps =3D QED_ROCE_QPS;
> -	params->rdma_pf_params.min_dpis =3D QED_ROCE_DPIS;
> -	/* divide by 3 the MRs to avoid MF ILT overflow */
> -	params->rdma_pf_params.num_mrs =3D RDMA_MAX_TIDS;
> -	params->rdma_pf_params.gl_pi =3D QED_ROCE_PROTOCOL_INDEX;
> -#endif
> +	if (IS_ENABLED(CONFIG_INFINIBAND_QEDR)) {
> +		params->rdma_pf_params.num_qps =3D QED_ROCE_QPS;
> +		params->rdma_pf_params.min_dpis =3D QED_ROCE_DPIS;
> +		/* divide by 3 the MRs to avoid MF ILT overflow */
> +		params->rdma_pf_params.num_mrs =3D RDMA_MAX_TIDS;
> +		params->rdma_pf_params.gl_pi =3D
> QED_ROCE_PROTOCOL_INDEX;
> +	}

Likewise

> -#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
> -	case PROTOCOLID_ROCE:
> -		qed_async_roce_event(p_hwfn, p_eqe);
> -		return 0;
> -#endif
>  	case PROTOCOLID_COMMON:
>  		return qed_sriov_eqe_event(p_hwfn,
>  					   p_eqe->opcode,
>  					   p_eqe->echo, &p_eqe->data);
> +	case PROTOCOLID_ROCE:
> +		if (IS_ENABLED(CONFIG_INFINIBAND_QEDR)) {
> +			qed_async_roce_event(p_hwfn, p_eqe);
> +			return 0;
> +		}
> +		/* fallthrough */

Not sure whether it helps readability; It might give the false
Impression that it's possible to receive an async roce event if
roce is compiled-out, which isn't the case.
