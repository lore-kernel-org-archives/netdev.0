From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] bcm87xx: Add MODULE_DEVICE_TABLE
Date: Tue, 3 Sep 2013 21:53:31 +0100
Message-ID: <20130903205331.GD7729@decadent.org.uk>
References: <1378071184.25743.52.camel@deadeye.wl.decadent.org.uk>
 <52261D12.5000009@gmail.com>
 <20130903185305.GC7729@decadent.org.uk>
 <522634D0.7080606@caviumnetworks.com>
 <52263872.40209@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	David Daney <ddaney.cavm@gmail.com>,
	David Daney <david.daney@cavium.com>,
	netdev <netdev@vger.kernel.org>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39731 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760506Ab3ICUxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 16:53:38 -0400
Content-Disposition: inline
In-Reply-To: <52263872.40209@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 12:28:50PM -0700, David Daney wrote:
> On 09/03/2013 12:13 PM, David Daney wrote:
> >On 09/03/2013 11:53 AM, Ben Hutchings wrote:
> >>On Tue, Sep 03, 2013 at 10:32:02AM -0700, David Daney wrote:
> >>>On 09/01/2013 02:33 PM, Ben Hutchings wrote:
> >>>>bcm87xx currently isn't auto-loaded if built as a module.
> >>>>
> >>>>Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> >>>>---
> >>>>Compile-tested only.
> >>>
> >>>Then how do you know that it does anything sensible?
> >>
> >>This is generally required in modular PHY drivers.  I was hoping you'd
> >>be able to say whether that it's useful or necessary for this one.
> >
> >
> >OK. I just tested the patch, and it is not sufficient to get the module
> >loaded automatically.
> >
> 
> The problem is that get_phy_c45_ids() sets the phy_id that is passed
> to request_module() to zero, so it will never match anything.

Right.  Now I see that phy_driver::phy_id{,_mask} are actually not
used for this driver because phy_driver::match_phy_device overrides
those.

> We need to think about how this should work for  802.3-c45 PHYs.
> 
> Most c54 PHYs are conceptually composed of several pieces each with
> its own set of identifiers.

Yes, I know that but I wasn't sure how libphy deals with them.

> Which of these should be used?  Will
> something break if we start supplying a C22 phy_id for these
> devices?

But which one?  Maybe it would make sense to generate a modalias for
the device with all MMDs listed:

    mdio:<mmd><id>...

where <mmd> is the MMD number converted to a letter (a-z, A-F) and
<id> is the device ID as a bitstring, and they're repeated for all
present MMDs.  A module would then have modaliases that match on
any particular MMD's ID, e.g. this module would have the aliases:

    mdio:*e00000001010000111011110111000001*
    mdio:*e00000001010000111011111111110000*

(I'm assuming that a driver wouldn't need to match on multiple
MMD IDs, which would make the device table structure and
modpost logic more complicated.)

Maybe there's a simpler way to do it, but I don't know what.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
