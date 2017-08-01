From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Tue, 1 Aug 2017 14:55:19 -0700
Message-ID: <1af0df70-c8a9-f327-abba-9c977c4dfdc9@gmail.com>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36894 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752465AbdHAVzX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 17:55:23 -0400
Received: by mail-wm0-f66.google.com with SMTP id t138so4887693wmt.4
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 14:55:23 -0700 (PDT)
In-Reply-To: <1501623460-3575-2-git-send-email-timur@codeaurora.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2017 02:37 PM, Timur Tabi wrote:
> The EMAC has a curious qwirk when RX flow control is enabled and the
> kernel hangs.  With the kernel hung, the EMAC's RX queue soon fills.
> If RX flow control is enabled, the EMAC will then send a non-stop
> stream of pause frames until the system is reset.  The EMAC does not
> have a built-in watchdog.
> 
> In various tests, the pause frame stream sometimes overloads nearby
> switches, effectively disabling the network.  Since the RX queue is
> large and the host processor is more than capable of handling incoming
> packets quickly, the only time the EMAC will send any pause frames is
> when the kernel is hung and unrecoverable.

This is not specific to your EMAC, a lot of adapters have this problem
actually.

I wonder if it would make sense to reach for a broader solution where we
could have a networking stack panic/oops notifier which will actively
clean up the active network devices' RX queue(s) and if tx_pause was
enabled, disable it. We could have drivers announce themselves as
needing this either via NETIF_F_* feature bit or some other private flag.

> 
> To avoid all these problems, we disable flow control autonegotiation
> by default, and only enable receiving pause frames.
> 
> Cc: stable@vger.kernel.org # 4.11.x
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
>  drivers/net/ethernet/qualcomm/emac/emac.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
> index 60850bfa3d32..475c0ea29235 100644
> --- a/drivers/net/ethernet/qualcomm/emac/emac.c
> +++ b/drivers/net/ethernet/qualcomm/emac/emac.c
> @@ -441,8 +441,13 @@ static void emac_init_adapter(struct emac_adapter *adpt)
>  	/* others */
>  	adpt->preamble = EMAC_PREAMBLE_DEF;
>  
> -	/* default to automatic flow control */
> -	adpt->automatic = true;
> +	/* Disable transmission of pause frames by default, to avoid the
> +	 * risk of a pause frame flood that can occur if the kernel hangs.
> +	 * We still want to be able to respond to them, however.
> +	 */
> +	adpt->automatic = false;
> +	adpt->tx_flow_control = false;
> +	adpt->rx_flow_control = true;
>  }
>  
>  /* Get the clock */
> 


-- 
Florian
