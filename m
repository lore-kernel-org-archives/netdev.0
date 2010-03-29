From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Mon, 29 Mar 2010 17:43:00 +1100
Message-ID: <20100329174300.512d83a8.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

After merging the final tree, today's linux-next build (powerpc
ppc44x_defconfig) failed like this:

net/core/net-sysfs.c:476: warning: 'struct netdev_rx_queue' declared inside parameter list
net/core/net-sysfs.c:476: warning: its scope is only this definition or declaration, which is probably not what you want
net/core/net-sysfs.c:478: warning: 'struct netdev_rx_queue' declared inside parameter list
net/core/net-sysfs.c: In function 'rx_queue_attr_show':
net/core/net-sysfs.c:489: error: dereferencing pointer to incomplete type
net/core/net-sysfs.c:489: warning: type defaults to 'int' in declaration of '__mptr'
net/core/net-sysfs.c:489: warning: initialization from incompatible pointer type
net/core/net-sysfs.c:489: error: invalid use of undefined type 'struct netdev_rx_queue'
net/core/net-sysfs.c:494: warning: passing argument 1 of 'attribute->show' from incompatible pointer type
net/core/net-sysfs.c:494: note: expected 'struct netdev_rx_queue *' but argument is of type 'struct netdev_rx_queue *'

(and many more)

Caused by commit 0a9627f2649a02bea165cfd529d7bcb625c2fcad ("rps: Receive
Packet Steering") from the net tree.  struct netdev_rx_queue is protected by
CONFIG_RPS in netdevice.h, but uses are not so protected in net-sysfs.c.

I applied the following patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 29 Mar 2010 17:27:55 +1100
Subject: [PATCH] rps: fix net-sysfs build for !CONFIG_RPS

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/core/net-sysfs.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index c810042..95af841 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -467,6 +467,7 @@ static struct attribute_group wireless_group = {
 };
 #endif
 
+#ifdef CONFIG_RPS
 /*
  * RX queue sysfs structures and functions.
  */
@@ -677,6 +678,12 @@ static void rx_queue_remove_kobjects(struct net_device *net)
 	kset_unregister(net->queues_kset);
 }
 
+#else /* CONFIG_RPS */
+
+static int rx_queue_register_kobjects(struct net_device *net) { return 0; }
+static void rx_queue_remove_kobjects(struct net_device *net) { }
+
+#endif /* CONFIG_RPS */
 #endif /* CONFIG_SYSFS */
 
 #ifdef CONFIG_HOTPLUG
-- 
1.7.0.3

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
