From: Veaceslav Falico <vfalico@redhat.com>
Subject: [RFC PATCH net-next] bonding: remove bond->vlan_list
Date: Tue,  6 Aug 2013 19:58:58 +0200
Message-ID: <1375811944-31942-1-git-send-email-vfalico@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756325Ab3HFR6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 13:58:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The aim of this patchset is to remove bond->vlan_list completely, and use
8021q's standard functions instead of it.

The patchset is on top of Nik's latest two patches:
[net-next,v2,1/2] bonding: change the bond's vlan syncing functions with
			   the standard ones
[net-next,v2,2/2] bonding: unwind on bond_add_vlan failure


First two patches add two helper functions to vlan code:

bonding: add vlan_uses_dev_rcu() and make bond_vlan_used() use it

	Here we add a copy of vlan_uses_dev(), only rcu'd instead of rtnl,
	and make bond_vlan_used() use it under rcu_read_lock().

vlan: add __vlan_find_dev_next_id()

	This function takes dev and vlan_id and returns the next vlan id
	that uses this dev. It can be used to cycle through the vlan list,
	and not only by bonding - but by any network driver that uses its
	private vlan list.

Next four patches actually convert bonding to use the new
functions/approach and remove the vlan_list completely.

This patchset solves several issues with bonding, simplify it overall,
RCUify further and add infrastructure to anyone else who'd like to use
8021q standard functions instead of their own vlan_list, which is quite
common amongst network drivers currently.

I'm testing it continuously currently, no issues found, will update on
anything.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Patrick McHardy <kaber@trash.net>
CC: "David S. Miller" <davem@davemloft.net>
CC: Nikolay Aleksandrov <nikolay@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 drivers/net/bonding/bond_alb.c  |   29 +++++---
 drivers/net/bonding/bond_alb.h  |    2 +-
 drivers/net/bonding/bond_main.c |  145 +++++----------------------------------
 drivers/net/bonding/bonding.h   |   16 +++--
 include/linux/if_vlan.h         |   12 +++
 net/8021q/vlan_core.c           |   47 +++++++++++++
 6 files changed, 105 insertions(+), 146 deletions(-)
