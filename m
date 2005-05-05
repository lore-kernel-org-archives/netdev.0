From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter6: ICMPv6 type 143 doesn't match
Date: Thu, 05 May 2005 22:20:05 +0200
Message-ID: <427A7FF5.4030900@trash.net>
References: <6050E336B1A0D7D8E70C66F3@t1mobil.muc.aerasec.de>	<200412270417.iBR4HZRG021429@toshiba.co.jp>
	<427A79C0.4020103@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010408040000090202080001"
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org, laforge@gnumonks.org, pb@bieringer.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <427A79C0.4020103@trash.net>
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
--------------010408040000090202080001
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Yasuyuki Kozakai wrote:
> 
>>Well, the Multicast Listener Report seems that skb->data != skb->nh.ipv6h
>>when interface is up. But IPv6 netfilter modules assumes that
>>skb->data == skb->nh.ipv6h like IPv4 netfilter modules.
>>
>>folks, is this wrong or bad asumption ? If so, I'll fix this problem in
>>many modules as follows.
> 
> 
> Sorry for getting back to this so late, I must have missed it at the
> time. Anyway, I think it would be safer to restore netfilters assumption
> by doing something like this patch. If everyone is fine with it I'm
> going to add it to my pending netfilter patches for 2.6.13.

The last patch left some unreachable code.


--------------010408040000090202080001
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
@@ -1312,6 +1303,25 @@
 	return skb;
 }
 
+static inline int igmp6_dev_queue_xmit(struct sk_buff *skb)
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
 static void mld_sendpack(struct sk_buff *skb)
 {
 	struct ipv6hdr *pip6 = skb->nh.ipv6h;
@@ -1329,7 +1339,7 @@
 	pmr->csum = csum_ipv6_magic(&pip6->saddr, &pip6->daddr, mldlen,
 		IPPROTO_ICMPV6, csum_partial(skb->h.raw, mldlen, 0));
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
-		dev_queue_xmit);
+		igmp6_dev_queue_xmit);
 	if (!err) {
 		ICMP6_INC_STATS(idev,ICMP6_MIB_OUTMSGS);
 		IP6_INC_STATS(IPSTATS_MIB_OUTMCASTPKTS);
@@ -1635,12 +1645,6 @@
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
@@ -1668,7 +1672,7 @@
 	idev = in6_dev_get(skb->dev);
 
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
-		dev_queue_xmit);
+		igmp6_dev_queue_xmit);
 	if (!err) {
 		if (type == ICMPV6_MGM_REDUCTION)
 			ICMP6_INC_STATS(idev, ICMP6_MIB_OUTGROUPMEMBREDUCTIONS);
@@ -1682,10 +1686,6 @@
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
 	return;
-
-out:
-	IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
-	kfree_skb(skb);
 }
 
 static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,

--------------010408040000090202080001--
