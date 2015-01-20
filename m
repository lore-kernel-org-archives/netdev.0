From: Vijay <katoch.vijay@gmail.com>
Subject: PHYless ethernet switch MAC-MAC serdes connection
Date: Tue, 20 Jan 2015 13:20:26 +0000 (UTC)
Message-ID: <loom.20150120T140914-531@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:55718 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbbATNZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2015 08:25:07 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1YDYno-0001Bn-BP
	for netdev@vger.kernel.org; Tue, 20 Jan 2015 14:25:04 +0100
Received: from 2024ob.scansafe.net ([115.111.223.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 14:25:04 +0100
Received: from katoch.vijay by 2024ob.scansafe.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 14:25:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All,
 
I have a custom board with Marvell 88E6046 ethernet switch which is 
connected directly to freescale P1010 processor.
 
  +------------+
  |              |             +------------+
  |              |   SGMII     |            |----- p0
  |         eth0 |-------------| p9         |
  |              |             |            |----- p1
  |              |             +------------+
  |              |               88e6086 (Switch)
  |              |
  |              |
  |              |    SGMII    +-------------+
  |         eth1 |-------------|             |
  +--------------+             +-------------+
  FS P1010                      88E1512 ( PHY)
 
  My dts looks like this,
 
          mii_bus0: mdio@24000 {
                      #address-cells = <1>;
                      #size-cells = <0>;
                      compatible = "fsl,etsec2-mdio";
                      reg = <0x24000 0x1000 0xb0030 0x4>;
 
                     /* No PHY on external MDIO for 88e6086 Switch,  
PHYless direct connection*/
                     /*------------*/
 
                    /* External PHY 88E1512 for eth1 */
                 phy1: ethernet-phy@1 {
                      interrupt-parent = <&mpic>;
                      interrupts = <3 1>;
                      reg = <0x1>;
                };
 
             };
 
         mdio@25000 {
                 #address-cells = <1>;
                 #size-cells = <0>;
                 compatible = "fsl,etsec2-tbi";
                 reg = <0x25000 0x1000 0xb1030 0x4>;
 
                 tbi0: tbi-phy@11 {                               /* TBI 
needed by gianfar for fixed-link eth0 */
                 reg = <0x11>;
                 device_type = "tbi-phy";
                 };
            };
 
      mdio@26000 {
                #address-cells = <1>;
                #size-cells = <0>;
                compatible = "fsl,etsec2-tbi";
                reg = <0x26000 0x1000 0xb1030 0x4>;
 
                tbi1: tbi-phy@12 {
                reg = <0x12>;
                device_type = "tbi-phy";
                 };
             };
 
 
            enet1: ethernet@b1000 {                          /*switch 
connected here*/
                 #address-cells = <1>;
                #size-cells = <1>;
                device_type = "network";
               model = "eTSEC";
               compatible = "fsl,etsec2";
               reg = <0xb1000 0x1000>;
               interrupts = <35 2 36 2 40 2>;
               fsl,num_rx_queues = <0x1>;
               fsl,num_tx_queues = <0x1>;
               local-mac-address = [ 00 00 00 00 00 00 ];
               interrupt-parent = <&mpic>;
               fixed-link = <0 1 1000 0 0>;
               tbi-handle = <&tbi0>;
               phy-mode = "sgmii";
               queue-group@0 {
                                #address-cells = <1>;
                                #size-cells = <1>;
                                reg = <0xb1000 0x1000>;
                                rx-bit-map = <0xff>;
                                tx-bit-map = <0xff>;
                                interrupts = <35 2 36 2 40 2>;
                        };
                 };
 
               enet2: ethernet@b2000 {
                      #address-cells = <1>;
                      #size-cells = <1>;
                      device_type = "network";
                      model = "eTSEC";
                      compatible = "fsl,etsec2";
                      fsl,num_rx_queues = <0x1>;
                      fsl,num_tx_queues = <0x1>;
                      local-mac-address = [ 00 00 00 00 00 00 ];
                      interrupt-parent = <&mpic>;
                      phy-handle = <&phy1>;
                      tbi-handle = <&tbi1>;
                      phy-connection-type = "sgmii";
 
                      ptimer-handle = < &ptp_timer >;
                      queue-group@0 {
                           #address-cells = <1>;
                           #size-cells = <1>;
                           reg = <0xb2000 0x1000>;
                           rx-bit-map = <0xff>;
                           tx-bit-map = <0xff>;
                           interrupts = <31 2 32 2 33 2>;
                      };
                 };
 
                 dsa@0 {
                           compatible = "marvell,dsa";
                           #address-cells = <2>;
                           #size-cells = <0>;
                           dsa,ethernet = <&enet1>;
                           dsa,mii-bus = <&mii_bus0>;
 
                           switch@0 {
                           #address-cells = <1>;
                           #size-cells = <0>;
                           reg = <31 0>;   /* Switch at SMI Add 0x1f */
 
                           port@0 {
                                     reg = <0>;
                                     label = "lan1";
                           };
 
                           port@1 {
                                     reg = <1>;
                                     label = "lan2";
                           };
 
                           port@9 {
                                     reg = <9>;
                                     label = "cpu";
                           };
                 };
       };
 

I have disabled auto-negotiation in gianfar driver for fixed-link eth0 
and associated TBI-PHY, so that SGMII link at 1Gb/ps can be forced with 
switch port 9 GMII MAC.
Linux DSA driver is able to detect and configure switch. It discover 
switch at external MDIO bus, DSA configure 'eth0' as master and 'lan1' 
and 'lan2' as slave port.
After assigning IPs to eth0 (Switch) and eth1 ( with external PHY) like,
     ifconfig eth0 up
     ifconfig lan1 xx.xx.xx.x1 up
     ifconfig lan2 xx.xx.xx.x2 up
 
     ifconfig eth1 xx.xx.xx.x3 up
 
When I ping from any other host on network, only lan1 is able to 
respond, because it was configured first. If any other port is pinged it 
will be able to respond
only if 'lan1 is connected to network'. If ethernet cable from lan1 is 
removed, rest of ports will not be able to respond, though they will be 
receiving packets but
their TX counter will not increase.
 
It seems whichever port is configured first ( lan1 here ) will be able 
to transmit packets. If eth1 ( connected to Phy not switch) is 
configured first then only this
will be able to respond. All other ports then depends on eth1.
 
I tried to move 'eth1' to another mdio bus ( mdio@25000 ) by modifying 
dts file above. But it seems 'PHY' and 'Switch' will only be detected if 
they are on
mdio@24000.

What could be the reason of such strange behaviour ?
Why only one interface is controlling the bus its either eth0/lan0/lan1 
or eth1. Rx counter of every interface increments but only one of these 
have Tx counter incremented. If I disable switch ports ( lan0/lan1), 
strangely eth1 also does not receive any packets ( though its Rx counter 
increments but Tx is 0). Is it happening because dsa@0 also controlling 
phy1 on same mdio bus ?
