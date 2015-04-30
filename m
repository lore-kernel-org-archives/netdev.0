From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 3/8] net: phy: Allow PHY devices to identify
 themselves as Ethernet switches
Date: Thu, 30 Apr 2015 19:48:37 +0200
Message-ID: <20150430174837.GB1476@lunn.ch>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
 <1430359064-23454-4-git-send-email-f.fainelli@gmail.com>
 <20150430125658.GB22831@lunn.ch>
 <55425AB3.2040908@gmail.com>
 <20150430171630.GE18874@lunn.ch>
 <55426868.8020606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44901 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231AbbD3RxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 13:53:16 -0400
Content-Disposition: inline
In-Reply-To: <55426868.8020606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2015 at 10:37:44AM -0700, Florian Fainelli wrote:
> On 30/04/15 10:16, Andrew Lunn wrote:
> >>> Hi Florian
> >>>
> >>> I have another two use cases for fixed_phy which i'm thinking about
> >>> implementing soon. Both require putting a fixed_phy into DSA port
> >>> properties in DT.
> >>>
> >>> The first is when the CPU ethernet and the switch don't have the same
> >>> speed capabilities. At the moment, the switch driver configures the
> >>> CPU port to its maximum speed. But i know of a board coming soon with
> >>> gigabit switch ports, but the CPU Ethernet is only fast Ethernet.
> >>
> >> With the patch after, if your switch is MDIO connected to your host, you
> >> could make that happen easily, since the read_status() callback would
> >> only be invoked for the CPU port from the CPU Ethernet MAC driver
> >> (that's the theory).
> > 
> > I'm not sure i get what you are saying.
> > 
> > What we currently have is:
> > 
> > CPU ETH->fixed_phy                      Switch port CPU
> > |                                       |
> > +---------------------------------------+
> > 
> > and what i'm thinking we want is:
> > 
> > CPU ETH->fixed_phy          fixed_phy <-Switch port CPU
> > |                                       |
> > +---------------------------------------+
> > 
> > So that when setting up the switch side of the link, i can read from
> > the switch ports fixed_phy how the port should be configured.
> 
> I see, but it still seems to me like these fixed PHY devices could be
> eliminated completely only, and only if your switch is MDIO connected,
> because then this becomes this:
> 
> CPU ETH -> PHY driver <- CPU port of the switch
> 
> and the PHY driver provided by your switch gives you the correct link
> parameters for both ends, right?

Are you suggesting this phy driver sat in the middle effectively
performs auto negotiation in both directions? It sees what both sides
offer and then gives back the highest common setting?

> If you do not have a MDIO switch, or something we could discover the
> link parameters from, then a fixed PHY has to be used, and it seems to
> me like we should have some sort of generic code doing that in DSA
> today: try to find a 'fixed-link' subnode (or old 5-tuple property) in
> the device tree node pointed at by dsa,ethernet, read these and feed
> them back to the DSA switch driver such that link parameters can be
> properly configured?

I don't think it should come from dsa,ethernet. Think of the case of
two CPU ports? It is a property of the cpu port(s).
 
> Feels like whatever we decide there is definitively something missing
> today though, either the Ethernet MAC does not have the hooks to get the
> parameters, or the switch has hardcoded them...

Agreed. And we should also try to include into the picture how we code
with fixed phy configurations on normal ports, e.g. SFP modules. Maybe
we don't need anything special for CPU and DSA ports, we solve it for
all types of ports.

    Andrew
