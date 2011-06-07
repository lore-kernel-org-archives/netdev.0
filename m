From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH 1/2] vlan: only create special VLAN 0 once
Date: Tue, 7 Jun 2011 18:18:08 +0200
Message-ID: <20110607161808.GA5018@midget.suse.cz>
References: <20110603200738.GA24804@midget.suse.cz>
 <20110605.142823.1727360496050285755.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbohac@suse.cz, kaber@trash.net, netdev@vger.kernel.org,
	pedro.netdev@dondevamos.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57530 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754866Ab1FGQSK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 12:18:10 -0400
Content-Disposition: inline
In-Reply-To: <20110605.142823.1727360496050285755.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sun, Jun 05, 2011 at 02:28:23PM -0700, David Miller wrote:
> From: Jiri Bohac <jbohac@suse.cz>
> Date: Fri, 3 Jun 2011 22:07:38 +0200
> 
> > Commit ad1afb00 registers a VLAN with vid == 0 for every device to handle
> > 802.1p frames.  This is currently done on every NETDEV_UP event and the special
> > vlan is never unregistered.  This may have strange effects on drivers
> > implementning ndo_vlan_rx_add_vid(). E.g. bonding will allocate a linked-list
> > element each time, causing a memory leak.
> > 
> > Only register the special VLAN once on NETDEV_REGISTER.
> > 
> > Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> 
> I recognize the problem, but this solution isn't all that good.
> 
> I am pretty sure that the hardware device driver methods that
> implement ndo_vlan_rx_add_vid() assume that the device is up.
> Because most drivers completely reset the chip when the
> interface is brought up and this will likely clear out the
> VLAN ID tables in the chip.

Really? In that case, we have a much bigger problem: the vlan
code allows registering a new vlan on an interface that is down.
And it only registers the VID with ndo_vlan_rx_add_vid() in
register_vlan_dev() during the registration of the new vlan
interface -- it never re-registers the VIDs on a NETDEV_UP.

That would mean doing:

	ip link set down eth0
	ip link add link eth0 name eth0.1 type vlan id 1
	ip link set up eth0

... should result in a non-working setup, right? I would expect
an -EINVAL somewhere along the way.
However, at least for e1000, I just tested the above setup works.

Could you be wrong about this? Or is this supposed to fail with
other chips?  In that case, the vlan code or the drivers need
fixing. Something should either disallow adding vlans when down
and disallow putting the interface down then vlans are
configured, or it should re-register the VIDs on every NETDEV_UP.

> Second, now even devices which don't ever get brought up will
> have the VLAN ID 0 thing allocated.

Why is this a problem?
 
> Probably the thing to do is to remove the VLAN ID 0 entry on
> NETDEV_DOWN.

OK, if you prefer fixing it this way, why not...

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

