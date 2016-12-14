From: John Crispin <john@phrozen.org>
Subject: dsa: handling more than 1 cpu port
Date: Wed, 14 Dec 2016 11:01:54 +0100
Message-ID: <1671ae82-c213-7611-584f-02a3b1d5dff9@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:43916 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754583AbcLNKB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 05:01:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

switches supported by qca8k have 2 gmacs that we can wire an external
mii interface to. Usually this is used to wire 2 of the SoCs MACs to the
switch. Thw switch itself is aware of one of the MACs being the cpu port
and expects this to be port/mac0. Using the other will break the
hardware offloading features. The original series from Matthieu added a
feature to configure the switch in a pass-through mode [1]. This
resulted in us having to define the pass-through inside the dts which
means that we loose userland configurability. Assume the setup as
follows ...

port0 - cpu port wired to SoCs MAC0
port1-4 - the lan ports
port5 - the wan port
port6 - wired to the SoCs MAC1

What i have done now is bring up one bridge for port1-4 and a second one
for port5-6. Once setup I can pass traffic on the SoCs MAC1 and it will
flow via port6 and egress on port5. So far so good, however due to the
way the port based vlans are setup and how the bridge_join/leave() logic
works, port5/6 will also fwd traffic to the cpu port. the driver has now
to tell that we are trunking traffic on eth1 via port6. also the MII
mode is not known to the driver. Adding some hackish register writes
will make this work nicely. My proposed way of fixing this cleanly in an
upstream friendly way would be as follows

1) add an extra dsa,ethernet property to the 2nd MII port

dsa@0 {
        compatible = "qca,ar8xxx";

        dsa,ethernet = <&gmac1>;

	[...]

        switch@0 {
		[...]

                port@5 {
                        reg = <5>;
                        label = "wan";
                        phy-handle = <&phy_port5>;
                };

                port@6 {
                        reg = <6>;
                        label = "gmac2";

                        dsa,ethernet = <&gmac2>;
                        fixed-link {
                                speed = <1000>;
                                full-duplex;
                        };
                };
        };
};

2) fix up the port_bridge_join/leave() logic such that if a port is
present in the bridge that has a reference to a ethernet interface it
will remove all ports in the bridge from the port based vlan of the
actual cpu port.

3) in case of this switch we also need to fiddle with the bcast/mcast
flooding registers

would this be ok and would it be better to probe the extra dsa_ethernet
inside the subsystem or the driver ? i was considering to do add a
dsa_is_trunk_port() or similar to achieve this.

	John




[1] https://patchwork.ozlabs.org/patch/477525/
