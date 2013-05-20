From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net]  vxlan: revert per-vxlan port
Date: Mon, 20 May 2013 10:30:17 -0700
Message-ID: <20130520103017.054ae605@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:40503 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887Ab3ETRaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 13:30:22 -0400
Received: by mail-pd0-f177.google.com with SMTP id u11so905812pdi.8
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 10:30:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

\This commit 823aa873bc782f1c51b1ce8ec6da7cfcaf93836e
Author: stephen hemminger <stephen@networkplumber.org>
Date:   Sat Apr 27 11:31:57 2013 +0000

    vxlan: allow choosing destination port per vxlan

is broken revert it. The change allowed setting per port for transmit
but did not add additional listening sockets, which made any vxlan's
defined with non-default port send only.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
This patch needs to go -net only and not -net-next where the problem has
been resolved. Not sure what the process flow is to make that happen.


--- a/drivers/net/vxlan.c	2013-05-20 08:13:49.078440463 -0700
+++ b/drivers/net/vxlan.c	2013-05-20 09:31:32.752105130 -0700
@@ -110,7 +110,6 @@ struct vxlan_dev {
 	struct net_device *dev;
 	struct vxlan_rdst default_dst;	/* default destination */
 	__be32		  saddr;	/* source address */
-	__be16		  dst_port;
 	__u16		  port_min;	/* source port range */
 	__u16		  port_max;
 	__u8		  tos;		/* TOS override */
@@ -193,7 +192,7 @@ static int vxlan_fdb_info(struct sk_buff
 	if (send_ip && nla_put_be32(skb, NDA_DST, rdst->remote_ip))
 		goto nla_put_failure;
 
-	if (rdst->remote_port && rdst->remote_port != vxlan->dst_port &&
+	if (rdst->remote_port && rdst->remote_port != htons(vxlan_port) &&
 	    nla_put_be16(skb, NDA_PORT, rdst->remote_port))
 		goto nla_put_failure;
 	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
@@ -480,7 +479,7 @@ static int vxlan_fdb_add(struct ndmsg *n
 			return -EINVAL;
 		port = nla_get_be16(tb[NDA_PORT]);
 	} else
-		port = vxlan->dst_port;
+		port = htons(vxlan_port);
 
 	if (tb[NDA_VNI]) {
 		if (nla_len(tb[NDA_VNI]) != sizeof(u32))
@@ -591,7 +590,7 @@ static void vxlan_snoop(struct net_devic
 		err = vxlan_fdb_create(vxlan, src_mac, src_ip,
 				       NUD_REACHABLE,
 				       NLM_F_EXCL|NLM_F_CREATE,
-				       vxlan->dst_port,
+				       vxlan_port,
 				       vxlan->default_dst.remote_vni,
 				       0, NTF_SELF);
 		spin_unlock(&vxlan->hash_lock);
@@ -982,7 +981,7 @@ static netdev_tx_t vxlan_xmit_one(struct
 	__be16 df = 0;
 	__u8 tos, ttl;
 
-	dst_port = rdst->remote_port ? rdst->remote_port : vxlan->dst_port;
+	dst_port = rdst->remote_port ? rdst->remote_port : htons(vxlan_port);
 	vni = rdst->remote_vni;
 	dst = rdst->remote_ip;
 
@@ -1326,7 +1325,6 @@ static void vxlan_setup(struct net_devic
 	inet_get_local_port_range(&low, &high);
 	vxlan->port_min = low;
 	vxlan->port_max = high;
-	vxlan->dst_port = htons(vxlan_port);
 
 	vxlan->dev = dev;
 
@@ -1349,7 +1347,6 @@ static const struct nla_policy vxlan_pol
 	[IFLA_VXLAN_RSC]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L2MISS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L3MISS]	= { .type = NLA_U8 },
-	[IFLA_VXLAN_PORT]	= { .type = NLA_U16 },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -1479,9 +1476,6 @@ static int vxlan_newlink(struct net *net
 		vxlan->port_max = ntohs(p->high);
 	}
 
-	if (data[IFLA_VXLAN_PORT])
-		vxlan->dst_port = nla_get_be16(data[IFLA_VXLAN_PORT]);
-
 	SET_ETHTOOL_OPS(dev, &vxlan_ethtool_ops);
 
 	err = register_netdevice(dev);
@@ -1517,7 +1511,6 @@ static size_t vxlan_get_size(const struc
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_AGEING */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
-		nla_total_size(sizeof(__be16))+ /* IFLA_VXLAN_PORT */
 		0;
 }
 
@@ -1554,8 +1547,7 @@ static int vxlan_fill_info(struct sk_buf
 	    nla_put_u8(skb, IFLA_VXLAN_L3MISS,
 			!!(vxlan->flags & VXLAN_F_L3MISS)) ||
 	    nla_put_u32(skb, IFLA_VXLAN_AGEING, vxlan->age_interval) ||
-	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->addrmax) ||
-	    nla_put_be16(skb, IFLA_VXLAN_PORT, vxlan->dst_port))
+	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->addrmax))
 		goto nla_put_failure;
 
 	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
