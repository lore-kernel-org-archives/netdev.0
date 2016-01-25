From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: dsa: fix mv88e6xxx switches
Date: Mon, 25 Jan 2016 10:49:51 -0800 (PST)
Message-ID: <20160125.104951.2107445075808691892.davem@davemloft.net>
References: <E1aNGs1-0002kA-1b@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	netdev@vger.kernel.org
To: rmk+kernel@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbcAYStw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 13:49:52 -0500
In-Reply-To: <E1aNGs1-0002kA-1b@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Sun, 24 Jan 2016 09:22:05 +0000

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

Applied and queued up for -stable, thanks Russell.
