From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/7] netpoll: Add ndo_netpoll_setup
Date: Thu, 10 Jun 2010 22:42:05 +1000
Message-ID: <E1OMh5B-0004Ni-DS@gondolin.me.apana.org.au>
References: <20100610124047.GA16658@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen He
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:52029 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758965Ab0FJMmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 08:42:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netpoll: Add ndo_netpoll_setup

This patch adds ndo_netpoll_setup as the initialisation primitive
to complement ndo_netpoll_cleanup.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netdevice.h |    2 ++
 net/core/netpoll.c        |   10 ++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 40291f3..619d3f1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -728,6 +728,8 @@ struct net_device_ops {
 						        unsigned short vid);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	void                    (*ndo_poll_controller)(struct net_device *dev);
+	int			(*ndo_netpoll_setup)(struct net_device *dev,
+						     struct netpoll_info *info);
 	void			(*ndo_netpoll_cleanup)(struct net_device *dev);
 #endif
 	int			(*ndo_set_vf_mac)(struct net_device *dev,
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 9dcd767..c445896 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -729,6 +729,7 @@ int netpoll_setup(struct netpoll *np)
 	struct net_device *ndev = NULL;
 	struct in_device *in_dev;
 	struct netpoll_info *npinfo;
+	const struct net_device_ops *ops;
 	unsigned long flags;
 	int err;
 
@@ -828,6 +829,13 @@ int netpoll_setup(struct netpoll *np)
 		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
 
 		atomic_set(&npinfo->refcnt, 1);
+
+		ops = np->dev->netdev_ops;
+		if (ops->ndo_netpoll_setup) {
+			err = ops->ndo_netpoll_setup(ndev, npinfo);
+			if (err)
+				goto free_npinfo;
+		}
 	} else {
 		npinfo = ndev->npinfo;
 		atomic_inc(&npinfo->refcnt);
@@ -848,6 +856,8 @@ int netpoll_setup(struct netpoll *np)
 
 	return 0;
 
+free_npinfo:
+	kfree(npinfo);
 unlock:
 	rtnl_unlock();
 put:
