From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Device Tree Binding for Marvell DSA Switch on imx28 board over
 Mdio Interface
Date: Thu, 13 Nov 2014 12:03:40 -0800
Message-ID: <54650E9C.7080708@gmail.com>
References: <CA+KjHfYZdZ88ZFzFCPN-bGphh+mnSWy6i0WNzFYv=gOsafXA7g@mail.gmail.com>	<5463B2AC.6090904@gmail.com> <CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Oliver Graute <oliver.graute@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:62812 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933146AbaKMUDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 15:03:45 -0500
Received: by mail-pd0-f172.google.com with SMTP id r10so15253619pdi.3
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 12:03:45 -0800 (PST)
In-Reply-To: <CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2014 07:15 AM, Oliver Graute wrote:
> Hello Florian,
> 
> On Wed, Nov 12, 2014 at 8:19 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 11/12/2014 05:07 AM, Oliver Graute wrote:
>>> Hello,
>>>
>>> how do I specify the DSA node and the MDIO node in the Device Tree
>>> Binding to integrate a Marvell 88e6071 switch with a imx28 board?
>>>
>>> On my board the Marvell switch 88e6071 is connected via phy1 (on a
>>> imx28 PCB) to phy5 on the Marvell switch (on a Switch PCB). All phys
>>> are connected via the same MDIO Bus.
>>>
>>> I enabled the Marvell DSA Support Driver, Gianfar Ethernet Driver and
>>> Freescale PQ MDIO Driver in the Kernel (I' am not sure if this is the
>>> right choice for imx28 fec ethernet controller is it?)
>>>
> 
> I changed my DeviceTree according to your proposal. Now I got a ENODEV 19
> in dsa_of_probe. Because  of_find_device_by_node(ethernet) is returning 0.
> Is my ethernet setting still wrong?

Is your ethernet driver also modular? If so, you will need it to be
loaded *before* dsa. of_find_device_by_node() also needs the ethernet
driver to be a platform_driver.

NB: I have a patch that looks up a net_device based on the struct
device_node that might be better to use, since it makes no assumption
about whether that is a platform_device/pci_device etc...

> 
> dsa@0 {
>         compatible = "marvell,dsa";
>         #address-cells = <2>;
>         #size-cells = <0>;
> 
>         interrupts = <10>;
>         dsa,ethernet = <&eth1>;
>         dsa,mii-bus = <&mdio_bus>;
> 
>         switch@0 {
>             #address-cells = <1>;
>             #size-cells = <0>;
>             reg = <5 0>;   /* MDIO address 5, switch 0 in tree */
> 
>             port@0 {
>                 reg = <0>;
>                 label = "lan1";
>                 phy-handle = <&ethphy1>;
>             };
> 
>             port@1 {
>                 reg = <1>;
>                 label = "lan2";
>             };
> 
>             port@2 {
>                 reg = <2>;
>                 label = "lan3";
>             };
> 
>             port@3 {
>                 reg = <3>;
>                 label = "lan4";
>             };
> 
>             port@4 {
>                 reg = <4>;
>                 label = "lan5";
>             };
> 
>             port@5 {
>                 reg = <5>;
>                 label = "cpu";
>             };
> 
>         };
>     };
> 
> eth1: eth1 {
>     status = "okay";
>     ethernet1-port@1 {
>         phy-handle = <&ethphy1>;
> 
>         fixed-link {
>                 speed = <1000>;
>                 full-duplex;
>             };
>     };
> };
> 
> mdio_bus: mdio@800f0040 {
>         #address-cells = <1>;
>         #size-cells = <0>;
>         device_type = "mdio";
>         //compatible = "fsl,gianfar-mdio";
>         compatible = "fsl,mpc875-fec-mdio", "fsl,pq1-fec-mdio";
>         reg = <0x800f0040 0x188>;
>         status = "okay";
> 
>          ethphy0: ethernet-phy@0 {
>                 compatible = "fsl,gianfar-mdio";
>                 device_type = "network";
>                 model = "FEC";
>                 reg = <0x00>;
> 
>          };
> 
>          ethphy1: ethernet-phy@1 {
>                  compatible = "fsl,gianfar-mdio";
>                  device_type = "network";
>                  model = "FEC";
>                  reg = <0x01>;
>                 };
>                  //reg = <0xff>; */ /* No PHY attached */
>                  //speed = <1000>;
>                  //duple = <1>;
>        };
> 
> modprobe dsa_core
> [  151.720180] !!!!!enter dsa_init_module!!!!!
> [  151.724713] !!!!Enter dsa Probe!!!!!
> [  151.728321] Distributed Switch Architecture driver version 0.1
> [  151.739026] !!!!!Enter dsa_of_probe!!!!!
> [  151.744515] !!!!!mdio->name=mdio mdio->type=mdio
> mdio->full_name=/mdio@800f0040 !!!!!
> [  151.753559] !!!!!np->name=dsa np->type=<NULL> np->full_name=/dsa@0 !!!!!
> [  151.761419] !!!!before of_mdio_find_bus!!!!!
> [  151.765732] !!!!!enter of_mdio_find_bus!!!!!
> [  151.772418] !!!!!!enter class_find_device!!!!!
> [  151.776908] !!!!!!enter class_dev_iter_init!!!!!
> [  151.783512] !!!!!!iter->type->name=(null) !!!!!
> [  151.788085] !!!!!!leave class_dev_iter_init!!!!!
> [  151.794439] !!!!!enter of_mdio_bus_match!!!!!
> [  151.798845] !!!!!enter of_mdio_bus_match!!!!!
> [  151.804967] !!!!!enter of_mdio_bus_match!!!!!
> [  151.809381] !!!!!!leave class_find_device return dev=!!!!!
> [  151.816668] !!!!Leave of_mdio_find_bus !!!!!
> [  151.822057] !!!!before of_parse_phandle dsa,ethernet!!!!!
> [  151.827553] !!!!before of find_device_by_node!!!!!
> [  151.834819] !!!!!ethernet->name=eth1 ethernet->type=<NULL>
> ethernet->full_name=/eth1 !!!!!
> [  151.844540] !!!!! enter of_find_device_by_node !!!!!
> [  151.850692] !!!!! Leave of_find_device_by_node dev=0 !!!!!
> [  151.856221] !!!! return  of_find-device_by_node =19 !!!!!
> [  151.863419] dsa_of_probe returns=-19
> [  151.873509] !!!!!leave dsa_init_module!!!!!
> 
> 
> Best Regards,
> 
> Oliver
> 
