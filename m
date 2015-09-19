From: Kevin Hao <haokexin@gmail.com>
Subject: Re: [PATCH] Revert "net/phy: Add Vitesse 8641 phy ID"
Date: Sat, 19 Sep 2015 14:22:43 +0800
Message-ID: <20150919062243.GA11699@pek-khao-d1.corp.ad.wrs.com>
References: <1442562150-19720-1-git-send-email-haokexin@gmail.com>
 <BLUPR03MB14759657A388F648ED6928FDE2590@BLUPR03MB1475.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="pf9I7BMVVzbSWLtt"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Shaohui Xie <Shaohui.Xie@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33364 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754254AbbISGWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 02:22:53 -0400
Received: by pacex6 with SMTP id ex6so69311285pac.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 23:22:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <BLUPR03MB14759657A388F648ED6928FDE2590@BLUPR03MB1475.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 18, 2015 at 09:36:42AM +0000, Shaohui Xie wrote:
> > -----Original Message-----
> > From: Kevin Hao [mailto:haokexin@gmail.com]
> > Sent: Friday, September 18, 2015 3:43 PM
> > To: netdev@vger.kernel.org
> > Cc: Florian Fainelli; Xie Shaohui-B21989
> > Subject: [PATCH] Revert "net/phy: Add Vitesse 8641 phy ID"
> >=20
> > This reverts commit 1298267b548a78840bd4b3e030993ff8747ca5e6.
> >=20
> > That commit claim that the Vitesse VSC8641 is compatible with Vitesse
> > 82xx. But this is not true. It seems that all the registers used in
> > Vitesse phy driver are not compatible between 8641 and 82xx.
> [S.H] There are differences between some register's bit define.=20
> But some are not used by driver.=20
>=20
> > It does cause malfunction of the Ethernet on p1010rdb-pa board.
> [S.H] Which exact register's setting caused problem?
> If it needs different setting,
> It can be handled by distinguishing phy_id, or replacing relative API for=
 VSC8641.

In my case, the malfunction of the Ethernet is caused by writing the wrong
value for the skew timing. The Ethernet can work if I skip the setting of
skew in phy driver. But as I said in the commit log, all the registers used
in the current Vitesse phy driver are not compatible between 8641 and 82xx.
The following are the main differences between these registers:


Auxiliary Control & Status Register (0x1c):
              8641                                  8244
             6: reserved                        6: ActiPHY Mode Enable
             1: Sticky Reset Enable             1-0: ActiPHYTM Sleep Timer

Extended PHY Control Set 1 (0x17):
              8641                                  8244
            8: RGMII skew timing                11-10: RGMII TX_CLK Skew Se=
lection
                                                9 - 8: RGMII RX_CLK Skew Se=
lection
            5: ActiPHY mode enable              5: RX Idle Clock Enable
            3: reserved                         3: Far End Loopback Mode En=
able
            1: GMII transmit pin reversal       2 - 1: MAC/Media Interface =
Mode Select
            0: reserved                         0: EEPROM Status

MII_VSC82X4_EXT_PAGE_16E (0x10):
              8641                                  8244
           Enhanced LED Method Select register     Reserved register=20

MII_VSC82X4_EXT_PAGE_17E (0x11):
              8641                                  8244
           Enhanced LED Behavior register          CLK125 micro Clock Enable

MII_VSC82X4_EXT_PAGE_18E (0x12):
              8641                                  8244
           CRC Good Counter register               Reserved register

As you can see, I don't think it is a better option to sprinkle the checking
phy id for each writing of these register. Of course we can add the specific
API for 8641 to fix this problem. But since the generic phy driver works we=
ll
with the 8641 phy, this commit does seem a regression for me.  So I prefer a
simple revert to this commit and merge the revert into the stable kernel tr=
ee
to fix the regression first. We can add the corresponding 8641 phy API in t=
he
following patches.

Thanks,
Kevin

--pf9I7BMVVzbSWLtt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJV/P8oAAoJEJNY7TDerrFxCw4IAJL1YSdksFco9jW/AOxnP2sz
sjoSGYd5j52hhOJ5zZ/yi2Z/FKqSnJDrGFPiJlQH2jDW53Bxzwy6zlzEwLEytvYG
DsF41++7JwlM++ttvkKc9B52SsxyGYNk2YLv37LZ8qaP65Cx9AsCLQ4Ob2RbJOsg
7y18+6hD2BP3CpmysTTIqcDjFk8SZj7/S204Rrzyny5+3PvtTl3zZWF7M2LKAQRj
vopBl20iaioiYzNJcgovEgJhwEgLP67p4kV1tU290s+Kw8SwCeWq/Qk1fRFm9Ulv
1PEhG3xNyhJdnBtJbTDM/EVbWfMCx9GtEWGR+NeDIQojEkzYnhZGDxL3ZX1DajE=
=om2P
-----END PGP SIGNATURE-----

--pf9I7BMVVzbSWLtt--
