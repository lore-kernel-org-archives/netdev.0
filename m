From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Thu, 24 Mar 2016 21:16:30 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264402F31B5@CHN-SV-EXMX02.mchp-main.com>
References: <20160216203625.GC2558@lunn.ch>
 <20160216.154358.164326104187806534.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
 <20160216.155244.2052910262411568012.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com>
 <20160216221536.GB6033@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402F0018@CHN-SV-EXMX02.mchp-main.com>
 <20160219201415.GA9884@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:47533 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751209AbcCXVQd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 17:16:33 -0400
In-Reply-To: <20160219201415.GA9884@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Friday, February 19, 2016 3:14 PM 

> > I'm not yet sure how it attaches to the underlying Ethernet driver.
> 
> The DSA core does that for you. If you look at the device tree
> binding:
> 
>         dsa@0 {
>                 compatible = "marvell,dsa";
>                 #address-cells = <2>;
>                 #size-cells = <0>;
> 
>                 interrupts = <10>;
>                 dsa,ethernet = <&ethernet0>;
> 
> So this says which Ethernet interface to use. net/dsa/dsa.c will create a slave
> interface per external port of your switch. This slave is a netdev. Frames
> transmitted by this slave are fed through the tag code to add additional
> headers/trailers, and then passed to this ethernet device. Frames received
> by the ethernet again through the tag code, stripping off any headers/trails
> and demuxing to the correct slave.

Hi Andrew,

Sorry to bother you with this. But I'm having major difficulty with getting my dsa driver entry points called.

Here is what I've done so far.

I copied drivers/net/dsa/mv88x6060.c into drivers/net/dsa/mchp9352_dsa.c
I then modified mchp9352_dsa.c as follows
I emptied out the function bodies, and replaced them with a printk("Not Implemented\n");

I did the same thing with net/dsa/tag_trailer.c which was copied into net/dsa/tag_mchp9352.c
And function bodies were replaced with printk("Not Implemented\n");

I also modified net/dsa/dsa.c, and net/dsa/slave.c, to include the hooks into my new tag files.

My intent was to just see one of my "Not Implemented" functions called, and then I would focus on implementing it.

But so far I have not seen any of my "Not Implemented" functions called.

Here is what I know so far.

It appears the dsa.c is not able to attach my underlying net device. And that seems to be due to it is unable to find the mdio_bus. 
So I modified my net device driver so that in probe it calls of_mdiobus_register instead of mdiobus_register.
And of_mdiobus_register seems to be looking for some kind of phy definitions in the device tree, which it does not find. And so it does not appear to register the bus in such a way that dsa.c can connect to it.

So the problem appears to be an issue with my device tree, which is partially shown below.

&gpmc {
	status = "okay";
	ranges = <0 0 0x10000000 0x08000000>;	// CS0: 128M 
	pinctrl-names = "default";
	pinctrl-0 = <&gpmc_pins>;
	lan9352: ethernet@gpmc {
		compatible = "microchip,lan9352";
		interrupt-parent = <&gpio0>;
		interrupts = <7 8>;//7==GPIO bit 7, 8 = Active low level triggered.

		bank-width = <2>;

		phy-mode = "mii";

		reg = <0 0 0x10000>;

		reg-io-width = <4>;
		microchip,save-mac-address;
		microchip,irq-push-pull;

	};
};

/ {
	dsa@0 {
		compatible = "microchip,dsa";
		#address-cells = <2>;
		#size-cells = <0>;
		dsa,ethernet = <&lan9352>;
		dsa,mii-bus = <&lan9352>;
		switch@0 {
			#address-cells = <1>;
			#size-cells = <0>;
			reg = <0 0>;	/* MDIO address 0, switch 0 in tree */
			port@0 {
				reg = <0>;
				label = "cpu";
			};
			port@1 {
				reg = <1>;
				label = "lan1";
			};
			port@2 {
				reg = <2>;
				label = "lan2";
			};
		};
	};
};

I modeled this from what I found in 
arch/arm/boot/dts/kirkwood-mv88f6281gtw-ge.dts 

So my question is. Can you see anything that I'm doing wrong?
Given the issue seems to be about the lan9352 node not having child phy nodes, then I wonder if I'm not looking at the best example since my example does not use child phy nodes either. If so, can you point me to a better example?

Anyway I'm really hitting a road block here, so any and all guidance is greatly appreciated.

Thanks,
Bryan
