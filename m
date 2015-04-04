From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/9] netfilter: Use nf_hook_state in nf_queue_entry.
Date: Fri, 03 Apr 2015 22:07:48 -0400 (EDT)
Message-ID: <20150403.220748.881599362397267871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



That way we don't have to reinstantiate another nf_hook_state
on the stack of the nf_reinject() path.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/netfilter/nf_queue.h     |  6 +----
 net/ipv4/netfilter.c                 |  4 ++--
 net/ipv6/netfilter.c                 |  4 ++--
 net/netfilter/nf_queue.c             | 44 ++++++++++++++++--------------------
 net/netfilter/nfnetlink_queue_core.c | 30 ++++++++++++------------
 5 files changed, 39 insertions(+), 49 deletions(-)

diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index 84a53d7..d81d584 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -12,12 +12,8 @@ struct nf_queue_entry {
 	unsigned int		id;
 
 	struct nf_hook_ops	*elem;
-	u_int8_t		pf;
+	struct nf_hook_state	state;
 	u16			size; /* sizeof(entry) + saved route keys */
-	unsigned int		hook;
-	struct net_device	*indev;
-	struct net_device	*outdev;
-	int			(*okfn)(struct sk_buff *);
 
 	/* extra space to store route keys */
 };
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 7ebd6e3..65de068 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -94,7 +94,7 @@ static void nf_ip_saveroute(const struct sk_buff *skb,
 {
 	struct ip_rt_info *rt_info = nf_queue_entry_reroute(entry);
 
-	if (entry->hook == NF_INET_LOCAL_OUT) {
+	if (entry->state.hook == NF_INET_LOCAL_OUT) {
 		const struct iphdr *iph = ip_hdr(skb);
 
 		rt_info->tos = iph->tos;
@@ -109,7 +109,7 @@ static int nf_ip_reroute(struct sk_buff *skb,
 {
 	const struct ip_rt_info *rt_info = nf_queue_entry_reroute(entry);
 
-	if (entry->hook == NF_INET_LOCAL_OUT) {
+	if (entry->state.hook == NF_INET_LOCAL_OUT) {
 		const struct iphdr *iph = ip_hdr(skb);
 
 		if (!(iph->tos == rt_info->tos &&
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 398377a..d958718 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -84,7 +84,7 @@ static void nf_ip6_saveroute(const struct sk_buff *skb,
 {
 	struct ip6_rt_info *rt_info = nf_queue_entry_reroute(entry);
 
-	if (entry->hook == NF_INET_LOCAL_OUT) {
+	if (entry->state.hook == NF_INET_LOCAL_OUT) {
 		const struct ipv6hdr *iph = ipv6_hdr(skb);
 
 		rt_info->daddr = iph->daddr;
@@ -98,7 +98,7 @@ static int nf_ip6_reroute(struct sk_buff *skb,
 {
 	struct ip6_rt_info *rt_info = nf_queue_entry_reroute(entry);
 
-	if (entry->hook == NF_INET_LOCAL_OUT) {
+	if (entry->state.hook == NF_INET_LOCAL_OUT) {
 		const struct ipv6hdr *iph = ipv6_hdr(skb);
 		if (!ipv6_addr_equal(&iph->daddr, &rt_info->daddr) ||
 		    !ipv6_addr_equal(&iph->saddr, &rt_info->saddr) ||
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 6f8e948..d3cd37e 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -47,11 +47,13 @@ EXPORT_SYMBOL(nf_unregister_queue_handler);
 
 void nf_queue_entry_release_refs(struct nf_queue_entry *entry)
 {
+	struct nf_hook_state *state = &entry->state;
+
 	/* Release those devices we held, or Alexey will kill me. */
-	if (entry->indev)
-		dev_put(entry->indev);
-	if (entry->outdev)
-		dev_put(entry->outdev);
+	if (state->in)
+		dev_put(state->in);
+	if (state->out)
+		dev_put(state->out);
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (entry->skb->nf_bridge) {
 		struct nf_bridge_info *nf_bridge = entry->skb->nf_bridge;
@@ -70,13 +72,15 @@ EXPORT_SYMBOL_GPL(nf_queue_entry_release_refs);
 /* Bump dev refs so they don't vanish while packet is out */
 bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
 {
+	struct nf_hook_state *state = &entry->state;
+
 	if (!try_module_get(entry->elem->owner))
 		return false;
 
-	if (entry->indev)
-		dev_hold(entry->indev);
-	if (entry->outdev)
-		dev_hold(entry->outdev);
+	if (state->in)
+		dev_hold(state->in);
+	if (state->out)
+		dev_hold(state->out);
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (entry->skb->nf_bridge) {
 		struct nf_bridge_info *nf_bridge = entry->skb->nf_bridge;
@@ -131,11 +135,7 @@ int nf_queue(struct sk_buff *skb,
 	*entry = (struct nf_queue_entry) {
 		.skb	= skb,
 		.elem	= elem,
-		.pf	= state->pf,
-		.hook	= state->hook,
-		.indev	= state->in,
-		.outdev	= state->out,
-		.okfn	= state->okfn,
+		.state	= *state,
 		.size	= sizeof(*entry) + afinfo->route_key_size,
 	};
 
@@ -168,7 +168,6 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	struct sk_buff *skb = entry->skb;
 	struct nf_hook_ops *elem = entry->elem;
 	const struct nf_afinfo *afinfo;
-	struct nf_hook_state state;
 	int err;
 
 	rcu_read_lock();
@@ -182,33 +181,28 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	}
 
 	if (verdict == NF_ACCEPT) {
-		afinfo = nf_get_afinfo(entry->pf);
+		afinfo = nf_get_afinfo(entry->state.pf);
 		if (!afinfo || afinfo->reroute(skb, entry) < 0)
 			verdict = NF_DROP;
 	}
 
-	state.hook = entry->hook;
-	state.thresh = INT_MIN;
-	state.pf = entry->pf;
-	state.in = entry->indev;
-	state.out = entry->outdev;
-	state.okfn = entry->okfn;
+	entry->state.thresh = INT_MIN;
 
 	if (verdict == NF_ACCEPT) {
 	next_hook:
-		verdict = nf_iterate(&nf_hooks[entry->pf][entry->hook],
-				     skb, &state, &elem);
+		verdict = nf_iterate(&nf_hooks[entry->state.pf][entry->state.hook],
+				     skb, &entry->state, &elem);
 	}
 
 	switch (verdict & NF_VERDICT_MASK) {
 	case NF_ACCEPT:
 	case NF_STOP:
 		local_bh_disable();
-		entry->okfn(skb);
+		entry->state.okfn(skb);
 		local_bh_enable();
 		break;
 	case NF_QUEUE:
-		err = nf_queue(skb, elem, &state,
+		err = nf_queue(skb, elem, &entry->state,
 			       verdict >> NF_VERDICT_QBITS);
 		if (err < 0) {
 			if (err == -ECANCELED)
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 86ee8b0..6e74655 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -314,13 +314,13 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	if (entskb->tstamp.tv64)
 		size += nla_total_size(sizeof(struct nfqnl_msg_packet_timestamp));
 
-	if (entry->hook <= NF_INET_FORWARD ||
-	   (entry->hook == NF_INET_POST_ROUTING && entskb->sk == NULL))
+	if (entry->state.hook <= NF_INET_FORWARD ||
+	   (entry->state.hook == NF_INET_POST_ROUTING && entskb->sk == NULL))
 		csum_verify = !skb_csum_unnecessary(entskb);
 	else
 		csum_verify = false;
 
-	outdev = entry->outdev;
+	outdev = entry->state.out;
 
 	switch ((enum nfqnl_config_mode)ACCESS_ONCE(queue->copy_mode)) {
 	case NFQNL_COPY_META:
@@ -368,23 +368,23 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		return NULL;
 	}
 	nfmsg = nlmsg_data(nlh);
-	nfmsg->nfgen_family = entry->pf;
+	nfmsg->nfgen_family = entry->state.pf;
 	nfmsg->version = NFNETLINK_V0;
 	nfmsg->res_id = htons(queue->queue_num);
 
 	nla = __nla_reserve(skb, NFQA_PACKET_HDR, sizeof(*pmsg));
 	pmsg = nla_data(nla);
 	pmsg->hw_protocol	= entskb->protocol;
-	pmsg->hook		= entry->hook;
+	pmsg->hook		= entry->state.hook;
 	*packet_id_ptr		= &pmsg->packet_id;
 
-	indev = entry->indev;
+	indev = entry->state.in;
 	if (indev) {
 #if !IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 		if (nla_put_be32(skb, NFQA_IFINDEX_INDEV, htonl(indev->ifindex)))
 			goto nla_put_failure;
 #else
-		if (entry->pf == PF_BRIDGE) {
+		if (entry->state.pf == PF_BRIDGE) {
 			/* Case 1: indev is physical input device, we need to
 			 * look for bridge group (when called from
 			 * netfilter_bridge) */
@@ -414,7 +414,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		if (nla_put_be32(skb, NFQA_IFINDEX_OUTDEV, htonl(outdev->ifindex)))
 			goto nla_put_failure;
 #else
-		if (entry->pf == PF_BRIDGE) {
+		if (entry->state.pf == PF_BRIDGE) {
 			/* Case 1: outdev is physical output device, we need to
 			 * look for bridge group (when called from
 			 * netfilter_bridge) */
@@ -633,8 +633,8 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	struct nfqnl_instance *queue;
 	struct sk_buff *skb, *segs;
 	int err = -ENOBUFS;
-	struct net *net = dev_net(entry->indev ?
-				  entry->indev : entry->outdev);
+	struct net *net = dev_net(entry->state.in ?
+				  entry->state.in : entry->state.out);
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 
 	/* rcu_read_lock()ed by nf_hook_slow() */
@@ -647,7 +647,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 
 	skb = entry->skb;
 
-	switch (entry->pf) {
+	switch (entry->state.pf) {
 	case NFPROTO_IPV4:
 		skb->protocol = htons(ETH_P_IP);
 		break;
@@ -757,11 +757,11 @@ nfqnl_set_mode(struct nfqnl_instance *queue,
 static int
 dev_cmp(struct nf_queue_entry *entry, unsigned long ifindex)
 {
-	if (entry->indev)
-		if (entry->indev->ifindex == ifindex)
+	if (entry->state.in)
+		if (entry->state.in->ifindex == ifindex)
 			return 1;
-	if (entry->outdev)
-		if (entry->outdev->ifindex == ifindex)
+	if (entry->state.out)
+		if (entry->state.out->ifindex == ifindex)
 			return 1;
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (entry->skb->nf_bridge) {
-- 
2.1.0

