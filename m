From: Bjorn Helgaas <bhelgaas@google.com>
Subject: [PATCH v2] netpoll: Fix extra refcount release in netpoll_cleanup()
Date: Thu, 24 Mar 2016 21:56:21 -0500
Message-ID: <20160325025621.32476.93348.stgit@bhelgaas-glaptop2.roam.corp.google.com>
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

Set and clear np->dev at the points where we dev_hold() and dev_put() the
device.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 net/core/netpoll.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 94acfc8..a57bd17 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -603,7 +603,6 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 	const struct net_device_ops *ops;
 	int err;
 
-	np->dev = ndev;
 	strlcpy(np->dev_name, ndev->name, IFNAMSIZ);
 	INIT_WORK(&np->cleanup_work, netpoll_async_cleanup);
 
@@ -670,6 +669,7 @@ int netpoll_setup(struct netpoll *np)
 		goto unlock;
 	}
 	dev_hold(ndev);
+	np->dev = ndev;
 
 	if (netdev_master_upper_dev_get(ndev)) {
 		np_err(np, "%s is a slave device, aborting\n", np->dev_name);
@@ -770,6 +770,7 @@ int netpoll_setup(struct netpoll *np)
 	return 0;
 
 put:
+	np->dev = NULL;
 	dev_put(ndev);
 unlock:
 	rtnl_unlock();
