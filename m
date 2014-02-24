From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 5/5] be2net: isolate TX workarounds not applicable
 to Skyhawk-R
Date: Mon, 24 Feb 2014 22:15:46 +0300
Message-ID: <530B9A62.9050405@cogentembedded.com>
References: <ad20d448-e798-4898-9823-898de98d54a2@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>
To: Somnath Kotur <somnath.kotur@emulex.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:62943 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbaBXSPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 13:15:50 -0500
Received: by mail-la0-f53.google.com with SMTP id e16so6279325lan.12
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 10:15:48 -0800 (PST)
In-Reply-To: <ad20d448-e798-4898-9823-898de98d54a2@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/24/2014 09:51 AM, Somnath Kotur wrote:

> From: Vasundhara Volam <vasundhara.volam@emulex.com>

> Some of TX workarounds in be_xmit_workarounds() routine
> are not applicable (and result in HW errors) to Skyhawk-R chip.
> Isolate BE3-R/Lancer specific workarounds to a separate routine.
>
> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> ---
>   drivers/net/ethernet/emulex/benet/be_main.c |   42 ++++++++++++++++++--------
>   1 files changed, 29 insertions(+), 13 deletions(-)

> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index f6a4481..6cf6e2a 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
[...]
> @@ -991,6 +981,32 @@ err:
>   	return NULL;
>   }
>
> +static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
> +					   struct sk_buff *skb,
> +					   bool *skip_hw_vlan)
> +{
> +	/* Lancer, SH-R ASICs have a bug wherein Packets that are 32 bytes or
> +	 * less may cause a transmit stall on that port. So the work-around is
> +	 * to pad short packets (<= 32 bytes) to a 36-byte length.
> +	 */
> +	if (unlikely(!BEx_chip(adapter) && skb->len <= 32)) {
> +		if (skb_padto(skb, 36))
> +			goto err;

    Why not just return NULL?

> +		skb->len = 36;
> +	}
> +
> +	if (BEx_chip(adapter) || lancer_chip(adapter)) {
> +		skb = be_lancer_xmit_workarounds(adapter, skb, skip_hw_vlan);
> +		if (!skb)
> +			goto err;

    Likewise...

> +	}
> +
> +	return skb;
> +
> +err:
> +	return NULL;
> +}
> +

WBR, Sergei
