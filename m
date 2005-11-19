From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/10]: [NETFILTER]: Defer fragmentation in ip_output
 when connection tracking is used
Date: Sat, 19 Nov 2005 08:02:12 +0100
Message-ID: <437ECDF4.5090901@trash.net>
References: <43740DB5.9070206@trash.net>
	<20051115104425.GA31719@gondor.apana.org.au>
	<437BEAC8.40904@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010907070202020507070002"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Harald Welte <laforge@gnumonks.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <437BEAC8.40904@trash.net>
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

This is a multi-part message in MIME format.
--------------010907070202020507070002
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Herbert Xu wrote:
> 
>> On Fri, Nov 11, 2005 at 03:19:17AM +0000, Patrick McHardy wrote:
>>
>>> [NETFILTER]: Defer fragmentation in ip_output when connection 
>>> tracking is used
>>>
>> I'm slightly uneasy about this change because for POST_ROUTING, the
>> defragmentation occurs in the middle of the hook, NF_IP_PRI_NAT_SRC.
>>
>> This means that things like the mangle table currently sees the
>> fragments as opposed to the whole packet.  This patch will change
>> that.
>>
>> Now I'm not saying that this is necessarily a bad thing.  In fact,
>> for all I know it might make more sense to do this.  But we should
>> consider the possible implications before embarking on it.
> 
> 
> Good point. I would also prefer to have fragmentation occur after
> POST_ROUTING in all cases. Looking at the in-tree targets, it means
> loosing the ability to do a couple of things:
> 
> - CLASSIFY fragments differently
> - MARK fragments differently
> - DSCP/ECN/TOS mark fragments differently
> - Change TTLs of fragments to differently values
> 
> None of them seems very important. The DSCP and ECN targets were
> broken until not long ago without anyone noticing, the TTL target is
> relatively new. So it comes down to loosing the ability to classify
> fragments of one packet differently using iptables, which doesn't
> make much sense too me. In fact I think it would make classification
> easier if mangle would see the whole packet.

How about this patch that moves the POST_ROUTING hook before
fragmentation instead of defering it? Can anyone think of a
reason why mangle/POSTROUTING should see fragments?


--------------010907070202020507070002
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: Call POST_ROUTING hook before fragmentation

Call POST_ROUTING hook before fragmentation to get rid of the okfn use
in ip_refrag and save the useless fragmentation/defragmentation step
when NAT is used.

The patch introduces one user-visible change, the POSTROUTING chain
in the mangle table gets entire packets, not fragments, which should
simplify use of the MARK and CLASSIFY targets for queueing as a nice
side-effect.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 1bead31b7e969e00bc5c043d34f20f9edb12a961
tree 16b82a0bedbb29b6a709140a7047ce2d52bb776f
parent 6dafdbcbf8b78409e4767ae30766826f21300a9f
author Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 07:58:46 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 07:58:46 +0100

 include/net/ip.h                               |    1 -
 net/ipv4/ip_output.c                           |   30 +++++++++++-------------
 net/ipv4/netfilter/ip_conntrack_standalone.c   |   26 +--------------------
 net/ipv4/netfilter/ip_nat_standalone.c         |   17 --------------
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   26 +--------------------
 5 files changed, 16 insertions(+), 84 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index e4563bb..9f09882 100644
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
index 11c2f68..946e812 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -202,13 +202,11 @@ static inline int ip_finish_output2(stru
 
 static inline int ip_finish_output(struct sk_buff *skb)
 {
-	struct net_device *dev = skb->dst->dev;
-
-	skb->dev = dev;
-	skb->protocol = htons(ETH_P_IP);
-
-	return NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL, dev,
-		       ip_finish_output2);
+	if (skb->len > dst_mtu(skb->dst) &&
+	    !(skb_shinfo(skb)->ufo_size || skb_shinfo(skb)->tso_size))
+		return ip_fragment(skb, ip_finish_output2);
+	else
+		return ip_finish_output2(skb);
 }
 
 int ip_mc_output(struct sk_buff *skb)
@@ -265,21 +263,21 @@ int ip_mc_output(struct sk_buff *skb)
 				newskb->dev, ip_dev_loopback_xmit);
 	}
 
-	if (skb->len > dst_mtu(&rt->u.dst))
-		return ip_fragment(skb, ip_finish_output);
-	else
-		return ip_finish_output(skb);
+	return NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dev,
+		       ip_finish_output);
 }
 
 int ip_output(struct sk_buff *skb)
 {
+	struct net_device *dev = skb->dst->dev;
+
 	IP_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 
-	if (skb->len > dst_mtu(skb->dst) &&
-		!(skb_shinfo(skb)->ufo_size || skb_shinfo(skb)->tso_size))
-		return ip_fragment(skb, ip_finish_output);
-	else
-		return ip_finish_output(skb);
+	skb->dev = dev;
+	skb->protocol = htons(ETH_P_IP);
+
+	return NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL, dev,
+		       ip_finish_output);
 }
 
 int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
diff --git a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfilter/ip_conntrack_standalone.c
index dd476b1..13ed18a 100644
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
@@ -543,7 +519,7 @@ static struct nf_hook_ops ip_conntrack_h
 
 /* Refragmenter; last chance. */
 static struct nf_hook_ops ip_conntrack_out_ops = {
-	.hook		= ip_refrag,
+	.hook		= ip_confirm,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
 	.hooknum	= NF_IP_POST_ROUTING,
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index 30cd4e1..f04111f 100644
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -190,23 +190,6 @@ ip_nat_out(unsigned int hooknum,
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
-
 	return ip_nat_fn(hooknum, pskb, in, out, okfn);
 }
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 8202c1c..818ba72 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -180,30 +180,6 @@ static unsigned int ipv4_conntrack_defra
 	return NF_ACCEPT;
 }
 
-static unsigned int ipv4_refrag(unsigned int hooknum,
-				struct sk_buff **pskb,
-				const struct net_device *in,
-				const struct net_device *out,
-				int (*okfn)(struct sk_buff *))
-{
-	struct rtable *rt = (struct rtable *)(*pskb)->dst;
-
-	/* We've seen it coming out the other side: confirm */
-	if (ipv4_confirm(hooknum, pskb, in, out, okfn) != NF_ACCEPT)
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
 static unsigned int ipv4_conntrack_in(unsigned int hooknum,
 				      struct sk_buff **pskb,
 				      const struct net_device *in,
@@ -283,7 +259,7 @@ static struct nf_hook_ops ipv4_conntrack
 
 /* Refragmenter; last chance. */
 static struct nf_hook_ops ipv4_conntrack_out_ops = {
-	.hook		= ipv4_refrag,
+	.hook		= ipv4_confirm,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
 	.hooknum	= NF_IP_POST_ROUTING,

--------------010907070202020507070002--
