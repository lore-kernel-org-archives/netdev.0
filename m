From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/13] batman-adv: deselect current GW on client mode switch off
Date: Thu,  9 Jan 2014 15:52:53 +0100
Message-ID: <1389279182-3256-5-git-send-email-antonio@meshcoding.com>
References: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:43342 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbaAIOyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:54:36 -0500
In-Reply-To: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

When switching from gw_mode client to either off or server
the current selected gateway has to be deselected.
In this way when client mode is enabled again a gateway
re-election is forced and a GW_ADD event is consequently
sent.

The current behaviour instead is to keep the current gateway
leading to no GW_ADD event when gw_mode client is selected
for a second time

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/gateway_client.c | 5 +++++
 net/batman-adv/sysfs.c          | 9 +++++++++
 2 files changed, 14 insertions(+)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 3564173..53a9009 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -205,6 +205,11 @@ void batadv_gw_check_client_stop(struct batadv_priv *bat_priv)
 	if (!curr_gw)
 		return;
 
+	/* deselect the current gateway so that next time that client mode is
+	 * enabled a proper GW_ADD event can be sent
+	 */
+	batadv_gw_select(bat_priv, NULL);
+
 	/* if batman-adv is switching the gw client mode off and a gateway was
 	 * already selected, send a DEL uevent
 	 */
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index e28f951..b652a56 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -406,6 +406,15 @@ static ssize_t batadv_store_gw_mode(struct kobject *kobj,
 	batadv_info(net_dev, "Changing gw mode from: %s to: %s\n",
 		    curr_gw_mode_str, buff);
 
+	/* Invoking batadv_gw_reselect() is not enough to really de-select the
+	 * current GW. It will only instruct the gateway client code to perform
+	 * a re-election the next time that this is needed.
+	 *
+	 * When gw client mode is being switched off the current GW must be
+	 * de-selected explicitly otherwise no GW_ADD uevent is thrown on
+	 * client mode re-activation. This is operation is performed in
+	 * batadv_gw_check_client_stop().
+	 */
 	batadv_gw_deselect(bat_priv);
 	/* always call batadv_gw_check_client_stop() before changing the gateway
 	 * state
-- 
1.8.5.2
