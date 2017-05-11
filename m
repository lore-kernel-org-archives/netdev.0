From: Fredrik Markstrom <fredrik.markstrom@gmail.com>
Subject: [PATCH v2 2/2] veth: Added attribute to set maximum
	receive size on veth interfaces
Date: Thu, 11 May 2017 15:46:28 +0200
Message-ID: <20170511134629.139528-3-fredrik.markstrom@gmail.com>
References: <20170511134629.139528-1-fredrik.markstrom@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>,
	Fredrik Markstrom <fredrik.markstrom@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170511134629.139528-1-fredrik.markstrom@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Currently veth drops all packet larger then the mtu set on the receiving
end of the pair. This is inconsistent with most hardware ethernet drivers.
This patch adds a new driver attribute to set the maximum size of received
packet to make it possible to create configurations similar to those
possible with (most) hardware ethernet interfaces.

Signed-off-by: Fredrik Markstrom <fredrik.markstrom@gmail.com>
---
 drivers/net/veth.c        | 45 ++++++++++++++++++++++++++++++++++++++++++++-
 include/uapi/linux/veth.h |  1 +
 2 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 561da3a63b8a..5669286dd531 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -33,6 +33,7 @@ struct veth_priv {
 	struct net_device __rcu	*peer;
 	atomic64_t		dropped;
 	unsigned		requested_headroom;
+	int			mru;
 };
 
 /*
@@ -106,6 +107,7 @@ static const struct ethtool_ops veth_ethtool_ops = {
 static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct veth_priv *priv = netdev_priv(dev);
+	struct veth_priv *rcv_priv;
 	struct net_device *rcv;
 	int length = skb->len;
 
@@ -115,8 +117,10 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 		kfree_skb(skb);
 		goto drop;
 	}
+	rcv_priv = netdev_priv(rcv);
 
-	if (likely(dev_forward_skb(rcv, skb, 0) == NET_RX_SUCCESS)) {
+	if (likely(dev_forward_skb(rcv, skb, rcv_priv->mru) ==
+		   NET_RX_SUCCESS)) {
 		struct pcpu_vstats *stats = this_cpu_ptr(dev->vstats);
 
 		u64_stats_update_begin(&stats->syncp);
@@ -346,6 +350,11 @@ static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
 		if (!is_valid_veth_mtu(nla_get_u32(tb[IFLA_MTU])))
 			return -EINVAL;
 	}
+
+	if (tb[VETH_MRU])
+		if (!is_valid_veth_mtu(nla_get_u32(tb[VETH_MRU])))
+			return -EINVAL;
+
 	return 0;
 }
 
@@ -450,10 +459,15 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	 */
 
 	priv = netdev_priv(dev);
+	if (tb[VETH_MRU])
+		priv->mru = nla_get_u32(tb[VETH_MRU]);
 	rcu_assign_pointer(priv->peer, peer);
 
 	priv = netdev_priv(peer);
+	if (tbp[VETH_MRU])
+		priv->mru = nla_get_u32(tbp[VETH_MRU]);
 	rcu_assign_pointer(priv->peer, dev);
+
 	return 0;
 
 err_register_dev:
@@ -489,8 +503,34 @@ static void veth_dellink(struct net_device *dev, struct list_head *head)
 	}
 }
 
+static int veth_changelink(struct net_device *dev,
+			   struct nlattr *tb[], struct nlattr *data[])
+{
+	struct veth_priv *priv = netdev_priv(dev);
+
+	if (data && data[VETH_MRU])
+		priv->mru = nla_get_u32(data[VETH_MRU]);
+	return 0;
+}
+
+static size_t veth_get_size(const struct net_device *dev)
+{
+	return nla_total_size(4);/* VETH_MRU */
+}
+
+static int veth_fill_info(struct sk_buff *skb,
+			  const struct net_device *dev)
+{
+	struct veth_priv *priv = netdev_priv(dev);
+
+	if (nla_put_u32(skb, VETH_MRU, priv->mru))
+		return -EMSGSIZE;
+	return 0;
+}
+
 static const struct nla_policy veth_policy[VETH_INFO_MAX + 1] = {
 	[VETH_INFO_PEER]	= { .len = sizeof(struct ifinfomsg) },
+	[VETH_MRU]		= { .type = NLA_U32 },
 };
 
 static struct net *veth_get_link_net(const struct net_device *dev)
@@ -508,9 +548,12 @@ static struct rtnl_link_ops veth_link_ops = {
 	.validate	= veth_validate,
 	.newlink	= veth_newlink,
 	.dellink	= veth_dellink,
+	.changelink	= veth_changelink,
 	.policy		= veth_policy,
 	.maxtype	= VETH_INFO_MAX,
 	.get_link_net	= veth_get_link_net,
+	.get_size	= veth_get_size,
+	.fill_info	= veth_fill_info,
 };
 
 /*
diff --git a/include/uapi/linux/veth.h b/include/uapi/linux/veth.h
index 3354c1eb424e..8665b260f156 100644
--- a/include/uapi/linux/veth.h
+++ b/include/uapi/linux/veth.h
@@ -4,6 +4,7 @@
 enum {
 	VETH_INFO_UNSPEC,
 	VETH_INFO_PEER,
+	VETH_MRU,
 
 	__VETH_INFO_MAX
 #define VETH_INFO_MAX	(__VETH_INFO_MAX - 1)
-- 
2.11.0
