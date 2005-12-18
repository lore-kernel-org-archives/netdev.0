From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Sun, 18 Dec 2005 15:27:01 +0100
Message-ID: <43A571B5.205@trash.net>
References: <4381F4C7.9070903@trash.net>	<43826F77.7040502@miyazawa.org>	<438270F2.3000603@trash.net>
	<20051123.193824.38162996.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010907010406080305040606"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net, kozakai@linux-ipv6.org, kazunori@miyazawa.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20051123.193824.38162996.yoshfuji@linux-ipv6.org>
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
--------------010907010406080305040606
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

YOSHIFUJI Hideaki / $B5HF#1QL@ wrote:
> In article <438270F2.3000603@trash.net> (at Tue, 22 Nov 2005 02:14:26 +0100), Patrick McHardy <kaber@trash.net> says:
> 
> 
>>The easiest way would be to store nhoff somewhere in the skb and
>>use it to continue at the next header. But I still hope there is
>>a way without keeping data in the skb.
> 
> 
> We've coded up this.

How about this patch instead? It eliminates the nhoffp argument
to IPv6 protocol handlers by storing it in the IP6CB, which allows
to call ip6_input_finish a second time and have it skip already
parsed headers and also gets rid of the manual hopopts skipping.

> Though we have still another issue (call chain issue) to resolve,
> we're getting closer to the goal.
> i.e. we should continue the loop for common case.

I'll look into this now.

--------------010907010406080305040606
Content-Type: text/x-patch;
 name="04.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04.diff"

[IPv6]: Move nextheader offset to the IP6CB

Move nextheader offset to the IP6CB to make it possible to pass a
packet to ip6_input_finish multiple times and have it skip already
parsed headers. As a nice side-effect this gets rid of the manual
hopopts skipping.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 6678dcab480a4c410fe7984c43a9d1830c9b9912
tree 5eb3a8f6f5379c5f2b91af6d37dab9ca880681ae
parent 4cd76cb0703ffcb89d6c49e4d9171d7b6a116cd9
author Patrick McHardy <kaber@trash.net> Sun, 18 Dec 2005 06:52:02 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 18 Dec 2005 06:52:02 +0100

 include/linux/ipv6.h    |    1 +
 include/net/protocol.h  |    2 +-
 include/net/xfrm.h      |    6 +++---
 net/dccp/ipv6.c         |    2 +-
 net/ipv6/exthdrs.c      |   19 ++++++++++++-------
 net/ipv6/icmp.c         |    4 ++--
 net/ipv6/ip6_input.c    |   21 ++++++---------------
 net/ipv6/ip6_tunnel.c   |    2 +-
 net/ipv6/reassembly.c   |   11 +++++------
 net/ipv6/tcp_ipv6.c     |    2 +-
 net/ipv6/udp.c          |    2 +-
 net/ipv6/xfrm6_input.c  |    8 ++++----
 net/ipv6/xfrm6_tunnel.c |    6 +++---
 net/sctp/ipv6.c         |    2 +-
 14 files changed, 42 insertions(+), 46 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index a0d0489..04bd248 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -190,6 +190,7 @@ struct inet6_skb_parm {
 	__u16			srcrt;
 	__u16			dst1;
 	__u16			lastopt;
+	__u32			nhoff;
 };
 
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
diff --git a/include/net/protocol.h b/include/net/protocol.h
index a29cb29..7006a25 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -43,7 +43,7 @@ struct net_protocol {
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 struct inet6_protocol 
 {
-	int	(*handler)(struct sk_buff **skb, unsigned int *nhoffp);
+	int	(*handler)(struct sk_buff **skb);
 
 	void	(*err_handler)(struct sk_buff *skb,
 			       struct inet6_skb_parm *opt,
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f327cb3..1b2876c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -830,7 +830,7 @@ struct xfrm_tunnel {
 };
 
 struct xfrm6_tunnel {
-	int (*handler)(struct sk_buff **pskb, unsigned int *nhoffp);
+	int (*handler)(struct sk_buff **pskb);
 	void (*err_handler)(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			    int type, int code, int offset, __u32 info);
 };
@@ -867,8 +867,8 @@ extern int xfrm4_rcv(struct sk_buff *skb
 extern int xfrm4_output(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
-extern int xfrm6_rcv_spi(struct sk_buff **pskb, unsigned int *nhoffp, u32 spi);
-extern int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp);
+extern int xfrm6_rcv_spi(struct sk_buff **pskb, u32 spi);
+extern int xfrm6_rcv(struct sk_buff **pskb);
 extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler);
 extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler);
 extern u32 xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 599b0be..67518c5 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1027,7 +1027,7 @@ discard:
 	return 0;
 }
 
-static int dccp_v6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
+static int dccp_v6_rcv(struct sk_buff **pskb)
 {
 	const struct dccp_hdr *dh;
 	struct sk_buff *skb = *pskb;
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 113374d..2a1e7e4 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -152,7 +152,7 @@ static struct tlvtype_proc tlvprocdestop
 	{-1,			NULL}
 };
 
-static int ipv6_destopt_rcv(struct sk_buff **skbp, unsigned int *nhoffp)
+static int ipv6_destopt_rcv(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp;
 	struct inet6_skb_parm *opt = IP6CB(skb);
@@ -169,7 +169,7 @@ static int ipv6_destopt_rcv(struct sk_bu
 
 	if (ip6_parse_tlv(tlvprocdestopt_lst, skb)) {
 		skb->h.raw += ((skb->h.raw[1]+1)<<3);
-		*nhoffp = opt->dst1;
+		opt->nhoff = opt->dst1;
 		return 1;
 	}
 
@@ -192,7 +192,7 @@ void __init ipv6_destopt_init(void)
   NONE header. No data in packet.
  ********************************/
 
-static int ipv6_nodata_rcv(struct sk_buff **skbp, unsigned int *nhoffp)
+static int ipv6_nodata_rcv(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp;
 
@@ -215,7 +215,7 @@ void __init ipv6_nodata_init(void)
   Routing header.
  ********************************/
 
-static int ipv6_rthdr_rcv(struct sk_buff **skbp, unsigned int *nhoffp)
+static int ipv6_rthdr_rcv(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp;
 	struct inet6_skb_parm *opt = IP6CB(skb);
@@ -249,7 +249,7 @@ looped_back:
 		skb->h.raw += (hdr->hdrlen + 1) << 3;
 		opt->dst0 = opt->dst1;
 		opt->dst1 = 0;
-		*nhoffp = (&hdr->nexthdr) - skb->nh.raw;
+		opt->nhoff = (&hdr->nexthdr) - skb->nh.raw;
 		return 1;
 	}
 
@@ -487,9 +487,14 @@ static struct tlvtype_proc tlvprochopopt
 
 int ipv6_parse_hopopts(struct sk_buff *skb, int nhoff)
 {
-	IP6CB(skb)->hop = sizeof(struct ipv6hdr);
-	if (ip6_parse_tlv(tlvprochopopt_lst, skb))
+	struct inet6_skb_parm *opt = IP6CB(skb);
+
+	opt->hop = sizeof(struct ipv6hdr);
+	if (ip6_parse_tlv(tlvprochopopt_lst, skb)) {
+		skb->h.raw += (skb->h.raw[1]+1)<<3;
+		opt->nhoff = sizeof(struct ipv6hdr);
 		return sizeof(struct ipv6hdr);
+	}
 	return -1;
 }
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 34a3322..d415c00 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -79,7 +79,7 @@ DEFINE_SNMP_STAT(struct icmpv6_mib, icmp
 static DEFINE_PER_CPU(struct socket *, __icmpv6_socket) = NULL;
 #define icmpv6_socket	__get_cpu_var(__icmpv6_socket)
 
-static int icmpv6_rcv(struct sk_buff **pskb, unsigned int *nhoffp);
+static int icmpv6_rcv(struct sk_buff **pskb);
 
 static struct inet6_protocol icmpv6_protocol = {
 	.handler	=	icmpv6_rcv,
@@ -569,7 +569,7 @@ static void icmpv6_notify(struct sk_buff
  *	Handle icmp messages
  */
 
-static int icmpv6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
+static int icmpv6_rcv(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
 	struct net_device *dev = skb->dev;
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index a6026d2..13d7241 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -97,6 +97,9 @@ int ipv6_rcv(struct sk_buff *skb, struct
 	if (hdr->version != 6)
 		goto err;
 
+	skb->h.raw = (u8 *)(hdr + 1);
+	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
+
 	pkt_len = ntohs(hdr->payload_len);
 
 	/* pkt_len may be zero if Jumbo payload option is present */
@@ -111,8 +114,7 @@ int ipv6_rcv(struct sk_buff *skb, struct
 	}
 
 	if (hdr->nexthdr == NEXTHDR_HOP) {
-		skb->h.raw = (u8*)(hdr+1);
-		if (ipv6_parse_hopopts(skb, offsetof(struct ipv6hdr, nexthdr)) < 0) {
+		if (ipv6_parse_hopopts(skb, IP6CB(skb)->nhoff) < 0) {
 			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
 			return 0;
 		}
@@ -143,26 +145,15 @@ static inline int ip6_input_finish(struc
 	int nexthdr;
 	u8 hash;
 
-	skb->h.raw = skb->nh.raw + sizeof(struct ipv6hdr);
-
 	/*
 	 *	Parse extension headers
 	 */
 
-	nexthdr = skb->nh.ipv6h->nexthdr;
-	nhoff = offsetof(struct ipv6hdr, nexthdr);
-
-	/* Skip hop-by-hop options, they are already parsed. */
-	if (nexthdr == NEXTHDR_HOP) {
-		nhoff = sizeof(struct ipv6hdr);
-		nexthdr = skb->h.raw[0];
-		skb->h.raw += (skb->h.raw[1]+1)<<3;
-	}
-
 	rcu_read_lock();
 resubmit:
 	if (!pskb_pull(skb, skb->h.raw - skb->data))
 		goto discard;
+	nhoff = IP6CB(skb)->nhoff;
 	nexthdr = skb->nh.raw[nhoff];
 
 	raw_sk = sk_head(&raw_v6_htable[nexthdr & (MAX_INET_PROTOS - 1)]);
@@ -194,7 +185,7 @@ resubmit:
 		    !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) 
 			goto discard;
 		
-		ret = ipprot->handler(&skb, &nhoff);
+		ret = ipprot->handler(&skb);
 		if (ret > 0)
 			goto resubmit;
 		else if (ret == 0)
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index e315d0f..f079621 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -510,7 +510,7 @@ static inline void ip6ip6_ecn_decapsulat
  **/
 
 static int 
-ip6ip6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
+ip6ip6_rcv(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
 	struct ipv6hdr *ipv6h;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 5d316cb..15e1456 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -581,7 +581,6 @@ err:
  *	the last and the first frames arrived and all the bits are here.
  */
 static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff **skb_in,
-			  unsigned int *nhoffp,
 			  struct net_device *dev)
 {
 	struct sk_buff *fp, *head = fq->fragments;
@@ -654,6 +653,7 @@ static int ip6_frag_reasm(struct frag_qu
 	head->dev = dev;
 	skb_set_timestamp(head, &fq->stamp);
 	head->nh.ipv6h->payload_len = htons(payload_len);
+	IP6CB(head)->nhoff = nhoff;
 
 	*skb_in = head;
 
@@ -663,7 +663,6 @@ static int ip6_frag_reasm(struct frag_qu
 
 	IP6_INC_STATS_BH(IPSTATS_MIB_REASMOKS);
 	fq->fragments = NULL;
-	*nhoffp = nhoff;
 	return 1;
 
 out_oversize:
@@ -678,7 +677,7 @@ out_fail:
 	return -1;
 }
 
-static int ipv6_frag_rcv(struct sk_buff **skbp, unsigned int *nhoffp)
+static int ipv6_frag_rcv(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp; 
 	struct net_device *dev = skb->dev;
@@ -710,7 +709,7 @@ static int ipv6_frag_rcv(struct sk_buff 
 		skb->h.raw += sizeof(struct frag_hdr);
 		IP6_INC_STATS_BH(IPSTATS_MIB_REASMOKS);
 
-		*nhoffp = (u8*)fhdr - skb->nh.raw;
+		IP6CB(skb)->nhoff = (u8*)fhdr - skb->nh.raw;
 		return 1;
 	}
 
@@ -722,11 +721,11 @@ static int ipv6_frag_rcv(struct sk_buff 
 
 		spin_lock(&fq->lock);
 
-		ip6_frag_queue(fq, skb, fhdr, *nhoffp);
+		ip6_frag_queue(fq, skb, fhdr, IP6CB(skb)->nhoff);
 
 		if (fq->last_in == (FIRST_IN|LAST_IN) &&
 		    fq->meat == fq->len)
-			ret = ip6_frag_reasm(fq, skbp, nhoffp, dev);
+			ret = ip6_frag_reasm(fq, skbp, dev);
 
 		spin_unlock(&fq->lock);
 		fq_put(fq, NULL);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2947bc5..a25f4e8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1153,7 +1153,7 @@ ipv6_pktoptions:
 	return 0;
 }
 
-static int tcp_v6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
+static int tcp_v6_rcv(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
 	struct tcphdr *th;	
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d8538dc..c476488 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -435,7 +435,7 @@ out:
 	read_unlock(&udp_hash_lock);
 }
 
-static int udpv6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
+static int udpv6_rcv(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
 	struct sock *sk;
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 28c29d7..1079e47 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -26,7 +26,7 @@ static inline void ipip6_ecn_decapsulate
 		IP6_ECN_set_ce(inner_iph);
 }
 
-int xfrm6_rcv_spi(struct sk_buff **pskb, unsigned int *nhoffp, u32 spi)
+int xfrm6_rcv_spi(struct sk_buff **pskb, u32 spi)
 {
 	struct sk_buff *skb = *pskb;
 	int err;
@@ -38,7 +38,7 @@ int xfrm6_rcv_spi(struct sk_buff **pskb,
 	int nexthdr;
 	unsigned int nhoff;
 
-	nhoff = *nhoffp;
+	nhoff = IP6CB(skb)->nhoff;
 	nexthdr = skb->nh.raw[nhoff];
 
 	seq = 0;
@@ -144,7 +144,7 @@ drop:
 
 EXPORT_SYMBOL(xfrm6_rcv_spi);
 
-int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
+int xfrm6_rcv(struct sk_buff **pskb)
 {
-	return xfrm6_rcv_spi(pskb, nhoffp, 0);
+	return xfrm6_rcv_spi(pskb, 0);
 }
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index fbef782..da09ff2 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -397,7 +397,7 @@ int xfrm6_tunnel_deregister(struct xfrm6
 
 EXPORT_SYMBOL(xfrm6_tunnel_deregister);
 
-static int xfrm6_tunnel_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
+static int xfrm6_tunnel_rcv(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
 	struct xfrm6_tunnel *handler = xfrm6_tunnel_handler;
@@ -405,11 +405,11 @@ static int xfrm6_tunnel_rcv(struct sk_bu
 	u32 spi;
 
 	/* device-like_ip6ip6_handler() */
-	if (handler && handler->handler(pskb, nhoffp) == 0)
+	if (handler && handler->handler(pskb) == 0)
 		return 0;
 
 	spi = xfrm6_tunnel_spi_lookup((xfrm_address_t *)&iph->saddr);
-	return xfrm6_rcv_spi(pskb, nhoffp, spi);
+	return xfrm6_rcv_spi(pskb, spi);
 }
 
 static void xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index fa3be2b..bb8f8cf 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -905,7 +905,7 @@ static struct inet_protosw sctpv6_stream
 	.flags         = SCTP_PROTOSW_FLAG,
 };
 
-static int sctp6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
+static int sctp6_rcv(struct sk_buff **pskb)
 {
 	return sctp_rcv(*pskb) ? -1 : 0;
 }

--------------010907010406080305040606--
