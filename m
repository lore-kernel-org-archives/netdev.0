From: Patrick McHardy <kaber@trash.net>
Subject: [NF+IPsec 2/6]: Defer fragmentation in ip_output when connection
 tracking is used
Date: Mon, 17 Oct 2005 02:22:15 +0200
Message-ID: <4352EEB7.9030406@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="02.diff"
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Defer fragmentation in ip_output when connection tracking is used

This allows to get rid of the okfn use in ip_refrag and save the useless
fragmentation/defragmentation when NAT is used.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b8225d3928324d81a16b7d82c6c413005ac52c50
tree 9d8de6dd564153f586c1118854350e642fa75580
parent 12a6be7122de1d1039298adc6f401b3edf8788e5
author Patrick McHardy <kaber@trash.net> Sun, 16 Oct 2005 16:43:25 +0200
committer Patrick McHardy <kaber@trash.net> Sun, 16 Oct 2005 16:43:25 +0200

 include/linux/netfilter.h                    |    6 ++++++
 include/net/ip.h                             |    1 -
 net/ipv4/ip_output.c                         |   17 +++++++++++++---
 net/ipv4/netfilter/ip_conntrack_standalone.c |   27 +-------------------------
 net/ipv4/netfilter/ip_nat_standalone.c       |   19 ++----------------
 5 files changed, 23 insertions(+), 47 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -261,6 +261,11 @@ struct nf_queue_rerouter {
 extern int nf_register_queue_rerouter(int pf, struct nf_queue_rerouter *rer);
 extern int nf_unregister_queue_rerouter(int pf);
 
+static inline int nf_defer_fragment(struct sk_buff *skb)
+{
+	return skb->nfct != NULL;
+}
+
 #ifdef CONFIG_PROC_FS
 #include <linux/proc_fs.h>
 extern struct proc_dir_entry *proc_net_netfilter;
@@ -269,6 +274,7 @@ extern struct proc_dir_entry *proc_net_n
 #else /* !CONFIG_NETFILTER */
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
+static inline int nf_defer_fragment(struct sk_buff *skb) { return 0; }
 #endif /*CONFIG_NETFILTER*/
 
 #endif /*__KERNEL__*/
diff --git a/include/net/ip.h b/include/net/ip.h
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -310,7 +310,6 @@ enum ip_defrag_users
 	IP_DEFRAG_CALL_RA_CHAIN,
 	IP_DEFRAG_CONNTRACK_IN,
 	IP_DEFRAG_CONNTRACK_OUT,
-	IP_DEFRAG_NAT_OUT,
 	IP_DEFRAG_VS_IN,
 	IP_DEFRAG_VS_OUT,
 	IP_DEFRAG_VS_FWD
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -160,7 +160,7 @@ int ip_build_and_send_pkt(struct sk_buff
 
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
 
-static inline int ip_finish_output2(struct sk_buff *skb)
+static inline int ip_finish_output3(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct hh_cache *hh = dst->hh;
@@ -200,6 +200,16 @@ static inline int ip_finish_output2(stru
 	return -EINVAL;
 }
 
+static inline int ip_finish_output2(struct sk_buff *skb)
+{
+#ifdef CONFIG_NETFILTER
+	/* defered fragmentation when connection tracking is used */
+	if (skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->tso_size)
+		return ip_fragment(skb, ip_finish_output3);
+#endif
+	return ip_finish_output3(skb);
+}
+
 static inline int ip_finish_output(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dst->dev;
@@ -265,7 +275,7 @@ int ip_mc_output(struct sk_buff *skb)
 				newskb->dev, ip_dev_loopback_xmit);
 	}
 
-	if (skb->len > dst_mtu(&rt->u.dst))
+	if (skb->len > dst_mtu(&rt->u.dst) && !nf_defer_fragment(skb))
 		return ip_fragment(skb, ip_finish_output);
 	else
 		return ip_finish_output(skb);
@@ -275,7 +285,8 @@ int ip_output(struct sk_buff *skb)
 {
 	IP_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 
-	if (skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->tso_size)
+	if (skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->tso_size &&
+	    !nf_defer_fragment(skb))
 		return ip_fragment(skb, ip_finish_output);
 	else
 		return ip_finish_output(skb);
diff --git a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfilter/ip_conntrack_standalone.c
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c
@@ -450,30 +450,6 @@ static unsigned int ip_conntrack_defrag(
 	return NF_ACCEPT;
 }
 
-static unsigned int ip_refrag(unsigned int hooknum,
-			      struct sk_buff **pskb,
-			      const struct net_device *in,
-			      const struct net_device *out,
-			      int (*okfn)(struct sk_buff *))
-{
-	struct rtable *rt = (struct rtable *)(*pskb)->dst;
-
-	/* We've seen it coming out the other side: confirm */
-	if (ip_confirm(hooknum, pskb, in, out, okfn) != NF_ACCEPT)
-		return NF_DROP;
-
-	/* Local packets are never produced too large for their
-	   interface.  We degfragment them at LOCAL_OUT, however,
-	   so we have to refragment them here. */
-	if ((*pskb)->len > dst_mtu(&rt->u.dst) &&
-	    !skb_shinfo(*pskb)->tso_size) {
-		/* No hook can be after us, so this should be OK. */
-		ip_fragment(*pskb, okfn);
-		return NF_STOLEN;
-	}
-	return NF_ACCEPT;
-}
-
 static unsigned int ip_conntrack_local(unsigned int hooknum,
 				       struct sk_buff **pskb,
 				       const struct net_device *in,
@@ -541,9 +517,8 @@ static struct nf_hook_ops ip_conntrack_h
 	.priority	= NF_IP_PRI_CONNTRACK_HELPER,
 };
 
-/* Refragmenter; last chance. */
 static struct nf_hook_ops ip_conntrack_out_ops = {
-	.hook		= ip_refrag,
+	.hook		= ip_confirm,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
 	.hooknum	= NF_IP_POST_ROUTING,
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -69,7 +69,7 @@ ip_nat_fn(unsigned int hooknum,
 	enum ip_nat_manip_type maniptype = HOOK2MANIP(hooknum);
 
 	/* We never see fragments: conntrack defrags on pre-routing
-	   and local-out, and ip_nat_out protects post-routing. */
+	   and local-out. */
 	IP_NF_ASSERT(!((*pskb)->nh.iph->frag_off
 		       & htons(IP_MF|IP_OFFSET)));
 
@@ -190,22 +190,7 @@ ip_nat_out(unsigned int hooknum,
 	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	/* We can hit fragment here; forwarded packets get
-	   defragmented by connection tracking coming in, then
-	   fragmented (grr) by the forward code.
-
-	   In future: If we have nfct != NULL, AND we have NAT
-	   initialized, AND there is no helper, then we can do full
-	   NAPT on the head, and IP-address-only NAT on the rest.
-
-	   I'm starting to have nightmares about fragments.  */
-
-	if ((*pskb)->nh.iph->frag_off & htons(IP_MF|IP_OFFSET)) {
-		*pskb = ip_ct_gather_frags(*pskb, IP_DEFRAG_NAT_OUT);
-
-		if (!*pskb)
-			return NF_STOLEN;
-	}
+	WARN_ON((*pskb)->nh.iph->frag_off & htons(IP_MF|IP_OFFSET));
 
 	return ip_nat_fn(hooknum, pskb, in, out, okfn);
 }
