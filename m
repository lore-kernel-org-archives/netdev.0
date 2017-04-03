From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/5] qed: Fix TM block ILT allocation
Date: Mon, 3 Apr 2017 14:46:20 +0300
Message-ID: <7b179126-2a66-8696-98f9-3f3dca7a6d9e@cogentembedded.com>
References: <1491211273-10910-1-git-send-email-Yuval.Mintz@cavium.com>
 <1491211273-10910-3-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michal Kalderon <Michal.Kalderon@cavium.com>
To: Yuval Mintz <Yuval.Mintz@cavium.com>, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:33426 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751649AbdDCLqW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 07:46:22 -0400
Received: by mail-lf0-f53.google.com with SMTP id h125so71177005lfe.0
        for <netdev@vger.kernel.org>; Mon, 03 Apr 2017 04:46:21 -0700 (PDT)
In-Reply-To: <1491211273-10910-3-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/2017 12:21 PM, Yuval Mintz wrote:

> From: Michal Kalderon <Michal.Kalderon@cavium.com>
>
> When configuring the HW timers block we should set the number of CIDs
> up until the last CID that require timers, instead of only those CIDs
> whose protocol needs timers support.
>
> Today, the protocols that require HW timers' support have their CIDs
> before any other protocol, but that would change in future [when we
> add iWARP support].
>
> Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> ---
>  drivers/net/ethernet/qlogic/qed/qed_cxt.c | 32 ++++++++++++++++++++++++-------
>  1 file changed, 25 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
> index 1012b3c..259dafa 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
> @@ -303,16 +303,34 @@ struct qed_tm_iids {
>  	u32 per_vf_tids;
>  };
>
> -static void qed_cxt_tm_iids(struct qed_cxt_mngr *p_mngr,
> +static void qed_cxt_tm_iids(struct qed_hwfn *p_hwfn,
> +			    struct qed_cxt_mngr *p_mngr,
>  			    struct qed_tm_iids *iids)
>  {
> -	u32 i, j;
> -
> -	for (i = 0; i < MAX_CONN_TYPES; i++) {
> +	bool tm_vf_required = false;
> +	bool tm_required = false;
> +	int i, j;
> +
> +	/* Timers is a special case -> we don't count how many cids require

    S/is/are/. CIDs?

> +	 * timers but what's the max cid that will be used by the timer block.
> +	 * therefore we traverse in reverse order, and once we hit a protocol
> +	 * that requires the timers memory, we'll sum all the protocols up
> +	 * to that one.
> +	 */
> +	for (i = MAX_CONN_TYPES - 1; i >= 0; i--) {
[...]

MBR, Sergei
