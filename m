From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deadlock, L2TP over IP are not working, 3.4.1
Date: Sun, 10 Jun 2012 15:31:01 +0200
Message-ID: <1339335061.6001.466.camel@edumazet-glaptop>
References: <7ed49f446365ac625437702d92946add@visp.net.lb>
	 <20120607205356.GA2491@electric-eye.fr.zoreil.com>
	 <1339104606.6001.4.camel@edumazet-glaptop>
	 <20120607223752.GA4475@electric-eye.fr.zoreil.com>
	 <1339134438.6001.13.camel@edumazet-glaptop>
	 <20120608154106.GD5024@kvack.org>
	 <67d8beaf421874815145fdefc69b3366@visp.net.lb>
	 <1339171495.6001.118.camel@edumazet-glaptop>
	 <CAA7+ByWEZDqzZhzH0FZoapqfUrujUrxyjwp6qb1SSfWBTZ=4AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Denys Fedoryshchenko <denys@visp.net.lb>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hong zhi guo <honkiko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAA7+ByWEZDqzZhzH0FZoapqfUrujUrxyjwp6qb1SSfWBTZ=4AA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-06-10 at 20:14 +0800, Hong zhi guo wrote:
> Is there any conclusion about the problem?  Will bh_lock_sock_nested
> fix the lockdep violation?

lockdep violation could indeed be fixed like that, but LLTX seems more
appropriate.

But there is still a bug because skb->len is used after 
l2tp_xmit_skb(session, skb, session->hdr_len);

There is also a bug in l2tp_core.c, because it assumes RX path is not
reentrant. That should be fixed eventually.

I believe we could avoid percpu stuf and new locking, adding the
following unions in net_device_stats. It seems enough to have machine
long words stats, no need to force 64bit stats on 32bit arches.

 include/linux/netdevice.h |   40 ++++++++++++++++++++++++++++--------
 net/l2tp/l2tp_eth.c       |   29 +++++++++++++-------------
 2 files changed, 47 insertions(+), 22 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d94cb14..1dee75a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -171,14 +171,38 @@ static inline bool dev_xmit_complete(int rc)
  */
 
 struct net_device_stats {
-	unsigned long	rx_packets;
-	unsigned long	tx_packets;
-	unsigned long	rx_bytes;
-	unsigned long	tx_bytes;
-	unsigned long	rx_errors;
-	unsigned long	tx_errors;
-	unsigned long	rx_dropped;
-	unsigned long	tx_dropped;
+	union {
+		unsigned long	rx_packets;
+		atomic_long_t   rx_packets_atomic;
+	};
+	union {
+		unsigned long	tx_packets;
+		atomic_long_t	tx_packets_atomic;
+	};
+	union {
+		unsigned long	rx_bytes;
+		atomic_long_t	rx_bytes_atomic;
+	};
+	union {
+		unsigned long	tx_bytes;
+		atomic_long_t	tx_bytes_atomic;
+	};
+	union {
+		unsigned long	rx_errors;
+		atomic_long_t	rx_errors_atomic;
+	};
+	union {
+		unsigned long	tx_errors;
+		atomic_long_t	tx_errors_atomic;
+	};
+	union {
+		unsigned long	rx_dropped;
+		atomic_long_t	rx_dropped_atomic;
+	};
+	union {
+		unsigned long	tx_dropped;
+		atomic_long_t	tx_dropped_atomic;
+	};
 	unsigned long	multicast;
 	unsigned long	collisions;
 	unsigned long	rx_length_errors;
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 185f12f..9e80ec4 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -83,20 +83,20 @@ static void l2tp_eth_dev_uninit(struct net_device *dev)
 	dev_put(dev);
 }
 
-static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct l2tp_eth *priv = netdev_priv(dev);
 	struct l2tp_session *session = priv->session;
 
-	l2tp_xmit_skb(session, skb, session->hdr_len);
+	atomic_long_add(skb->len, &dev->stats.tx_bytes_atomic);
+	atomic_long_inc(&dev->stats.tx_packets_atomic);
 
-	dev->stats.tx_bytes += skb->len;
-	dev->stats.tx_packets++;
+	l2tp_xmit_skb(session, skb, session->hdr_len);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
-static struct net_device_ops l2tp_eth_netdev_ops = {
+static const struct net_device_ops l2tp_eth_netdev_ops = {
 	.ndo_init		= l2tp_eth_dev_init,
 	.ndo_uninit		= l2tp_eth_dev_uninit,
 	.ndo_start_xmit		= l2tp_eth_dev_xmit,
@@ -106,8 +106,9 @@ static void l2tp_eth_dev_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
-	dev->netdev_ops		= &l2tp_eth_netdev_ops;
-	dev->destructor		= free_netdev;
+	dev->features	|= NETIF_F_LLTX;
+	dev->netdev_ops	= &l2tp_eth_netdev_ops;
+	dev->destructor	= free_netdev;
 }
 
 static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb, int data_len)
@@ -139,15 +140,15 @@ static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb,
 	nf_reset(skb);
 
 	if (dev_forward_skb(dev, skb) == NET_RX_SUCCESS) {
-		dev->stats.rx_packets++;
-		dev->stats.rx_bytes += data_len;
-	} else
-		dev->stats.rx_errors++;
-
+		atomic_long_inc(&dev->stats.rx_packets_atomic);
+		atomic_long_add(data_len, &dev->stats.rx_bytes_atomic);
+	} else {
+		atomic_long_inc(&dev->stats.rx_errors_atomic);
+	}
 	return;
 
 error:
-	dev->stats.rx_errors++;
+	atomic_long_inc(&dev->stats.rx_errors_atomic);
 	kfree_skb(skb);
 }
 
