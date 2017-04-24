From: Rafa Corvillo <rafael.corvillo@aoifes.com>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Mon, 24 Apr 2017 08:45:26 +0200
Message-ID: <58FD9F06.4040804@aoifes.com>
References: <58F9FD64.80506@aoifes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-relay-03-3.dondominio.net ([31.214.176.46]:35446 "EHLO
        smtp-relay-03-3.dondominio.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1165749AbdDXGpa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 02:45:30 -0400
Received: from mail-node.dondominio.com
        by smtp-relay.dondominio.com (Postfix) with ESMTP id A022A41516
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 08:45:27 +0200 (CEST)
Received: from [192.168.100.99] (unknown [217.130.92.202])
        (Authenticated sender: rafael.corvillo@aoifes.com)
        by mail-node.dondominio.com (Postfix) with ESMTPA id 7728440719
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 08:45:27 +0200 (CEST)
In-Reply-To: <58F9FD64.80506@aoifes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I resend the mail with the schema fixed. Sorry for the inconvenience.

We are working in an ARMv7 embedded system running kernel 4.9 (LEDE build).
It is an imx6 board with 2 ethernet interfaces. One of them is connected to
a Marvell switch.

The schema of the system is the following:

+-------------------+ eth0
  |                   +--+
  |                   |  |
  | Embedded system   +--+
  |                   |
  |      ARMv7        |
  |                   | Marvell 88E8057(sky2) +-------------+
  |                   +--+ +--+             +--+ eth1
  |                   |  +---------------------+ |             |  +------+
  |                   +--+      CPU port       +--+ mv88e6176  +--+
  +------+--+---------+ |             |
emulated|  | |             |
GPIO    +--+ +--+             +--+ eth2
MDIO      +-----------------------------------+ |             |  +------+
                               MDIO +--+             +--+
+-------------+

There is a bridge (br-lan) which includes eth0/eth1/eth2

If I connect the eth1/eth2, the link is up and I can do ping through it. 
But, once
I start sending a heavy traffic load the link fails and the kernel sends 
the
following messages:

[   48.557140] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
length 1518
[   48.564964] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
length 1518
[   48.572110] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
length 1518
[   48.579263] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
length 1518
[   48.586417] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
length 1518
[   48.593573] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
length 1518
[   48.600718] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
length 1518
[   54.877567] net_ratelimit: 6 callbacks suppressed
[   54.882293] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
length 1518
[   61.413552] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
length 1518

I have a modified device-tree of imx6 which includes the mdio and dsa 
nodes. This
device-tree works in a kernel 4.1.6, but I know that these parts of the 
kernel have
a lot of changes. The changes included for mdio and dsa in the 
device-tree are the
following (diff arch/arm/boot/dts/imx6qdl-gw53xx.dtsi 
arch/arm/boot/dts/imx6qdl-gw53xx-mdio.dtsi):

16a17,18
 >     can0 = &can1;
 >     ethernet0 = &fec;
21a24
 >     sky2 = &eth1;
24a28,29
 >     usdhc2 = &usdhc3;
 >     mdio-gpio0 = &mdio0;
62a68,125
 >   mdio0: mdio {
 >     compatible = "virtual,mdio-gpio";
 >     #address-cells = <1>;
 >     #size-cells = <0>;
 >     /* MDC = gpio-17, MDIO = gpio-20 */
 >     gpios =  <&gpio1 17 1
 >         &gpio1 20 0>;
 >                 ethernet-phy@0  {
 >           compatible = "marvell,dsa";
 >                 };
 >   };
 >
 >   dsa {
 >     compatible = "marvell,dsa";
 >     #address-cells = <2>;
 >     #size-cells = <0>;
 >
 >     interrupts = <10>;
 >     dsa,ethernet = <&eth1>;
 >     dsa,mii-bus = <&mdio0>;
 >
 >     switch@0 {
 >       #address-cells = <1>;
 >       #size-cells = <0>;
 >       reg = <0 0>;  /* MDIO address 0, switch 0 in tree */
 >
 >       port@0 {
 >         reg = <0>;
 >         label = "cpu";
 >       };
 >
 >       port@1 {
 >         reg = <1>;
 >         label = "eth1";
 >       };
 >
 >       port@2 {
 >         reg = <2>;
 >         label = "eth2";
 >       };
 >
 >       port@3 {
 >         reg = <3>;
 >         label = "eth3";
 >       };
 >
 >       port@4 {
 >         reg = <4>;
 >         label = "eth4";
 >       };
 >     };
 >   };
 >
361a425,430
 > &mdio0 {
 >   pinctrl-names = "default";
 >   pinctrl-0 = <&pinctrl_mdio>;
 >   status = "okay";
 > };
 >
363c432
<   imx6qdl-gw53xx {
---
 >   imx6qdl-gw53xx-mdio {
448a518,524
 >       >;
 >     };
 >
 >     pinctrl_mdio: mdiogrp {
 >       fsl,pins = <
 >         MX6QDL_PAD_SD1_DAT1__GPIO1_IO17   0x1b0b9
 >         MX6QDL_PAD_SD1_CLK__GPIO1_IO20    0x1b0b9

Do you know of any possible reason why this could be happening?

Thanks in advance.

Rafa
