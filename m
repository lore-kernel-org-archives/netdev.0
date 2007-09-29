From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] via-velocity: more cleanup
Date: Sat, 29 Sep 2007 01:28:12 -0400
Message-ID: <46FDE26C.6010000@garzik.org>
References: <20070824135649.509e1fe7@freepuppy.rosehill.hemminger.net>	<20070824211547.GW21089@ftp.linux.org.uk> <20070824144045.087d41ff@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ftp.linux.org.uk>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42994 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752417AbXI2F2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 01:28:23 -0400
In-Reply-To: <20070824144045.087d41ff@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Per Al's suggestion, get rid of the stupid stuff:
> Remove cam_type switch,
> And deinline things that aren't important for speed.
> And make big macro and inline.
> And remove some dead/unused code.
> And use const char * for chip name.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> 
> --- a/drivers/net/via-velocity.c	2007-08-24 13:49:17.000000000 -0700
> +++ b/drivers/net/via-velocity.c	2007-08-24 14:39:14.000000000 -0700
> @@ -85,6 +85,163 @@
>  static int velocity_nics = 0;
>  static int msglevel = MSG_LEVEL_INFO;
>  
> +/**
> + *	mac_get_cam_mask	-	Read a CAM mask
> + *	@regs: register block for this velocity
> + *	@mask: buffer to store mask
> + *
> + *	Fetch the mask bits of the selected CAM and store them into the
> + *	provided mask buffer.
> + */
> +
> +static void mac_get_cam_mask(struct mac_regs __iomem * regs, u8 * mask)
> +{
> +	int i;
> +
> +	/* Select CAM mask */
> +	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
> +
> +	writeb(0, &regs->CAMADDR);
> +
> +	/* read mask */
> +	for (i = 0; i < 8; i++)
> +		*mask++ = readb(&(regs->MARCAM[i]));
> +
> +	/* disable CAMEN */
> +	writeb(0, &regs->CAMADDR);
> +
> +	/* Select mar */
> +	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
> +
> +}
> +
> +
> +/**
> + *	mac_set_cam_mask	-	Set a CAM mask
> + *	@regs: register block for this velocity
> + *	@mask: CAM mask to load
> + *
> + *	Store a new mask into a CAM
> + */
> +
> +static void mac_set_cam_mask(struct mac_regs __iomem * regs, u8 * mask)
> +{
> +	int i;
> +	/* Select CAM mask */
> +	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
> +
> +	writeb(CAMADDR_CAMEN, &regs->CAMADDR);
> +
> +	for (i = 0; i < 8; i++) {
> +		writeb(*mask++, &(regs->MARCAM[i]));
> +	}
> +	/* disable CAMEN */
> +	writeb(0, &regs->CAMADDR);
> +
> +	/* Select mar */
> +	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
> +}


I applied both your via-velocity cleanups.  For future patches, please 
always separate code movement into a separate patch from other cleanups.

