From: gfree.wind@foxmail.com
Subject: [PATCH net v4 04/12] driver: team: Fix one possbile memleak when fail to register_netdevice
Date: Tue,  2 May 2017 13:58:46 +0800
Message-ID: <94ce7a6c3e2d7de9f06b3386c8265b4cbb8b6a62.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg332.qq.com ([14.17.43.227]:49371 "EHLO smtpbg332.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751008AbdEBGPP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 02:15:15 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
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
 drivers/net/team/team.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 85c0124..d8dd203 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1619,6 +1619,13 @@ static int team_init(struct net_device *dev)
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
@@ -1636,13 +1643,15 @@ static void team_uninit(struct net_device *dev)
 	team_queue_override_fini(team);
 	mutex_unlock(&team->lock);
 	netdev_change_features(dev);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		team_destructor_free(dev);
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
1.9.1
