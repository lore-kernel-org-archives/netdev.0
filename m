From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 01/12] net: axienet: Support for RGMII
Date: Tue, 05 May 2015 21:32:29 -0700
Message-ID: <5549995D.2070407@gmail.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com> <8C367E791021814DA6CAFCCCD4EFC2297C97A227@XSJ-PSEXMBX01.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Srikanth Thokala <srikanth.thokala@xilinx.com>,
	Soren Brinkmann <sorenb@xilinx.com>,
	"monstr@monstr.eu" <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>
To: John Linn <john.linn@xilinx.com>,
	Michal Simek <michals@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35484 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbbEFEcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 00:32:32 -0400
Received: by obcux3 with SMTP id ux3so154336885obc.2
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 21:32:31 -0700 (PDT)
In-Reply-To: <8C367E791021814DA6CAFCCCD4EFC2297C97A227@XSJ-PSEXMBX01.xlnx.xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/05/15 05:54, John Linn a =C3=A9crit :
> Hi Michal,
>=20
> I removed the mailing lists.
>=20
> One of the issues we see in the field is that the value of PHY_INTERF=
ACE_MODE_RGMII_ID causes a delay on the RX and TX side in the PHY to al=
ign the clock and the data. Yet this does not work on every board such =
that         PHY_INTERFACE_MODE_RGMII_RXID or        PHY_INTERFACE_MODE=
_RGMII_TXID must be used.
>=20
> I realize that's a pain.  Sometimes the PHY driver allows register va=
lues (like Marvell) to be setup on the PHY node which helps, but not al=
ways.  It seems that the information in the device tree is not adequate=
 to describe the hardware. I've not looked to see what others do as may=
be this is a common problem, just thought I should pass on the problem.

There is a standard Device Tree node property described in
Documentation/devicetree/bindings/net/ethernet.txt: phy-mode which
allows you to specify exactly this: whether you should have your TX dat=
a
and clocks aligned or shifted.

See include/linux/phy.h in the kernel for how the string translates int=
o
a given PHY_INTERFACE_MODE_* value.

If your concern is more about whether the fact that given PHY driver
should support RGMII_ID, RGMII_TXID and RGMII_RXID, all of this is
typically extremely specific to the board (PCB), Ethernet MAC and
Ethernet PHY, so unless there is the need to configure that, it may jus=
t
be that people use the default values that happen to work for them
without much research on the subject.

>=20
> Thanks
> John
>=20
> -----Original Message-----
> From: Michal Simek [mailto:monstr@monstr.eu] On Behalf Of Michal Sime=
k
> Sent: Tuesday, May 05, 2015 4:26 AM
> To: netdev@vger.kernel.org
> Cc: Srikanth Thokala; Soren Brinkmann; monstr@monstr.eu; John Linn; A=
nirudha Sarangi; linux-kernel@vger.kernel.org; linux-arm-kernel@lists.i=
nfradead.org
> Subject: [PATCH 01/12] net: axienet: Support for RGMII
>=20
> From: Srikanth Thokala <srikanth.thokala@xilinx.com>
>=20
> This patch adds support for the RGMII. The h/w configuration paramete=
r C_PHY_TYPE, which represents the interface configured in the design, =
is used to differentiate various interfaces supported by AXI Ethernet.
>=20
> Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> ---
>=20
>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/driv=
ers/net/ethernet/xilinx/xilinx_axienet_main.c
> index 28b7e7d9c272..0ab607732bb4 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> @@ -925,9 +925,16 @@ static int axienet_open(struct net_device *ndev)
>                 return ret;
>=20
>         if (lp->phy_node) {
> -               lp->phy_dev =3D of_phy_connect(lp->ndev, lp->phy_node=
,
> +               if (lp->phy_type =3D=3D XAE_PHY_TYPE_GMII) {
> +                       lp->phy_dev =3D of_phy_connect(lp->ndev, lp->=
phy_node,
>                                              axienet_adjust_link, 0,
>                                              PHY_INTERFACE_MODE_GMII)=
;
> +               } else if (lp->phy_type =3D=3D XAE_PHY_TYPE_RGMII_2_0=
) {
> +                       lp->phy_dev =3D of_phy_connect(lp->ndev, lp->=
phy_node,
> +                                            axienet_adjust_link, 0,
> +                                            PHY_INTERFACE_MODE_RGMII=
_ID);
> +               }
> +
>                 if (!lp->phy_dev) {
>                         dev_err(lp->dev, "of_phy_connect() failed\n")=
;
>                         return -ENODEV;
> --
> 2.3.5
>=20
>=20
>=20
> This email and any attachments are intended for the sole use of the n=
amed recipient(s) and contain(s) confidential information that may be p=
roprietary, privileged or copyrighted under applicable law. If you are =
not the intended recipient, do not read, copy, or forward this email me=
ssage or any attachments. Delete this email message and any attachments=
 immediately.
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--=20
=46lorian
