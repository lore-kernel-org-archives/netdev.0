From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH] [v2] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Fri, 24 Aug 2012 12:29:41 -0600
Message-ID: <5037C815.4020906@wwwdotorg.org>
References: <1345751071-23128-1-git-send-email-timur@freescale.com> <5036B4BD.70208@wwwdotorg.org> <6AE080B68D46FC4BA2D2769E68D765B7059D1DC7@039-SN2MPN1-022.039d.mgd.msft.net> <5036EB06.7060807@wwwdotorg.org> <5037AB67.6030106@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Fleming Andy-AFLEMING <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	"ddaney.cavm@gmail.com" <ddaney.cavm@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Scott Wood <scottwood@freescale.com>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avon.wwwdotorg.org ([70.85.31.133]:39706 "EHLO
	avon.wwwdotorg.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753823Ab2HXS3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 14:29:44 -0400
In-Reply-To: <5037AB67.6030106@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2012 10:27 AM, Timur Tabi wrote:
> Stephen Warren wrote:
>>>>>> Then, that'd have to be <9 1>;
>>>>
>>>> Actually, I had #size-cells = <0>.
> 
>> I think that if you have #size-cells=<0>, then you'll see the following
>> error message when attempting to translate the address into the parent's
>> address space:
>>
>> prom_parse: Bad cell count for /board-control@3,0/mdio-mux-emi2
> 
> It doesn't appear to be working.  Here's my tree:
> 
> / {
> 	model = "fsl,P5020DS";
> 	compatible = "fsl,P5020DS";
> 	#address-cells = <2>;
> 	#size-cells = <2>;
> 	interrupt-parent = <&mpic>;
> 
> 	lbc: localbus@ffe124000 {
> 		reg = <0xf 0xfe124000 0 0x1000>;
> 		ranges = <0 0 0xf 0xe8000000 0x08000000
> 			  2 0 0xf 0xffa00000 0x00040000
> 			  3 0 0xf 0xffdf0000 0x00008000>;
> 
> 		fpga: board-control@3,0 {
> 			#address-cells = <1>;
> 			#size-cells = <1>;
> 			compatible = "fsl,p5020ds-fpga", "fsl,fpga-ngpixis";
> 			reg = <3 0 0x30>;
> 
> 			mdio-mux-emi1 {
> 				compatible = "mdio-mux-mmioreg";
> 				mdio-parent-bus = <&mdio0>;
> 				#address-cells = <1>;
> 				#size-cells = <0>;
> 				reg = <9 1>; // BRDCFG1
> 				mux-mask = <0x78>; // EMI1
> 
> That means that the physical address that I need is fffdf0009.  However,
> when I call of_address_to_resource(), the returned address I get is fe8000009.
> 
> So it's not picking up the "3" in the 'reg' property of the
> board-control@3,0 node.  What am I missing?  Do I need a 'ranges' property
> in the board-control@3,0 node?

Yes.

When translating the child node's reg property into the parent's address
space, the parent's reg property shouldn't even be used at all; all the
mapping is done through the ranges property.

I thought the code error-checked for a missing ranges property, but I
guess not...
