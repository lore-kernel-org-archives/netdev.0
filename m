From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: RE: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Mon, 7 Mar 2016 09:33:28 +0000
Message-ID: <SG2PR06MB10389F82D83C6D4B89F75BC1C3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <20160305043010.GC13525@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mkl@pengutronix.de" <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"geert+renesas@glider.be" <geert+renesas@glider.be>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:65448 "EHLO
	relmlie2.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752055AbcCGJde convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 04:33:34 -0500
In-Reply-To: <20160305043010.GC13525@rob-hp-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob,

Thanks for the review comments.

> On Thu, Mar 03, 2016 at 03:38:35PM +0000, Ramesh Shanmugasundaram wrote:
> > This patch adds support for the CAN FD controller found in Renesas
> > R-Car SoCs. The controller operates in CAN FD mode by default.
> >
> > CAN FD mode supports both Classical CAN & CAN FD frame formats. The
> > controller supports ISO 11898-1:2015 CAN FD format only.
> >
> > This controller supports two channels and the driver can enable either
> > or both of the channels.
> >
> > Driver uses Rx FIFOs (one per channel) for reception & Common FIFOs
> > (one per channel) for transmission. Rx filter rules are configured to
> > the minimum (one per channel) and it accepts Standard, Extended, Data
> > & Remote Frame combinations.
> >
> > Note: There are few documentation errors in R-Car Gen3 Hardware User
> > Manual v0.5E with respect to CAN FD controller. They are listed below:
> >
> > 1. CAN FD interrupt numbers 29 & 30 are listed as per channel
> > interrupts. However, they are common to both channels (i.e.) they are
> > global and channel interrupts respectively.
> >
> > 2. CANFD clock is derived from PLL1. This is not documented.
> >
> > 3. CANFD clock is further divided by (1/2) within the CAN FD controller.
> > This is not documented.
> >
> > 4. The minimum value of NTSEG1 in RSCFDnCFDCmNCFG register is 2 Tq. It
> > is mentioned 4 Tq in the manual.
> >
> > 5. The maximum number of message RAM area the controller can use is
> > 3584 bytes. It is specified 10752 bytes in the manual.
> >
> > Signed-off-by: Ramesh Shanmugasundaram
> > <ramesh.shanmugasundaram@bp.renesas.com>
> > ---
> > Changes since v1:
> > 	* Removed testmodes & debugfs code (suggested by Oliver H)
> > 	* Fixed tx path race issue by introducing lock (suggested by Marc K)
> > 	* Removed __maybe_unused attribute of rcar_canfd_of_table
> >
> > Thanks,
> > Ramesh
> > ---
> >  .../devicetree/bindings/net/can/rcar_canfd.txt     |   86 ++
> >  drivers/net/can/Kconfig                            |   10 +
> >  drivers/net/can/Makefile                           |    1 +
> >  drivers/net/can/rcar_canfd.c                       | 1624
> ++++++++++++++++++++
> >  4 files changed, 1721 insertions(+)
> >  create mode 100644
> > Documentation/devicetree/bindings/net/can/rcar_canfd.txt
> >  create mode 100644 drivers/net/can/rcar_canfd.c
> >
> > diff --git a/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
> > b/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
> > new file mode 100644
> > index 0000000..4299bd8
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
> > @@ -0,0 +1,86 @@
> > +Renesas R-Car CAN FD controller Device Tree Bindings
> > +----------------------------------------------------
> > +
> > +Required properties:
> > +- compatible: Must contain one or more of the following:
> > +  - "renesas,rcar-gen3-canfd" for R-Car Gen3 compatible controller.
> > +  - "renesas,r8a7795-canfd" for R8A7795 (R-Car H3) compatible
> controller.
> > +
> > +  When compatible with the generic version, nodes must list the
> > + SoC-specific version corresponding to the platform first, followed
> > + by the  family-specific and/or generic versions.
> > +
> > +- reg: physical base address and size of the R-Car CAN FD register map.
> > +- interrupts: interrupt specifier for the Global & Channel interrupts
> > +- clocks: phandles and clock specifiers for 3 clock inputs.
> > +- clock-names: 3 clock input name strings: "fck", "canfd", "can_clk".
> > +- pinctrl-0: pin control group to be used for this controller.
> > +- pinctrl-names: must be "default".
> > +
> > +Required properties for "renesas,r8a7795-canfd" compatible:
> > +In R8A7795 SoC, canfd clock is a div6 clock and can be used by both
> > +CAN and CAN FD controller at the same time. It needs to be scaled to
> > +maximum frequency if any of these controllers use it. This is done
> > +using the below properties.
> > +
> > +- assigned-clocks: phandle of canfd clock.
> > +- assigned-clock-rates: maximum frequency of this clock.
> > +
> > +Each channel is represented as a child node. They can be
> > +enabled/disabled using "status" property.
> 
> How many channels? Required or optional?

Two channels and it is a required property. I will update as below in the next revision.

Required child node:
The controller supports two channels and each is represented as a child
node. The names of the child nodes are "channel0" and "channel1" respectively.
Each child node supports the "status" property only, which is used to
enable/disable the respective channel.

> 
> > +
> > +Example
> > +-------
> > +
> > +SoC common .dtsi file:
> > +
> > +		canfd: canfd@e66c0000 {
> 
> can@e66c0000

Thanks. I will update.

Thanks,
Ramesh
