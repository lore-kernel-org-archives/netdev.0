From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2 net-next 11/13] Documentation: Bindings: Update DT
 binding for separating dsaf dev support
Date: Tue, 26 Apr 2016 07:48:47 -0500
Message-ID: <20160426124847.GA26682@rob-hp-laptop>
References: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1461402317-136499-12-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, davem@davemloft.net, will.deacon@arm.com,
	catalin.marinas@arm.com, yankejian@huawei.com,
	huangdaode@hisilicon.com, salil.mehta@huawei.com,
	lipeng321@huawei.com, liguozhu@huawei.com, xieqianqian@huawei.com,
	xuwei5@hisilicon.com, linuxarm@huawei.com
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:34948 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbcDZMsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 08:48:55 -0400
Content-Disposition: inline
In-Reply-To: <1461402317-136499-12-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 23, 2016 at 05:05:15PM +0800, Yisen Zhuang wrote:
> Because debug dsaf port was separated from service dsaf port, this patch
> updates the related information of DT binding.

Separated when? New version of the h/w? If so, where's the new 
compatible string? This is quite a big binding change. 

> Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> 
> ---
>  .../devicetree/bindings/net/hisilicon-hns-dsaf.txt | 59 ++++++++++++++++++----
>  1 file changed, 49 insertions(+), 10 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
> index ecacfa4..5ccd4f0 100644
> --- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
> @@ -7,19 +7,47 @@ Required properties:
>  - mode: dsa fabric mode string. only support one of dsaf modes like these:
>  		"2port-64vf",
>  		"6port-16rss",
> -		"6port-16vf".
> +		"6port-16vf",
> +		"single-port".
>  - interrupt-parent: the interrupt parent of this device.
>  - interrupts: should contain the DSA Fabric and rcb interrupt.
>  - reg: specifies base physical address(es) and size of the device registers.
> -  The first region is external interface control register base and size.
> -  The second region is SerDes base register and size.
> +  The first region is external interface control register base and size(optional,
> +  only be used when subctrl-syscon is not exists). It is recommended using

only used when subctrl-syscon does not exist

> +  subctrl-syscon rather than this address.
> +  The second region is SerDes base register and size(optional, only be used when
> +  serdes-syscon in port node is not exists. It is recommended using

similar rewording needed here.

> +  serdes-syscon rather than this address.
>    The third region is the PPE register base and size.
> -  The fourth region is dsa fabric base register and size.
> -  The fifth region is cpld base register and size, it is not required if do not use cpld.
> -- phy-handle: phy handle of physicl port, 0 if not any phy device. see ethernet.txt [1].
> +  The fourth region is dsa fabric base register and size. It is not required for
> +  single-port mode.
> +- reg-names: may be ppe-base and(or) dsaf-base. It is used to find the
> +  corresponding reg's index.

But you have up to 5 regions.

The variable nature of what regions you have tells me you need more 
specific compatible strings for each chip.

> +
> +- phy-handle: phy handle of physicl port, 0 if not any phy device. It is optional

s/physicl/physical/

> +  attribute. If port node is exists, phy-handle in each port node will be used.
> +  see ethernet.txt [1].
> +- subctrl-syscon: is syscon handle for external interface control register.
> +- reset-field-offset: is offset of reset field. Its value depends on the hardware
> +  user manual.
>  - buf-size: rx buffer size, should be 16-1024.
>  - desc-num: number of description in TX and RX queue, should be 512, 1024, 2048 or 4096.
>  
> +- port: subnodes of dsaf. A dsaf node may contain several port nodes(Depending
> +  on mode of dsaf). Port node contain some attributes listed below:
> +- port-id: is physical port index in one dsaf.

Indexes should generally be avoided. What does the number correspond 
to in h/w (if anything)?

> +- phy-handle: phy handle of physicl port. It is not required if there isn't
> +  phy device. see ethernet.txt [1].
> +- serdes-syscon: is syscon handle for SerDes register.
> +- cpld-syscon: is syscon handle for cpld register. It is not required if there
> +  isn't cpld device.
> +- cpld-ctrl-reg: is cpld register offset. It is not required if there isn't
> +  cpld-syscon.

This would usually be a cell in the cpld-syscon property.

> +- port-rst-offset: is offset of reset field for each port in dsaf. Its value
> +  depends on the hardware user manual.
> +- port-mode-offset: is offset of port mode field for each port in dsaf. Its
> +  value depends on the hardware user manual.

Again, sounds like you need more specific compatible strings that imply 
this information.

> +
>  [1] Documentation/devicetree/bindings/net/phy.txt
>  
>  Example:
> @@ -28,11 +56,11 @@ dsaf0: dsa@c7000000 {
>  	compatible = "hisilicon,hns-dsaf-v1";
>  	mode = "6port-16rss";
>  	interrupt-parent = <&mbigen_dsa>;
> -	reg = <0x0 0xC0000000 0x0 0x420000
> -	       0x0 0xC2000000 0x0 0x300000
> -	       0x0 0xc5000000 0x0 0x890000
> +	reg = <0x0 0xc5000000 0x0 0x890000
>  	       0x0 0xc7000000 0x0 0x60000>;
> -	phy-handle = <0 0 0 0 &soc0_phy4 &soc0_phy5 0 0>;
> +	reg-names = "ppe-base", "dsaf-base";
> +	subctrl-syscon = <&subctrl>;
> +	reset-field-offset = 0;
>  	interrupts = <131 4>,<132 4>, <133 4>,<134 4>,
>  		     <135 4>,<136 4>, <137 4>,<138 4>,
>  		     <139 4>,<140 4>, <141 4>,<142 4>,
> @@ -43,4 +71,15 @@ dsaf0: dsa@c7000000 {
>  	buf-size = <4096>;
>  	desc-num = <1024>;
>  	dma-coherent;
> +
> +	prot@0 {

port?

> +		port-id = 0;
> +		phy-handle = <&phy0>;
> +		serdes-syscon = <&serdes>;
> +	};
> +
> +	prot@1 {
> +                port-id = 1;
> +                serdes-syscon = <&serdes>;
> +        };
>  };
> -- 
> 1.9.1
> 
