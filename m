From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 1/3] team: Do not hold rcu_read_lock when running netlink cmds
Date: Wed, 16 Nov 2011 22:09:07 +0100
Message-ID: <1321477749-1877-2-git-send-email-jpirko@redhat.com>
References: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753655Ab1KPVJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 16:09:18 -0500
In-Reply-To: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 60672bb..e0cf11c 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1043,8 +1043,7 @@ err_msg_put:
 
 /*
  * Netlink cmd functions should be locked by following two functions.
- * To ensure team_uninit would not be called in between, hold rcu_read_lock
- * all the time.
+ * Since dev gets held here, that ensures dev won't disappear in between.
  */
 static struct team *team_nl_team_get(struct genl_info *info)
 {
@@ -1057,12 +1056,9 @@ static struct team *team_nl_team_get(struct genl_info *info)
 		return NULL;
 
 	ifindex = nla_get_u32(info->attrs[TEAM_ATTR_TEAM_IFINDEX]);
-	rcu_read_lock();
-	dev = dev_get_by_index_rcu(net, ifindex);
-	if (!dev || dev->netdev_ops != &team_netdev_ops) {
-		rcu_read_unlock();
+	dev = dev_get_by_index(net, ifindex);
+	if (!dev || dev->netdev_ops != &team_netdev_ops)
 		return NULL;
-	}
 
 	team = netdev_priv(dev);
 	spin_lock(&team->lock);
@@ -1072,7 +1068,7 @@ static struct team *team_nl_team_get(struct genl_info *info)
 static void team_nl_team_put(struct team *team)
 {
 	spin_unlock(&team->lock);
-	rcu_read_unlock();
+	dev_put(team->dev);
 }
 
 static int team_nl_send_generic(struct genl_info *info, struct team *team,
-- 
1.7.6
