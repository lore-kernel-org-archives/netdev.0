From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: fix mv88e6xxx switches
Date: Sat, 23 Jan 2016 19:15:26 +0100
Message-ID: <20160123181526.GD3880@lunn.ch>
References: <E1aMvmm-0006G3-8T@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41338 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753472AbcAWSPf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jan 2016 13:15:35 -0500
Content-Disposition: inline
In-Reply-To: <E1aMvmm-0006G3-8T@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 23, 2016 at 10:51:16AM +0000, Russell King wrote:
> Since commit 76e398a62712 ("net: dsa: use switchdev obj for VLAN add/del
> ops"), the Marvell 88E6xxx switch has been unable to pass traffic
> between ports - any received traffic is discarded by the switch.
> Taking a port out of bridge mode and configuring a vlan on it also the
> port to start passing traffic.
> 
> With the debugfs files re-instated to allow debug of this issue by
> comparing the register settings between the working and non-working
> case, the reason becomes clear:
> 
>      GLOBAL GLOBAL2 SERDES   0    1    2    3    4    5    6
> - 7:  1111    707f    2001     2    2    2    2    2    0    2
> + 7:  1111    707f    2001     1    1    1    1    1    0    1
> 
> Register 7 for the ports is the default vlan tag register, and in the
> non-working setup, it has been set to 2, despite vlan 2 not being
> configured.  This causes the switch to drop all packets coming in to
> these ports.  The working setup has the default vlan tag register set
> to 1, which is the default vlan when none is configured.
> 
> Inspection of the code reveals why.  The code prior to this commit
> was:
> 
> -		for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
> ...
> -			if (!err && vlan->flags & BRIDGE_VLAN_INFO_PVID)
> -				err = ds->drv->port_pvid_set(ds, p->port, vid);
> 
> but the new code is:
> 
> +	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
> ...
> +	}
> ...
> +	if (pvid)
> +		err = _mv88e6xxx_port_pvid_set(ds, port, vid);
> 
> This causes the new code to always set the default vlan to one higher
> than the old code.
> 
> Fix this.
> 
> Fixes: 76e398a62712 ("net: dsa: use switchdev obj for VLAN add/del ops")
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Hi Russell

Thanks for digging into this.

I think this is a step towards a solution, but does not solve all the
problems.

e.g. I have a switch interface lan0 with the IP address
192.168.10.2. I can ping this address from another host. I then take
the IP address off the interface, create a br0 device, add lan0 to the
bridge, and put 192.168.10.2 onto the bridge. I should be able to then
ping the address. But it does not work.

     Andrew
