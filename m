From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH] netfilter6: Skip extension headers when matching
 icmp6-type
Date: Fri, 01 Oct 2004 14:09:10 +0900 (JST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <200410010509.i9159Cg2021037@toshiba.co.jp>
References: <200409301244.i8UCid17009482@toshiba.co.jp>
	<415C1CC9.2090604@trash.net>
	<200410010019.i910JlZY002193@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
	boundary="--Next_Part(Fri_Oct__1_14:09:10_2004_359)--"
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	usagi-core@linux-ipv6.org, kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: yasuyuki.kozakai@toshiba.co.jp
In-Reply-To: <200410010019.i910JlZY002193@toshiba.co.jp>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

----Next_Part(Fri_Oct__1_14:09:10_2004_359)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date: Fri, 01 Oct 2004 09:19:46 +0900 (JST)

> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 30 Sep 2004 16:48:41 +0200
> 
> > >Sorry, I sent it to only netfilter-devel ml because I wanted someone to test
> > >it more before sending it to netdev ml.
> > >  
> > >
> > 
> > I've reviewed the patch, I think we can push it soon.
> > Did you do any changes besides the u_int8_t fix since
> > the last patch you sent ?

You mean that "I" should send the fixed patch to netdev ?
OK, David, here you are.

# Sometimes I confuse I should send patches to netdev, or send them to
# netfilter-devel and core team of netfilter review/send it to netdev.

<Summary>
This patch is the preparation before removing skb_linearize() from
ip6_tables.c. The codes parsing headers are changed to use
skb_header_pointer().

To do this, I also changed the arguments of match functions. The match
functions get the offset to layer 4 protocol header instead of the pointer
to it. The offset is calculated at ip6_packet_match().

In the result, this patch fixes the bug which assumes layer 4 protocol header
is next to IPv6 header.

Moreover, the arguments order of target functions are changed likely IPv4
to occur compiling error when a user try this patch and old target modules.

This patch doesn't remove skb_linearize() yet. It will be done after
all match/target functions are changed to use skb_header_pointer().


Signed-off-by: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>

Regards,
-----------------------------------------------------------------
Yasuyuki KOZAKAI @ USAGI Project <yasuyuki.kozakai@toshiba.co.jp>


----Next_Part(Fri_Oct__1_14:09:10_2004_359)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="nolinearize.patch"

diff -Nur linux-2.6.9-rc3/include/linux/netfilter_ipv6/ip6_tables.h linux-2.6.9-rc3-nolinearize/include/linux/netfilter_ipv6/ip6_tables.h
--- linux-2.6.9-rc3/include/linux/netfilter_ipv6/ip6_tables.h	2004-09-30 18:45:23.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/include/linux/netfilter_ipv6/ip6_tables.h	2004-10-01 12:42:35.225648336 +0900
@@ -355,13 +355,15 @@
 
 	/* Return true or false: return FALSE and set *hotdrop = 1 to
            force immediate packet drop. */
+	/* Arguments changed since 2.6.9, as this must now handle
+	   non-linear skb, using skb_header_pointer and
+	   skb_ip_make_writable. */
 	int (*match)(const struct sk_buff *skb,
 		     const struct net_device *in,
 		     const struct net_device *out,
 		     const void *matchinfo,
 		     int offset,
-		     const void *hdr,
-		     u_int16_t datalen,
+		     unsigned int protoff,
 		     int *hotdrop);
 
 	/* Called when user tries to insert an entry of this type. */
@@ -386,11 +388,13 @@
 
 	const char name[IP6T_FUNCTION_MAXNAMELEN];
 
-	/* Returns verdict. */
+	/* Returns verdict. Argument order changed since 2.6.9, as this
+	   must now handle non-linear skbs, using skb_copy_bits and
+	   skb_ip_make_writable. */
 	unsigned int (*target)(struct sk_buff **pskb,
-			       unsigned int hooknum,
 			       const struct net_device *in,
 			       const struct net_device *out,
+			       unsigned int hooknum,
 			       const void *targinfo,
 			       void *userdata);
 
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6_tables.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6_tables.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6_tables.c	2004-09-30 18:45:24.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6_tables.c	2004-10-01 12:43:02.644480040 +0900
@@ -158,14 +158,15 @@
 /* Returns whether matches rule or not. */
 static inline int
 ip6_packet_match(const struct sk_buff *skb,
-		 const struct ipv6hdr *ipv6,
 		 const char *indev,
 		 const char *outdev,
 		 const struct ip6t_ip6 *ip6info,
-		 int isfrag)
+		 unsigned int *protoff,
+		 int *fragoff)
 {
 	size_t i;
 	unsigned long ret;
+	const struct ipv6hdr *ipv6 = skb->nh.ipv6h;
 
 #define FWINV(bool,invflg) ((bool) ^ !!(ip6info->invflags & invflg))
 
@@ -216,9 +217,10 @@
 	/* look for the desired protocol header */
 	if((ip6info->flags & IP6T_F_PROTO)) {
 		u_int8_t currenthdr = ipv6->nexthdr;
-		struct ipv6_opt_hdr *hdrptr;
+		struct ipv6_opt_hdr _hdr, *hp;
 		u_int16_t ptr;		/* Header offset in skb */
 		u_int16_t hdrlen;	/* Header */
+		u_int16_t _fragoff = 0, *fp = NULL;
 
 		ptr = IPV6_HDR_LEN;
 
@@ -234,23 +236,41 @@
 				(currenthdr == IPPROTO_ESP))
 				return 0;
 
-	                hdrptr = (struct ipv6_opt_hdr *)(skb->data + ptr);
+			hp = skb_header_pointer(skb, ptr, sizeof(_hdr), &_hdr);
+			BUG_ON(hp == NULL);
 
 			/* Size calculation */
 	                if (currenthdr == IPPROTO_FRAGMENT) {
+				fp = skb_header_pointer(skb,
+						   ptr+offsetof(struct frag_hdr,
+								frag_off),
+						   sizeof(_fragoff),
+						   &_fragoff);
+				if (fp == NULL)
+					return 0;
+
+				_fragoff = ntohs(*fp) & ~0x7;
 	                        hdrlen = 8;
 	                } else if (currenthdr == IPPROTO_AH)
-	                        hdrlen = (hdrptr->hdrlen+2)<<2;
+	                        hdrlen = (hp->hdrlen+2)<<2;
 	                else
-	                        hdrlen = ipv6_optlen(hdrptr);
+	                        hdrlen = ipv6_optlen(hp);
 
-			currenthdr = hdrptr->nexthdr;
+			currenthdr = hp->nexthdr;
 	                ptr += hdrlen;
 			/* ptr is too large */
 	                if ( ptr > skb->len ) 
 				return 0;
+			if (_fragoff) {
+				if (ip6t_ext_hdr(currenthdr))
+					return 0;
+				break;
+			}
 		}
 
+		*protoff = ptr;
+		*fragoff = _fragoff;
+
 		/* currenthdr contains the protocol header */
 
 		dprintf("Packet protocol %hi ?= %s%hi.\n",
@@ -292,9 +312,9 @@
 
 static unsigned int
 ip6t_error(struct sk_buff **pskb,
-	  unsigned int hooknum,
 	  const struct net_device *in,
 	  const struct net_device *out,
+	  unsigned int hooknum,
 	  const void *targinfo,
 	  void *userinfo)
 {
@@ -310,13 +330,12 @@
 	     const struct net_device *in,
 	     const struct net_device *out,
 	     int offset,
-	     const void *hdr,
-	     u_int16_t datalen,
+	     unsigned int protoff,
 	     int *hotdrop)
 {
 	/* Stop iteration if it doesn't match */
 	if (!m->u.kernel.match->match(skb, in, out, m->data,
-				      offset, hdr, datalen, hotdrop))
+				      offset, protoff, hotdrop))
 		return 1;
 	else
 		return 0;
@@ -338,10 +357,8 @@
 	      void *userdata)
 {
 	static const char nulldevname[IFNAMSIZ];
-	u_int16_t offset = 0;
-	struct ipv6hdr *ipv6;
-	void *protohdr;
-	u_int16_t datalen;
+	int offset = 0;
+	unsigned int protoff = 0;
 	int hotdrop = 0;
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
 	unsigned int verdict = NF_DROP;
@@ -354,9 +371,6 @@
 		return NF_DROP;
 
 	/* Initialization */
-	ipv6 = (*pskb)->nh.ipv6h;
-	protohdr = (u_int32_t *)((char *)ipv6 + IPV6_HDR_LEN);
-	datalen = (*pskb)->len - IPV6_HDR_LEN;
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 
@@ -393,17 +407,19 @@
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
 		(*pskb)->nfcache |= e->nfcache;
-		if (ip6_packet_match(*pskb, ipv6, indev, outdev, 
-			&e->ipv6, offset)) {
+		if (ip6_packet_match(*pskb, indev, outdev, &e->ipv6,
+			&protoff, &offset)) {
 			struct ip6t_entry_target *t;
 
 			if (IP6T_MATCH_ITERATE(e, do_match,
 					       *pskb, in, out,
-					       offset, protohdr,
-					       datalen, &hotdrop) != 0)
+					       offset, protoff, &hotdrop) != 0)
 				goto no_match;
 
-			ADD_COUNTER(e->counters, ntohs(ipv6->payload_len) + IPV6_HDR_LEN, 1);
+			ADD_COUNTER(e->counters,
+				    ntohs((*pskb)->nh.ipv6h->payload_len)
+				    + IPV6_HDR_LEN,
+				    1);
 
 			t = ip6t_get_target(e);
 			IP_NF_ASSERT(t->u.kernel.target);
@@ -443,8 +459,8 @@
 					= 0xeeeeeeec;
 #endif
 				verdict = t->u.kernel.target->target(pskb,
-								     hook,
 								     in, out,
+								     hook,
 								     t->data,
 								     userdata);
 
@@ -459,11 +475,6 @@
 				((struct ip6t_entry *)table_base)->comefrom
 					= 0x57acc001;
 #endif
-				/* Target might have changed stuff. */
-				ipv6 = (*pskb)->nh.ipv6h;
-				protohdr = (u_int32_t *)((void *)ipv6 + IPV6_HDR_LEN);
-				datalen = (*pskb)->len - IPV6_HDR_LEN;
-
 				if (verdict == IP6T_CONTINUE)
 					e = (void *)e + e->next_offset;
 				else
@@ -1535,26 +1546,31 @@
 
 static int
 tcp_find_option(u_int8_t option,
-		const struct tcphdr *tcp,
-		u_int16_t datalen,
+		const struct sk_buff *skb,
+		unsigned int tcpoff,
+		unsigned int optlen,
 		int invert,
 		int *hotdrop)
 {
-	unsigned int i = sizeof(struct tcphdr);
-	const u_int8_t *opt = (u_int8_t *)tcp;
+	/* tcp.doff is only 4 bits, ie. max 15 * 4 bytes */
+	u_int8_t _opt[60 - sizeof(struct tcphdr)], *op;
+	unsigned int i;
 
 	duprintf("tcp_match: finding option\n");
+	if (!optlen)
+		return invert;
 	/* If we don't have the whole header, drop packet. */
-	if (tcp->doff * 4 < sizeof(struct tcphdr) ||
-	    tcp->doff * 4 > datalen) {
+	op = skb_header_pointer(skb, tcpoff + sizeof(struct tcphdr), optlen,
+				_opt);
+	if (op == NULL) {
 		*hotdrop = 1;
 		return 0;
 	}
 
-	while (i < tcp->doff * 4) {
-		if (opt[i] == option) return !invert;
-		if (opt[i] < 2) i++;
-		else i += opt[i+1]?:1;
+	for (i = 0; i < optlen; ) {
+		if (op[i] == option) return !invert;
+		if (op[i] < 2) i++;
+		else i += op[i+1]?:1;
 	}
 
 	return invert;
@@ -1566,27 +1582,31 @@
 	  const struct net_device *out,
 	  const void *matchinfo,
 	  int offset,
-	  const void *hdr,
-	  u_int16_t datalen,
+	  unsigned int protoff,
 	  int *hotdrop)
 {
-	const struct tcphdr *tcp;
+	struct tcphdr _tcph, *th;
 	const struct ip6t_tcp *tcpinfo = matchinfo;
-	int tcpoff;
-	u8 nexthdr = skb->nh.ipv6h->nexthdr;
 
-	/* To quote Alan:
+	if (offset) {
+		/* To quote Alan:
 
-	   Don't allow a fragment of TCP 8 bytes in. Nobody normal
-	   causes this. Its a cracker trying to break in by doing a
-	   flag overwrite to pass the direction checks.
-	*/
-
-	if (offset == 1) {
-		duprintf("Dropping evil TCP offset=1 frag.\n");
-		*hotdrop = 1;
+		   Don't allow a fragment of TCP 8 bytes in. Nobody normal
+		   causes this. Its a cracker trying to break in by doing a
+		   flag overwrite to pass the direction checks.
+		*/
+		if (offset == 1) {
+			duprintf("Dropping evil TCP offset=1 frag.\n");
+			*hotdrop = 1;
+		}
+		/* Must not be a fragment. */
 		return 0;
-	} else if (offset == 0 && datalen < sizeof(struct tcphdr)) {
+	}
+
+#define FWINVTCP(bool,invflg) ((bool) ^ !!(tcpinfo->invflags & invflg))
+
+	th = skb_header_pointer(skb, protoff, sizeof(_tcph), &_tcph);
+	if (th == NULL) {
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
 		duprintf("Dropping evil TCP offset=0 tinygram.\n");
@@ -1594,45 +1614,30 @@
 		return 0;
 	}
 
-	tcpoff = (u8*)(skb->nh.ipv6h + 1) - skb->data;
-	tcpoff = ipv6_skip_exthdr(skb, tcpoff, &nexthdr, skb->len - tcpoff);
-	if (tcpoff < 0 || tcpoff > skb->len) {
-		duprintf("tcp_match: cannot skip exthdr. Dropping.\n");
-		*hotdrop = 1;
-		return 0;
-	} else if (nexthdr == IPPROTO_FRAGMENT)
-		return 0;
-	else if (nexthdr != IPPROTO_TCP ||
-		 skb->len - tcpoff < sizeof(struct tcphdr)) {
-		/* cannot be occured */
-		duprintf("tcp_match: cannot get TCP header. Dropping.\n");
-		*hotdrop = 1;
-		return 0;
+	if (!port_match(tcpinfo->spts[0], tcpinfo->spts[1],
+			ntohs(th->source),
+			!!(tcpinfo->invflags & IP6T_TCP_INV_SRCPT)))
+		return 0;
+	if (!port_match(tcpinfo->dpts[0], tcpinfo->dpts[1],
+			ntohs(th->dest),
+			!!(tcpinfo->invflags & IP6T_TCP_INV_DSTPT)))
+		return 0;
+	if (!FWINVTCP((((unsigned char *)th)[13] & tcpinfo->flg_mask)
+		      == tcpinfo->flg_cmp,
+		      IP6T_TCP_INV_FLAGS))
+		return 0;
+	if (tcpinfo->option) {
+		if (th->doff * 4 < sizeof(_tcph)) {
+			*hotdrop = 1;
+			return 0;
+		}
+		if (!tcp_find_option(tcpinfo->option, skb, protoff,
+				     th->doff*4 - sizeof(*th),
+				     tcpinfo->invflags & IP6T_TCP_INV_OPTION,
+				     hotdrop))
+			return 0;
 	}
-
-	tcp = (struct tcphdr *)(skb->data + tcpoff);
-
-	/* FIXME: Try tcp doff >> packet len against various stacks --RR */
-
-#define FWINVTCP(bool,invflg) ((bool) ^ !!(tcpinfo->invflags & invflg))
-
-	/* Must not be a fragment. */
-	return !offset
-		&& port_match(tcpinfo->spts[0], tcpinfo->spts[1],
-			      ntohs(tcp->source),
-			      !!(tcpinfo->invflags & IP6T_TCP_INV_SRCPT))
-		&& port_match(tcpinfo->dpts[0], tcpinfo->dpts[1],
-			      ntohs(tcp->dest),
-			      !!(tcpinfo->invflags & IP6T_TCP_INV_DSTPT))
-		&& FWINVTCP((((unsigned char *)tcp)[13]
-			     & tcpinfo->flg_mask)
-			    == tcpinfo->flg_cmp,
-			    IP6T_TCP_INV_FLAGS)
-		&& (!tcpinfo->option
-		    || tcp_find_option(tcpinfo->option, tcp, datalen,
-				       tcpinfo->invflags
-				       & IP6T_TCP_INV_OPTION,
-				       hotdrop));
+	return 1;
 }
 
 /* Called when user tries to insert an entry of this type. */
@@ -1658,16 +1663,18 @@
 	  const struct net_device *out,
 	  const void *matchinfo,
 	  int offset,
-	  const void *hdr,
-	  u_int16_t datalen,
+	  unsigned int protoff,
 	  int *hotdrop)
 {
-	const struct udphdr *udp;
+	struct udphdr _udph, *uh;
 	const struct ip6t_udp *udpinfo = matchinfo;
-	int udpoff;
-	u8 nexthdr = skb->nh.ipv6h->nexthdr;
 
-	if (offset == 0 && datalen < sizeof(struct udphdr)) {
+	/* Must not be a fragment. */
+	if (offset)
+		return 0;
+
+	uh = skb_header_pointer(skb, protoff, sizeof(_udph), &_udph);
+	if (uh == NULL) {
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
 		duprintf("Dropping evil UDP tinygram.\n");
@@ -1675,30 +1682,11 @@
 		return 0;
 	}
 
-	udpoff = (u8*)(skb->nh.ipv6h + 1) - skb->data;
-	udpoff = ipv6_skip_exthdr(skb, udpoff, &nexthdr, skb->len - udpoff);
-	if (udpoff < 0 || udpoff > skb->len) {
-		duprintf("udp_match: cannot skip exthdr. Dropping.\n");
-		*hotdrop = 1;
-		return 0;
-	} else if (nexthdr == IPPROTO_FRAGMENT)
-		return 0;
-	else if (nexthdr != IPPROTO_UDP ||
-		 skb->len - udpoff < sizeof(struct udphdr)) {
-		duprintf("udp_match: cannot get UDP header. Dropping.\n");
-		*hotdrop = 1;
-		return 0;
-	}
-
-	udp = (struct udphdr *)(skb->data + udpoff);
-
-	/* Must not be a fragment. */
-	return !offset
-		&& port_match(udpinfo->spts[0], udpinfo->spts[1],
-			      ntohs(udp->source),
-			      !!(udpinfo->invflags & IP6T_UDP_INV_SRCPT))
+	return port_match(udpinfo->spts[0], udpinfo->spts[1],
+			  ntohs(uh->source),
+			  !!(udpinfo->invflags & IP6T_UDP_INV_SRCPT))
 		&& port_match(udpinfo->dpts[0], udpinfo->dpts[1],
-			      ntohs(udp->dest),
+			      ntohs(uh->dest),
 			      !!(udpinfo->invflags & IP6T_UDP_INV_DSTPT));
 }
 
@@ -1748,14 +1736,18 @@
 	   const struct net_device *out,
 	   const void *matchinfo,
 	   int offset,
-	   const void *hdr,
-	   u_int16_t datalen,
+	   unsigned int protoff,
 	   int *hotdrop)
 {
-	const struct icmp6hdr *icmp = hdr;
+	struct icmp6hdr _icmp, *ic;
 	const struct ip6t_icmp *icmpinfo = matchinfo;
 
-	if (offset == 0 && datalen < 2) {
+	/* Must not be a fragment. */
+	if (offset)
+		return 0;
+
+	ic = skb_header_pointer(skb, protoff, sizeof(_icmp), &_icmp);
+	if (ic == NULL) {
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
 		duprintf("Dropping evil ICMP tinygram.\n");
@@ -1763,13 +1755,11 @@
 		return 0;
 	}
 
-	/* Must not be a fragment. */
-	return !offset
-		&& icmp6_type_code_match(icmpinfo->type,
-					icmpinfo->code[0],
-					icmpinfo->code[1],
-					icmp->icmp6_type, icmp->icmp6_code,
-					!!(icmpinfo->invflags&IP6T_ICMP_INV));
+	return icmp6_type_code_match(icmpinfo->type,
+				     icmpinfo->code[0],
+				     icmpinfo->code[1],
+				     ic->icmp6_type, ic->icmp6_code,
+				     !!(icmpinfo->invflags&IP6T_ICMP_INV));
 }
 
 /* Called when user tries to insert an entry of this type. */
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_LOG.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_LOG.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_LOG.c	2004-09-30 18:45:24.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_LOG.c	2004-10-01 12:42:35.228647880 +0900
@@ -335,9 +335,9 @@
 
 static unsigned int
 ip6t_log_target(struct sk_buff **pskb,
-		unsigned int hooknum,
 		const struct net_device *in,
 		const struct net_device *out,
+		unsigned int hooknum,
 		const void *targinfo,
 		void *userinfo)
 {
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_MARK.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_MARK.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_MARK.c	2004-08-14 14:37:41.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_MARK.c	2004-10-01 12:42:35.228647880 +0900
@@ -20,9 +20,9 @@
 
 static unsigned int
 target(struct sk_buff **pskb,
-       unsigned int hooknum,
        const struct net_device *in,
        const struct net_device *out,
+       unsigned int hooknum,
        const void *targinfo,
        void *userinfo)
 {
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_ah.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_ah.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_ah.c	2004-08-14 14:36:17.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_ah.c	2004-10-01 12:42:35.229647728 +0900
@@ -45,8 +45,7 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *protohdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
        struct ip_auth_hdr *ah = NULL;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_dst.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_dst.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_dst.c	2004-08-14 14:36:13.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_dst.c	2004-10-01 12:42:35.229647728 +0900
@@ -60,8 +60,7 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *protohdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
        struct ipv6_opt_hdr *optsh = NULL;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_esp.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_esp.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_esp.c	2004-08-14 14:37:15.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_esp.c	2004-10-01 12:42:35.230647576 +0900
@@ -45,8 +45,7 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *protohdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
 	struct ip_esp_hdr *esp = NULL;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_eui64.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_eui64.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_eui64.c	2004-08-14 14:36:11.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_eui64.c	2004-10-01 12:42:35.230647576 +0900
@@ -24,8 +24,7 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *hdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
 
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_frag.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_frag.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_frag.c	2004-08-14 14:36:32.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_frag.c	2004-10-01 12:42:35.230647576 +0900
@@ -70,8 +70,7 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *protohdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
        struct fraghdr *frag = NULL;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_hbh.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_hbh.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_hbh.c	2004-08-14 14:37:38.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_hbh.c	2004-10-01 12:42:35.231647424 +0900
@@ -59,8 +59,7 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *protohdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
        struct ipv6_opt_hdr *optsh = NULL;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_hl.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_hl.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_hl.c	2004-08-14 14:37:26.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_hl.c	2004-10-01 12:42:35.231647424 +0900
@@ -20,7 +20,7 @@
 
 static int match(const struct sk_buff *skb, const struct net_device *in,
 		 const struct net_device *out, const void *matchinfo,
-		 int offset, const void *hdr, u_int16_t datalen,
+		 int offset, unsigned int protoff,
 		 int *hotdrop)
 {
 	const struct ip6t_hl_info *info = matchinfo;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_ipv6header.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_ipv6header.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_ipv6header.c	2004-08-14 14:38:10.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_ipv6header.c	2004-10-01 12:42:35.231647424 +0900
@@ -31,8 +31,7 @@
 		 const struct net_device *out,
 		 const void *matchinfo,
 		 int offset,
-		 const void *protohdr,
-		 u_int16_t datalen,
+		 unsigned int protoff,
 		 int *hotdrop)
 {
 	const struct ip6t_ipv6header_info *info = matchinfo;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_length.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_length.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_length.c	2004-08-14 14:38:08.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_length.c	2004-10-01 12:42:35.257643472 +0900
@@ -23,8 +23,7 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *hdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
 	const struct ip6t_length_info *info = matchinfo;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_limit.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_limit.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_limit.c	2004-08-14 14:36:32.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_limit.c	2004-10-01 12:42:35.258643320 +0900
@@ -57,8 +57,7 @@
 		const struct net_device *out,
 		const void *matchinfo,
 		int offset,
-		const void *hdr,
-		u_int16_t datalen,
+		unsigned int protoff,
 		int *hotdrop)
 {
 	struct ip6t_rateinfo *r = ((struct ip6t_rateinfo *)matchinfo)->master;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_mac.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_mac.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_mac.c	2004-08-14 14:37:41.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_mac.c	2004-10-01 12:42:35.258643320 +0900
@@ -25,8 +25,7 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *hdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
     const struct ip6t_mac_info *info = matchinfo;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_mark.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_mark.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_mark.c	2004-08-14 14:38:11.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_mark.c	2004-10-01 12:42:35.258643320 +0900
@@ -24,8 +24,7 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *hdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
 	const struct ip6t_mark_info *info = matchinfo;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_multiport.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_multiport.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_multiport.c	2004-08-14 14:38:09.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_multiport.c	2004-10-01 12:42:35.259643168 +0900
@@ -53,15 +53,14 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *hdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
-	const struct udphdr *udp = hdr;
+	const struct udphdr *udp = (const struct udphdr *)(skb->data + protoff);
 	const struct ip6t_multiport *multiinfo = matchinfo;
 
 	/* Must be big enough to read ports. */
-	if (offset == 0 && datalen < sizeof(struct udphdr)) {
+	if (offset == 0 && skb->len - protoff < sizeof(struct udphdr)) {
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
 			duprintf("ip6t_multiport:"
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_owner.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_owner.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_owner.c	2004-08-14 14:37:38.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_owner.c	2004-10-01 12:42:35.259643168 +0900
@@ -92,8 +92,7 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *hdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
 	const struct ip6t_owner_info *info = matchinfo;
diff -Nur linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_rt.c linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_rt.c
--- linux-2.6.9-rc3/net/ipv6/netfilter/ip6t_rt.c	2004-08-14 14:36:33.000000000 +0900
+++ linux-2.6.9-rc3-nolinearize/net/ipv6/netfilter/ip6t_rt.c	2004-10-01 12:42:35.259643168 +0900
@@ -47,8 +47,7 @@
       const struct net_device *out,
       const void *matchinfo,
       int offset,
-      const void *protohdr,
-      u_int16_t datalen,
+      unsigned int protoff,
       int *hotdrop)
 {
        struct ipv6_rt_hdr *route = NULL;

----Next_Part(Fri_Oct__1_14:09:10_2004_359)----
