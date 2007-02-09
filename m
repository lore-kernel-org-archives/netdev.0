From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Fri, 9 Feb 2007 18:11:40 +0100
Message-ID: <200702091811.40683.mb@bu3sch.de>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 09 February 2007 17:32, Larry Finger wrote:
> The specifications for the bcm43xx driver have been modified. This patch
> incorporates these changes in the code, which results in the BCM4311 and
> BCM4312 working. The name of one of the PHY parameters, previously known
> as "version", has been changed to "analog core version" .
> 
> Signed-off-by: Larry Finger<Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---

> @@ -729,19 +729,19 @@ static void bcm43xx_phy_initb5(struct bc
>  	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
>  	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
>  	u16 offset;
> +	u16 value;
> +	u8 old_channel;
>  
> -	if (phy->version == 1 &&
> -	    radio->version == 0x2050) {

Why do you delete the check to radio version.
It's still there in latest specs:
http://bcm-v4.sipsolutions.net/802.11/PHY/Init/B5

> +	if (phy->analog == 1)
>  		bcm43xx_radio_write16(bcm, 0x007A,
>  				      bcm43xx_radio_read16(bcm, 0x007A)
>  				      | 0x0050);
> -	}
>  	if ((bcm->board_vendor != PCI_VENDOR_ID_BROADCOM) &&
>  	    (bcm->board_type != 0x0416)) {
> +		value = 0x2120;
>  		for (offset = 0x00A8 ; offset < 0x00C7; offset++) {
> -			bcm43xx_phy_write(bcm, offset,
> -					  (bcm43xx_phy_read(bcm, offset) + 0x2020)
> -					  & 0x3F3F);
> +			bcm43xx_phy_write(bcm, offset, value);
> +			value += 0x0202;
>  		}

I don't see how this matches specs.

>  	}
>  	bcm43xx_phy_write(bcm, 0x0035,
> @@ -776,7 +776,7 @@ static void bcm43xx_phy_initb5(struct bc
>  				  bcm43xx_phy_read(bcm, BCM43xx_PHY_RADIO_BITFIELD) | (1 << 11));
>  	}
>  
> -	if (phy->version == 1 && radio->version == 0x2050) {

Dito.

> +	if (phy->analog == 1) {
>  		bcm43xx_phy_write(bcm, 0x0026, 0xCE00);
>  		bcm43xx_phy_write(bcm, 0x0021, 0x3763);
>  		bcm43xx_phy_write(bcm, 0x0022, 0x1BC3);
> @@ -787,14 +787,15 @@ static void bcm43xx_phy_initb5(struct bc
>  	bcm43xx_phy_write(bcm, 0x0030, 0x00C6);
>  	bcm43xx_write16(bcm, 0x03EC, 0x3F22);
>  
> -	if (phy->version == 1 && radio->version == 0x2050)

Dito.

> +	if (phy->analog == 1)
>  		bcm43xx_phy_write(bcm, 0x0020, 0x3E1C);
>  	else
>  		bcm43xx_phy_write(bcm, 0x0020, 0x301C);
>  
> -	if (phy->version == 0)
> +	if (phy->analog == 0)
>  		bcm43xx_write16(bcm, 0x03E4, 0x3000);
>  
> +	old_channel = radio->channel;
>  	/* Force to channel 7, even if not supported. */
>  	bcm43xx_radio_selectchannel(bcm, 7, 0);
>  
> @@ -816,11 +817,11 @@ static void bcm43xx_phy_initb5(struct bc
>  
>  	bcm43xx_radio_write16(bcm, 0x007A, bcm43xx_radio_read16(bcm, 0x007A) | 0x0007);
>  
> -	bcm43xx_radio_selectchannel(bcm, BCM43xx_RADIO_DEFAULT_CHANNEL_BG, 0);
> +	bcm43xx_radio_selectchannel(bcm, old_channel, 0);
>  
>  	bcm43xx_phy_write(bcm, 0x0014, 0x0080);
>  	bcm43xx_phy_write(bcm, 0x0032, 0x00CA);
> -	bcm43xx_phy_write(bcm, 0x88A3, 0x002A);
> +	bcm43xx_phy_write(bcm, 0x002A, 0x88A3);

Well, this seems correct, but specs are still different. From where did you get this?


Well, I don't review the rest until you say to which specs you did the changes. ;)

-- 
Greetings Michael.
