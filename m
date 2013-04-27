From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 6/6] vxlan: allow choosing destination port per vxlan
Date: Sat, 27 Apr 2013 14:31:57 -0700
Message-ID: <20130427213258.534077786@vyatta.com>
References: <20130427213151.255971631@vyatta.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52172 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753898Ab3D0Vqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 17:46:36 -0400
Content-Disposition: inline; filename=vxlan-dst-udp-port.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow configuring the default destination port on a per-device basis.
Adds new netlink paramater IFLA_VXLAN_PORT to allow setting destination
port when creating new vxlan.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/vxlan.c	2013-04-27 14:04:28.776531047 -0700
+++ b/drivers/net/vxlan.c	2013-04-27 14:27:23.495911755 -0700
@@ -110,6 +110,7 @@ struct vxlan_dev {
 	struct net_device *dev;
 	struct vxlan_rdst default_dst;	/* default destination */
 	__be32		  saddr;	/* source address */
+	__be16		  dst_port;
 	__u16		  port_min;	/* source port range */
 	__u16		  port_max;
 	__u8		  tos;		/* TOS override */
@@ -192,7 +193,7 @@ static int vxlan_fdb_info(struct sk_buff
 	if (send_ip && nla_put_be32(skb, NDA_DST, rdst->remote_ip))
 		goto nla_put_failure;
 
-	if (rdst->remote_port && rdst->remote_port != htons(vxlan_port) &&
+	if (rdst->remote_port && rdst->remote_port != vxlan->dst_port &&
 	    nla_put_be16(skb, NDA_PORT, rdst->remote_port))
 		goto nla_put_failure;
 	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
@@ -467,7 +468,7 @@ static int vxlan_fdb_add(struct ndmsg *n
 			return -EINVAL;
 		port = nla_get_be16(tb[NDA_PORT]);
 	} else
-		port = htons(vxlan_port);
+		port = vxlan->dst_port;
 
 	if (tb[NDA_VNI]) {
 		if (nla_len(tb[NDA_VNI]) != sizeof(u32))
@@ -579,7 +580,7 @@ static void vxlan_snoop(struct net_devic
 		err = vxlan_fdb_create(vxlan, src_mac, src_ip,
 				       NUD_REACHABLE,
 				       NLM_F_EXCL|NLM_F_CREATE,
-				       vxlan_port,
+				       vxlan->dst_port,
 				       vxlan->default_dst.remote_vni,
 				       0, NTF_SELF);
 		spin_unlock(&vxlan->hash_lock);
@@ -970,7 +971,7 @@ static netdev_tx_t vxlan_xmit_one(struct
 	__be16 df = 0;
 	__u8 tos, ttl;
 
-	dst_port = rdst->remote_port ? rdst->remote_port : htons(vxlan_port);
+	dst_port = rdst->remote_port ? rdst->remote_port : vxlan->dst_port;
 	vni = rdst->remote_vni;
 	dst = rdst->remote_ip;
 
@@ -1314,6 +1315,7 @@ static void vxlan_setup(struct net_devic
 	inet_get_local_port_range(&low, &high);
 	vxlan->port_min = low;
 	vxlan->port_max = high;
+	vxlan->dst_port = htons(vxlan_port);
 
 	vxlan->dev = dev;
 
@@ -1336,6 +1338,7 @@ static const struct nla_policy vxlan_pol
 	[IFLA_VXLAN_RSC]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L2MISS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L3MISS]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_PORT]	= { .type = NLA_U16 },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -1465,6 +1468,9 @@ static int vxlan_newlink(struct net *net
 		vxlan->port_max = ntohs(p->high);
 	}
 
+	if (data[IFLA_VXLAN_PORT])
+		vxlan->dst_port = nla_get_be16(data[IFLA_VXLAN_PORT]);
+
 	SET_ETHTOOL_OPS(dev, &vxlan_ethtool_ops);
 
 	err = register_netdevice(dev);
@@ -1500,6 +1506,7 @@ static size_t vxlan_get_size(const struc
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_AGEING */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
+		nla_total_size(sizeof(__be16))+ /* IFLA_VXLAN_PORT */
 		0;
 }
 
@@ -1536,7 +1543,8 @@ static int vxlan_fill_info(struct sk_buf
 	    nla_put_u8(skb, IFLA_VXLAN_L3MISS,
 			!!(vxlan->flags & VXLAN_F_L3MISS)) ||
 	    nla_put_u32(skb, IFLA_VXLAN_AGEING, vxlan->age_interval) ||
-	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->addrmax))
+	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->addrmax) ||
+	    nla_put_be16(skb, IFLA_VXLAN_PORT, vxlan->dst_port))
 		goto nla_put_failure;
 
 	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
--- a/include/uapi/linux/if_link.h	2013-04-27 13:59:41.000000000 -0700
+++ b/include/uapi/linux/if_link.h	2013-04-27 14:04:52.752220968 -0700
@@ -305,11 +305,12 @@ enum {
 	IFLA_VXLAN_LEARNING,
 	IFLA_VXLAN_AGEING,
 	IFLA_VXLAN_LIMIT,
-	IFLA_VXLAN_PORT_RANGE,
+	IFLA_VXLAN_PORT_RANGE,	/* source port */
 	IFLA_VXLAN_PROXY,
 	IFLA_VXLAN_RSC,
 	IFLA_VXLAN_L2MISS,
 	IFLA_VXLAN_L3MISS,
+	IFLA_VXLAN_PORT,	/* destination port */
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
