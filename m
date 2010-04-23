From: Chris Wright <chrisw@redhat.com>
Subject: Re: eSwitch management
Date: Fri, 23 Apr 2010 12:44:55 -0700
Message-ID: <20100423194455.GA3843@x200.localdomain>
References: <C7F64614.2ADDF%scofeldm@cisco.com>
 <DD92D5A8-1ECC-4440-BE81-ABDCC6847021@qlogic.com>
 <20100423162307.GI30693@x200.localdomain>
 <8A4C54B1-B5E5-461D-9699-38526B9CEBF4@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@redhat.com>,
	Scott Feldman <scofeldm@cisco.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	shemminger@vyatta.com
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756450Ab0DWTpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Apr 2010 15:45:13 -0400
Content-Disposition: inline
In-Reply-To: <8A4C54B1-B5E5-461D-9699-38526B9CEBF4@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Anirban Chakraborty (anirban.chakraborty@qlogic.com) wrote:
> On Apr 23, 2010, at 9:23 AM, Chris Wright wrote:
> > * Anirban Chakraborty (anirban.chakraborty@qlogic.com) wrote:
> >> It looks like ifla_vf_info does contain most of the data set. But if I use it, what NETLINK protocol family should I use in my driver to receive netlink messages? Do I need to create a private protocol family?
> > 
> > No, you don't need to use netlink in your driver.  You just need to fill
> > in the relevant net_device_ops in your driver init.  Specifically:
> > 
> > *      SR-IOV management functions.
> > * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
> > * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
> > * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
> > * int (*ndo_get_vf_config)(struct net_device *dev,
> > *                          int vf, struct ifla_vf_info *ivf);
> > 
> > These are all operating on a VF indexed internally w/in the driver, so it's
> > a little cumbersome to use from userspace.
> 
> These are all intended for VFs and are configureable from PF.

Yes, and while the set of callbacks can change, they are always tied to
some net_device (typically the PF) that knows how to make hardware
settings on behalf of a VF.

> However, in our case, there are multiple physical NIC function on a
> port which are configureable by the eswitch.

Is there a PCI function that represents the switch?  Or a special PCI
NIC function that has VEB mgmt plane access?  And do you have examples
of configuration that you'll do here?

> So, what we are setting
> is essentially switch ports, rather than configuring any setting on the
> physical functions. If netlink doesn't fly, is sysfs going to work?

Before we go to implementation specifics (i.e. netlink vs. sysfs, and my
guess is sysfs isn't going to be the right fit), let's step back and
look at what needs setting.

> If
> we allocate a buffer and fill it up with user space tools that the driver
> grabs it and does the configuration itself?

One idea that has been discussed in the past is to create essentially
a pluggable set of bridge_ops.  The first step would be purely internal
shuffling, to make the existing sw bridge code go through the bridge_ops.
The second step would be making your driver for whichever PCI function
you have that supports managing the bridge create a net_device which is
a bridge during driver init.  And now normal brctl can call into your
VEB via the bridge_ops callbacks. </handwave>

But this too starts w/ looking at what the management requirements are
for your bridge.  Can you enumerate those?

thanks,
-chris
