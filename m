From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] macvlan: use call_rcu for port free
Date: Mon, 7 Jun 2010 13:36:29 +0200
Message-ID: <20100607113629.GA2730@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752558Ab0FGLgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 07:36:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use call_rcu rather than synchronize_rcu.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/macvlan.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 53422ce..59c3155 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -37,6 +37,7 @@ struct macvlan_port {
 	struct net_device	*dev;
 	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
 	struct list_head	vlans;
+	struct rcu_head		rcu;
 };
 
 static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
@@ -540,14 +541,21 @@ static int macvlan_port_create(struct net_device *dev)
 	return err;
 }
 
+static void macvlan_port_rcu_free(struct rcu_head *head)
+{
+	struct macvlan_port *port;
+
+	port = container_of(head, struct macvlan_port, rcu);
+	kfree(port);
+}
+
 static void macvlan_port_destroy(struct net_device *dev)
 {
 	struct macvlan_port *port = dev->macvlan_port;
 
 	netdev_rx_handler_unregister(dev);
 	rcu_assign_pointer(dev->macvlan_port, NULL);
-	synchronize_rcu();
-	kfree(port);
+	call_rcu(&port->rcu, macvlan_port_rcu_free);
 }
 
 static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
1.7.0.1

