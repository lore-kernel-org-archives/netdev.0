From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Respect call-iptables sysctls everywhere
Date: Sun, 5 Oct 2014 11:53:43 +0800
Message-ID: <20141005035343.GA13696@gondor.apana.org.au>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
 <20141004035606.GA8228@gondor.apana.org.au>
 <20141004100413.GA1241@breakpoint.cc>
 <20141004135508.GA10705@gondor.apana.org.au>
 <20141004141802.GA10878@gondor.apana.org.au>
 <20141004180647.GB1241@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, bsd@redhat.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davidn@davidnewall.com,
	"David S. Miller" <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141004180647.GB1241@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 04, 2014 at 08:06:47PM +0200, Florian Westphal wrote:
>
> Fair enough.  We lose frag_max_size information from ipv4 defrag,

Sigh.  Why are people still doing IP netfilter through the bridge?
It's a huge security hole because all bridge devices share the same
defrag zone so each bridge port can inject packets into any bridge
device on the system through conntrack.  It used to be an even bigger
hole when all defrag were in the same zone which meant that you could
inject packets into the IP stack itself.  At least that hole is
closed now.

So in this case what we have is a bridge packet that temporarily
enters the IP stack for filtering, then reenters the bridge for
processing, and then gets reinserted into the IP stack for filtering.

What we should do therefore is to save any necessary information
such as frag_max_size into the bridge CB area when reentering the
bridge and then copy it back upon the next reentry into the IP stack.

But really we should be printing a big warning to tell people that
this feature (specifically IP netfilter through the bridge, netfilter
through the bridge itself is fine) is insecure and shouldn't be used
until such a time that it is redesigned properly.

> plus netfilter hooks are called without validating ip options.

This was the status quo before the patch in question.  Patches are
welcome.
 
> So I am fine with it, provided we rename br_parse_ip_options() --
> thats not what it does after this patch (br_validate_iphdr(), for
> example?)

I thought about renaming it but if we ever do add option parsing
then we'll be renaming it back.  So let's just stick with the name
plus my comment in the function.

While reviewing this code it occured to me that we have a serious
bug in that call-iptables sysctls aren't even respected in FORWARD
and POST_ROUTING.  Here is a patch that fixes this.

bridge: Respect call-iptables sysctls everywhere

>From the very beginning the call-iptables sysctl only prevented
the PRE_ROUTING hook from entering the IP stack.  This is very
wrong.  The sysctl is used because entering the IP stack from the
bridge has serious security ramifications so when the admin says
that we shouldn't do it, it really means no.

This patch fixes this by also checking the sysctl in FORWARD and
POST_ROUTING.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index c0fdb4d..389d1c6 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -171,20 +171,28 @@ void br_netfilter_rtable_init(struct net_bridge *br)
 	rt->dst.ops = &fake_dst_ops;
 }
 
-static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
+static inline struct net_bridge *bridge_parent(const struct net_device *dev)
 {
 	struct net_bridge_port *port;
 
 	port = br_port_get_rcu(dev);
-	return port ? &port->br->fake_rtable : NULL;
+	return port ? port->br : NULL;
 }
 
-static inline struct net_device *bridge_parent(const struct net_device *dev)
+static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
 {
-	struct net_bridge_port *port;
+	struct net_bridge *br;
 
-	port = br_port_get_rcu(dev);
-	return port ? port->br->dev : NULL;
+	br = bridge_parent(dev);
+	return br ? &br->fake_rtable : NULL;
+}
+
+static inline struct net_device *bridge_parent_dev(const struct net_device *dev)
+{
+	struct net_bridge *br;
+
+	br = bridge_parent(dev);
+	return br ? br->dev : NULL;
 }
 
 static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
@@ -367,7 +375,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 	struct neighbour *neigh;
 	struct dst_entry *dst;
 
-	skb->dev = bridge_parent(skb->dev);
+	skb->dev = bridge_parent_dev(skb->dev);
 	if (!skb->dev)
 		goto free_skb;
 	dst = skb_dst(skb);
@@ -517,7 +525,7 @@ static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct
 {
 	struct net_device *vlan, *br;
 
-	br = bridge_parent(dev);
+	br = bridge_parent_dev(dev);
 	if (brnf_pass_vlan_indev == 0 || !vlan_tx_tag_present(skb))
 		return br;
 
@@ -763,6 +771,7 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 {
 	struct nf_bridge_info *nf_bridge;
 	struct net_device *parent;
+	struct net_bridge *br;
 	u_int8_t pf;
 
 	if (!skb->nf_bridge)
@@ -773,15 +782,21 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	if (!nf_bridge_unshare(skb))
 		return NF_DROP;
 
-	parent = bridge_parent(out);
-	if (!parent)
+	br = bridge_parent(out);
+	if (!br)
 		return NF_DROP;
 
-	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb))
+	parent = br->dev;
+
+	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb)) {
 		pf = NFPROTO_IPV4;
-	else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb))
+		if (!brnf_call_iptables && !br->nf_call_iptables)
+			return NF_ACCEPT;
+	} else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb)) {
 		pf = NFPROTO_IPV6;
-	else
+		if (!brnf_call_ip6tables && !br->nf_call_ip6tables)
+			return NF_ACCEPT;
+	} else
 		return NF_ACCEPT;
 
 	nf_bridge_pull_encap_header(skb);
@@ -877,20 +892,27 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 				       int (*okfn)(struct sk_buff *))
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
-	struct net_device *realoutdev = bridge_parent(skb->dev);
+	struct net_bridge *br = bridge_parent(skb->dev);
+	struct net_device *realoutdev;
 	u_int8_t pf;
 
 	if (!nf_bridge || !(nf_bridge->mask & BRNF_BRIDGED))
 		return NF_ACCEPT;
 
-	if (!realoutdev)
+	if (!br)
 		return NF_DROP;
 
-	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb))
+	realoutdev = br->dev;
+
+	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb)) {
 		pf = NFPROTO_IPV4;
-	else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb))
+		if (!brnf_call_iptables && !br->nf_call_iptables)
+			return NF_ACCEPT;
+	} else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb)) {
 		pf = NFPROTO_IPV6;
-	else
+		if (!brnf_call_ip6tables && !br->nf_call_ip6tables)
+			return NF_ACCEPT;
+	} else
 		return NF_ACCEPT;
 
 	/* We assume any code from br_dev_queue_push_xmit onwards doesn't care

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
