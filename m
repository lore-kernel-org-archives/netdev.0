From: gfree.wind@foxmail.com
Subject: [PATCH net v3] driver: team: Fix one possbile memleak when fail to register_netdevice
Date: Sat, 29 Apr 2017 11:50:35 +0800
Message-ID: <1493437835-27097-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgbr2.qq.com ([54.207.22.56]:45713 "EHLO smtpbgbr2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1164264AbdD2Duv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 23:50:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The team driver allocates some resources in its ndo_init func, and
free some of them in its destructor func. Then there is one memleak
that some errors happen after register_netdevice invokes the ndo_init
callback. Because only the ndo_uninit callback is invoked in the error
handler of register_netdevice, but destructor not.

Now create one new func team_destructor_free to free the mem in the
destructor, and ndo_uninit func also invokes it when fail to register
the team device.

It's not only free all resources, but also follow the original desgin
that the resources are freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 v3: Split one patch to multiple commits, per David Ahern
 v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
 v1: initial version

 drivers/net/team/team.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 1b52520..575eb00 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1625,6 +1625,13 @@ static int team_init(struct net_device *dev)
 	return err;
 }
 
+static void team_destructor_free(struct net_device *dev)
+{
+	struct team *team = netdev_priv(dev);
+
+	free_percpu(team->pcpu_stats);
+}
+
 static void team_uninit(struct net_device *dev)
 {
 	struct team *team = netdev_priv(dev);
@@ -1641,13 +1648,16 @@ static void team_uninit(struct net_device *dev)
 	team_notify_peers_fini(team);
 	team_queue_override_fini(team);
 	mutex_unlock(&team->lock);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		team_destructor_free(dev);
+
 }
 
 static void team_destructor(struct net_device *dev)
 {
-	struct team *team = netdev_priv(dev);
-
-	free_percpu(team->pcpu_stats);
+	team_destructor_free(dev);
 	free_netdev(dev);
 }
 
-- 
2.7.4
