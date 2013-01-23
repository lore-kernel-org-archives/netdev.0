From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 1/2] tuntap: reduce memory using of queues
Date: Wed, 23 Jan 2013 21:59:12 +0800
Message-ID: <1358949553-30309-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Woodhouse <dwmw2@infradead.org>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A MAX_TAP_QUEUES(1024) queues of tuntap device is always allocated
unconditionally even userspace only requires a single queue device. This is
unnecessary and will lead a very high order of page allocation when has a high
possibility to fail. Solving this by creating a one queue net device when
userspace only use one queue and also reduce MAX_TAP_QUEUES to
DEFAULT_MAX_NUM_RSS_QUEUES which can guarantee the success of
the allocation.

Reported-by: Dirk Hohndel <dirk@hohndel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index c81680d..8939d21 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -109,11 +109,10 @@ struct tap_filter {
 	unsigned char	addr[FLT_EXACT_COUNT][ETH_ALEN];
 };
 
-/* 1024 is probably a high enough limit: modern hypervisors seem to support on
- * the order of 100-200 CPUs so this leaves us some breathing space if we want
- * to match a queue per guest CPU.
- */
-#define MAX_TAP_QUEUES 1024
+/* DEFAULT_MAX_NUM_RSS_QUEUES were choosed to let the rx/tx queues allocated for
+ * the netdevice to be fit in one page. So we can make sure the success of
+ * memory allocation. TODO: increase the limit. */
+#define MAX_TAP_QUEUES DEFAULT_MAX_NUM_RSS_QUEUES
 
 #define TUN_FLOW_EXPIRE (3 * HZ)
 
@@ -1583,6 +1582,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	else {
 		char *name;
 		unsigned long flags = 0;
+		int queues = ifr->ifr_flags & IFF_MULTI_QUEUE ?
+			     MAX_TAP_QUEUES : 1;
 
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
@@ -1606,8 +1607,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			name = ifr->ifr_name;
 
 		dev = alloc_netdev_mqs(sizeof(struct tun_struct), name,
-				       tun_setup,
-				       MAX_TAP_QUEUES, MAX_TAP_QUEUES);
+				       tun_setup, queues, queues);
+
 		if (!dev)
 			return -ENOMEM;
 
-- 
1.7.1
