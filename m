From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC] NET: PHY: adds driver for Lantiq PHY11G
Date: Mon, 23 May 2016 04:42:17 +0200
Message-ID: <20160523024217.GB20405@lunn.ch>
References: <1463945631-29273-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, alexander.stein@systec-electronic.com,
	netdev@vger.kernel.org, john@phrozen.org, openwrt@kresin.me,
	hauke.mehrtens@intel.com
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47699 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752672AbcEWCmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2016 22:42:24 -0400
Content-Disposition: inline
In-Reply-To: <1463945631-29273-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 22, 2016 at 09:33:51PM +0200, Hauke Mehrtens wrote:
> Supports the Lantiq / Intel CHD 11G and 22E PHYs.
> These PHYs are also named PEF 7061, PEF 7071, PEF 7072
> 
> Signed-off-by: John Crispin <john@phrozen.org>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
> 
> This is based on a driver from OpenWrt / LEDE. This is send as a RFC
> because the merge window is open now and it adds a new driver. This
> patch was cleaned up on request of Alexander.
> 
> 
>  .../devicetree/bindings/phy/phy-lanitq.txt         | 216 +++++++++++++++++
>  drivers/net/phy/Kconfig                            |   6 +
>  drivers/net/phy/Makefile                           |   1 +
>  drivers/net/phy/lantiq.c                           | 269 +++++++++++++++++++++
>  4 files changed, 492 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/phy/phy-lanitq.txt
>  create mode 100644 drivers/net/phy/lantiq.c
> 
> diff --git a/Documentation/devicetree/bindings/phy/phy-lanitq.txt b/Documentation/devicetree/bindings/phy/phy-lanitq.txt
> new file mode 100644
> index 0000000..d9746e8
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/phy/phy-lanitq.txt
> @@ -0,0 +1,216 @@
> +Lanitq PHY binding
> +============================================
> +
> +This devicetree binding controls the lantiq ethernet phys led functionality.

Hi Hauke

You should CC: the device tree list.

> +
> +Example:
> +	mdio@0 {
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		compatible = "lantiq,xrx200-mdio";
> +			phy5: ethernet-phy@5 {
> +			reg = <0x1>;
> +			compatible = "lantiq,phy11g", "ethernet-phy-ieee802.3-c22";
> +		};
> +		phy11: ethernet-phy@11 {
> +			reg = <0x11>;
> +			compatible = "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
> +			lantiq,led2h = <0x00>;
> +			lantiq,led2l = <0x03>;
> +		};
> +		phy12: ethernet-phy@12 {
> +			reg = <0x12>;
> +			compatible = "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
> +			lantiq,led1h = <0x00>;
> +			lantiq,led1l = <0x03>;
> +		};
> +		phy13: ethernet-phy@13 {
> +			reg = <0x13>;
> +			compatible = "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
> +			lantiq,led2h = <0x00>;
> +			lantiq,led2l = <0x03>;
> +		};
> +		phy14: ethernet-phy@14 {
> +			reg = <0x14>;
> +			compatible = "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
> +			lantiq,led1h = <0x00>;
> +			lantiq,led1l = <0x03>;
> +		};
> +	};
> +
> +Register Description
> +============================================
> +
> +LEDCH:
> +
> +Name	Hardware Reset Value
> +LEDCH	0x00C5
> +
> +| 15 |    |    |    |    |    |    |  8 |
> +=========================================
> +|		RES			|
> +=========================================
> +
> +|  7 |    |    |    |    |    |    |  0 |
> +=========================================
> +|   FBF   |   SBF   |RES |     NACS     |
> +=========================================
> +
> +Field	Bits	Type	Description
> +FBC	7:6	RW	Fast Blink Frequency
> +			---
> +			0x0 (00b) F02HZ 2 Hz blinking frequency
> +			0x1 (01b) F04HZ 4 Hz blinking frequency
> +			0x2 (10b) F08HZ 8 Hz blinking frequency
> +			0x3 (11b) F16HZ 16 Hz blinking frequency
> +
> +SBF	5:4	RW	Slow Blink Frequency
> +			---
> +			0x0 (00b) F02HZ 2 Hz blinking frequency
> +			0x1 (01b) F04HZ 4 Hz blinking frequency
> +			0x2 (10b) F08HZ 8 Hz blinking frequency
> +			0x3 (11b) F16HZ 16 Hz blinking frequency
> +
> +NACS	2:0	RW	Inverse of Scan Function
> +			---
> +			0x0 (000b) NONE No Function
> +			0x1 (001b) LINK Complex function enabled when link is up
> +			0x2 (010b) PDOWN Complex function enabled when device is powered-down
> +			0x3 (011b) EEE Complex function enabled when device is in EEE mode
> +			0x4 (100b) ANEG Complex function enabled when auto-negotiation is running
> +			0x5 (101b) ABIST Complex function enabled when analog self-test is running
> +			0x6 (110b) CDIAG Complex function enabled when cable diagnostics are running
> +			0x7 (111b) TEST Complex function enabled when test mode is running
> +
> +LEDCL:

I doubt the device tree maintainers will accept this. You don't
normally put register values in device tree.

This patch should not be merged until it gets an ACK from the device
tree people.

     Andrew
