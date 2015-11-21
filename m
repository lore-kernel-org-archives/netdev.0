From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2 9/9] net: ipmr: factor out common vif init code
Date: Sat, 21 Nov 2015 15:57:32 +0100
Message-ID: <1448117852-4254-10-git-send-email-razor@blackwall.org>
References: <1448117852-4254-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38407 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761132AbbKUO7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 09:59:32 -0500
Received: by wmec201 with SMTP id c201so54620491wme.1
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 06:59:31 -0800 (PST)
In-Reply-To: <1448117852-4254-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Factor out common vif init code used in both tunnel and pimreg
initialization and create ipmr_init_vif_indev() function.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 40 +++++++++++++++++++---------------------
 1 file changed, 19 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index e384f39202cb..a2d248d9c35c 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -391,6 +391,23 @@ static void ipmr_del_tunnel(struct net_device *dev, struct vifctl *v)
 	}
 }
 
+/* Initialize ipmr pimreg/tunnel in_device */
+static bool ipmr_init_vif_indev(const struct net_device *dev)
+{
+	struct in_device *in_dev;
+
+	ASSERT_RTNL();
+
+	in_dev = __in_dev_get_rtnl(dev);
+	if (!in_dev)
+		return false;
+	ipv4_devconf_setall(in_dev);
+	neigh_parms_data_state_setall(in_dev->arp_parms);
+	IPV4_DEVCONF(in_dev->cnf, RP_FILTER) = 0;
+
+	return true;
+}
+
 static struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
 {
 	struct net_device  *dev;
@@ -402,7 +419,6 @@ static struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
 		int err;
 		struct ifreq ifr;
 		struct ip_tunnel_parm p;
-		struct in_device  *in_dev;
 
 		memset(&p, 0, sizeof(p));
 		p.iph.daddr = v->vifc_rmt_addr.s_addr;
@@ -427,15 +443,8 @@ static struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
 		if (err == 0 &&
 		    (dev = __dev_get_by_name(net, p.name)) != NULL) {
 			dev->flags |= IFF_MULTICAST;
-
-			in_dev = __in_dev_get_rtnl(dev);
-			if (!in_dev)
+			if (!ipmr_init_vif_indev(dev))
 				goto failure;
-
-			ipv4_devconf_setall(in_dev);
-			neigh_parms_data_state_setall(in_dev->arp_parms);
-			IPV4_DEVCONF(in_dev->cnf, RP_FILTER) = 0;
-
 			if (dev_open(dev))
 				goto failure;
 			dev_hold(dev);
@@ -502,7 +511,6 @@ static void reg_vif_setup(struct net_device *dev)
 static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
 {
 	struct net_device *dev;
-	struct in_device *in_dev;
 	char name[IFNAMSIZ];
 
 	if (mrt->id == RT_TABLE_DEFAULT)
@@ -522,18 +530,8 @@ static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
 		return NULL;
 	}
 
-	rcu_read_lock();
-	in_dev = __in_dev_get_rcu(dev);
-	if (!in_dev) {
-		rcu_read_unlock();
+	if (!ipmr_init_vif_indev(dev))
 		goto failure;
-	}
-
-	ipv4_devconf_setall(in_dev);
-	neigh_parms_data_state_setall(in_dev->arp_parms);
-	IPV4_DEVCONF(in_dev->cnf, RP_FILTER) = 0;
-	rcu_read_unlock();
-
 	if (dev_open(dev))
 		goto failure;
 
-- 
2.4.3
