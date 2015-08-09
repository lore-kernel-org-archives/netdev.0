From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 net-next] dsa: Support multiple MDIO busses
Date: Sun, 9 Aug 2015 19:35:17 +0200
Message-ID: <20150809173517.GC11157@lunn.ch>
References: <1439083745-14169-1-git-send-email-andrew@lunn.ch>
 <55C749FD.8050303@cogentembedded.com>
 <20150809142030.GB14271@lunn.ch>
 <55C78D52.5040401@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56503 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933105AbbHIRmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2015 13:42:24 -0400
Content-Disposition: inline
In-Reply-To: <55C78D52.5040401@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >The optional mii-bus properties i'm adding should be used in
> >preference to this global one, for this switch. Keeping the names the
> >same makes sense. But i did drop the dsa prefix to indicate it is
> >local, not global scope,
> 
>    Dropping a vendor prefix usually means that it's (standardized)
> common property name. I don't know where you took the "local" scope
> thing...

DSA has at least three levels of hierarchy. The following is the
example from the binding documentation. There is a 'global' scope
dsa,mii-bus = <&mii_bus0> in the top level, which is mandatory. This
patch allows optional 'local' scope mii bus to be specified at an
individual switch level. The 'local' value, if present, will override
the 'global' value.

Maybe more properties should use the dsa prefix? But dsa is not a
vendor prefix, it just refers to "Distributed Switch Architecture",
the scheme for accessing a number of Ethernet switches connected
together in a cluster. But as the binding has grown, this prefix has
not been used with new properties.

    Andrew

        dsa@0 {
                compatible = "marvell,dsa";
                #address-cells = <2>;
                #size-cells = <0>;

                interrupts = <10>;
                dsa,ethernet = <&ethernet0>;
                dsa,mii-bus = <&mii_bus0>;

                switch@0 {
                        #address-cells = <1>;
                        #size-cells = <0>;
                        reg = <16 0>;   /* MDIO address 16, switch 0 in tree */

                        port@0 {
                                reg = <0>;
                                label = "lan1";
                                phy-handle = <&phy0>;
                        };

                        port@1 {
                                reg = <1>;
                                label = "lan2";
                        };

                        port@5 {
                                reg = <5>;
                                label = "cpu";
                        };

                        switch0port6: port@6 {
                                reg = <6>;
                                label = "dsa";
                                link = <&switch1port0
                                        &switch2port0>;
                        };
                };

                switch@1 {
                        #address-cells = <1>;
                        #size-cells = <0>;
                        reg = <17 1>;   /* MDIO address 17, switch 1 in tree */
                        mii-bus = <&mii_bus1>;

                        switch1port0: port@0 {
                                reg = <0>;
                                label = "dsa";
                                link = <&switch0port6>;
                        };
                        switch1port1: port@1 {
                                reg = <1>;
                                label = "dsa";
                                link = <&switch2port1>;
                        };
                };

                switch@2 {
                        #address-cells = <1>;
                        #size-cells = <0>;
                        reg = <18 2>;   /* MDIO address 18, switch 2 in tree */
                        mii-bus = <&mii_bus1>;

                        switch2port0: port@0 {
                                reg = <0>;
                                label = "dsa";
                                link = <&switch1port1
                                        &switch0port6>;
                        };
                };
        };
