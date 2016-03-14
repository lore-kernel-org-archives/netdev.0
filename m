From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 0/2] DT MDIO bus of fixed phys
Date: Mon, 14 Mar 2016 20:04:30 +0100
Message-ID: <20160314190430.GA10040@lunn.ch>
References: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
 <56E35432.2010300@gmail.com>
 <20160311233610.GB23969@lunn.ch>
 <56E35712.5080508@gmail.com>
 <20160312001224.GE23969@lunn.ch>
 <56E6EC23.9080301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47426 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753861AbcCNTEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 15:04:33 -0400
Content-Disposition: inline
In-Reply-To: <56E6EC23.9080301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2016 at 09:51:47AM -0700, Florian Fainelli wrote:
> On 11/03/16 16:12, Andrew Lunn wrote:
> >>>> Humm, if that's the problem we want to solve, we could introduce a
> >>>> helper function which tries to locate the phy using a 'phy-handle'
> >>>> property
> >>>
> >>> I don't follow you. Where do you get a phandle from to use with
> >>> phy-handle?
> >>
> >> >From the caller of the function: the consumer of that phy-handle and/or
> >> fixed-link property which is either an Ethernet MAC driver or a DSA's
> >> switch port node.
> > 
> > I still don't get it. Lets take a real example. I currently have this
> > in one of my dts files:
> > 
> > &fec1 {
> >        phy-mode = "rmii";
> >        pinctrl-names = "default";
> >        pinctrl-0 = <&pinctrl_fec1>;
> >        status = "okay";
> > 
> >        fixed-link {
> >                   speed = <100>;
> >                   full-duplex;
> >        };
> > };
> 
> All drivers have this exact same structure:
> 
> &fec1 {
> 	phy-handle = <XYZ>;
> 	or
> 	fixed-link {
> 		speed = <100>;
> 		full-duplex;
> 	};
> };
> 
> In both cases, the argument that this proposed helper function would
> take is a struct device_node pointing to &fec1 here. You could therefore
> imagine having something along these lines:
> 
> struct device_node *of_get_phy_by_phandle(struct device_node *dn, bool
> try_fixed_link)

I don't particularly like this name. It suggests it is using the
phandle, when it might not.

> {
> 	struct device_node *phy_dn;
> 	int ret;
> 
> 	phy_dn = of_parse_phandle(dn, "phy-handle", 0);
> 	if (!phy_dn && !try_fixed_link)
> 		return -ENODEV;
> 
> 	if (of_phy_is_fixed_link(dn)) {
> 		ret  = of_phy_register_fixed_link(dn);
> 		if (ret)
> 			return PTR_ERR(-ret);
> 
> 		phy_dn = of_node_get(dn);
> 	}
> 
> 	return phy_dn;		
> }

To make release work, i think you need to hack something into
phy_disconnect() or phy_detach() so that the fixed_phy registered
above gets freed.

I don't particularly like these special cases. What i suggested does
not require any special cases, because they act just like phys on an
mdio bus.

     Andrew
