From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v2 5/5] ipvlan: set dev_id for l2 ports to generate unique
 IPv6 addresses
Date: Fri, 03 Jul 2015 15:58:41 +0300
Message-ID: <20150703125841.24121.73888.stgit@buzz>
References: <20150703125132.24121.50592.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1g.mail.yandex.net ([95.108.253.251]:59525 "EHLO
	forward-corp1g.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755181AbbGCM6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 08:58:45 -0400
In-Reply-To: <20150703125132.24121.50592.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All ipvlan ports use one MAC address, this way ipv6 RA tries to assign
one ipv6 address to all of them. This patch assigns unique dev_id to each
ipvlan port. This field is used instead of common FF-FE in Modified EUI-64.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 Documentation/networking/ipvlan.txt |   11 ++++++++++-
 drivers/net/ipvlan/ipvlan.h         |    1 +
 drivers/net/ipvlan/ipvlan_main.c    |   19 +++++++++++++++++++
 3 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ipvlan.txt b/Documentation/networking/ipvlan.txt
index cf996394e466..d1123de81469 100644
--- a/Documentation/networking/ipvlan.txt
+++ b/Documentation/networking/ipvlan.txt
@@ -24,7 +24,7 @@ using IProute2/ip utility.
 
 	ip link add link <master-dev> <slave-dev> type ipvlan mode { l2 | L3 }
 
-	e.g. ip link add link ipvl0 eth0 type ipvlan mode l2
+	e.g. ip link add link eth0 ipvl0 type ipvlan mode l2
 
 
 4. Operating modes:
@@ -41,6 +41,15 @@ slave device and packets are switched and queued to the master device to send
 out. In this mode the slaves will RX/TX multicast and broadcast (if applicable)
 as well.
 
+	In L2 mode slave devices receive Router Advertisements from the network
+and perform autoconfiguration as well as master device. Each port has unique
+16-bit device id which is used for filling octets 4-5 of Modified EUI-64.
+That gives 65533 addresses (FF-FE used by master, FF-FF/00-00 reserved/not used).
+
+	Also lower half of IPv6 address could be set as interface token:
+
+	ip token set ::aaaa:bbbb:cccc:dddd dev ipvl0
+
 4.2 L3 mode:
 	In this mode TX processing upto L3 happens on the stack instance attached
 to the slave device and packets are switched to the stack instance of the
diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index a23069aec4d9..0d1f5e8ed75f 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -98,6 +98,7 @@ struct ipvl_port {
 	int			count;
 	u16			mode;
 	spinlock_t		addr_lock;
+	struct ida		ida;
 };
 
 static inline struct ipvl_port *ipvlan_port_get_rcu(const struct net_device *d)
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 83a936f76248..d465b2c287cb 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -53,6 +53,7 @@ static int ipvlan_port_create(struct net_device *dev)
 	INIT_LIST_HEAD(&port->ipvlans);
 	for (idx = 0; idx < IPVLAN_HASH_SIZE; idx++)
 		INIT_HLIST_HEAD(&port->hlhead[idx]);
+	ida_init(&port->ida);
 
 	skb_queue_head_init(&port->backlog);
 	INIT_WORK(&port->wq, ipvlan_process_multicast);
@@ -78,6 +79,7 @@ static void ipvlan_port_destroy(struct net_device *dev)
 	netdev_rx_handler_unregister(dev);
 	cancel_work_sync(&port->wq);
 	__skb_queue_purge(&port->backlog);
+	ida_destroy(&port->ida);
 	kfree_rcu(port, rcu);
 }
 
@@ -481,6 +483,18 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	 */
 	memcpy(dev->dev_addr, phy_dev->dev_addr, ETH_ALEN);
 
+	if (port->mode == IPVLAN_MODE_L2) {
+		/*
+		 * IPv6 addrconf uses it to produce unique addresses,
+		 * see function addrconf_ifid_eui48.
+		 */
+		err = ida_simple_get(&port->ida, 1, 0xFFFE, GFP_KERNEL);
+		if (err > 0)
+			dev->dev_id = err;
+		else if (err != -ENOSPC)
+			goto ipvlan_destroy_port;
+	}
+
 	dev->priv_flags |= IFF_IPVLAN_SLAVE;
 
 	port->count += 1;
@@ -517,6 +531,11 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 	}
 	ipvlan_addr_unlock_bh(ipvlan);
 
+	if (dev->dev_id) {
+		ida_simple_remove(&ipvlan->port->ida, dev->dev_id);
+		dev->dev_id = 0;
+	}
+
 	list_del_rcu(&ipvlan->pnode);
 	unregister_netdevice_queue(dev, head);
 	netdev_upper_dev_unlink(ipvlan->phy_dev, dev);
