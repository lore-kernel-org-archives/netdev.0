From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v4] netpoll: fix a rtnl lock assertion failure
Date: Tue, 15 Jan 2013 17:34:06 +0800
Message-ID: <1358242446-4273-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48531 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689Ab3AOJeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2013 04:34:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

v4: hold rtnl lock for the whole netpoll_setup()
v3: remove the comment
v2: use RCU read lock

This patch fixes the following warning:

[   72.013864] RTNL: assertion failed at net/core/dev.c (4955)
[   72.017758] Pid: 668, comm: netpoll-prep-v6 Not tainted 3.8.0-rc1+ #474
[   72.019582] Call Trace:
[   72.020295]  [<ffffffff8176653d>] netdev_master_upper_dev_get+0x35/0x58
[   72.022545]  [<ffffffff81784edd>] netpoll_setup+0x61/0x340
[   72.024846]  [<ffffffff815d837e>] store_enabled+0x82/0xc3
[   72.027466]  [<ffffffff815d7e51>] netconsole_target_attr_store+0x35/0x37
[   72.029348]  [<ffffffff811c3479>] configfs_write_file+0xe2/0x10c
[   72.030959]  [<ffffffff8115d239>] vfs_write+0xaf/0xf6
[   72.032359]  [<ffffffff81978a05>] ? sysret_check+0x22/0x5d
[   72.033824]  [<ffffffff8115d453>] sys_write+0x5c/0x84
[   72.035328]  [<ffffffff819789d9>] system_call_fastpath+0x16/0x1b

In case of other races, hold rtnl lock for the entire netpoll_setup() function.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 9f05067..a5ad1c1 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -1048,11 +1048,13 @@ int netpoll_setup(struct netpoll *np)
 	struct in_device *in_dev;
 	int err;
 
+	rtnl_lock();
 	if (np->dev_name)
-		ndev = dev_get_by_name(&init_net, np->dev_name);
+		ndev = __dev_get_by_name(&init_net, np->dev_name);
 	if (!ndev) {
 		np_err(np, "%s doesn't exist, aborting\n", np->dev_name);
-		return -ENODEV;
+		err = -ENODEV;
+		goto unlock;
 	}
 
 	if (netdev_master_upper_dev_get(ndev)) {
@@ -1066,15 +1068,14 @@ int netpoll_setup(struct netpoll *np)
 
 		np_info(np, "device %s not up yet, forcing it\n", np->dev_name);
 
-		rtnl_lock();
 		err = dev_open(ndev);
-		rtnl_unlock();
 
 		if (err) {
 			np_err(np, "failed to open %s\n", ndev->name);
 			goto put;
 		}
 
+		rtnl_unlock();
 		atleast = jiffies + HZ/10;
 		atmost = jiffies + carrier_timeout * HZ;
 		while (!netif_carrier_ok(ndev)) {
@@ -1094,16 +1095,14 @@ int netpoll_setup(struct netpoll *np)
 			np_notice(np, "carrier detect appears untrustworthy, waiting 4 seconds\n");
 			msleep(4000);
 		}
+		rtnl_lock();
 	}
 
 	if (!np->local_ip.ip) {
 		if (!np->ipv6) {
-			rcu_read_lock();
-			in_dev = __in_dev_get_rcu(ndev);
-
+			in_dev = __in_dev_get_rtnl(ndev);
 
 			if (!in_dev || !in_dev->ifa_list) {
-				rcu_read_unlock();
 				np_err(np, "no IP address for %s, aborting\n",
 				       np->dev_name);
 				err = -EDESTADDRREQ;
@@ -1111,14 +1110,12 @@ int netpoll_setup(struct netpoll *np)
 			}
 
 			np->local_ip.ip = in_dev->ifa_list->ifa_local;
-			rcu_read_unlock();
 			np_info(np, "local IP %pI4\n", &np->local_ip.ip);
 		} else {
 #if IS_ENABLED(CONFIG_IPV6)
 			struct inet6_dev *idev;
 
 			err = -EDESTADDRREQ;
-			rcu_read_lock();
 			idev = __in6_dev_get(ndev);
 			if (idev) {
 				struct inet6_ifaddr *ifp;
@@ -1133,7 +1130,6 @@ int netpoll_setup(struct netpoll *np)
 				}
 				read_unlock_bh(&idev->lock);
 			}
-			rcu_read_unlock();
 			if (err) {
 				np_err(np, "no IPv6 address for %s, aborting\n",
 				       np->dev_name);
@@ -1151,17 +1147,17 @@ int netpoll_setup(struct netpoll *np)
 	/* fill up the skb queue */
 	refill_skbs();
 
-	rtnl_lock();
 	err = __netpoll_setup(np, ndev, GFP_KERNEL);
-	rtnl_unlock();
-
 	if (err)
 		goto put;
 
+	rtnl_unlock();
 	return 0;
 
 put:
 	dev_put(ndev);
+unlock:
+	rtnl_unlock();
 	return err;
 }
 EXPORT_SYMBOL(netpoll_setup);
