From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV4] Make ipt_REJECT use icmp_send again
Date: Wed, 16 Mar 2005 21:51:00 +1100
Message-ID: <20050316105100.GA8404@gondor.apana.org.au>
References: <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050315100522.GA7275@gondor.apana.org.au> <20050315102450.0f3f1618.davem@davemloft.net> <42373142.6090902@trash.net> <20050315204006.GB22349@gondor.apana.org.au> <42374A35.6020308@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6TrnltStXW4iwmi0"
Cc: "David S. Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42374A35.6020308@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Mar 15, 2005 at 09:48:53PM +0100, Patrick McHardy wrote:
> 
> Ok. I can't see any different reason to keep it, so go ahead. I'll take
> care of the xrlim stuff later.

Great.  Here is the patch that makes ipt_REJECT use icmp_send again.
We've gone full circle :)

As it is ipt_REJECT doesn't work at all with IPsec.  Despite my efforts
previously in making the policy lookups work there I neglected to change
the final call to dst_output so the policy lookup is useless.

ipt_REJECT also had a number of deviations from icmp_send which seems to
be unjustified.  For examples it ignored source routing IP options.

There was a bug in icmp_send too :) It didn't set the ICMP type/code
values for the policy lookup.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I compared the two functions line-by-line to make sure that there
weren't any subtle differences.  Please double check this in case
I overlooked something important.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-18

===== net/ipv4/icmp.c 1.50 vs edited =====
--- 1.50/net/ipv4/icmp.c	2005-03-15 16:26:11 +11:00
+++ edited/net/ipv4/icmp.c	2005-03-16 21:20:41 +11:00
@@ -518,14 +518,6 @@
 					   IPTOS_PREC_INTERNETCONTROL) :
 					  iph->tos;
 
-	{
-		struct flowi fl = { .nl_u = { .ip4_u = { .daddr = iph->saddr,
-							 .saddr = saddr,
-							 .tos = RT_TOS(tos) } },
-				    .proto = IPPROTO_ICMP };
-		if (ip_route_output_key(&rt, &fl))
-		    goto out_unlock;
-	}
 	if (ip_options_echo(&icmp_param.replyopts, skb_in))
 		goto ende;
 
@@ -544,13 +536,26 @@
 	inet_sk(icmp_socket->sk)->tos = tos;
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param.replyopts;
-	if (icmp_param.replyopts.srr) {
-		struct flowi fl = { .nl_u = { .ip4_u =
-					      { .daddr = icmp_param.replyopts.faddr,
-						.saddr = saddr,
-						.tos = RT_TOS(tos) } },
-				    .proto = IPPROTO_ICMP };
-		ip_rt_put(rt);
+
+	{
+		struct flowi fl = {
+			.nl_u = {
+				.ip4_u = {
+					.daddr = icmp_param.replyopts.srr ?
+						icmp_param.replyopts.faddr :
+						iph->saddr,
+					.saddr = saddr,
+					.tos = RT_TOS(tos)
+				}
+			},
+			.proto = IPPROTO_ICMP,
+			.uli_u = {
+				.icmpt = {
+					.type = type,
+					.code = code
+				}
+			}
+		};
 		if (ip_route_output_key(&rt, &fl))
 			goto out_unlock;
 	}
===== net/ipv4/netfilter/ipt_REJECT.c 1.35 vs edited =====
--- 1.35/net/ipv4/netfilter/ipt_REJECT.c	2005-03-04 09:20:32 +11:00
+++ edited/net/ipv4/netfilter/ipt_REJECT.c	2005-03-16 21:19:20 +11:00
@@ -220,146 +220,9 @@
 	kfree_skb(nskb);
 }
 
-static void send_unreach(struct sk_buff *skb_in, int code)
+static inline void send_unreach(struct sk_buff *skb_in, int code)
 {
-	struct iphdr *iph;
-	struct icmphdr *icmph;
-	struct sk_buff *nskb;
-	u32 saddr;
-	u8 tos;
-	int hh_len, length;
-	struct rtable *rt = (struct rtable*)skb_in->dst;
-	unsigned char *data;
-
-	if (!rt)
-		return;
-
-	/* FIXME: Use sysctl number. --RR */
-	if (!xrlim_allow(&rt->u.dst, 1*HZ))
-		return;
-
-	iph = skb_in->nh.iph;
-
-	/* No replies to physical multicast/broadcast */
-	if (skb_in->pkt_type!=PACKET_HOST)
-		return;
-
-	/* Now check at the protocol level */
-	if (rt->rt_flags&(RTCF_BROADCAST|RTCF_MULTICAST))
-		return;
-
-	/* Only reply to fragment 0. */
-	if (iph->frag_off&htons(IP_OFFSET))
-		return;
-
-	/* If we send an ICMP error to an ICMP error a mess would result.. */
-	if (iph->protocol == IPPROTO_ICMP) {
-		struct icmphdr ihdr;
-
-		icmph = skb_header_pointer(skb_in, skb_in->nh.iph->ihl*4,
-					   sizeof(ihdr), &ihdr);
-		if (!icmph)
-			return;
-
-		/* Between echo-reply (0) and timestamp (13),
-		   everything except echo-request (8) is an error.
-		   Also, anything greater than NR_ICMP_TYPES is
-		   unknown, and hence should be treated as an error... */
-		if ((icmph->type < ICMP_TIMESTAMP
-		     && icmph->type != ICMP_ECHOREPLY
-		     && icmph->type != ICMP_ECHO)
-		    || icmph->type > NR_ICMP_TYPES)
-			return;
-	}
-
-	saddr = iph->daddr;
-	if (!(rt->rt_flags & RTCF_LOCAL))
-		saddr = 0;
-
-	tos = (iph->tos & IPTOS_TOS_MASK) | IPTOS_PREC_INTERNETCONTROL;
-
-	{
-		struct flowi fl = {
-			.nl_u = {
-				.ip4_u = {
-					.daddr = skb_in->nh.iph->saddr,
-					.saddr = saddr,
-					.tos = RT_TOS(tos)
-				}
-			},
-			.proto = IPPROTO_ICMP,
-			.uli_u = {
-				.icmpt = {
-					.type = ICMP_DEST_UNREACH,
-					.code = code
-				}
-			}
-		};
-
-		if (ip_route_output_key(&rt, &fl))
-			return;
-	}
-	/* RFC says return as much as we can without exceeding 576 bytes. */
-	length = skb_in->len + sizeof(struct iphdr) + sizeof(struct icmphdr);
-
-	if (length > dst_pmtu(&rt->u.dst))
-		length = dst_pmtu(&rt->u.dst);
-	if (length > 576)
-		length = 576;
-
-	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
-
-	nskb = alloc_skb(hh_len + length, GFP_ATOMIC);
-	if (!nskb) {
-		ip_rt_put(rt);
-		return;
-	}
-
-	nskb->priority = 0;
-	nskb->dst = &rt->u.dst;
-	skb_reserve(nskb, hh_len);
-
-	/* Set up IP header */
-	iph = nskb->nh.iph
-		= (struct iphdr *)skb_put(nskb, sizeof(struct iphdr));
-	iph->version=4;
-	iph->ihl=5;
-	iph->tos=tos;
-	iph->tot_len = htons(length);
-
-	/* PMTU discovery never applies to ICMP packets. */
-	iph->frag_off = 0;
-
-	iph->ttl = MAXTTL;
-	ip_select_ident(iph, &rt->u.dst, NULL);
-	iph->protocol=IPPROTO_ICMP;
-	iph->saddr=rt->rt_src;
-	iph->daddr=rt->rt_dst;
-	iph->check=0;
-	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
-
-	/* Set up ICMP header. */
-	icmph = nskb->h.icmph
-		= (struct icmphdr *)skb_put(nskb, sizeof(struct icmphdr));
-	icmph->type = ICMP_DEST_UNREACH;
-	icmph->code = code;	
-	icmph->un.gateway = 0;
-	icmph->checksum = 0;
-	
-	/* Copy as much of original packet as will fit */
-	data = skb_put(nskb,
-		       length - sizeof(struct iphdr) - sizeof(struct icmphdr));
-
-	skb_copy_bits(skb_in, 0, data,
-		      length - sizeof(struct iphdr) - sizeof(struct icmphdr));
-
-	icmph->checksum = ip_compute_csum((unsigned char *)icmph,
-					  length - sizeof(struct iphdr));
-
-	nf_ct_attach(nskb, skb_in);
-
-	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
-		ip_finish_output);
+	icmp_send(skb_in, ICMP_DEST_UNREACH, code, 0);
 }	
 
 static unsigned int reject(struct sk_buff **pskb,

--6TrnltStXW4iwmi0--
