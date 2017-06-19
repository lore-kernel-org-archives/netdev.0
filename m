From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v3 3/6] vxlan: improve validation of address family configuration
Date: Mon, 19 Jun 2017 10:03:57 +0200
Message-ID: <c7e6e666f63206660d22183870b1bef50266c796.1497825555.git.mschiffer@universe-factory.net>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, hannes@stressinduktion.org,
        pshelar@ovn.org, aduyck@mirantis.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([31.24.148.19]:55158 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750952AbdFSIEJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 04:04:09 -0400
In-Reply-To: <cover.1497825555.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1497825555.git.mschiffer@universe-factory.net>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Address families of source and destination addresses must match, and
changelink operations can't change the address family.

In addition, always use the VXLAN_F_IPV6 to check if a VXLAN device uses
IPv4 or IPv6.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---

Notes:
    v2: new patch
    v3: rebase

 drivers/net/vxlan.c | 39 ++++++++++++++++++++++++++++-----------
 1 file changed, 28 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index b4fce3b29647..00680cc597ac 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2484,10 +2484,7 @@ static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
 	struct vxlan_rdst *dst = &vxlan->default_dst;
 	struct net_device *lowerdev = __dev_get_by_index(vxlan->net,
 							 dst->remote_ifindex);
-	bool use_ipv6 = false;
-
-	if (dst->remote_ip.sa.sa_family == AF_INET6)
-		use_ipv6 = true;
+	bool use_ipv6 = !!(vxlan->cfg.flags & VXLAN_F_IPV6);
 
 	/* This check is different than dev->max_mtu, because it looks at
 	 * the lowerdev->mtu, rather than the static dev->max_mtu
@@ -2897,11 +2894,20 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 		}
 	}
 
-	if (!conf->remote_ip.sa.sa_family)
+	if (!conf->remote_ip.sa.sa_family && !conf->saddr.sa.sa_family) {
+		/* Unless IPv6 is explicitly requested, assume IPv4 */
 		conf->remote_ip.sa.sa_family = AF_INET;
+		conf->saddr.sa.sa_family = AF_INET;
+	} else if (!conf->remote_ip.sa.sa_family) {
+		conf->remote_ip.sa.sa_family = conf->saddr.sa.sa_family;
+	} else if (!conf->saddr.sa.sa_family) {
+		conf->saddr.sa.sa_family = conf->remote_ip.sa.sa_family;
+	}
+
+	if (conf->saddr.sa.sa_family != conf->remote_ip.sa.sa_family)
+		return -EINVAL;
 
-	if (conf->remote_ip.sa.sa_family == AF_INET6 ||
-	    conf->saddr.sa.sa_family == AF_INET6) {
+	if (conf->saddr.sa.sa_family == AF_INET6) {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
 		use_ipv6 = true;
@@ -2949,11 +2955,9 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 			continue;
 
 		if (tmp->cfg.vni == conf->vni &&
-		    (tmp->default_dst.remote_ip.sa.sa_family == AF_INET6 ||
-		     tmp->cfg.saddr.sa.sa_family == AF_INET6) == use_ipv6 &&
 		    tmp->cfg.dst_port == conf->dst_port &&
-		    (tmp->cfg.flags & VXLAN_F_RCV_FLAGS) ==
-		    (conf->flags & VXLAN_F_RCV_FLAGS))
+		    (tmp->cfg.flags & (VXLAN_F_RCV_FLAGS | VXLAN_F_IPV6)) ==
+		    (conf->flags & (VXLAN_F_RCV_FLAGS | VXLAN_F_IPV6)))
 			return -EEXIST;
 	}
 
@@ -3084,22 +3088,35 @@ static int vxlan_nl2conf(struct nlattr *tb[], struct nlattr *data[],
 	}
 
 	if (data[IFLA_VXLAN_GROUP]) {
+		if (changelink && (conf->remote_ip.sa.sa_family != AF_INET))
+			return -EOPNOTSUPP;
+
 		conf->remote_ip.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_GROUP]);
+		conf->remote_ip.sa.sa_family = AF_INET;
 	} else if (data[IFLA_VXLAN_GROUP6]) {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
 
+		if (changelink && (conf->remote_ip.sa.sa_family != AF_INET6))
+			return -EOPNOTSUPP;
+
 		conf->remote_ip.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_GROUP6]);
 		conf->remote_ip.sa.sa_family = AF_INET6;
 	}
 
 	if (data[IFLA_VXLAN_LOCAL]) {
+		if (changelink && (conf->saddr.sa.sa_family != AF_INET))
+			return -EOPNOTSUPP;
+
 		conf->saddr.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_LOCAL]);
 		conf->saddr.sa.sa_family = AF_INET;
 	} else if (data[IFLA_VXLAN_LOCAL6]) {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
 
+		if (changelink && (conf->saddr.sa.sa_family != AF_INET6))
+			return -EOPNOTSUPP;
+
 		/* TODO: respect scope id */
 		conf->saddr.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_LOCAL6]);
 		conf->saddr.sa.sa_family = AF_INET6;
-- 
2.13.1
