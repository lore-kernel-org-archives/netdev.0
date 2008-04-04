From: Pavel Emelyanov <xemul@openvz.org>
Subject: [RFC][PATCH 1/3] Introduce the net_device_ops structure.
Date: Fri, 04 Apr 2008 18:10:52 +0400
Message-ID: <47F636EC.5070506@openvz.org>
References: <47F63681.1030603@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33898 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752554AbYDDNrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 09:47:16 -0400
Received: from [10.30.3.76] (swsoft-msk-nat.sw.ru [195.214.232.10])
	(authenticated bits=0)
	by sacred.ru (8.13.8/8.13.8) with ESMTP id m34Dl88B009305
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 4 Apr 2008 17:47:09 +0400
In-Reply-To: <47F63681.1030603@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And fill it with copied from net_device.

Also make newly created devices be assigned to the 
(currently empty) nd_default_ops.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/linux/netdevice.h |   39 +++++++++++++++++++++++++++++++++++++++
 net/core/dev.c            |    9 +++++++++
 2 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8b17ed4..33f00ff 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -447,6 +447,43 @@ static inline void napi_synchronize(const struct napi_struct *n)
  *	moves out.
  */
 
+struct net_device_ops {
+	int			(*init)(struct net_device *dev);
+	struct net_device_stats* (*get_stats)(struct net_device *dev);
+	int			(*hard_start_xmit) (struct sk_buff *skb,
+						    struct net_device *dev);
+	void			(*uninit)(struct net_device *dev);
+	void			(*destructor)(struct net_device *dev);
+	int			(*open)(struct net_device *dev);
+	int			(*stop)(struct net_device *dev);
+	void			(*change_rx_flags)(struct net_device *dev,
+						   int flags);
+	void			(*set_rx_mode)(struct net_device *dev);
+	void			(*set_multicast_list)(struct net_device *dev);
+	int			(*set_mac_address)(struct net_device *dev,
+						   void *addr);
+	int			(*validate_addr)(struct net_device *dev);
+	int			(*do_ioctl)(struct net_device *dev,
+					    struct ifreq *ifr, int cmd);
+	int			(*set_config)(struct net_device *dev,
+					      struct ifmap *map);
+	int			(*change_mtu)(struct net_device *dev,
+						int new_mtu);
+	void			(*tx_timeout) (struct net_device *dev);
+
+	void			(*vlan_rx_register)(struct net_device *dev,
+						    struct vlan_group *grp);
+	void			(*vlan_rx_add_vid)(struct net_device *dev,
+						   unsigned short vid);
+	void			(*vlan_rx_kill_vid)(struct net_device *dev,
+						    unsigned short vid);
+	int			(*neigh_setup)(struct net_device *dev,
+						struct neigh_parms *);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	void                    (*poll_controller)(struct net_device *dev);
+#endif
+};
+
 struct net_device
 {
 
@@ -662,6 +699,8 @@ struct net_device
 	       NETREG_RELEASED,		/* called free_netdev */
 	} reg_state;
 
+	struct net_device_ops	*nd_ops;
+
 	/* Called after device is detached from network. */
 	void			(*uninit)(struct net_device *dev);
 	/* Called after last user reference disappears. */
diff --git a/net/core/dev.c b/net/core/dev.c
index 7aa0112..5e7bf79 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3976,6 +3976,13 @@ static struct net_device_stats *internal_stats(struct net_device *dev)
 	return &dev->stats;
 }
 
+/*
+ * temporary devices operations - to be removed very soon
+ */
+
+static struct net_device_ops nd_default_ops = {
+};
+
 /**
  *	alloc_netdev_mq - allocate network device
  *	@sizeof_priv:	size of private data to allocate space for
@@ -4027,6 +4034,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev->get_stats = internal_stats;
 	netpoll_netdev_init(dev);
 	setup(dev);
+	if (dev->nd_ops == NULL)
+		dev->nd_ops = &nd_default_ops;
 	strcpy(dev->name, name);
 	return dev;
 }
-- 
1.5.3.4

