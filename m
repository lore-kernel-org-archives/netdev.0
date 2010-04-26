From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] pppoe: use phonet_pernet instead of directly
 net_generic
Date: Mon, 26 Apr 2010 15:41:00 +0200
Message-ID: <20100426134100.GF2941@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45181 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750876Ab0DZNlC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 09:41:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As in for example pppoe introduce phonet_pernet and use it instead of calling
net_generic directly.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 9b4ced6..c33da65 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -46,9 +46,16 @@ struct phonet_net {
 
 int phonet_net_id __read_mostly;
 
+static struct phonet_net *phonet_pernet(struct net *net)
+{
+	BUG_ON(!net);
+
+	return net_generic(net, phonet_net_id);
+}
+
 struct phonet_device_list *phonet_device_list(struct net *net)
 {
-	struct phonet_net *pnn = net_generic(net, phonet_net_id);
+	struct phonet_net *pnn = phonet_pernet(net);
 	return &pnn->pndevs;
 }
 
@@ -261,7 +268,7 @@ static int phonet_device_autoconf(struct net_device *dev)
 
 static void phonet_route_autodel(struct net_device *dev)
 {
-	struct phonet_net *pnn = net_generic(dev_net(dev), phonet_net_id);
+	struct phonet_net *pnn = phonet_pernet(dev_net(dev));
 	unsigned i;
 	DECLARE_BITMAP(deleted, 64);
 
@@ -313,7 +320,7 @@ static struct notifier_block phonet_device_notifier = {
 /* Per-namespace Phonet devices handling */
 static int __net_init phonet_init_net(struct net *net)
 {
-	struct phonet_net *pnn = net_generic(net, phonet_net_id);
+	struct phonet_net *pnn = phonet_pernet(net);
 
 	if (!proc_net_fops_create(net, "phonet", 0, &pn_sock_seq_fops))
 		return -ENOMEM;
@@ -326,7 +333,7 @@ static int __net_init phonet_init_net(struct net *net)
 
 static void __net_exit phonet_exit_net(struct net *net)
 {
-	struct phonet_net *pnn = net_generic(net, phonet_net_id);
+	struct phonet_net *pnn = phonet_pernet(net);
 	struct net_device *dev;
 	unsigned i;
 
@@ -376,7 +383,7 @@ void phonet_device_exit(void)
 
 int phonet_route_add(struct net_device *dev, u8 daddr)
 {
-	struct phonet_net *pnn = net_generic(dev_net(dev), phonet_net_id);
+	struct phonet_net *pnn = phonet_pernet(dev_net(dev));
 	struct phonet_routes *routes = &pnn->routes;
 	int err = -EEXIST;
 
@@ -393,7 +400,7 @@ int phonet_route_add(struct net_device *dev, u8 daddr)
 
 int phonet_route_del(struct net_device *dev, u8 daddr)
 {
-	struct phonet_net *pnn = net_generic(dev_net(dev), phonet_net_id);
+	struct phonet_net *pnn = phonet_pernet(dev_net(dev));
 	struct phonet_routes *routes = &pnn->routes;
 
 	daddr = daddr >> 2;
@@ -413,7 +420,7 @@ int phonet_route_del(struct net_device *dev, u8 daddr)
 
 struct net_device *phonet_route_get(struct net *net, u8 daddr)
 {
-	struct phonet_net *pnn = net_generic(net, phonet_net_id);
+	struct phonet_net *pnn = phonet_pernet(net);
 	struct phonet_routes *routes = &pnn->routes;
 	struct net_device *dev;
 
@@ -428,7 +435,7 @@ struct net_device *phonet_route_get(struct net *net, u8 daddr)
 
 struct net_device *phonet_route_output(struct net *net, u8 daddr)
 {
-	struct phonet_net *pnn = net_generic(net, phonet_net_id);
+	struct phonet_net *pnn = phonet_pernet(net);
 	struct phonet_routes *routes = &pnn->routes;
 	struct net_device *dev;
 
