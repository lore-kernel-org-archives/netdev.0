From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: [PATCH] forcedeth: mac address fix
Date: Tue, 1 Apr 2008 02:05:02 +0200
Message-ID: <20080401000502.GB7423@atjola.homenet>
References: <47F1534A.7020402@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:55434 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750727AbYDAAFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 20:05:07 -0400
Content-Disposition: inline
In-Reply-To: <47F1534A.7020402@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008.03.31 16:10:34 -0500, Ayaz Abdulla wrote:
> This critical patch fixes a mac address issue recently introduced. If=
 =20

Does "recently" mean my commit 2e3884b5b16795c03a7bf295797c1b2402885b88=
?
If so, I like to be told directly when I break stuff ;-)

> the device's mac address was in correct order and the flag =20
> NVREG_TRANSMITPOLL_MAC_ADDR_REV was set, during nv_remove the flag wo=
uld =20
> get cleared. During next load, the mac address would get reversed =20
> because the flag is missing.

Hm, but nv_remove also writes back the reversed mac address. I don't se=
e
how a plain remove/probe cycle would mess things up.

> As it has been indicated previously, the flag is cleared across a low=
 =20
> power transition. Therefore, the driver should set the mac address ba=
ck =20
> into the reversed order when clearing the flag.

That's what nv_remove is supposed to do. Is there a case where nv_remov=
e
is not called?

> Also, the driver should set back the flag after a low power transitio=
n =20
> to protect against kexec command calling nv_probe a second time.

Sounds like suspend stopped calling nv_remove? That would make sense
then. I never checked whether suspend ever actually did call nv_remove
(I think), but as my patch worked, it basically must have done so, at
least in the past, right?

Thanks,
Bj=F6rn

>
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
>

> --- old/drivers/net/forcedeth.c	2008-03-31 15:25:05.000000000 -0700
> +++ new/drivers/net/forcedeth.c	2008-03-31 15:41:51.000000000 -0700
> @@ -5317,8 +5317,7 @@
> =20
>  	/* check the workaround bit for correct mac address order */
>  	txreg =3D readl(base + NvRegTransmitPoll);
> -	if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
> -	    (id->driver_data & DEV_HAS_CORRECT_MACADDR)) {
> +	if (id->driver_data & DEV_HAS_CORRECT_MACADDR) {
>  		/* mac address is already in correct order */
>  		dev->dev_addr[0] =3D (np->orig_mac[0] >>  0) & 0xff;
>  		dev->dev_addr[1] =3D (np->orig_mac[0] >>  8) & 0xff;
> @@ -5326,6 +5325,22 @@
>  		dev->dev_addr[3] =3D (np->orig_mac[0] >> 24) & 0xff;
>  		dev->dev_addr[4] =3D (np->orig_mac[1] >>  0) & 0xff;
>  		dev->dev_addr[5] =3D (np->orig_mac[1] >>  8) & 0xff;
> +	} else if (txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) {
> +		/* mac address is already in correct order */
> +		dev->dev_addr[0] =3D (np->orig_mac[0] >>  0) & 0xff;
> +		dev->dev_addr[1] =3D (np->orig_mac[0] >>  8) & 0xff;
> +		dev->dev_addr[2] =3D (np->orig_mac[0] >> 16) & 0xff;
> +		dev->dev_addr[3] =3D (np->orig_mac[0] >> 24) & 0xff;
> +		dev->dev_addr[4] =3D (np->orig_mac[1] >>  0) & 0xff;
> +		dev->dev_addr[5] =3D (np->orig_mac[1] >>  8) & 0xff;
> +		/*
> +		 * Set orig mac address back to the reversed version.
> +		 * This flag will be cleared during low power transition.
> +		 * Therefore, we should always put back the reversed address.
> +		 */
> +		np->orig_mac[0] =3D (dev->dev_addr[5] << 0) + (dev->dev_addr[4] <<=
 8) +
> +			(dev->dev_addr[3] << 16) + (dev->dev_addr[2] << 24);
> +		np->orig_mac[1] =3D (dev->dev_addr[1] << 0) + (dev->dev_addr[0] <<=
 8);
>  	} else {
>  		/* need to reverse mac address to correct order */
>  		dev->dev_addr[0] =3D (np->orig_mac[1] >>  8) & 0xff;
> @@ -5596,7 +5611,9 @@
>  static int nv_resume(struct pci_dev *pdev)
>  {
>  	struct net_device *dev =3D pci_get_drvdata(pdev);
> +	u8 __iomem *base =3D get_hwbase(dev);
>  	int rc =3D 0;
> +	u32 txreg;
> =20
>  	if (!netif_running(dev))
>  		goto out;
> @@ -5607,6 +5624,11 @@
>  	pci_restore_state(pdev);
>  	pci_enable_wake(pdev, PCI_D0, 0);
> =20
> +	/* restore mac address reverse flag */
> +	txreg =3D readl(base + NvRegTransmitPoll);
> +	txreg |=3D NVREG_TRANSMITPOLL_MAC_ADDR_REV;
> +	writel(txreg, base + NvRegTransmitPoll);
> +
>  	rc =3D nv_open(dev);
>  out:
>  	return rc;

