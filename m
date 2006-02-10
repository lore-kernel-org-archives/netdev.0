From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [GIT PULL] bcm43xx: Update B6PHY initialization
Date: Thu, 9 Feb 2006 19:51:12 -0500
Message-ID: <20060210005107.GD27279@tuxdriver.com>
References: <43DFFB6C.9050907@gentoo.org> <20060201002101.GA8306@havoc.gtf.org> <200602011051.00973.kugelfang@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Danny van Dyk <kugelfang-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200602011051.00973.kugelfang-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

In the future, please include a Signed-off-by: line in your patches
or git commits...thanks!

John

On Wed, Feb 01, 2006 at 10:51:00AM +0100, Danny van Dyk wrote:
> John, please
> 
> git pull rsync://pitr.amd64.dev.gentoo.org/kugelfang/wireless-2.6.git
> 
> which will provide this changeset:
> 
> Danny van Dyk:
>       [bcm43xx] Sync bcm43xx_phy_initb6() with specs
> 
> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c 
> b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
> index f5e7a6a..d90f207 100644
> --- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
> @@ -947,7 +947,7 @@ static void bcm43xx_phy_initb6(struct bc
>  	bcm43xx_radio_write16(bcm, 0x0050, 0x0020);
>  	if ((bcm->current_core->radio->manufact == 0x17F) &&
>  	    (bcm->current_core->radio->version == 0x2050) &&
> -	    (bcm->current_core->radio->revision == 2)) {
> +	    (bcm->current_core->radio->revision <= 2)) {
>  		bcm43xx_radio_write16(bcm, 0x0050, 0x0020);
>  		bcm43xx_radio_write16(bcm, 0x005A, 0x0070);
>  		bcm43xx_radio_write16(bcm, 0x005B, 0x007B);
> @@ -984,10 +984,15 @@ static void bcm43xx_phy_initb6(struct bc
>  		bcm43xx_write16(bcm, 0x03E4, 0x0009);
>  	if (phy->type == BCM43xx_PHYTYPE_B) {
>  		bcm43xx_write16(bcm, 0x03E6, 0x8140);
> -		bcm43xx_phy_write(bcm, 0x0016, 0x5410);
> -		bcm43xx_phy_write(bcm, 0x0017, 0xA820);
> -		bcm43xx_phy_write(bcm, 0x0007, 0x0062);
> -		TODO();//TODO: calibrate stuff.
> +		bcm43xx_phy_write(bcm, 0x0016, 0x0410);
> +		bcm43xx_phy_write(bcm, 0x0017, 0x0820);
> +		bcm43xx_phy_write(bcm, 0x0062, 0x0007);
> +		(void) bcm43xx_radio_calibrationvalue(bcm);
> +		bcm43xx_phy_lo_b_measure(bcm);
> +		if (bcm->sprom.boardflags & BCM43xx_BFL_RSSI) {
> +			bcm43xx_calc_nrssi_slope(bcm);
> +			bcm43xx_calc_nrssi_threshold(bcm);
> +		}
>  		bcm43xx_phy_init_pctl(bcm);
>  	} else
>  		bcm43xx_write16(bcm, 0x03E6, 0x0);
> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c 
> b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
> index 5ce6ace..3901aa9 100644
> --- a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
> @@ -1184,7 +1184,7 @@ int bcm43xx_radio_set_interference_mitig
>  	return 0;
>  }
>  
> -static u16 bcm43xx_radio_calibrationvalue(struct bcm43xx_private *bcm)
> +u16 bcm43xx_radio_calibrationvalue(struct bcm43xx_private *bcm)
>  {
>  	u16 reg, index, ret;
>  
> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_radio.h 
> b/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
> index 89fe292..a5d2e10 100644
> --- a/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
> @@ -89,5 +89,6 @@ void bcm43xx_nrssi_hw_update(struct bcm4
>  void bcm43xx_nrssi_mem_update(struct bcm43xx_private *bcm);
>  
>  void bcm43xx_radio_set_tx_iq(struct bcm43xx_private *bcm);
> +u16 bcm43xx_radio_calibrationvalue(struct bcm43xx_private *bcm);
>  
>  #endif /* BCM43xx_RADIO_H_ */
> -- 
> Danny van Dyk <kugelfang-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
> Gentoo/AMD64 Project, Gentoo Scientific Project
> 
> -- 
> Danny van Dyk <kugelfang-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
> Gentoo/AMD64 Project, Gentoo Scientific Project

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
