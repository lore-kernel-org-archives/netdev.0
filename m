From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [4/5] [NET]: Added GSO toggle
Date: Tue, 20 Jun 2006 19:30:28 +1000
Message-ID: <20060620093028.GD31854@gondor.apana.org.au>
References: <20060620090919.GA31613@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="RYJh/3oyKhIjGcML"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35850 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030207AbWFTJaa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 05:30:30 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060620090919.GA31613@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--RYJh/3oyKhIjGcML
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

[NET]: Added GSO toggle

This patch adds a generic segmentation offload toggle that can be turned
on/off for each net device.  For now it only supports in TCPv4.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--RYJh/3oyKhIjGcML
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p4.patch"

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -408,6 +408,8 @@ struct ethtool_ops {
 #define ETHTOOL_GPERMADDR	0x00000020 /* Get permanent hardware address */
 #define ETHTOOL_GUFO		0x00000021 /* Get UFO enable (ethtool_value) */
 #define ETHTOOL_SUFO		0x00000022 /* Set UFO enable (ethtool_value) */
+#define ETHTOOL_GGSO		0x00000023 /* Get GSO enable (ethtool_value) */
+#define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -309,6 +309,7 @@ struct net_device
 #define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
 #define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
+#define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
 
 	/* Segmentation offload features */
diff --git a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1031,9 +1031,13 @@ static inline void sk_setup_caps(struct 
 {
 	__sk_dst_set(sk, dst);
 	sk->sk_route_caps = dst->dev->features;
+	if (sk->sk_route_caps & NETIF_F_GSO)
+		sk->sk_route_caps |= NETIF_F_TSO;
 	if (sk->sk_route_caps & NETIF_F_TSO) {
 		if (sock_flag(sk, SOCK_NO_LARGESEND) || dst->header_len)
 			sk->sk_route_caps &= ~NETIF_F_TSO;
+		else 
+			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
 	}
 }
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -376,15 +376,20 @@ void br_features_recompute(struct net_br
 	features = br->feature_mask & ~NETIF_F_ALL_CSUM;
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (checksum & NETIF_F_NO_CSUM &&
-		    !(p->dev->features & NETIF_F_NO_CSUM))
+		unsigned long feature = p->dev->features;
+
+		if (checksum & NETIF_F_NO_CSUM && !(feature & NETIF_F_NO_CSUM))
 			checksum ^= NETIF_F_NO_CSUM | NETIF_F_HW_CSUM;
-		if (checksum & NETIF_F_HW_CSUM &&
-		    !(p->dev->features & NETIF_F_HW_CSUM))
+		if (checksum & NETIF_F_HW_CSUM && !(feature & NETIF_F_HW_CSUM))
 			checksum ^= NETIF_F_HW_CSUM | NETIF_F_IP_CSUM;
-		if (!(p->dev->features & NETIF_F_IP_CSUM))
+		if (!(feature & NETIF_F_IP_CSUM))
 			checksum = 0;
-		features &= p->dev->features;
+
+		if (feature & NETIF_F_GSO)
+			feature |= NETIF_F_TSO;
+		feature |= NETIF_F_GSO;
+
+		features &= feature;
 	}
 
 	br->dev->features = features | checksum | NETIF_F_LLTX;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -614,6 +614,29 @@ static int ethtool_set_ufo(struct net_de
 	return dev->ethtool_ops->set_ufo(dev, edata.data);
 }
 
+static int ethtool_get_gso(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GGSO };
+
+	edata.data = dev->features & NETIF_F_GSO;
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		 return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_gso(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+	if (edata.data)
+		dev->features |= NETIF_F_GSO;
+	else
+		dev->features &= ~NETIF_F_GSO;
+	return 0;
+}
+
 static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_test test;
@@ -905,6 +928,12 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_SUFO:
 		rc = ethtool_set_ufo(dev, useraddr);
 		break;
+	case ETHTOOL_GGSO:
+		rc = ethtool_get_gso(dev, useraddr);
+		break;
+	case ETHTOOL_SGSO:
+		rc = ethtool_set_gso(dev, useraddr);
+		break;
 	default:
 		rc =  -EOPNOTSUPP;
 	}

--RYJh/3oyKhIjGcML--
