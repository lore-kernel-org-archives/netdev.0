From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v2 1/4] ovs/gre,geneve: fix error path when creating an iface
Date: Mon, 13 Jun 2016 10:31:04 +0200
Message-ID: <1465806667-23148-2-git-send-email-nicolas.dichtel@6wind.com>
References: <CAOrHB_DCupNkAz+BSaOKKE+KLYhK-hytqW2vEV1yQ-iYr6hakg@mail.gmail.com>
 <1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, pshelar@ovn.org, jesse@kernel.org,
	linville@tuxdriver.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Wragg <david@weave.works>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38132 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964985AbcFMIbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 04:31:13 -0400
In-Reply-To: <1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After ipgre_newlink()/geneve_configure() call, the netdev is registered.

Fixes: 7e059158d57b ("vxlan, gre, geneve: Set a large MTU on ovs-created tunnel devices")
CC: David Wragg <david@weave.works>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/geneve.c | 10 +++++++---
 net/ipv4/ip_gre.c    | 10 +++++++---
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index cadefe4fdaa2..086c2dae4c3d 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1508,6 +1508,7 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 {
 	struct nlattr *tb[IFLA_MAX + 1];
 	struct net_device *dev;
+	LIST_HEAD(list_kill);
 	int err;
 
 	memset(tb, 0, sizeof(tb));
@@ -1519,8 +1520,10 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 	err = geneve_configure(net, dev, &geneve_remote_unspec,
 			       0, 0, 0, 0, htons(dst_port), true,
 			       GENEVE_F_UDP_ZERO_CSUM6_RX);
-	if (err)
-		goto err;
+	if (err) {
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
 
 	/* openvswitch users expect packet sizes to be unrestricted,
 	 * so set the largest MTU we can.
@@ -1532,7 +1535,8 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 	return dev;
 
  err:
-	free_netdev(dev);
+	geneve_dellink(dev, &list_kill);
+	unregister_netdevice_many(&list_kill);
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(geneve_dev_create_fb);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 4d2025f7ec57..08deba679c8c 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1121,6 +1121,7 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 {
 	struct nlattr *tb[IFLA_MAX + 1];
 	struct net_device *dev;
+	LIST_HEAD(list_kill);
 	struct ip_tunnel *t;
 	int err;
 
@@ -1136,8 +1137,10 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 	t->collect_md = true;
 
 	err = ipgre_newlink(net, dev, tb, NULL);
-	if (err < 0)
-		goto out;
+	if (err < 0) {
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
 
 	/* openvswitch users expect packet sizes to be unrestricted,
 	 * so set the largest MTU we can.
@@ -1148,7 +1151,8 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 
 	return dev;
 out:
-	free_netdev(dev);
+	ip_tunnel_dellink(dev, &list_kill);
+	unregister_netdevice_many(&list_kill);
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(gretap_fb_dev_create);
-- 
2.4.2
