From: William Dauchy <wdauchy@gmail.com>
Subject: Re: [net-next 07/15] ixgbe: Fix handling of NAPI budget when multiple
 queues are enabled per vector
Date: Fri, 27 Nov 2015 09:25:34 +0100
Message-ID: <CAJ75kXZfRUtOvsJtPpbT3JSJwrVO_sY=ePe9MHE0sLj1k1JNtQ@mail.gmail.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com> <1448307376-20063-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <aduyck@mirantis.com>,
	NETDEV <netdev@vger.kernel.org>, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33864 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbbK0IZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 03:25:55 -0500
Received: by lffu14 with SMTP id u14so121224072lff.1
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 00:25:53 -0800 (PST)
In-Reply-To: <1448307376-20063-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jeff,

There is also the equivalent patch for ixgbevf
http://patchwork.ozlabs.org/patch/539065/


On Mon, Nov 23, 2015 at 8:36 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Alexander Duyck <aduyck@mirantis.com>
>
> This patch corrects an issue in which the polling routine would increase
> the budget for Rx to at least 1 per queue if multiple queues were present.
> This would result in Rx packets being processed when the budget was 0 which
> is meant to indicate that no Rx can be handled.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> Tested-by: Darin Miller <darin.j.miller@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index c9b7e5e..4fa94a3 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -2783,7 +2783,8 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
>         ixgbe_for_each_ring(ring, q_vector->tx)
>                 clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
>
> -       if (!ixgbe_qv_lock_napi(q_vector))
> +       /* Exit if we are called by netpoll or busy polling is active */
> +       if ((budget <= 0) || !ixgbe_qv_lock_napi(q_vector))
>                 return budget;
>
>         /* attempt to distribute budget to each queue fairly, but don't allow
> --
> 2.5.0

-- 
William
