From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 10/16] net: dsa: Add basic framework to support ndo_fdb functions
Date: Thu, 26 Mar 2015 18:36:37 -0700
Message-ID: <1427420203-27685-11-git-send-email-linux@roeck-us.net>
References: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39378 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415AbbC0BhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 21:37:14 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YbJCz-0020kA-Rw
	for netdev@vger.kernel.org; Fri, 27 Mar 2015 01:37:14 +0000
In-Reply-To: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide callbacks for ndo_fdb_add, ndo_fdb_del, and ndo_fdb_dump.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 include/net/dsa.h |   6 ++++
 net/dsa/slave.c   | 102 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 108 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 47917e5e1e12..fbca63ba8f73 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -296,6 +296,12 @@ struct dsa_switch_driver {
 				     u32 br_port_mask);
 	int	(*port_stp_update)(struct dsa_switch *ds, int port,
 				   u8 state);
+	int	(*fdb_add)(struct dsa_switch *ds, int port,
+			   const unsigned char *addr, u16 vid);
+	int	(*fdb_del)(struct dsa_switch *ds, int port,
+			   const unsigned char *addr, u16 vid);
+	int	(*fdb_getnext)(struct dsa_switch *ds, int port,
+			       unsigned char *addr, bool *is_static);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 39555f3f263b..3597724ec3d8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -201,6 +201,105 @@ out:
 	return 0;
 }
 
+static int dsa_slave_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+			     struct net_device *dev,
+			     const unsigned char *addr, u16 vid, u16 nlm_flags)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret = -EOPNOTSUPP;
+
+	if (ds->drv->fdb_add)
+		ret = ds->drv->fdb_add(ds, p->port, addr, vid);
+
+	return ret;
+}
+
+static int dsa_slave_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
+			     struct net_device *dev,
+			     const unsigned char *addr, u16 vid)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret = -EOPNOTSUPP;
+
+	if (ds->drv->fdb_del)
+		ret = ds->drv->fdb_del(ds, p->port, addr, vid);
+
+	return ret;
+}
+
+static int dsa_slave_fill_info(struct net_device *dev, struct sk_buff *skb,
+			       const unsigned char *addr, u16 vid,
+			       bool is_static,
+			       u32 portid, u32 seq, int type,
+			       unsigned int flags)
+{
+	struct nlmsghdr *nlh;
+	struct ndmsg *ndm;
+
+	nlh = nlmsg_put(skb, portid, seq, type, sizeof(*ndm), flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	ndm = nlmsg_data(nlh);
+	ndm->ndm_family	 = AF_BRIDGE;
+	ndm->ndm_pad1    = 0;
+	ndm->ndm_pad2    = 0;
+	ndm->ndm_flags	 = NTF_EXT_LEARNED;
+	ndm->ndm_type	 = 0;
+	ndm->ndm_ifindex = dev->ifindex;
+	ndm->ndm_state   = is_static ? NUD_NOARP : NUD_REACHABLE;
+
+	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, addr))
+		goto nla_put_failure;
+
+	if (vid && nla_put_u16(skb, NDA_VLAN, vid))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+/* Dump information about entries, in response to GETNEIGH */
+static int dsa_slave_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
+			      struct net_device *dev,
+			      struct net_device *filter_dev, int idx)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	unsigned char addr[ETH_ALEN] = { 0 };
+	int ret;
+
+	if (!ds->drv->fdb_getnext)
+		return -EOPNOTSUPP;
+
+	for (; ; idx++) {
+		bool is_static;
+
+		ret = ds->drv->fdb_getnext(ds, p->port, addr, &is_static);
+		if (ret < 0)
+			break;
+
+		if (idx < cb->args[0])
+			continue;
+
+		ret = dsa_slave_fill_info(dev, skb, addr, 0,
+					  is_static,
+					  NETLINK_CB(cb->skb).portid,
+					  cb->nlh->nlmsg_seq,
+					  RTM_NEWNEIGH, NLM_F_MULTI);
+		if (ret < 0)
+			break;
+	}
+
+	return idx;
+}
+
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -572,6 +671,9 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
+	.ndo_fdb_add		= dsa_slave_fdb_add,
+	.ndo_fdb_del		= dsa_slave_fdb_del,
+	.ndo_fdb_dump		= dsa_slave_fdb_dump,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 };
 
-- 
2.1.0
