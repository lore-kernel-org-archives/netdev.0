From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipmr: Optimize multiple unregistration
Date: Wed, 28 Oct 2009 16:21:38 +0100
Message-ID: <4AE86182.80804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53806 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbZJ1PVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 11:21:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Speedup module unloading by factorizing synchronize_rcu() calls

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ipmr.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 6949745..ef4ee45 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -275,7 +275,8 @@ failure:
  *	@notify: Set to 1, if the caller is a notifier_call
  */
 
-static int vif_delete(struct net *net, int vifi, int notify)
+static int vif_delete(struct net *net, int vifi, int notify,
+		      struct list_head *head)
 {
 	struct vif_device *v;
 	struct net_device *dev;
@@ -319,7 +320,7 @@ static int vif_delete(struct net *net, int vifi, int notify)
 	}
 
 	if (v->flags&(VIFF_TUNNEL|VIFF_REGISTER) && !notify)
-		unregister_netdevice(dev);
+		unregister_netdevice_queue(dev, head);
 
 	dev_put(dev);
 	return 0;
@@ -870,14 +871,16 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 static void mroute_clean_tables(struct net *net)
 {
 	int i;
+	LIST_HEAD(list);
 
 	/*
 	 *	Shut down all active vif entries
 	 */
 	for (i = 0; i < net->ipv4.maxvif; i++) {
 		if (!(net->ipv4.vif_table[i].flags&VIFF_STATIC))
-			vif_delete(net, i, 0);
+			vif_delete(net, i, 0, &list);
 	}
+	unregister_netdevice_many(&list);
 
 	/*
 	 *	Wipe the cache
@@ -993,7 +996,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		if (optname == MRT_ADD_VIF) {
 			ret = vif_add(net, &vif, sk == net->ipv4.mroute_sk);
 		} else {
-			ret = vif_delete(net, vif.vifc_vifi, 0);
+			ret = vif_delete(net, vif.vifc_vifi, 0, NULL);
 		}
 		rtnl_unlock();
 		return ret;
@@ -1156,6 +1159,7 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 	struct net *net = dev_net(dev);
 	struct vif_device *v;
 	int ct;
+	LIST_HEAD(list);
 
 	if (!net_eq(dev_net(dev), net))
 		return NOTIFY_DONE;
@@ -1165,8 +1169,9 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 	v = &net->ipv4.vif_table[0];
 	for (ct = 0; ct < net->ipv4.maxvif; ct++, v++) {
 		if (v->dev == dev)
-			vif_delete(net, ct, 1);
+			vif_delete(net, ct, 1, &list);
 	}
+	unregister_netdevice_many(&list);
 	return NOTIFY_DONE;
 }
 
