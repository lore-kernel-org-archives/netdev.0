From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 11/23] e1000: Jumbo frames fixes for 82573
Date: Tue, 19 Sep 2006 15:32:28 -0400
Message-ID: <451045CC.7010607@pobox.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172857.4605.51747.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60091 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751055AbWISTcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 15:32:31 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060919172857.4605.51747.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Disable jumbo frames for 82573L alltogether and when ASPM is enabled
> since the hardware has problems with it. For the NICs that do support
> this in the 82573 series we set ERT_2048 to attempt to receive as much
> traffic as early as we can.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index e81aa03..2ecec51 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -3138,11 +3138,13 @@ e1000_change_mtu(struct net_device *netd
>  		}
>  		break;
>  	case e1000_82573:
> -		/* only enable jumbo frames if ASPM is disabled completely
> -		 * this means both bits must be zero in 0x1A bits 3:2 */
> +		/* Jumbo Frames not supported if:
> +		 * - this is not an 82573L device
> +		 * - ASPM is enabled in any way (0x1A bits 3:2) */
>  		e1000_read_eeprom(&adapter->hw, EEPROM_INIT_3GIO_3, 1,
>  		                  &eeprom_data);
> -		if (eeprom_data & EEPROM_WORD1A_ASPM_MASK) {
> +		if ((adapter->hw.device_id != E1000_DEV_ID_82573L) ||
> +		    (eeprom_data & EEPROM_WORD1A_ASPM_MASK)) {
>  			if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
>  				DPRINTK(PROBE, ERR,
>  			            	"Jumbo Frames not supported.\n");

NAK.  at probe time, set a jumbo-frames-enabled bit, then test it in 
e1000_change_mtu().

Don't include all this chip-checking code into the change_mtu function.


