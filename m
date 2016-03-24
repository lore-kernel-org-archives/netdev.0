From: Bjorn Helgaas <bhelgaas@google.com>
Subject: [PATCH] netpoll: Fix extra refcount release in netpoll_cleanup()
Date: Thu, 24 Mar 2016 11:13:34 -0500
Message-ID: <20160324161334.31279.26510.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, Neil Horman <nhorman@redhat.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netpoll_setup() does a dev_hold() on np->dev, the netpoll device.  If it
fails, it correctly does a dev_put() but leaves np->dev set.  If we call
netpoll_cleanup() after the failure, np->dev is still set so we do another
dev_put(), which decrements the refcount an extra time.

It's questionable to call netpoll_cleanup() after netpoll_setup() fails,
but it can be difficult to find the problem, and we can easily avoid it in
this case.  The extra decrements can lead to hangs like this:

  unregister_netdevice: waiting for bond0 to become free. Usage count = -3

In __netpoll_setup(), don't set np->dev until we know we're going to
succeed.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 net/core/netpoll.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 94acfc8..32e373e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -603,7 +603,6 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 	const struct net_device_ops *ops;
 	int err;
 
-	np->dev = ndev;
 	strlcpy(np->dev_name, ndev->name, IFNAMSIZ);
 	INIT_WORK(&np->cleanup_work, netpoll_async_cleanup);
 
@@ -628,7 +627,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 
 		atomic_set(&npinfo->refcnt, 1);
 
-		ops = np->dev->netdev_ops;
+		ops = ndev->netdev_ops;
 		if (ops->ndo_netpoll_setup) {
 			err = ops->ndo_netpoll_setup(ndev, npinfo);
 			if (err)
@@ -639,6 +638,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 		atomic_inc(&npinfo->refcnt);
 	}
 
+	np->dev = ndev;
 	npinfo->netpoll = np;
 
 	/* last thing to do is link it to the net device structure */
