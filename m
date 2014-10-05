From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Save frag_max_size between PRE_ROUTING and POST_ROUTING
Date: Sun, 5 Oct 2014 12:00:22 +0800
Message-ID: <20141005040022.GA14118@gondor.apana.org.au>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
 <20141004035606.GA8228@gondor.apana.org.au>
 <20141004100413.GA1241@breakpoint.cc>
 <20141004135508.GA10705@gondor.apana.org.au>
 <20141004141802.GA10878@gondor.apana.org.au>
 <20141004180647.GB1241@breakpoint.cc>
 <20141005035343.GA13696@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, bsd@redhat.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davidn@davidnewall.com,
	"David S. Miller" <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141005035343.GA13696@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 05, 2014 at 11:53:43AM +0800, Herbert Xu wrote:
> 
> What we should do therefore is to save any necessary information
> such as frag_max_size into the bridge CB area when reentering the
> bridge and then copy it back upon the next reentry into the IP stack.

Here's a patch that does just that:

bridge: Save frag_max_size between PRE_ROUTING and POST_ROUTING

As we may defragment the packet in IPv4 PRE_ROUTING and refragment
it after POST_ROUTING we should save the value of frag_max_size.

This is still very wrong as the bridge is supposed to leave the
packets intact, meaning that the right thing to do is to use the
original frag_list for fragmentation.

Unfortunately we don't currently guarantee that the frag_list is
left untouched throughout netfilter so until this changes this is
the best we can do.

There is also a spot in FORWARD where it appears that we can
forward a packet without going through fragmentation, mark it
so that we can fix it later.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 389d1c6..47fe079 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -398,6 +398,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 							 ETH_HLEN-ETH_ALEN);
 			/* tell br_dev_xmit to continue with forwarding */
 			nf_bridge->mask |= BRNF_BRIDGED_DNAT;
+			/* FIXME Need to refragment */
 			ret = neigh->output(neigh, skb);
 		}
 		neigh_release(neigh);
@@ -453,6 +454,10 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct rtable *rt;
 	int err;
+	int frag_max_size;
+
+	frag_max_size = IPCB(skb)->frag_max_size;
+	BR_INPUT_SKB_CB(skb)->frag_max_size = frag_max_size;
 
 	if (nf_bridge->mask & BRNF_PKT_TYPE) {
 		skb->pkt_type = PACKET_OTHERHOST;
@@ -864,13 +869,19 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
 	int ret;
+	int frag_max_size;
 
+	/* This is wrong! We should preserve the original fragment
+	 * boundaries by preserving frag_list rather than refragmenting.
+	 */
 	if (skb->protocol == htons(ETH_P_IP) &&
 	    skb->len + nf_bridge_mtu_reduction(skb) > skb->dev->mtu &&
 	    !skb_is_gso(skb)) {
+		frag_max_size = BR_INPUT_SKB_CB(skb)->frag_max_size;
 		if (br_parse_ip_options(skb))
 			/* Drop invalid packet */
 			return NF_DROP;
+		IPCB(skb)->frag_max_size = frag_max_size;
 		ret = ip_fragment(skb, br_dev_queue_push_xmit);
 	} else
 		ret = br_dev_queue_push_xmit(skb);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index b6c04cb..2398369 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -305,10 +305,14 @@ struct net_bridge
 
 struct br_input_skb_cb {
 	struct net_device *brdev;
+
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	int igmp;
 	int mrouters_only;
 #endif
+
+	u16 frag_max_size;
+
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	bool vlan_filtered;
 #endif

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
