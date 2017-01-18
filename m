From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: Setting link down or up in software
Date: Wed, 18 Jan 2017 11:29:23 +0100
Message-ID: <dc6378d7-d370-c893-63b7-c21cd7ef76fd@neratec.com>
References: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
 <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
 <0273a4ad-46f7-d7b9-a206-6bd713e6165e@neratec.com>
 <9be9b48d-1bef-b48f-866f-8651d9b9c245@free.fr>
 <bfe5bd8b-d4eb-8c8e-45d8-6ea1c133b4a7@neratec.com>
 <660b7b17-0136-bf69-fd12-1c125069829b@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:5566 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751204AbdARKaT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 05:30:19 -0500
In-Reply-To: <660b7b17-0136-bf69-fd12-1c125069829b@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2017 06:35 PM, Mason wrote:
> On 13/01/2017 17:28, Zefir Kurtisi wrote:
> 
>> As for your specific problem: since I fought myself with the PHY/ETH subsystems
>> over the past months, I might remember something relevant to your issue. Could you
>> give some more info on your setup (PHY driver, opmode (SGMII, RGMII, etc.), ETH).
> 
> Hello Zefir,
> 
> My boards are using these drivers:
> 
> http://lxr.free-electrons.com/source/drivers/net/ethernet/aurora/nb8800.c
> http://lxr.free-electrons.com/source/drivers/net/phy/at803x.c
> 
> The relevant device tree nodes are:
> 
> 		eth0: ethernet@26000 {
> 			compatible = "sigma,smp8734-ethernet";
> 			reg = <0x26000 0x800>;
> 			interrupts = <38 IRQ_TYPE_LEVEL_HIGH>;
> 			clocks = <&clkgen SYS_CLK>;
> 		};
> 
> &eth0 {
> 	phy-connection-type = "rgmii";
> 	phy-handle = <&eth0_phy>;
> 	#address-cells = <1>;
> 	#size-cells = <0>;
> 
> 	/* Atheros AR8035 */
> 	eth0_phy: ethernet-phy@4 {
> 		compatible = "ethernet-phy-id004d.d072",
> 			     "ethernet-phy-ieee802.3-c22";
> 		interrupts = <37 IRQ_TYPE_EDGE_RISING>;
> 		reg = <4>;
> 	};
> };
> 
> If I comment the PHY "interrupts" property, then the PHY framework
> falls back to polling.
> 
> Am I forgetting important information?
> 
> Regards.
> 
Hi,

in our system we attach the at8031 over SGMII to the gianfar (Freescale eTSEC) and
to fibre optics transceivers, which operate in fixed speeds. Getting this setup to
work reliably was challenging for various reasons, maybe worth to note

1) fixed SGMII speed not working: link is up on both ends, but no data is passed
2) known issue with SGMII link not completing autonegotiation correctly, see [1]
3) once autoneg is started or chip is reset, MII_CTRL1000 can not be written to
until autoneg is completed => breaks phy state machine when the driver loads with
unplugged cable and tries to set fixed speed

Unless you are using fixed speed links in your setup, none of those should affect
it. My experience with at8031 attached to RGMII is that it is genphy compliant,
therefore I would a) disable interrupts, and b) prevent loading at803x.ko and try
the genphy instead. Yours is an at8035, results may vary.


Cheers,
Zefir


[1] https://www.spinics.net/lists/netdev/msg400804.html
