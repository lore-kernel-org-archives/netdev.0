From: kan.liang@intel.com
Subject: [RFC V2 PATCH 18/25] net/netpolicy: set Tx queues according to policy
Date: Wed, 31 Dec 2014 20:39:07 -0500
Message-ID: <1420076354-4861-19-git-send-email-kan.liang@intel.com>
References: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

When the device tries to transmit a packet, netdev_pick_tx is called to
find the available Tx queues. If the net policy is applied, it picks up
the assigned Tx queue from net policy subsystem, and redirect the
traffic to the assigned queue.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/net/sock.h |  9 +++++++++
 net/core/dev.c     | 20 ++++++++++++++++++--
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index fd4132f..6219434 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2273,4 +2273,13 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
+/* Return netpolicy instance information from socket. */
+static inline struct netpolicy_instance *netpolicy_find_instance(struct sock *sk)
+{
+#ifdef CONFIG_NETPOLICY
+	if (is_net_policy_valid(sk->sk_netpolicy.policy))
+		return &sk->sk_netpolicy;
+#endif
+	return NULL;
+}
 #endif	/* _SOCK_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index 2a9c39f..08db6eb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3266,6 +3266,7 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 				    struct sk_buff *skb,
 				    void *accel_priv)
 {
+	struct sock *sk = skb->sk;
 	int queue_index = 0;
 
 #ifdef CONFIG_XPS
@@ -3280,8 +3281,23 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 		if (ops->ndo_select_queue)
 			queue_index = ops->ndo_select_queue(dev, skb, accel_priv,
 							    __netdev_pick_tx);
-		else
-			queue_index = __netdev_pick_tx(dev, skb);
+		else {
+#ifdef CONFIG_NETPOLICY
+			struct netpolicy_instance *instance;
+
+			queue_index = -1;
+			if (dev->netpolicy && sk) {
+				instance = netpolicy_find_instance(sk);
+				if (instance) {
+					if (!instance->dev)
+						instance->dev = dev;
+					queue_index = netpolicy_pick_queue(instance, false);
+				}
+			}
+			if (queue_index < 0)
+#endif
+				queue_index = __netdev_pick_tx(dev, skb);
+		}
 
 		if (!accel_priv)
 			queue_index = netdev_cap_txqueue(dev, queue_index);
-- 
2.5.5
