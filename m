From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 2 Aug 2017 01:15:54 +0200
Message-ID: <20170801231554.GA8415@lunn.ch>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48381 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751681AbdHAXQA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 19:16:00 -0400
Content-Disposition: inline
In-Reply-To: <1501623460-3575-2-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 01, 2017 at 04:37:39PM -0500, Timur Tabi wrote:
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

Hi Timur

Pause frames are something you can auto-negotiate at the PHY
level. Should you also be clearing some bits in the phydev, so the
peer knows pause frames are not supported?

     Andrew
