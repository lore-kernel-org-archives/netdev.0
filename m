From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH V2] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Fri, 12 Jan 2007 19:53:44 +0100
Message-ID: <200701121953.44630.mb@bu3sch.de>
References: <45a7ceb2.m02aaCgouBsadVk/%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:59467
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964927AbXALSzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jan 2007 13:55:17 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <45a7ceb2.m02aaCgouBsadVk/%Larry.Finger@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 12 January 2007 19:08, Larry Finger wrote:
> The PCI-E modifications to bcm43xx do not set up the interrupt vector
> correctly. Tested with BCM4311 (PCI-E) on x86_64 and BCM4306 (PCI) on i386.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

ACK.

> ---
> 
> John,
> 
> This fix should be applied to wireless-2.6 _AND_ pushed upstream to
> 2.6.20-rcX. Without this patch, none of the PCI-E interfaces will work.
> This version incorporates Michael Buesch's comments, and forgoes some
> code clean-ups that were in the first version/
> 
> Larry
> 
> 
> Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -2704,8 +2704,8 @@ static int bcm43xx_probe_cores(struct bc
>  		sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
>  
>  		/* extract core_id, core_rev, core_vendor */
> -		core_id = (sb_id_hi & 0xFFF0) >> 4;
> -		core_rev = (sb_id_hi & 0xF);
> +		core_id = (sb_id_hi & 0x8FF0) >> 4;
> +		core_rev = ((sb_id_hi & 0xF) | ((sb_id_hi & 0x7000) >> 8));
>  		core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
>  
>  		dprintk(KERN_INFO PFX "Core %d: ID 0x%x, rev 0x%x, vendor 0x%x\n",
> @@ -2876,7 +2876,10 @@ static int bcm43xx_wireless_core_init(st
>  		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
>  		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
>  		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
> -		sbimconfiglow |= 0x32;
> +		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
> +			sbimconfiglow |= 0x32;
> +		else
> +			sbimconfiglow |= 0x53;

This hunk is OK, but I just want to point out that bustype is
always equal to BCM43xx_BUSTYPE_PCI ;)
The 0x53 timeouts are for an SSB-BUS.
So strictly said this hunk is a NOP.

The other hunks are OK, too. They fix real bugs.
Thanks for spotting them, Larry!

>  		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
>  	}
>  
> @@ -3080,7 +3083,7 @@ static int bcm43xx_setup_backplane_pci_c
>  	if (err)
>  		goto out;
>  
> -	if (bcm->current_core->rev < 6 ||
> +	if (bcm->current_core->rev < 6 &&
>  		bcm->current_core->id == BCM43xx_COREID_PCI) {
>  		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
>  		value |= (1 << backplane_flag_nr);
> 
> ---
> 
> 

-- 
Greetings Michael.
