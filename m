From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 13/15] i40e/i40evf: use logical operators, not bitwise
Date: Mon, 22 Feb 2016 08:33:24 -0800
Message-ID: <CAKgT0Ud+SN85Pq0NokoWjA+Twr=SQDnaHvExrho1RbMUX55ttg@mail.gmail.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1455766737-11911-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@redhat.com>, sassmann@redhat.com,
	John Greene <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33908 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbcBVQdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 11:33:24 -0500
Received: by mail-io0-f177.google.com with SMTP id 9so184346167iom.1
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 08:33:24 -0800 (PST)
In-Reply-To: <1455766737-11911-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 7:38 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
>
> Mr. Spock would certainly raise an eyebrow to see us using bitwise
> operators, when we should clearly be relying on logic. Fascinating.
>
> Change-ID: Ie338010c016f93e9faa2002c07c90b15134b7477
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

NAK

The bitwise operator lets us at least make a pass through all rings.
With this new code you stop as soon as one ring has not completed
cleaning.

> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 5 +++--
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 5 +++--
>  2 files changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index 1abef01..0ffa9a8 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -1996,7 +1996,8 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
>          * budget and be more aggressive about cleaning up the Tx descriptors.
>          */
>         i40e_for_each_ring(ring, q_vector->tx) {
> -               clean_complete &= i40e_clean_tx_irq(ring, vsi->work_limit);
> +               clean_complete = clean_complete &&
> +                                i40e_clean_tx_irq(ring, vsi->work_limit);
>                 arm_wb = arm_wb || ring->arm_wb;
>                 ring->arm_wb = false;
>         }

For example here.  You now will not call i40e_clean_tx_irq if
clean_complete is false.

> @@ -2020,7 +2021,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
>
>                 work_done += cleaned;
>                 /* if we didn't clean as many as budgeted, we must be done */
> -               clean_complete &= (budget_per_ring != cleaned);
> +               clean_complete = clean_complete && (budget_per_ring > cleaned);
>         }
>
>         /* If work not completed, return budget and polling will return */

This code is now slower after this change.
