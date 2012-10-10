From: Michal Kubecek <mkubecek@suse.cz>
Subject: unresponsive vlan on top of bond with fail_over_mac=active
Date: Thu, 11 Oct 2012 01:11:22 +0200
Message-ID: <20121010231122.GB28935@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59142 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932301Ab2JJXLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 19:11:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

a customer of ours has the following problem:

A bond is set up in active-backup mode with fail_over_mac=1 (active). On
top of it, a VLAN is created so that it inherits MAC address of the bond
which is the same as address of its active slave.

When failover occurs, the bond switches its MAC address to address of
the new active slave but VLAN interface keeps the old address and it
stops receiving packets from outside.

The customer suggested that upon failover, not only bond should switch
its MAC address to the new active slave but also all VLAN interfaces on
top of it. I don't like this approach too much as there is already a
different mechanism for the problem: network device's uc list. Since
commits

  7d26bb10  bonding: emit event when bonding changes MAC
  2af73d4b  net/bonding: emit address change event also in bond_release

VLAN device's MAC address is copied into bond's uc list. Unfortunately
there is no code taking care of syncing the bond's uc list to its
slaves (so that the slave drops the packets for the VLAN). My idea is to
do this either via ndo_set_rx_mode method or in response to an event.

But before proposing a patch, I would like to ask: which approach is
preferrable: copying active slave's hw address to all VLAN devices
defined on top of the bond or syncing bond's uc list to its slaves?

Thanks in advance,
                                                         Michal Kubecek
