From: "Reizer, Eyal" <eyalr@ti.com>
Subject: RE: [PATCHv3] wlcore: spi: add wl18xx support
Date: Wed, 22 Jun 2016 06:05:34 +0000
Message-ID: <8665E2433BC68541A24DFFCA87B70F5B36139073@DFRE01.ent.ti.com>
References: <1466510145-15751-1-git-send-email-eyalr@ti.com>
 <8665E2433BC68541A24DFFCA87B70F5B36138299@DFRE01.ent.ti.com>
 <20160621215703.GA14228@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-spi@vger.kernel.org" <linux-spi@vger.kernel.org>,
	Mark Brown <broonie@kernel.org>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160621215703.GA14228@rob-hp-laptop>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >
> > - all wilink family needs special init command for entering wspi mode.
> >   extra clock cycles should be sent after the spi init command while the
> >   cs pin is high.
> > - Use inverted chip select for sending a dummy 4 bytes command that
> >   completes the init stage and puts the wilink chip into wspi mode.
> >
> > Signed-off-by: Eyal Reizer <eyalr@ti.com>
> > ---
> > v1->v2:update device tree bindings configuration
> > v2->v3:revert from manual gpio manipulation. use inverted chip select
> instead
> > for sending the extra init cycle, which achieves the same hardware purpose.
> > update device tree bindings docucmentation accordingly
> >
> >  .../bindings/net/wireless/ti,wlcore,spi.txt        |  47 ++++++--
> >  drivers/net/wireless/ti/wlcore/spi.c               | 124 +++++++++++++++++----
> >  2 files changed, 145 insertions(+), 26 deletions(-)
> >
> > diff --git
> a/Documentation/devicetree/bindings/net/wireless/ti,wlcore,spi.txt
> b/Documentation/devicetree/bindings/net/wireless/ti,wlcore,spi.txt
> > index 9180724..35467cf 100644
> > --- a/Documentation/devicetree/bindings/net/wireless/ti,wlcore,spi.txt
> > +++ b/Documentation/devicetree/bindings/net/wireless/ti,wlcore,spi.txt
> > @@ -1,19 +1,30 @@
> > -* Texas Instruments wl1271 wireless lan controller
> > +* Texas Instruments wl12xx/wl18xx wireless lan controller
> >
> > -The wl1271 chip can be connected via SPI or via SDIO. This
> > +The wl12xx/wl18xx chips can be connected via SPI or via SDIO. This
> >  document describes the binding for the SPI connected chip.
> >
> >  Required properties:
> > -- compatible :          Should be "ti,wl1271"
> > +- compatible :          Should be one of the following:
> > +    * "ti,wl1271"
> > +    * "ti,wl1273"
> > +    * "ti,wl1281"
> > +    * "ti,wl1283"
> > +    * "ti,wl1801"
> > +    * "ti,wl1805"
> > +    * "ti,wl1807"
> > +    * "ti,wl1831"
> > +    * "ti,wl1835"
> > +    * "ti,wl1837"
> >  - reg :                 Chip select address of device
> >  - spi-max-frequency :   Maximum SPI clocking speed of device in Hz
> > -- ref-clock-frequency : Reference clock frequency
> >  - interrupt-parent, interrupts :
> >                          Should contain parameters for 1 interrupt line.
> >                          Interrupt parameters: parent, line number, type.
> > -- vwlan-supply :        Point the node of the regulator that powers/enable the
> wl1271 chip
> > +- vwlan-supply :        Point the node of the regulator that powers/enable
> the
> > +                        wl12xx/wl18xx chip
> >
> >  Optional properties:
> > +- ref-clock-frequency : Reference clock frequency (should be set for
> wl12xx)
> >  - clock-xtal :          boolean, clock is generated from XTAL
> >
> >  - Please consult Documentation/devicetree/bindings/spi/spi-bus.txt
> > @@ -21,10 +32,15 @@ Optional properties:
> >
> >  Examples:
> >
> > +For wl12xx family:
> >  &spi1 {
> > -	wl1271@1 {
> > +	status = "okay";
> > +	pinctrl-names = "default";
> > +	pinctrl-0 = <&spi1_pins>;
> > +	#address-cells = <1>;
> > +	#size-cells = <0>;
> 
> None of this is really relevant to this binding.
> 

Understood. Will remove in v4

> > +	wlcore: wlcore@0 {
> 
> Now your unit-address and reg value don't match.

You are right. Will fix in v4

> 
> >  		compatible = "ti,wl1271";
> > -
> >  		reg = <1>;
> >  		spi-max-frequency = <48000000>;
> >  		clock-xtal;
> > @@ -34,3 +50,20 @@ Examples:
> >  		vwlan-supply = <&vwlan_fixed>;
> >  	};
> >  };
> > +
> > +For wl18xx family:
> > +&spi0	{
> > +	status = "okay";
> > +	pinctrl-names = "default";
> > +	pinctrl-0 = <&spi0_pins>;
> > +	#address-cells = <1>;
> > +	#size-cells = <0>;
> > +	wlcore: wlcore@0 {
> > +		compatible = "ti,wl1835";
> > +		vwlan-supply = <&wlan_en_reg>;
> > +		spi-max-frequency = <48000000>;
> > +		reg = <0>;
> > +		interrupt-parent = <&gpio0>;
> > +		interrupts = <27 IRQ_TYPE_EDGE_RISING>;
> > +	};
> > +};
