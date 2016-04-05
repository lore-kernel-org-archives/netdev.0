From: Bjorn Helgaas <bhelgaas@google.com>
Subject: [PATCH] Revert "netpoll: Fix extra refcount release in
 netpoll_cleanup()"
Date: Tue, 05 Apr 2016 15:58:22 -0500
Message-ID: <20160405205822.24724.95522.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@redhat.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Duyck <aduyck@mirantis.com>,
	Bart Van Assche <bart.vanassche@sandisk.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 543e3a8da5a4c453e992d5351ef405d5e32f27d7.

Direct callers of __netpoll_setup() depend on it to set np->dev,
so we can't simply move that assignment up to netpoll_stup().

Reported-by: Bart Van Assche <bart.vanassche@sandisk.com>
Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 net/core/netpoll.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a57bd17..94acfc8 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -603,6 +603,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 	const struct net_device_ops *ops;
 	int err;
 
+	np->dev = ndev;
 	strlcpy(np->dev_name, ndev->name, IFNAMSIZ);
 	INIT_WORK(&np->cleanup_work, netpoll_async_cleanup);
 
@@ -669,7 +670,6 @@ int netpoll_setup(struct netpoll *np)
 		goto unlock;
 	}
 	dev_hold(ndev);
-	np->dev = ndev;
 
 	if (netdev_master_upper_dev_get(ndev)) {
 		np_err(np, "%s is a slave device, aborting\n", np->dev_name);
@@ -770,7 +770,6 @@ int netpoll_setup(struct netpoll *np)
 	return 0;
 
 put:
-	np->dev = NULL;
 	dev_put(ndev);
 unlock:
 	rtnl_unlock();
