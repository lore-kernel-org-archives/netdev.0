From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sun, 1 Jul 2007 14:55:50 +0200
Message-ID: <200707011455.50734.mb@bu3sch.de>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com> <20070630081302.66b1d984@oldman> <4354d3270707010549x940a593v1cac2a7478fdd46f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	zambrano@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, power@bughost.org
To: "=?iso-8859-1?q?T=F6r=F6k?= Edvin" <edwintorok@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:58135
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755960AbXGAM4t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 08:56:49 -0400
In-Reply-To: <4354d3270707010549x940a593v1cac2a7478fdd46f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 01 July 2007 14:49:23 T=F6r=F6k Edvin wrote:
> On 6/30/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote=
:
> >
> > This is a non-standard formatting for comments, please follow
> > Coding style:
>=20
> Thanks, I have updated the patch.
>=20
> When the interface is down (or driver removed), the BroadCom 44xx car=
d
> remains powered on,
> and both its MAC and PHY is using up power.
> This patch makes the driver issue a MAC_CTRL_PHY_PDOWN when the
> interface is halted.
> Also doing a partial chip reset turns off the activity LEDs too.
>=20
> Signed-off-by: Torok Edwin <edwintorok@gmail.com>
> ---
>  b44.c |   28 +++++++++++++++++++++++-----
>   1 file changed, 23 insertions(+), 5 deletions(-)
> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index 879a2ff..43926fd 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -113,6 +113,8 @@ static void b44_init_rings(struct b44 *);
>  #define B44_FULL_RESET		1
>  #define B44_FULL_RESET_SKIP_PHY	2
>  #define B44_PARTIAL_RESET	3
> +#define B44_CHIP_RESET_FULL     4
> +#define B44_CHIP_RESET_PARTIAL  5
>=20
>  static void b44_init_hw(struct b44 *, int);
>=20
> @@ -1283,7 +1285,7 @@ static void b44_clear_stats(struct b44 *bp)
>  }
>=20
>  /* bp->lock is held. */
> -static void b44_chip_reset(struct b44 *bp)
> +static void b44_chip_reset(struct b44 *bp, int reset_kind)
>  {
>  	if (ssb_is_core_up(bp)) {
>  		bw32(bp, B44_RCV_LAZY, 0);
> @@ -1307,6 +1309,13 @@ static void b44_chip_reset(struct b44 *bp)
>=20
>  	b44_clear_stats(bp);
>=20
> +	/*
> +	 * Don't enable PHY if we are doing a partial reset
> +	 * we are probably going to power down
> +	 */
> +	if (reset_kind =3D=3D B44_CHIP_RESET_PARTIAL)
> +		return;
> +
>  	/* Make PHY accessible. */
>  	bw32(bp, B44_MDIO_CTRL, (MDIO_CTRL_PREAMBLE |
>  			     (0x0d & MDIO_CTRL_MAXF_MASK)));
> @@ -1332,7 +1341,14 @@ static void b44_chip_reset(struct b44 *bp)
>  static void b44_halt(struct b44 *bp)
>  {
>  	b44_disable_ints(bp);
> -	b44_chip_reset(bp);
> +	/* reset PHY */
> +	b44_phy_reset(bp);
> +	/* power down PHY */
> +	printk(KERN_INFO PFX "%s: powering down PHY\n", bp->dev->name);
> +	bw32(bp, B44_MAC_CTRL, MAC_CTRL_PHY_PDOWN);
> +	/* now reset the chip, but without enabling the MAC&PHY
> +	 * part of it. This has to be done _after_ we shut down the PHY */
> +	b44_chip_reset(bp, B44_CHIP_RESET_PARTIAL);
>  }
>=20
>  /* bp->lock is held. */
> @@ -1376,7 +1392,7 @@ static void b44_init_hw(struct b44 *bp, int res=
et_kind)
>  {
>  	u32 val;
>=20
> -	b44_chip_reset(bp);
> +	b44_chip_reset(bp, B44_CHIP_RESET_FULL);
>  	if (reset_kind =3D=3D B44_FULL_RESET) {
>  		b44_phy_reset(bp);
>  		b44_setup_phy(bp);
> @@ -1430,7 +1446,7 @@ static int b44_open(struct net_device *dev)
>=20
>  	err =3D request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name=
, dev);
>  	if (unlikely(err < 0)) {
> -		b44_chip_reset(bp);
> +		b44_chip_reset(bp, B44_CHIP_RESET_PARTIAL);
>  		b44_free_rings(bp);
>  		b44_free_consistent(bp);
>  		goto out;
> @@ -2250,7 +2266,7 @@ static int __devinit b44_init_one(struct pci_de=
v *pdev,
>  	/* Chip reset provides power to the b44 MAC & PCI cores, which
>  	 * is necessary for MAC register access.
>  	 */
> -	b44_chip_reset(bp);
> +	b44_chip_reset(bp, B44_CHIP_RESET_FULL);
>=20
>  	printk(KERN_INFO "%s: Broadcom 4400 10/100BaseT Ethernet ", dev->na=
me);
>  	for (i =3D 0; i < 6; i++)
> @@ -2284,6 +2300,7 @@ static void __devexit b44_remove_one(struct pci=
_dev *pdev)
>  	free_netdev(dev);
>  	pci_release_regions(pdev);
>  	pci_disable_device(pdev);
> +	pci_set_power_state(pdev, PCI_D3hot);
>  	pci_set_drvdata(pdev, NULL);
>  }
>=20
> @@ -2312,6 +2329,7 @@ static int b44_suspend(struct pci_dev *pdev,
> pm_message_t state)

You patch is also damaged here.
Check your MUA settings.

--=20
Greetings Michael.
