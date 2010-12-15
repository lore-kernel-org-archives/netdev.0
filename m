From: "Fenghua Yu" <fenghua.yu@intel.com>
Subject: [PATCH 2/3] net/packet/af_packet.c: implement multiqueue aware socket in af_apcket
Date: Wed, 15 Dec 2010 12:02:05 -0800
Message-ID: <8c24157203309f2ccb56fd8cdbc8fc648ae46e26.1292405004.git.fenghua.yu@intel.com>
References: <cover.1292405004.git.fenghua.yu@intel.com>
Cc: "netdev" <netdev@vger.kernel.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	Xinan Tang <xinan.tang@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"John Fastabend" <john.r.fastabend@intel.com>,
	"Xinan Tang" <xinan.tang@intel.com>,
	"Junchang Wang"
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1292405004.git.fenghua.yu@intel.com>
In-Reply-To: <cover.1292405004.git.fenghua.yu@intel.com>
References: <cover.1292405004.git.fenghua.yu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fenghua Yu <fenghua.yu@intel.com>

This patch implements multiqueue aware socket interfaces in af_packet.

The interfaces are:

1. ioctl(int sockfd, int SIOSTXQUEUEMAPPING, int *tx_queue);
Set tx queue mapping for sockfd;

2. int ioctl(int sockfd, int SIOGTXQUEUEMAPPING, int *tx_queue):
Get tx queue mapping for sockfd. If no queue mapping is set, error is returned.

3. ioctl(int sockfd, int SIOSRXQUEUEMAPPING, int *rx_queue);
Set rx queue mapping for sockfd;

4. ioctl(int sockfd, int SIOGRXQUEUEMAPPING, int *rx_queue);
Get rx queue mapping for sockfd. If no queue mapping is set, error is returned.

5. ioctl(int sockfd, int SIOGNUMTXQUEUE, int *num_tx_queue);
Get number of tx queue which is configured on the NIC interface bound to sockfd.

6. ioctl(int sockfd, int SIOGNUMRXQUEUE, int *num_rx_queue);
Get number of rx queue which is configured on the NIC interface bound to sockfd.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
Signed-off-by: Junchang Wang <junchangwang@gmail.com>
Signed-off-by: Xinan Tang <xinan.tang@intel.com>
---
 net/packet/af_packet.c |  109 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 109 insertions(+), 0 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8298e67..022900d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -659,6 +659,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct timeval tv;
 	struct timespec ts;
 	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
+	int rx_queue_mapping;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -666,6 +667,11 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	sk = pt->af_packet_priv;
 	po = pkt_sk(sk);
 
+	rx_queue_mapping = sk_rx_queue_get(sk);
+	if (rx_queue_mapping >= 0)
+		if (skb_get_queue_mapping(skb) != rx_queue_mapping + 1)
+			goto drop;
+
 	if (!net_eq(dev_net(dev), sock_net(sk)))
 		goto drop;
 
@@ -2219,6 +2225,83 @@ static int packet_notifier(struct notifier_block *this, unsigned long msg, void
 	return NOTIFY_DONE;
 }
 
+static void set_queue_mapping(struct sock *sk, unsigned int cmd, __u16 queue)
+{
+	if (cmd == SIOSRXQUEUEMAPPING)
+		sk_rx_queue_set(sk, queue);
+	else
+		sk_tx_queue_set(sk, queue);
+}
+
+static int get_num_queues(struct socket *sock, unsigned int cmd,
+			 unsigned int *p)
+{
+	struct net_device *dev;
+	struct sock *sk = sock->sk;
+
+	if (!pkt_sk(sk)->ifindex)
+		return -EPERM;
+
+	dev = dev_get_by_index(sock_net(sk), pkt_sk(sk)->ifindex);
+	if (dev == NULL)
+		return -ENODEV;
+
+	switch (cmd) {
+	case SIOGNUMRXQUEUE:
+		*p = dev->real_num_rx_queues;
+		break;
+	case SIOGNUMTXQUEUE:
+		*p = dev->real_num_tx_queues;
+		break;
+	default:
+		return -EFAULT;
+	}
+	return 0;
+}
+
+static int set_sock_queue(struct socket *sock, unsigned int cmd,
+			  char __user *uarg)
+{
+	__u16 queue;
+	struct sock *sk = sock->sk;
+	struct net_device *dev;
+	int num_queues;
+
+	if (copy_from_user(&queue, uarg, sizeof(queue)))
+		return -EFAULT;
+
+	if (!pkt_sk(sk)->ifindex)
+		return -EPERM;
+
+	dev = dev_get_by_index(sock_net(sk), pkt_sk(sk)->ifindex);
+	if (dev == NULL)
+		return -ENODEV;
+
+	num_queues = cmd == SIOSRXQUEUEMAPPING ? dev->real_num_rx_queues :
+						dev->real_num_tx_queues;
+	if (queue >= num_queues)
+		return -EINVAL;
+
+	set_queue_mapping(sk, cmd, queue);
+	return 0;
+}
+
+static int get_sock_queue(struct socket *sock, unsigned int cmd, int *p)
+{
+	struct sock *sk = sock->sk;
+
+	switch (cmd) {
+	case SIOGTXQUEUEMAPPING:
+		*p = sk_tx_queue_get(sk);
+		break;
+	case SIOGRXQUEUEMAPPING:
+		*p = sk_rx_queue_get(sk);
+		break;
+	default:
+		return -EFAULT;
+	}
+	return 0;
+}
 
 static int packet_ioctl(struct socket *sock, unsigned int cmd,
 			unsigned long arg)
@@ -2267,6 +2350,32 @@ static int packet_ioctl(struct socket *sock, unsigned int cmd,
 		return inet_dgram_ops.ioctl(sock, cmd, arg);
 #endif
 
+	case SIOGNUMRXQUEUE:
+	case SIOGNUMTXQUEUE:
+	{
+		int err;
+		unsigned int num_queues;
+		err = get_num_queues(sock, cmd, &num_queues);
+		if (!err)
+			return put_user(num_queues, (int __user *)arg);
+		else
+			return err;
+	}
+	case SIOSRXQUEUEMAPPING:
+	case SIOSTXQUEUEMAPPING:
+		return set_sock_queue(sock, cmd, (char __user *)arg);
+
+	case SIOGRXQUEUEMAPPING:
+	case SIOGTXQUEUEMAPPING:
+	{
+		int err;
+		int queue_mapping;
+		err = get_sock_queue(sock, cmd, &queue_mapping);
+		if (!err)
+			return put_user(queue_mapping, (int __user *)arg);
+		else
+			return err;
+	}
 	default:
 		return -ENOIOCTLCMD;
 	}
-- 
1.6.0.3
