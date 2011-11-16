From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 2/3] team: convert overall spinlock to mutex
Date: Wed, 16 Nov 2011 22:09:08 +0100
Message-ID: <1321477749-1877-3-git-send-email-jpirko@redhat.com>
References: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55067 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753699Ab1KPVJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 16:09:19 -0500
In-Reply-To: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to have spinlock for this purpose. So convert this to mutex and
avoid current schedule while atomic problems in netlink code.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   32 ++++++++++++++++----------------
 include/linux/if_team.h |    2 +-
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index e0cf11c..04f9302 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -443,9 +443,9 @@ static void __team_compute_features(struct team *team)
 
 static void team_compute_features(struct team *team)
 {
-	spin_lock(&team->lock);
+	mutex_lock(&team->lock);
 	__team_compute_features(team);
-	spin_unlock(&team->lock);
+	mutex_unlock(&team->lock);
 }
 
 static int team_port_enter(struct team *team, struct team_port *port)
@@ -647,7 +647,7 @@ static int team_init(struct net_device *dev)
 	int i;
 
 	team->dev = dev;
-	spin_lock_init(&team->lock);
+	mutex_init(&team->lock);
 
 	team->pcpu_stats = alloc_percpu(struct team_pcpu_stats);
 	if (!team->pcpu_stats)
@@ -672,13 +672,13 @@ static void team_uninit(struct net_device *dev)
 	struct team_port *port;
 	struct team_port *tmp;
 
-	spin_lock(&team->lock);
+	mutex_lock(&team->lock);
 	list_for_each_entry_safe(port, tmp, &team->port_list, list)
 		team_port_del(team, port->dev);
 
 	__team_change_mode(team, NULL); /* cleanup */
 	__team_options_unregister(team, team_options, ARRAY_SIZE(team_options));
-	spin_unlock(&team->lock);
+	mutex_unlock(&team->lock);
 }
 
 static void team_destructor(struct net_device *dev)
@@ -784,7 +784,7 @@ static int team_change_mtu(struct net_device *dev, int new_mtu)
 	 * Alhough this is reader, it's guarded by team lock. It's not possible
 	 * to traverse list in reverse under rcu_read_lock
 	 */
-	spin_lock(&team->lock);
+	mutex_lock(&team->lock);
 	list_for_each_entry(port, &team->port_list, list) {
 		err = dev_set_mtu(port->dev, new_mtu);
 		if (err) {
@@ -793,7 +793,7 @@ static int team_change_mtu(struct net_device *dev, int new_mtu)
 			goto unwind;
 		}
 	}
-	spin_unlock(&team->lock);
+	mutex_unlock(&team->lock);
 
 	dev->mtu = new_mtu;
 
@@ -802,7 +802,7 @@ static int team_change_mtu(struct net_device *dev, int new_mtu)
 unwind:
 	list_for_each_entry_continue_reverse(port, &team->port_list, list)
 		dev_set_mtu(port->dev, dev->mtu);
-	spin_unlock(&team->lock);
+	mutex_unlock(&team->lock);
 
 	return err;
 }
@@ -880,9 +880,9 @@ static int team_add_slave(struct net_device *dev, struct net_device *port_dev)
 	struct team *team = netdev_priv(dev);
 	int err;
 
-	spin_lock(&team->lock);
+	mutex_lock(&team->lock);
 	err = team_port_add(team, port_dev);
-	spin_unlock(&team->lock);
+	mutex_unlock(&team->lock);
 	return err;
 }
 
@@ -891,9 +891,9 @@ static int team_del_slave(struct net_device *dev, struct net_device *port_dev)
 	struct team *team = netdev_priv(dev);
 	int err;
 
-	spin_lock(&team->lock);
+	mutex_lock(&team->lock);
 	err = team_port_del(team, port_dev);
-	spin_unlock(&team->lock);
+	mutex_unlock(&team->lock);
 	return err;
 }
 
@@ -1061,13 +1061,13 @@ static struct team *team_nl_team_get(struct genl_info *info)
 		return NULL;
 
 	team = netdev_priv(dev);
-	spin_lock(&team->lock);
+	mutex_lock(&team->lock);
 	return team;
 }
 
 static void team_nl_team_put(struct team *team)
 {
-	spin_unlock(&team->lock);
+	mutex_unlock(&team->lock);
 	dev_put(team->dev);
 }
 
@@ -1483,9 +1483,9 @@ static void team_port_change_check(struct team_port *port, bool linkup)
 {
 	struct team *team = port->team;
 
-	spin_lock(&team->lock);
+	mutex_lock(&team->lock);
 	__team_port_change_check(port, linkup);
-	spin_unlock(&team->lock);
+	mutex_unlock(&team->lock);
 }
 
 /************************************
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 14f6388..a6eac12 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -92,7 +92,7 @@ struct team {
 	struct net_device *dev; /* associated netdevice */
 	struct team_pcpu_stats __percpu *pcpu_stats;
 
-	spinlock_t lock; /* used for overall locking, e.g. port lists write */
+	struct mutex lock; /* used for overall locking, e.g. port lists write */
 
 	/*
 	 * port lists with port count
-- 
1.7.6
