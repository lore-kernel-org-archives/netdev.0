From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [RFC 1/2] dt: emac: document device-tree based phy discovery and setup
Date: Sun, 19 Feb 2017 16:20:58 +0100
Message-ID: <2476200.DrVWeKAC8k@debian64>
References: <f57a340f615991ed2771d8af4b1a908dec436a5e.1486333475.git.chunkeey@googlemail.com> <23e29bef-4c49-8ff6-b156-3b028ed592c4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36503 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750836AbdBSPXj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 10:23:39 -0500
Received: by mail-wm0-f66.google.com with SMTP id r18so10259027wmd.3
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 07:23:11 -0800 (PST)
In-Reply-To: <23e29bef-4c49-8ff6-b156-3b028ed592c4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, February 5, 2017 2:33:44 PM CET Florian Fainelli wrote:
> Le 02/05/17 =E0 14:25, Christian Lamparter a =E9crit :
> > This patch adds documentation for a new "phy-handler" property
> > and "mdio" sub-node. These allows the enumeration of PHYs which
> > are supported by the phy library under drivers/net/phy.
> >=20
> > The EMAC ethernet controller in IBM and AMCC 4xx chips is
> > currently stuck with a few privately defined phy
> > implementations. It has no support for PHYs which
> > are supported by the generic phylib.
> >=20
> > Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
> > ---
> >  .../devicetree/bindings/powerpc/4xx/emac.txt       | 60 ++++++++++++++=
+++++++-
> >  1 file changed, 58 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/Documentation/devicetree/bindings/powerpc/4xx/emac.txt b/D=
ocumentation/devicetree/bindings/powerpc/4xx/emac.txt
> > index 712baf6c3e24..0572d053c35a 100644
> > --- a/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
> > +++ b/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
> > @@ -71,6 +71,8 @@
> >  			  For Axon it can be absent, though my current driver
> >  			  doesn't handle phy-address yet so for now, keep
> >  			  0x00ffffff in it.
> > +    - phy-handle	: See net/ethernet.txt file; used to describe
> > +			  configurations where a external PHY is used.
> >      - rx-fifo-size-gige : 1 cell, Rx fifo size in bytes for 1000 Mb/sec
> >  			  operations (if absent the value is the same as
> >  			  rx-fifo-size).  For Axon, either absent or 2048.
> > @@ -82,7 +84,18 @@
> >      - tah-channel       : 1 cell, optional. If appropriate, channel us=
ed on the
> >  			  TAH engine.
> > =20
> > -    Example:
> > +    - mdio subnode	: When the EMAC has a phy connected to its local
> > +			  mdio, which us supported by the kernel's network
> > +			  PHY library in drivers/net/phy, there must be device
> > +			  tree subnode with the following required properties:
> > +				- #address-cells: Must be <1>.
> > +				- #size-cells: Must be <0>.
> > +
> > +			  For each phy on the mdio bus, there must be a node
> > +			  with the following fields:
> > +				- reg: phy id used to communicate to phy.
> > +				- device_type: Must be "ethernet-phy".
>=20
> Just provide a reference to
> Documentation/devicetree/bindings/net/phy.txt and
> Documentation/devicetree/bindings/net/ethernet.txt here. device_type is
> not required.

Yes, I added a reference there.
>=20
> > +    Examples:
> > =20
> >  	EMAC0: ethernet@40000800 {
> >  		device_type =3D "network";
> > @@ -104,6 +117,50 @@
> >  		zmii-channel =3D <0>;
> >  	};
> > =20
> > +	EMAC1: ethernet@ef600c00 {
> > +		device_type =3D "network";
> > +		compatible =3D "ibm,emac-apm821xx", "ibm,emac4sync";
> > +		interrupt-parent =3D <&EMAC1>;
> > +		interrupts =3D <0 1>;
> > +		#interrupt-cells =3D <1>;
> > +		#address-cells =3D <0>;
> > +		#size-cells =3D <0>;
> > +		interrupt-map =3D <0 &UIC2 0x10 IRQ_TYPE_LEVEL_HIGH /* Status */
> > +				 1 &UIC2 0x14 IRQ_TYPE_LEVEL_HIGH /* Wake */>;
> > +		reg =3D <0xef600c00 0x000000c4>;
> > +		local-mac-address =3D [000000000000]; /* Filled in by U-Boot */
> > +		mal-device =3D <&MAL0>;
> > +		mal-tx-channel =3D <0>;
> > +		mal-rx-channel =3D <0>;
> > +		cell-index =3D <0>;
> > +		max-frame-size =3D <9000>;
> > +		rx-fifo-size =3D <16384>;
> > +		tx-fifo-size =3D <2048>;
> > +		fifo-entry-size =3D <10>;
> > +		phy-mode =3D "rgmii";
> > +		phy-map =3D <0x00000000>;
>=20
> If you have a proper mdio subnode, this property becomes irrelevant and
> should be unused.
This is emac.c doing. It defaults to 0xffff... if the property is absent.
<http://lxr.free-electrons.com/source/drivers/net/ethernet/ibm/emac/core.c#=
L2578>
> > +		phy-handle =3D <&phy0>;
> > +		rgmii-device =3D <&RGMII0>;
> > +		rgmii-channel =3D <0>;
> > +		tah-device =3D <&TAH0>;
> > +		tah-channel =3D <0>;
> > +		has-inverted-stacr-oc;
> > +		has-new-stacr-staopc;
> > +
> > +	        mdio {
> > +			#address-cells =3D <1>;
> > +			#size-cells =3D <0>;
> > +
> > +			phy0: ethernet-phy@0 {
> > +				device_type =3D "ethernet-phy";
> > +				reg =3D <0>;
> > +
> > +				qca,ar8327-initvals =3D <
> > +					0x0010 0x40000000>;
> > +		};
> > +	};
> > +
> > +
> >        ii) McMAL node
> > =20
> >      Required properties:
> > @@ -145,4 +202,3 @@
> >      - revision           : as provided by the RGMII new version regist=
er if
> >  			   available.
> >  			   For Axon: 0x0000012a
> > -
> >=20
>=20
>=20
>=20
