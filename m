From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net] bonding: fix vlan_features computing
Date: Fri,  2 May 2014 18:57:27 +0200 (CEST)
Message-ID: <20140502165727.850ECE635B@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Michal Miroslaw <mirq-linux@rere.qmqm.pl>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57729 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752872AbaEBQ52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2014 12:57:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_compute_features() uses netdev_increment_features() to
combine vlan_features of slaves into vlan_features of the bond.
As netdev_increment_features() only adds most features and we
start with BOND_VLAN_FEATURES, we may end up with features none
of the slaves provided.

In particular, BOND_VLAN_FEATURES contains NETIF_F_HW_CSUM so
that netdev_increment_features() clears NETIF_F_IP{,V6}_CSUM and
if we only have slaves with NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
(e.g. ixgbe based cards), the same will be in features of the
bond and a vlan device on top of the bond would support no
checksumming, resulting in significant performance degradation.

If there is at least one slave, initialize vlan_features only
with the flags in NETIF_F_ALL_FOR_ALL. Right now there is none
in BOND_VLAN_FEATURES but stating it explicitely will make the
code more future proof.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 69aff72..34ca55d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1038,6 +1038,7 @@ static void bond_compute_features(struct bonding *bond)
 
 	if (!bond_has_slaves(bond))
 		goto done;
+	vlan_features &= NETIF_F_ALL_FOR_ALL;
 
 	bond_for_each_slave(bond, slave, iter) {
 		vlan_features = netdev_increment_features(vlan_features,
-- 
1.8.1.4
