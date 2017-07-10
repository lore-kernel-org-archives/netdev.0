From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/2] net: ethernet: fsl: add phy reset after clk enable
 option
Date: Mon, 10 Jul 2017 08:26:47 -0500
Message-ID: <20170710132647.evisnuc46vbxmg2e@rob-hp-laptop>
References: <1499346330-12166-1-git-send-email-richard.leitner@skidata.com>
 <1499346330-12166-2-git-send-email-richard.leitner@skidata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fugang.duan-3arQi8VN3Tc@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dev-M/VWbR8SM2SsTnJN9+BGXg@public.gmane.org
To: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1499346330-12166-2-git-send-email-richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 06, 2017 at 03:05:30PM +0200, Richard Leitner wrote:
> Some PHYs (for example the LAN8710) doesn't allow turning the clocks off
> and on again without reset (according to their datasheet). Exactly this
> behaviour was introduced for power saving reasons by commit e8fcfcd5684a
> ("net: fec: optimize the clock management to save power")
> Therefore add a devictree option to perform a PHY reset and
> configuration after every clock enable.
> 
> For a better understanding here's a outline of the time response of the
> clock and reset lines before and after this patch:
> 
> 			  v--fec_probe()              v--fec_enet_open()
> 			  v                           v
> 	w/o patch eCLK: ___||||||||____________________|||||||||||||||||
> 	w/o patch nRST: ----__------------------------------------------
> 	w/o patch CONF: _______XX_______________________________________
> 
> 	w/  patch eCLK: ___||||||||____________________|||||||||||||||||
> 	w/  patch nRST: ----__--------------------------__--------------
> 	w/  patch CONF: _______XX__________________________XX___________
> 			  ^                           ^
> 			  ^--fec_probe()              ^--fec_enet_open()
> 
> In our case this problem does occur at about every 10th to 50th POR of
> an LAN8710 connected to an i.MX6 SoC. The typical symptom of this
> problem is a "swinging" ethernet link. Similar issues were experienced
> by users of the NXP forum:
> 	https://community.nxp.com/thread/389902
> 	https://community.nxp.com/message/309354
> With this patch applied the issue didn't occur for at least a few
> hundred PORs of our board.
> 
> Fixes: e8fcfcd5684a ("net: fec: optimize the clock management to sa...")
> Signed-off-by: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/fsl-fec.txt |  3 +++
>  drivers/net/ethernet/freescale/fec.h              |  1 +
>  drivers/net/ethernet/freescale/fec_main.c         | 16 ++++++++++++++++
>  3 files changed, 20 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> index 6f55bdd..1766579 100644
> --- a/Documentation/devicetree/bindings/net/fsl-fec.txt
> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> @@ -23,6 +23,9 @@ Optional properties:
>  - phy-handle : phandle to the PHY device connected to this device.
>  - fixed-link : Assume a fixed link. See fixed-link.txt in the same directory.
>    Use instead of phy-handle.
> +- phy-reset-after-clk-enable : If present then a phy reset and configuration
> +  will be performed everytime after the clocks are enabled. This is required
> +  for some PHYs to work properly.

Maybe this is not needed based on the discussion, but just to make 
sure. Since this is a property of the phy, it should be implied from the 
phy's compatible string.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
