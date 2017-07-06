From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Fri, 7 Jul 2017 00:33:24 +0200
Message-ID: <20170706223324.GA24237@lunn.ch>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
 <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
 <20170627032239.05cdc462@cakuba.netronome.com>
 <20170628134139.GB12559@lunn.ch>
 <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
 <20170628180008.42059797@cakuba.netronome.com>
 <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706120214.6076be46@cakuba.netronome.com>
 <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <kubakici@wp.pl>,
        Dustin Byford <dustin@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "vidya.chowdary@gmail.com" <vidya.chowdary@gmail.com>,
        "olson@cumulusnetworks.com" <olson@cumulusnetworks.com>,
        Manoj Malviya <manojmalviya@chelsio.com>,
        Santosh Rastapur <santosh@chelsio.com>,
        "yuval.mintz@qlogic.com" <yuval.mintz@qlogic.com>,
        "odedw@mellanox.com" <odedw@mellanox.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47289 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752452AbdGFWdm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 18:33:42 -0400
Content-Disposition: inline
In-Reply-To: <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 06, 2017 at 09:53:46PM +0000, Casey Leedom wrote:
> | From: Jakub Kicinski <kubakici@wp.pl>
> | Sent: Thursday, July 6, 2017 12:02 PM
> |
> | IMHO if something gets replugged all the settings should be reset.
> | I feel that it's not entirely unlike replugging a USB adapter.  Perhaps
> | we should introduce some (devlink) notifications for SFP module events
> | so userspace can apply whatever static user config it has?
> 
> Absolutely a valid approach.  As are all of the ones I outlined.
> 
> But, and far more importantly, ideally _*ANY*_ such decision is made at an
> architectural level to apply to all Link Parameters and Vendor Products.
> The last thing a user wants to deal with is a hodge-podge of different
> policies for different adapters from different vendors.

Yes.

SFP needs to becomes a Linux device, similar to Copper PHYs are Linux
devices. With some core code which all drivers can use, implement
ethtool --dump-module-eeprom, report speeds to the MAC using
adjust_link, etc..

> how do users conceive of a "Port"?

For a user, it is something they configure via /etc/network/interfaces
and then use ifup/ifdown on.

>  I.e. when a user requests that a particular
> Link Parameter be applied to a Port, are they thinking that it only applies
> to the current instantaneous combination of Adapter Transceiver Module Cage
> + Transceiver Module?  Or do they conceptualize a "Port" as being a higher
> level entity?
> 
> Or, let's make it Very Concrete with a specific example:
> 
>  1. User applies some set of Link Parameters.
> 
>  2. User attempts to bring Link up but it doesn't come up.

So these are effectively one step for the user, since the
configuration goes into /etc/network/interfaces, and it is only when
ifup is used is it applied. If the configuration is not valid, at this
point in time, i would expect ifup to give an error message.

>  3. User decides to try a different cable on the grounds that the first
>     cable may be bad.
> 
>  4. New cable is accidentally of a completely different type with completely
>     different subsequent Physical Port Capabilities, not capable of supporting
>     the user's selected Link Parameters.

And this is where it gets interesting, as you say. We are into a
hotplug model.

I think you also need to define 'cable' here. I assume you are not
talking about a piece of CAT 5 or glass fibre. You mean something
which is active. You are putting a different module into the SFP cage.

The extreme model would be, if you pull the module out, the whole
netdev is hot-unplugged. Plug a different modules in, the netdev is
hot-plugged. The user has to ifup it again, and would get an error
message if the configuration is invalid.

But i think this is too extreme.

I think the sfp device needs to give a hotplug event on unplug/plug.
A hot-unplug would result in an ifdown. And within the kernel, the
netdev is set down. If there is an "allow-hotplug" statement in
/etc/network/interfaces, on hot-plug, udev would try to ifup and get
an error and it will stay down. Without the "allow-hotplug" the
interface remains configured down until the user does an ifup and
would see an error message if the configuration is invalid.

    Andrew
