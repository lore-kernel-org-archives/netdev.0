From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter6: ICMPv6 type 143 doesn't match
Date: Fri, 06 May 2005 00:50:01 +0200
Message-ID: <427AA319.1040906@trash.net>
References: <OF647D617E.F01230B8-ON88256FF8.007AF1C9-88256FF8.007B457C@us.ibm.com>	<427A9EFF.5030907@trash.net>
	<20050505153118.0d26297c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000109000507000500000406"
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com,
	yasuyuki.kozakai@toshiba.co.jp,
	netfilter-devel@lists.netfilter.org, dlstevens@us.ibm.com,
	laforge@gnumonks.org, pb@bieringer.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050505153118.0d26297c.davem@davemloft.net>
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
--------------000109000507000500000406
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

David S. Miller wrote:
> On Fri, 06 May 2005 00:32:31 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>Is there a reason why these packets never hit the POST_ROUTING hook?
> 
> I think it is an oversight rather than intentional.
> 
> The NDISC lookup stuff wrt. routing went back and forth
> implementation wise.  We used to use a seperate routing
> table for NDISC entries, but that caused all kinds of
> problems wrt. IPSEC (which the seperate routing table
> was ironically meant to fix) so that got undone and now
> NDISC routes and normal routes exist in one table.
> 
> So I think this oversight is just fallout from all of
> those changes.

Thanks, I've added a call to NF_HOOK(NF_IP6_POST_ROUTING) to the patch.


--------------000109000507000500000406
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

Index: net/ipv6/mcast.c
===================================================================
--- 2cfdb1827d9c176f4df42619c693e7b990a61963/net/ipv6/mcast.c  (mode:100644 sha1:393b6e6f50a9626e2894c9a5abd8dafd903e5eba)
+++ uncommitted/net/ipv6/mcast.c  (mode:100644)
@@ -1280,15 +1280,6 @@
 		return NULL;
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
-	if (dev->hard_header) {
-		unsigned char ha[MAX_ADDR_LEN];
-
-		ndisc_mc_map(&mld2_all_mcr, ha, dev, 1);
-		if (dev->hard_header(skb, dev, ETH_P_IPV6,ha,NULL,size) < 0) {
-			kfree_skb(skb);
-			return NULL;
-		}
-	}
 
 	if (ipv6_get_lladdr(dev, &addr_buf)) {
 		/* <draft-ietf-magma-mld-source-05.txt>:
@@ -1312,6 +1303,31 @@
 	return skb;
 }
 
+static inline int mld_dev_queue_xmit2(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+
+	if (dev->hard_header) {
+		unsigned char ha[MAX_ADDR_LEN];
+		int err;
+
+		ndisc_mc_map(&skb->nh.ipv6h->daddr, ha, dev, 1);
+		err = dev->hard_header(skb, dev, ETH_P_IPV6, ha, NULL, skb->len);
+		if (err < 0) {
+			IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+			kfree_skb(skb);
+			return err;
+		}
+	}
+	return dev_queue_xmit(skb);
+}
+
+static inline int mld_dev_queue_xmit(struct sk_buff *skb)
+{
+	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL, skb->dev,
+	               mld_dev_queue_xmit2);
+}
+
 static void mld_sendpack(struct sk_buff *skb)
 {
 	struct ipv6hdr *pip6 = skb->nh.ipv6h;
@@ -1329,7 +1345,7 @@
 	pmr->csum = csum_ipv6_magic(&pip6->saddr, &pip6->daddr, mldlen,
 		IPPROTO_ICMPV6, csum_partial(skb->h.raw, mldlen, 0));
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
-		dev_queue_xmit);
+		mld_dev_queue_xmit);
 	if (!err) {
 		ICMP6_INC_STATS(idev,ICMP6_MIB_OUTMSGS);
 		IP6_INC_STATS(IPSTATS_MIB_OUTMCASTPKTS);
@@ -1635,12 +1651,6 @@
 	}
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
-	if (dev->hard_header) {
-		unsigned char ha[MAX_ADDR_LEN];
-		ndisc_mc_map(snd_addr, ha, dev, 1);
-		if (dev->hard_header(skb, dev, ETH_P_IPV6, ha, NULL, full_len) < 0)
-			goto out;
-	}
 
 	if (ipv6_get_lladdr(dev, &addr_buf)) {
 		/* <draft-ietf-magma-mld-source-05.txt>:
@@ -1668,7 +1678,7 @@
 	idev = in6_dev_get(skb->dev);
 
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
-		dev_queue_xmit);
+		mld_dev_queue_xmit);
 	if (!err) {
 		if (type == ICMPV6_MGM_REDUCTION)
 			ICMP6_INC_STATS(idev, ICMP6_MIB_OUTGROUPMEMBREDUCTIONS);
@@ -1682,10 +1692,6 @@
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
 	return;
-
-out:
-	IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
-	kfree_skb(skb);
 }
 
 static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,

--------------000109000507000500000406--
