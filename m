From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] qed: fix qed_fill_link() error handling
Date: Wed, 1 Jun 2016 10:55:02 +0000
Message-ID: <CO2PR11MB0088EB31E72E7E898DE763A797470@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1464623197-2084229-1-git-send-email-arnd@arndb.de>
 <CO2PR11MB00881A57063B9AB617359A9097450@CO2PR11MB0088.namprd11.prod.outlook.com>
 <20160531.142046.2026659803711147043.davem@davemloft.net>
 <5288285.fZuaAytaxX@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Manish Chopra <manish.chopra@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5288285.fZuaAytaxX@wuerfel>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I think both solutions are equally valid/elegant.
> >
> > Arnd?
> 
> I think we can just remove the IS_ENABLED() check there and define the
> IS_PF() macro conditionally to become 'true' if CONFIG_QED_SRIOV is not set,
> like some other drivers do
> 
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c
> b/drivers/net/ethernet/qlogic/qed/qed_main.c
> index 287f61c20c19..756176525cf9 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_main.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
> @@ -1110,7 +1110,7 @@ static int qed_get_link_data(struct qed_hwfn *hwfn,
> {
>  	void *p;
> 
> -	if (IS_ENABLED(CONFIG_QED_SRIOV) && !IS_PF(hwfn->cdev)) {
> +	if (!IS_PF(hwfn->cdev)) {
>  		qed_vf_get_link_params(hwfn, params);
>  		qed_vf_get_link_state(hwfn, link);
>  		qed_vf_get_link_caps(hwfn, link_caps); diff --git
> a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
> b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
> index c8667c65e685..c90b2b6ad969 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
> +++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
> @@ -12,11 +12,13 @@
>  #include "qed_vf.h"
>  #define QED_VF_ARRAY_LENGTH (3)
> 
> +#ifdef CONFIG_QED_SRIOV
>  #define IS_VF(cdev)             ((cdev)->b_is_vf)
>  #define IS_PF(cdev)             (!((cdev)->b_is_vf))
> -#ifdef CONFIG_QED_SRIOV
>  #define IS_PF_SRIOV(p_hwfn)     (!!((p_hwfn)->cdev->p_iov_info))
>  #else
> +#define IS_VF(cdev)             (0)
> +#define IS_PF(cdev)             (1)
>  #define IS_PF_SRIOV(p_hwfn)     (0)
>  #endif
>  #define IS_PF_SRIOV_ALLOC(p_hwfn)       (!!((p_hwfn)->pf_iov_info))
> 
> I don't see why that isn't already the case actually. If this is ok, I'll send an
> updated patch.
> 
> For the PF case, we still need to fix the qed_mcp_get_link_params() failure case,
> so the rest of my patch is needed anyway, regardless of how we address the
> warning.
> 
> 	Arnd

I think that would be unsafe with current qede - 
qede currently publishes its VFs' PCI device-id as part its MODULE_DEVICE_TABLE,
even if CONFIG_QED_SRIOV isn't enabled [might be the wrong thing to do, but that
how it goes].
Without changing this, if for some reason we'd have an assigned VF to a VM
whose kernel isn't compiled with CONFIG_QED_SRIOV [which is an odd config],
that VM is likely to miserably crash.
