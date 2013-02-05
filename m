From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] team: allow userspace to take control over carrier
Date: Tue,  5 Feb 2013 17:30:55 -0200
Message-ID: <1360092655-28223-1-git-send-email-fbl@redhat.com>
Cc: Jiri Pirko <jpirko@redhat.com>, Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754437Ab3BETbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 14:31:04 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r15JV3SG031670
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2013 14:31:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some modes don't require any special carrier handling so
in these cases, the kernel can control the carrier as for
any other interface.  However, some other modes, e.g. lacp,
requires more than just that, so userspace needs to control
the carrier itself.

The daemon today is ready to control it, but the kernel
still can change it based on events.

This fix so that either kernel or userspace is controlling
the carrier.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/team/team.c | 8 ++++++++
 include/linux/if_team.h | 1 +
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 694ccf6..05c5efe 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -508,6 +508,7 @@ static bool team_is_mode_set(struct team *team)
 
 static void team_set_no_mode(struct team *team)
 {
+	team->user_carrier_enabled = false;
 	team->mode = &__team_no_mode;
 }
 
@@ -1710,6 +1711,10 @@ static netdev_features_t team_fix_features(struct net_device *dev,
 
 static int team_change_carrier(struct net_device *dev, bool new_carrier)
 {
+	struct team *team = netdev_priv(dev);
+
+	team->user_carrier_enabled = true;
+
 	if (new_carrier)
 		netif_carrier_on(dev);
 	else
@@ -2573,6 +2578,9 @@ static void __team_carrier_check(struct team *team)
 	struct team_port *port;
 	bool team_linkup;
 
+	if (team->user_carrier_enabled)
+		return;
+
 	team_linkup = false;
 	list_for_each_entry(port, &team->port_list, list) {
 		if (port->linkup) {
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 0245def..4648d80 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -186,6 +186,7 @@ struct team {
 
 	const struct team_mode *mode;
 	struct team_mode_ops ops;
+	bool user_carrier_enabled;
 	bool queue_override_enabled;
 	struct list_head *qom_lists; /* array of queue override mapping lists */
 	long mode_priv[TEAM_MODE_PRIV_LONGS];
-- 
1.8.1
