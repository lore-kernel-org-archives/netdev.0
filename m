From: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v6 17/19] net: ethtool: remove unused __ethtool_get_settings
Date: Tue, 19 Jan 2016 16:44:02 -0800
Message-ID: <1453250644-14796-18-git-send-email-ddecotig@gmail.com>
References: <1453250644-14796-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ido Shamay <idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Ed Swierk <eswierk-FilZDy9cOaHkQYj/0HfcvtBPR1lH4CV8@public.gmane.org>,
	Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
	Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453250644-14796-1-git-send-email-ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>

replaced by __ethtool_get_ksettings.

Signed-off-by: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
---
 include/linux/ethtool.h |  4 ----
 net/core/ethtool.c      | 45 ++++++++++++++-------------------------------
 2 files changed, 14 insertions(+), 35 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 6077cbb..05d4f0e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -148,10 +148,6 @@ struct ethtool_ksettings {
 extern int __ethtool_get_ksettings(struct net_device *dev,
 				   struct ethtool_ksettings *ksettings);
 
-/* DEPRECATED, use __ethtool_get_ksettings */
-extern int __ethtool_get_settings(struct net_device *dev,
-				  struct ethtool_cmd *cmd);
-
 /**
  * struct ethtool_ops - optional netdev operations
  * @get_settings: DEPRECATED, use %get_ksettings/%set_ksettings
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index ed1fde3..95ce5c9 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -529,7 +529,12 @@ int __ethtool_get_ksettings(struct net_device *dev,
 	 * legacy %ethtool_cmd API, unless it's not supported either.
 	 * TODO: remove when ethtool_ops::get_settings disappears internally
 	 */
-	err = __ethtool_get_settings(dev, &cmd);
+	if (!dev->ethtool_ops->get_settings)
+		return -EOPNOTSUPP;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.cmd = ETHTOOL_GSET;
+	err = dev->ethtool_ops->get_settings(dev, &cmd);
 	if (err < 0)
 		return err;
 
@@ -699,30 +704,6 @@ static int ethtool_set_ksettings(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_ksettings(dev, &ksettings);
 }
 
-/* Internal kernel helper to query a device ethtool_cmd settings.
- *
- * Note about transition to ethtool_settings API: We do not need (or
- * want) this function to support "dev" instances that implement the
- * ethtool_settings API as we will update the drivers calling this
- * function to call __ethtool_get_ksettings instead, before the first
- * drivers implement ethtool_ops::get_ksettings.
- *
- * TODO 1: at least make this function static when no driver is using it
- * TODO 2: remove when ethtool_ops::get_settings disappears internally
- */
-int __ethtool_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	ASSERT_RTNL();
-
-	if (!dev->ethtool_ops->get_settings)
-		return -EOPNOTSUPP;
-
-	memset(cmd, 0, sizeof(struct ethtool_cmd));
-	cmd->cmd = ETHTOOL_GSET;
-	return dev->ethtool_ops->get_settings(dev, cmd);
-}
-EXPORT_SYMBOL(__ethtool_get_settings);
-
 static void
 warn_incomplete_ethtool_legacy_settings_conversion(const char *details)
 {
@@ -764,16 +745,18 @@ static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
 		/* send a sensible cmd tag back to user */
 		cmd.cmd = ETHTOOL_GSET;
 	} else {
-		int err;
-		/* TODO: return -EOPNOTSUPP when
-		 * ethtool_ops::get_settings disappears internally
-		 */
-
 		/* driver doesn't support %ethtool_ksettings
 		 * API. revert to legacy %ethtool_cmd API, unless it's
 		 * not supported either.
 		 */
-		err = __ethtool_get_settings(dev, &cmd);
+		int err;
+
+		if (!dev->ethtool_ops->get_settings)
+			return -EOPNOTSUPP;
+
+		memset(&cmd, 0, sizeof(cmd));
+		cmd.cmd = ETHTOOL_GSET;
+		err = dev->ethtool_ops->get_settings(dev, &cmd);
 		if (err < 0)
 			return err;
 	}
-- 
2.7.0.rc3.207.g0ac5344
