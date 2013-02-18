From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net 1/3] bonding: Fix race condition between bond_enslave() and bond_3ad_update_lacp_rate()
Date: Mon, 18 Feb 2013 18:59:02 +0100
Message-ID: <1361210344-14907-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57557 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756564Ab3BRSB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 13:01:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

port->slave can be NULL since it's being initialized in bond_enslave
thus dereferencing a NULL pointer in bond_3ad_update_lacp_rate()
Also fix a minor bug, which could cause a port not to have
AD_STATE_LACP_TIMEOUT since there's no sync between
bond_3ad_update_lacp_rate() and bond_3ad_bind_slave(), by changing
the read_lock to a write_lock_bh in bond_3ad_update_lacp_rate().

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index a030e63..1720742 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2494,11 +2494,13 @@ void bond_3ad_update_lacp_rate(struct bonding *bond)
 	struct port *port = NULL;
 	int lacp_fast;
 
-	read_lock(&bond->lock);
+	write_lock_bh(&bond->lock);
 	lacp_fast = bond->params.lacp_fast;
 
 	bond_for_each_slave(bond, slave, i) {
 		port = &(SLAVE_AD_INFO(slave).port);
+		if (port->slave == NULL)
+			continue;
 		__get_state_machine_lock(port);
 		if (lacp_fast)
 			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
@@ -2507,5 +2509,5 @@ void bond_3ad_update_lacp_rate(struct bonding *bond)
 		__release_state_machine_lock(port);
 	}
 
-	read_unlock(&bond->lock);
+	write_unlock_bh(&bond->lock);
 }
-- 
1.7.11.7
