From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Mon, 9 Mar 2015 14:02:53 +0100
Message-ID: <20150309130253.GA6677@salvia>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1425513160-496-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Florian,

On Thu, Mar 05, 2015 at 12:52:32AM +0100, Florian Westphal wrote:
> bridge_netfilter.h contains various helpers, some only used by br_netfilter,
> others however are also called in bridge or even ip stack.
> 
> Lets start untangling bridge, bridge netfilter, and the
> rest of the ip stack (esp. ip_fragment).
> 
> This changes ip_fragment() so that bridge netfilter
> can pass in the required information as arguments instead
> of using skb->nf_bridge to pass some extra information to it.
> 
> Another problem with br_netfilter and the way its plumbed to
> ip/ip6-tables (physdev match) is skb->nf_bridge.
> 
> nf_bridge is kmalloced blob with some extra information, including
> the bridge in and outports (mainly for iptables' physdev match).
> It also has various state bits so we know what manipulations
> have been performed by bridge netfilter on the skb (e.g.
> ppp header stripping).
>
> nf_bridge also provides scratch space where br_netfilter saves
> (and later restores) various things, e.g. ipv4 address for
> dnat detection, mac address to fix up ip fragmented skbs, etc.
> 
> But in almost all cases we can avoid using ->data completely.

I think one of the goals of this patchset is to prepare the removal of
that nf_bridge pointer from sk_buff which sounds as a good idea to me.

Did you consider to implement this scratchpad area using a per-cpu
area? I mean, something similar to what we used to have in
ip_conntrack for events:

http://www.cs.fsu.edu/~baker/devices/lxr/http/source/linux/net/netfilter/nf_conntrack_ecache.c?v=2.6.25#L65

Following that approach, I think we could avoid changing the
ip_fragment() interface. My concern is that these changes are too
specific of br_netfilter, which is not a good reference client of it
given all its design problems.

I'm preparing a new net-next batch, I can quickly take these three if
you agree:

1/8 bridge: move mac header copying into br_netfilter
2/8 netfilter: bridge: move nf_bridge_update_protocol to where its used
4/8 netfilter: bridge: refactor conditional in br_nf_dev_queue_xmit

Regarding 3/8, I think we can move that code to br_netfilter.c so we
reduce ifdef pollution a bit and keep as much of this monster code
fenced under that file. Please, see patch attached.

BTW, 6/8 I think needs some ifdef to make sure NF_CONNTRACK is in
placed. 7/8 needs NF_BRDIGE_MAX_MAC_HEADER_LENGTH which seems to have
a small typo in it, well these are dependent of 4/8 anyway.

Let me know, thanks a lot!

--sdtB3X0nJg68CQEu
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-brige-move-DNAT-helper-to-br_netfilter.patch"

>From 57a8e6c3ac46601615f0df0ccc98e6481c8017a9 Mon Sep 17 00:00:00 2001
From: Florian Westphal <fw@strlen.de>
Date: Thu, 5 Mar 2015 00:52:35 +0100
Subject: [PATCH] netfilter: brige: move DNAT helper to br_netfilter

Only one caller, there is no need to keep this in a header.
Move it to br_netfilter.c where this belongs to.

Based on patch from Florian Westphal.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge.h |   12 ------------
 net/bridge/br_device.c           |    5 +----
 net/bridge/br_netfilter.c        |   32 ++++++++++++++++++++++++++++++++
 net/bridge/br_private.h          |    5 +++++
 4 files changed, 38 insertions(+), 16 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index dd580a9..bb39113 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -44,18 +44,6 @@ static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 }
 
 int br_handle_frame_finish(struct sk_buff *skb);
-/* Only used in br_device.c */
-static inline int br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
-{
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
-
-	skb_pull(skb, ETH_HLEN);
-	nf_bridge->mask ^= BRNF_BRIDGED_DNAT;
-	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
-				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
-	skb->dev = nf_bridge->physindev;
-	return br_handle_frame_finish(skb);
-}
 
 /* This is called by the IP fragmenting code and it ensures there is
  * enough room for the encapsulating header (if there is one). */
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index ffd379d..294cbcc 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -36,13 +36,10 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	u16 vid = 0;
 
 	rcu_read_lock();
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
-		br_nf_pre_routing_finish_bridge_slow(skb);
+	if (br_nf_prerouting_finish_bridge(skb)) {
 		rcu_read_unlock();
 		return NETDEV_TX_OK;
 	}
-#endif
 
 	u64_stats_update_begin(&brstats->syncp);
 	brstats->tx_packets++;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index ef1fe28..a8361c7 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -892,6 +892,38 @@ static unsigned int ip_sabotage_in(const struct nf_hook_ops *ops,
 	return NF_ACCEPT;
 }
 
+/* This is called when br_netfilter has called into iptables/netfilter,
+ * and DNAT has taken place on a bridge-forwarded packet.
+ *
+ * neigh->output has created a new MAC header, with local br0 MAC
+ * as saddr.
+ *
+ * This restores the original MAC saddr of the bridged packet
+ * before invoking bridge forward logic to transmit the packet.
+ */
+static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
+{
+	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+
+	skb_pull(skb, ETH_HLEN);
+	nf_bridge->mask &= ~BRNF_BRIDGED_DNAT;
+
+	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
+				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
+	skb->dev = nf_bridge->physindev;
+	br_handle_frame_finish(skb);
+}
+
+int br_nf_prerouting_finish_bridge(struct sk_buff *skb)
+{
+	if (skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
+		br_nf_pre_routing_finish_bridge_slow(skb);
+		return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(br_nf_prerouting_finish_bridge);
+
 void br_netfilter_enable(void)
 {
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index de09199..d63fc17 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -764,10 +764,15 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 
 /* br_netfilter.c */
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+int br_nf_prerouting_finish_bridge(struct sk_buff *skb);
 int br_nf_core_init(void);
 void br_nf_core_fini(void);
 void br_netfilter_rtable_init(struct net_bridge *);
 #else
+static inline int br_nf_prerouting_finish_bridge(struct sk_buff *skb)
+{
+        return 0;
+}
 static inline int br_nf_core_init(void) { return 0; }
 static inline void br_nf_core_fini(void) {}
 #define br_netfilter_rtable_init(x)
-- 
1.7.10.4


--sdtB3X0nJg68CQEu--
