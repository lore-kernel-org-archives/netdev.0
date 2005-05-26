From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/6) bridge: features change notification
Date: Thu, 26 May 2005 11:04:10 -0700
Message-ID: <20050526110410.6858e2ab@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============89913038535726786=="
Cc: netdev@oss.sgi.com, bridge@osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: "David S. Miller" <davem@davemloft.net>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============89913038535726786==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Resend of earlier patch (no changes) from Catalin used to provide
device feature change notification.

Signed-off-by: Catalin BOIE <catab at umbrella.ro>
Acked-by: Stephen Hemminger <shemminger@osdl.org>

--- notify1/include/linux/notifier.h	2005-03-02 09:37:48.000000000 +0200
+++ linux/include/linux/notifier.h	2005-05-20 13:17:42.000000000 +0300
@@ -56,6 +56,7 @@ extern int notifier_call_chain(struct no
 #define NETDEV_CHANGEADDR	0x0008
 #define NETDEV_GOING_DOWN	0x0009
 #define NETDEV_CHANGENAME	0x000A
+#define NETDEV_FEAT_CHANGE	0x000B
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
--- notify1/net/core/ethtool.c	2005-03-02 09:38:37.000000000 +0200
+++ linux/net/core/ethtool.c	2005-05-23 11:30:47.000000000 +0300
@@ -682,6 +682,7 @@ int dev_ethtool(struct ifreq *ifr)
 	void __user *useraddr = ifr->ifr_data;
 	u32 ethcmd;
 	int rc;
+	int old_features;
 
 	/*
 	 * XXX: This can be pushed down into the ethtool_* handlers that
@@ -703,6 +704,8 @@ int dev_ethtool(struct ifreq *ifr)
 		if ((rc = dev->ethtool_ops->begin(dev)) < 0)
 			return rc;
 
+	old_features = dev->features;
+
 	switch (ethcmd) {
 	case ETHTOOL_GSET:
 		rc = ethtool_get_settings(dev, useraddr);
@@ -712,7 +715,6 @@ int dev_ethtool(struct ifreq *ifr)
 		break;
 	case ETHTOOL_GDRVINFO:
 		rc = ethtool_get_drvinfo(dev, useraddr);
-
 		break;
 	case ETHTOOL_GREGS:
 		rc = ethtool_get_regs(dev, useraddr);
@@ -801,6 +803,10 @@ int dev_ethtool(struct ifreq *ifr)
 	
 	if(dev->ethtool_ops->complete)
 		dev->ethtool_ops->complete(dev);
+
+	if (old_features != dev->features)
+		netdev_features_change(dev);
+
 	return rc;
 
  ioctl:
--- notify1/net/core/dev.c	2005-03-26 05:28:21.000000000 +0200
+++ linux/net/core/dev.c	2005-05-23 12:14:32.000000000 +0300
@@ -761,6 +761,18 @@ int dev_change_name(struct net_device *d
 }
 
 /**
+ *	netdev_features_change - device changes fatures
+ *	@dev: device to cause notification
+ *
+ *	Called to indicate a device has changed features.
+ */
+void netdev_features_change(struct net_device *dev)
+{
+	notifier_call_chain(&netdev_chain, NETDEV_FEAT_CHANGE, dev);
+}
+EXPORT_SYMBOL(netdev_features_change);
+
+/**
  *	netdev_state_change - device changes state
  *	@dev: device to cause notification
  *
--- notify1/include/linux/netdevice.h	2005-03-02 09:38:26.000000000 +0200
+++ linux/include/linux/netdevice.h	2005-05-23 10:16:43.000000000 +0300
@@ -916,6 +916,7 @@ extern void		dev_mc_discard(struct net_d
 extern void		dev_set_promiscuity(struct net_device *dev, int inc);
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
+extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
 extern void		dev_load(const char *name);
 extern void		dev_mcast_init(void);

--===============89913038535726786==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============89913038535726786==--
