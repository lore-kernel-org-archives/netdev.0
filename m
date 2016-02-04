From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] bonding: 3ad: allow to set ad_actor settings while the bond is up
Date: Thu,  4 Feb 2016 17:42:28 +0100
Message-ID: <1454604148-28658-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34414 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934203AbcBDQmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 11:42:33 -0500
Received: by mail-wm0-f67.google.com with SMTP id p63so12969260wmp.1
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 08:42:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

No need to require the bond down while changing these settings, the change
will be reflected immediately and the 3ad mode will sort itself out.
For faster convergence set port->ntt to true in order to generate new
LACPDUs immediately.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
This patch is on top of my previous change:
http://patchwork.ozlabs.org/patch/577908/

 drivers/net/bonding/bond_3ad.c     | 8 ++++++--
 drivers/net/bonding/bond_options.c | 3 +--
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index ee94056dbb2e..b9304a295f86 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2176,8 +2176,12 @@ void bond_3ad_update_ad_actor_settings(struct bonding *bond)
 		    *((struct mac_addr *)bond->params.ad_actor_system);
 
 	spin_lock_bh(&bond->mode_lock);
-	bond_for_each_slave(bond, slave, iter)
-		__ad_actor_update_port(&(SLAVE_AD_INFO(slave)->port));
+	bond_for_each_slave(bond, slave, iter) {
+		struct port *port = &(SLAVE_AD_INFO(slave))->port;
+
+		__ad_actor_update_port(port);
+		port->ntt = true;
+	}
 	spin_unlock_bh(&bond->mode_lock);
 }
 
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index ed0bdae64f5e..577e57cad1dc 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -402,7 +402,6 @@ static const struct bond_option bond_opts[BOND_OPT_LAST] = {
 		.id = BOND_OPT_AD_ACTOR_SYS_PRIO,
 		.name = "ad_actor_sys_prio",
 		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_8023AD)),
-		.flags = BOND_OPTFLAG_IFDOWN,
 		.values = bond_ad_actor_sys_prio_tbl,
 		.set = bond_option_ad_actor_sys_prio_set,
 	},
@@ -410,7 +409,7 @@ static const struct bond_option bond_opts[BOND_OPT_LAST] = {
 		.id = BOND_OPT_AD_ACTOR_SYSTEM,
 		.name = "ad_actor_system",
 		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_8023AD)),
-		.flags = BOND_OPTFLAG_RAWVAL | BOND_OPTFLAG_IFDOWN,
+		.flags = BOND_OPTFLAG_RAWVAL,
 		.set = bond_option_ad_actor_system_set,
 	},
 	[BOND_OPT_AD_USER_PORT_KEY] = {
-- 
2.4.3
