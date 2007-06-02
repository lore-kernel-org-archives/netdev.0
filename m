From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [4/4] [IPV4]: Restore old behaviour of default config values
Date: Sat, 2 Jun 2007 20:03:59 +1000
Message-ID: <20070602100359.GD9247@gondor.apana.org.au>
References: <20070602100132.GA9129@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4483 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754694AbXFBKEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 06:04:01 -0400
Content-Disposition: inline
In-Reply-To: <20070602100132.GA9129@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV4]: Restore old behaviour of default config values

Previously inet devices were only constructed when addresses are added
(or rarely in ipmr).  Therefore the default config values they get are
the ones at the time of these operations.

Now that we're creating inet devices earlier, this changes the behaviour
of default config values in an incompatible way (see bug #8519).

This patch creates a compromise by setting the default values at the
same point as before but only for those that have not been explicitly
set by the user since the inet device's creation.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -59,6 +59,11 @@ static inline void ipv4_devconf_set(stru
 	in_dev->cnf.data[index] = val;
 }
 
+static inline void ipv4_devconf_setall(struct in_device *in_dev)
+{
+	bitmap_fill(in_dev->cnf.state, __NET_IPV4_CONF_MAX - 1);
+}
+
 #define IN_DEV_CONF_GET(in_dev, attr) \
 	ipv4_devconf_get((in_dev), NET_IPV4_CONF_ ## attr)
 #define IN_DEV_CONF_SET(in_dev, attr, val) \
@@ -125,7 +130,6 @@ extern struct net_device 	*ip_dev_find(_
 extern int		inet_addr_onlink(struct in_device *in_dev, __be32 a, __be32 b);
 extern int		devinet_ioctl(unsigned int cmd, void __user *);
 extern void		devinet_init(void);
-extern struct in_device *inetdev_init(struct net_device *dev);
 extern struct in_device	*inetdev_by_index(int);
 extern __be32		inet_select_addr(const struct net_device *dev, __be32 dst, int scope);
 extern __be32		inet_confirm_addr(const struct net_device *dev, __be32 dst, __be32 local, int scope);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -147,7 +147,7 @@ void in_dev_finish_destroy(struct in_dev
 	}
 }
 
-struct in_device *inetdev_init(struct net_device *dev)
+static struct in_device *inetdev_init(struct net_device *dev)
 {
 	struct in_device *in_dev;
 
@@ -405,12 +405,10 @@ static int inet_set_ifa(struct net_devic
 	ASSERT_RTNL();
 
 	if (!in_dev) {
-		in_dev = inetdev_init(dev);
-		if (!in_dev) {
-			inet_free_ifa(ifa);
-			return -ENOBUFS;
-		}
+		inet_free_ifa(ifa);
+		return -ENOBUFS;
 	}
+	ipv4_devconf_setall(in_dev);
 	if (ifa->ifa_dev != in_dev) {
 		BUG_TRAP(!ifa->ifa_dev);
 		in_dev_hold(in_dev);
@@ -520,13 +518,12 @@ static struct in_ifaddr *rtm_to_ifaddr(s
 
 	in_dev = __in_dev_get_rtnl(dev);
 	if (in_dev == NULL) {
-		in_dev = inetdev_init(dev);
-		if (in_dev == NULL) {
-			err = -ENOBUFS;
-			goto errout;
-		}
+		err = -ENOBUFS;
+		goto errout;
 	}
 
+	ipv4_devconf_setall(in_dev);
+
 	ifa = inet_alloc_ifa();
 	if (ifa == NULL) {
 		/*
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -152,9 +152,11 @@ struct net_device *ipmr_new_tunnel(struc
 			dev->flags |= IFF_MULTICAST;
 
 			in_dev = __in_dev_get_rtnl(dev);
-			if (in_dev == NULL && (in_dev = inetdev_init(dev)) == NULL)
+			if (in_dev == NULL)
 				goto failure;
-			IN_DEV_CONF_SET(in_dev, RP_FILTER, 0);
+
+			ipv4_devconf_setall(in_dev);
+			IPV4_DEVCONF(in_dev->cnf, RP_FILTER) = 0;
 
 			if (dev_open(dev))
 				goto failure;
@@ -218,10 +220,15 @@ static struct net_device *ipmr_reg_vif(v
 	}
 	dev->iflink = 0;
 
-	if ((in_dev = inetdev_init(dev)) == NULL)
+	rcu_read_lock();
+	if ((in_dev = __in_dev_get_rcu(dev)) == NULL) {
+		rcu_read_unlock();
 		goto failure;
+	}
 
-	IN_DEV_CONF_SET(in_dev, RP_FILTER, 0);
+	ipv4_devconf_setall(in_dev);
+	IPV4_DEVCONF(in_dev->cnf, RP_FILTER) = 0;
+	rcu_read_unlock();
 
 	if (dev_open(dev))
 		goto failure;
