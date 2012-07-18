From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] team: refine IFF_XMIT_DST_RELEASE capability
Date: Wed, 18 Jul 2012 19:39:38 +0200
Message-ID: <1342633178-1411-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59535 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857Ab2GRRjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 13:39:43 -0400
Received: by wgbdr13 with SMTP id dr13so1597927wgb.1
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 10:39:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cloned patch of Eric Dumazet for bonding.

Some workloads greatly benefit of IFF_XMIT_DST_RELEASE capability
on output net device, avoiding dirtying dst refcount.

team currently disables IFF_XMIT_DST_RELEASE unconditionally.

If all ports have the IFF_XMIT_DST_RELEASE bit set, then
team dev can also have it in its priv_flags.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 1a13470..813e131 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -733,12 +733,14 @@ static void __team_compute_features(struct team *team)
 	struct team_port *port;
 	u32 vlan_features = TEAM_VLAN_FEATURES;
 	unsigned short max_hard_header_len = ETH_HLEN;
+	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
 
 	list_for_each_entry(port, &team->port_list, list) {
 		vlan_features = netdev_increment_features(vlan_features,
 					port->dev->vlan_features,
 					TEAM_VLAN_FEATURES);
 
+		dst_release_flag &= port->dev->priv_flags;
 		if (port->dev->hard_header_len > max_hard_header_len)
 			max_hard_header_len = port->dev->hard_header_len;
 	}
@@ -746,6 +748,9 @@ static void __team_compute_features(struct team *team)
 	team->dev->vlan_features = vlan_features;
 	team->dev->hard_header_len = max_hard_header_len;
 
+	flags = team->dev->priv_flags & ~IFF_XMIT_DST_RELEASE;
+	team->dev->priv_flags = flags | dst_release_flag;
+
 	netdev_change_features(team->dev);
 }
 
-- 
1.7.10.4
