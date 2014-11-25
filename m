From: Ronen Arad <ronen.arad@intel.com>
Subject: Re: [RFC PATCH 0/4] switch device: offload policy attributes
Date: Tue, 25 Nov 2014 03:10:41 +0000 (UTC)
Message-ID: <loom.20141125T032621-877@post.gmane.org>
References: <1416610170-21224-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bCDp2Cf=azOJvnm3_YRdsD5vwCafbcVFuseUaPuYKDA1g@mail.gmail.com> <547346EB.7060302@cumulusnetworks.com> <CAE4R7bAY2zMy4SiuwhdXyH2Swqv1KfkrBJ_ZwU_RYdCW3k+Mvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:55507 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750770AbaKYDPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 22:15:06 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Xt6al-00017k-Ph
	for netdev@vger.kernel.org; Tue, 25 Nov 2014 04:15:03 +0100
Received: from 192.55.55.41 ([192.55.55.41])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 04:15:03 +0100
Received: from ronen.arad by 192.55.55.41 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 04:15:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Feldman <sfeldma <at> gmail.com> writes:

> 
> On Mon, Nov 24, 2014 at 4:55 AM, Roopa Prabhu <roopa <at> 
cumulusnetworks.com> wrote:
> > On 11/24/14, 2:18 AM, Scott Feldman wrote:
> >>
> >> Hi Roopa,
> >>
> >> I have a patch pending against Jiri's v2 that's uses existing
> >> ndo_bridge_setlink/getlink to push policy settings down to port driver
> >> for controlling HW offload.  I had to make a few tweaks, but for the
> >> most part setlink/getlink already has the master/self semantics so
> >> users can set policy flags on bridge's SW version of the port (master)
> >> or on the offloaded version of the port (self).
> >>    I added the new
> >> hwmode option "swdev" to the existing "vepa"|"veb" choices.  When you
> >> specify hwmode, SELF is set and the port driver's setlink get's
> >> called.  Did you look at setlink/getlink?  It looks like the kernel
> >> and iproute2 where going down this route of using setlink/getlink for
> >> SELF policy, so I'm wondering if we need more?
> >
> > If i understand you correctly, this will mean the port driver implements 
the
> > setlink/getlink with the  bridge port flags and attributes. And, it also
> > means
> > the port driver will parse the netlink msg instead of the bridge driver
> > parsing all attributes and then calling offloads.
> 
> Yes, exactly, the port driver parses/fills bridge_setlink/getlink
> netlink msg to set/get port settings.  It's basically a passthru for
> rtnl_bridge_setlink/getlink handling RTM_GETLNK/RTM_SETLINK on
> PF_BRIDGE.
> 
> > But, in cases where we want bridge port flags and attributes set both in 
hw
> > and sw,
> > the user (iproute2) will have to set both MASTER and SELF flags, and the
> > netlink parsing will now happen in two places, the bridge driver and the
> > bridge port
> > driver ?
> 

How does VLAN filtering is expected to work with an HW-offloaded bridge?

When MASTER flag is set by iproute2 in the netlink message (or no flag is
 set), br_setlink - the ndo_bridge_setlink function of the port's master
bridge is called. It takes care of setting the VLAN policy in the 
net_port_vlans of the net_bridge_port. During this sequence the 
ndo_vlan_rx_add_vid function of the port dev is called. However, it only gets 
the vid. It does not have access to the flags (PVID, UNTAGGED) and those are 
not set in the net_port_vlans struct at that time.

Giving the port driver access to the VLAN policy requires both MASTER and 
SLAVE flags to be set in the IFLA_BRIDGE_FLAGS attribute.
Is the end user is expected to set both flags in the "bridge vlan add"
command (Failing to do that will prevent the bridge and HW from being in
sync)?

Even with both MASTER and SLAVE flags being set in a single netlink request,
the HW and bridge could get out of sync if adding the VLAN policy to the port
driver would fail after it was added to the bridge netdev.
Is there any mechanism for keeping both software and HW in-sync?

-Ronen
