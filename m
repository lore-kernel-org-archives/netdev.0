From: Florian Fainelli <f.fainelli@gmail.com>
Subject: RE: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Thu, 24 Mar 2016 15:36:23 -0700
Message-ID: <6193B00B-757B-44B8-9B71-0292E5FD432D@gmail.com>
References: <20160216203625.GC2558@lunn.ch> <20160216.154358.164326104187806534.davem@davemloft.net> <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com> <20160216.155244.2052910262411568012.davem@davemloft.net> <90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com> <20160216221536.GB6033@lunn.ch> <90A7E81AE28BAE4CBDDB3B35F187D264402F0018@CHN-SV-EXMX02.mchp-main.com> <20160219201415.GA9884@lunn.ch> <90A7E81AE28BAE4CBDDB3B35F187D264402F31B5@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36502 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbcCXWgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 18:36:33 -0400
Received: by mail-pa0-f43.google.com with SMTP id tt10so32785650pab.3
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 15:36:33 -0700 (PDT)
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402F31B5@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On March 24, 2016 2:16:30 PM PDT, Bryan.Whitehead@microchip.com wrote:
>> -----Original Message-----
>Hi Andrew,
>
>Sorry to bother you with this. But I'm having major difficulty with
>getting my dsa driver entry points called.
>
>Here is what I've done so far.
>
>I copied drivers/net/dsa/mv88x6060.c into
>drivers/net/dsa/mchp9352_dsa.c
>I then modified mchp9352_dsa.c as follows
>I emptied out the function bodies, and replaced them with a printk("Not
>Implemented\n");
>
>I did the same thing with net/dsa/tag_trailer.c which was copied into
>net/dsa/tag_mchp9352.c
>And function bodies were replaced with printk("Not Implemented\n");
>
>I also modified net/dsa/dsa.c, and net/dsa/slave.c, to include the
>hooks into my new tag files.
>
>My intent was to just see one of my "Not Implemented" functions called,
>and then I would focus on implementing it.
>
>But so far I have not seen any of my "Not Implemented" functions
>called.
>
>Here is what I know so far.
>
>It appears the dsa.c is not able to attach my underlying net device.
>And that seems to be due to it is unable to find the mdio_bus. 
>So I modified my net device driver so that in probe it calls
>of_mdiobus_register instead of mdiobus_register.
>And of_mdiobus_register seems to be looking for some kind of phy
>definitions in the device tree, which it does not find. And so it does
>not appear to register the bus in such a way that dsa.c can connect to
>it.

If the lan9352 HW has a MDIO bus, which connects to internal switch, or PHYs from the switch, there must be an mii_bus structure allocated and registered to make that available.

>
>So the problem appears to be an issue with my device tree, which is
>partially shown below.
>
>&gpmc {
>	status = "okay";
>	ranges = <0 0 0x10000000 0x08000000>;	// CS0: 128M 
>	pinctrl-names = "default";
>	pinctrl-0 = <&gpmc_pins>;
>	lan9352: ethernet@gpmc {
>		compatible = "microchip,lan9352";
>		interrupt-parent = <&gpio0>;
>		interrupts = <7 8>;//7==GPIO bit 7, 8 = Active low level triggered.
>
>		bank-width = <2>;
>
>		phy-mode = "mii";

Having a phy-mode without a phy-handle property or fixed-phy subnode does not sound correct nor useful.

Considering that you are interfaced to a built-in switch a fixed-link subnode is needed to tell the Ethernet MAC about the link parameters. See drivers/net/ethernet/broadcom/bcmsysport.c for an example by grepping for fixed_phy.

>
>		reg = <0 0 0x10000>;
>
>		reg-io-width = <4>;
>		microchip,save-mac-address;
>		microchip,irq-push-pull;
>
>	};
>};
>
>/ {
>	dsa@0 {
>		compatible = "microchip,dsa";

Did you also update net/dsa/dsa.c so it tries to match this compatible string? DSA is right now a platform device (though there is pending working from Andrew to change that) so we need a way to probe DSA.


>		#address-cells = <2>;
>		#size-cells = <0>;
>		dsa,ethernet = <&lan9352>;

That looks correct.

>		dsa,mii-bus = <&lan9352>;

But not that one, this must point to a device tree node which is a MDIO bus controller. It could be a sub-node to lan9352 provided that there is a way to expose a MDIO bus controller.

Moving forward, with Andrew's latest patches included, this may become entirely optional, but it is not just now.

-- 
Florian
