From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: [PACTH][IPV6] Introduce ip6_append_data
Date: Thu, 17 Apr 2003 13:02:31 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030417130231.179c7f00.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

This patch introduces ip6_append_data and related functions,
which are similer to ip_append_data and the functions in IPv4.
This makes the kernel transmit fragmented packets with IPsec and
cork the datagram packet.

This patch is for linux-2.5.67 + CS1.1202

#ip6_frag_xmit and ip6_build_xmit remain.

Best regards,

--Kazunori Miyazawa (Yokogawa Electric Corporation)

Index: include/linux/ipv6.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/include/linux/ipv6.h,v
retrieving revision 1.1.1.5
retrieving revision 1.1.1.5.10.3
diff -u -u -r1.1.1.5 -r1.1.1.5.10.3
--- include/linux/ipv6.h	8 Apr 2003 08:57:38 -0000	1.1.1.5
+++ include/linux/ipv6.h	17 Apr 2003 02:14:13 -0000	1.1.1.5.10.3
@@ -121,6 +121,7 @@
 #include <linux/icmpv6.h>
 #include <net/if_inet6.h>       /* struct ipv6_mc_socklist */
 #include <linux/tcp.h>
+#include <linux/udp.h>
 
 /* 
    This structure contains results of exthdrs parsing
@@ -178,6 +179,11 @@
 
 	struct ipv6_txoptions	*opt;
 	struct sk_buff		*pktoptions;
+	struct {
+		struct ipv6_txoptions *opt;
+		struct rt6_info	*rt;
+		struct flowi *fl;
+	} cork;
 };
 
 struct raw6_opt {
@@ -200,6 +206,7 @@
 	struct sock	  sk;
 	struct ipv6_pinfo *pinet6;
 	struct inet_opt   inet;
+	struct udp_opt	  udp;
 	struct ipv6_pinfo inet6;
 };
 
Index: include/linux/skbuff.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/include/linux/skbuff.h,v
retrieving revision 1.1.1.8
retrieving revision 1.1.1.8.12.1
diff -u -u -r1.1.1.8 -r1.1.1.8.12.1
--- include/linux/skbuff.h	2 Apr 2003 04:14:20 -0000	1.1.1.8
+++ include/linux/skbuff.h	16 Apr 2003 14:34:33 -0000	1.1.1.8.12.1
@@ -792,6 +792,15 @@
 	return len + skb_headlen(skb);
 }
 
+static inline void skb_fill_page_desc(struct sk_buff *skb, int i, struct page *page, int off, int size)
+{
+	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+	frag->page = page;
+	frag->page_offset = off;
+	frag->size = size;
+	skb_shinfo(skb)->nr_frags = i+1;
+}
+
 #define SKB_PAGE_ASSERT(skb) do { if (skb_shinfo(skb)->nr_frags) \
 					BUG(); } while (0)
 #define SKB_FRAG_ASSERT(skb) do { if (skb_shinfo(skb)->frag_list) \
Index: include/net/ipv6.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/include/net/ipv6.h,v
retrieving revision 1.1.1.5
retrieving revision 1.1.1.5.14.1
diff -u -u -r1.1.1.5 -r1.1.1.5.14.1
--- include/net/ipv6.h	25 Mar 2003 04:32:21 -0000	1.1.1.5
+++ include/net/ipv6.h	16 Apr 2003 14:34:33 -0000	1.1.1.5.14.1
@@ -292,6 +292,26 @@
 					       struct ipv6_txoptions *opt,
 					       int hlimit, int flags);
 
+extern int			ip6_append_data(struct sock *sk,
+						int getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb),
+		    				void *from,
+						int length,
+						int transhdrlen,
+		      				int hlimit,
+						struct ipv6_txoptions *opt,
+						struct flowi *fl,
+						struct rt6_info *rt,
+						unsigned int flags);
+
+extern int			ip6_push_pending_frames(struct sock *sk);
+
+extern void			ip6_flush_pending_frames(struct sock *sk);
+
+extern int			ip6_dst_lookup(struct sock *sk,
+					       struct dst_entry **dst,
+					       struct flowi *fl,
+					       struct in6_addr **saddr);
+
 /*
  *	skb processing functions
  */
Index: net/ipv4/ip_output.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv4/ip_output.c,v
retrieving revision 1.1.1.12
retrieving revision 1.1.1.12.6.1
diff -u -u -r1.1.1.12 -r1.1.1.12.6.1
--- net/ipv4/ip_output.c	14 Apr 2003 04:34:12 -0000	1.1.1.12
+++ net/ipv4/ip_output.c	16 Apr 2003 14:34:34 -0000	1.1.1.12.6.1
@@ -685,16 +685,6 @@
 	return 0;
 }
 
-static void
-skb_fill_page_desc(struct sk_buff *skb, int i, struct page *page, int off, int size)
-{
-	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-	frag->page = page;
-	frag->page_offset = off;
-	frag->size = size;
-	skb_shinfo(skb)->nr_frags = i+1;
-}
-
 static inline unsigned int
 csum_page(struct page *page, int offset, int copy)
 {
Index: net/ipv6/icmp.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/icmp.c,v
retrieving revision 1.1.1.9
retrieving revision 1.1.1.9.14.5
diff -u -u -r1.1.1.9 -r1.1.1.9.14.5
--- net/ipv6/icmp.c	25 Mar 2003 04:33:45 -0000	1.1.1.9
+++ net/ipv6/icmp.c	17 Apr 2003 01:43:15 -0000	1.1.1.9.14.5
@@ -26,6 +26,7 @@
  *	yoshfuji		:	ensure to sent parameter problem for
  *					fragments.
  *	YOSHIFUJI Hideaki @USAGI:	added sysctl for icmp rate limit.
+ *	Kazunori MIYAZAWA @USAGI:       change output process to use ip6_append_data
  */
 
 #include <linux/module.h>
@@ -101,42 +102,6 @@
 	spin_unlock_bh(&icmpv6_socket->sk->lock.slock);
 }
 
-
-
-/*
- *	getfrag callback
- */
-
-static int icmpv6_getfrag(const void *data, struct in6_addr *saddr, 
-			   char *buff, unsigned int offset, unsigned int len)
-{
-	struct icmpv6_msg *msg = (struct icmpv6_msg *) data;
-	struct icmp6hdr *icmph;
-	__u32 csum;
-
-	if (offset) {
-		csum = skb_copy_and_csum_bits(msg->skb, msg->offset +
-					      (offset - sizeof(struct icmp6hdr)),
-					      buff, len, msg->csum);
-		msg->csum = csum;
-		return 0;
-	}
-
-	csum = csum_partial_copy_nocheck((void *) &msg->icmph, buff,
-					 sizeof(struct icmp6hdr), msg->csum);
-
-	csum = skb_copy_and_csum_bits(msg->skb, msg->offset,
-				      buff + sizeof(struct icmp6hdr),
-				      len - sizeof(struct icmp6hdr), csum);
-
-	icmph = (struct icmp6hdr *) buff;
-
-	icmph->icmp6_cksum = csum_ipv6_magic(saddr, msg->daddr, msg->len,
-					     IPPROTO_ICMPV6, csum);
-	return 0; 
-}
-
-
 /* 
  * Slightly more convenient version of icmpv6_send.
  */
@@ -239,6 +204,55 @@
 	return (optval&0xC0) == 0x80;
 }
 
+int icmpv6_push_pending_frames(struct sock *sk, struct flowi *fl, struct icmp6hdr *thdr, int len)
+{
+	struct sk_buff *skb;
+	struct icmp6hdr *icmp6h;
+	int err = 0;
+
+	if ((skb = skb_peek(&sk->write_queue)) == NULL)
+		goto out;
+
+	icmp6h = (struct icmp6hdr*) skb->h.raw;
+	memcpy(icmp6h, thdr, sizeof(struct icmp6hdr));
+	icmp6h->icmp6_cksum = 0;
+
+	if (skb_queue_len(&sk->write_queue) == 1) {
+		skb->csum = csum_partial((char *)icmp6h,
+					sizeof(struct icmp6hdr), skb->csum);
+		icmp6h->icmp6_cksum = csum_ipv6_magic(fl->fl6_src,
+					     fl->fl6_dst,
+					     len, fl->proto, skb->csum);
+	} else {
+		u32 tmp_csum = 0;
+
+		skb_queue_walk(&sk->write_queue, skb) {
+			tmp_csum = csum_add(tmp_csum, skb->csum);
+		}
+
+		tmp_csum = csum_partial((char *)icmp6h,
+					sizeof(struct icmp6hdr), tmp_csum);
+		tmp_csum = csum_ipv6_magic(fl->fl6_src,
+					   fl->fl6_dst,
+					   len, fl->proto, tmp_csum);
+		icmp6h->icmp6_cksum = tmp_csum;
+	}
+	if (icmp6h->icmp6_cksum == 0)
+		icmp6h->icmp6_cksum = -1;
+	ip6_push_pending_frames(sk);
+out:
+	return err;
+}
+
+static int icmpv6_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb)
+{
+	struct sk_buff *org_skb = (struct sk_buff *)from;
+	__u32 csum = 0;
+	csum = skb_copy_and_csum_bits(org_skb, offset, to, len, csum);
+	skb->csum = csum_block_add(skb->csum, csum, odd);
+	return 0;
+}
+
 /*
  *	Send an ICMP message in response to a packet in error
  */
@@ -248,12 +262,16 @@
 {
 	struct ipv6hdr *hdr = skb->nh.ipv6h;
 	struct sock *sk = icmpv6_socket->sk;
-	struct in6_addr *saddr = NULL;
-	int iif = 0;
-	struct icmpv6_msg msg;
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct in6_addr *saddr = NULL, *tmp_saddr = NULL;
+	struct dst_entry *dst;
+	struct icmp6hdr tmp_hdr;
 	struct flowi fl;
+	int iif = 0;
 	int addr_type = 0;
-	int len;
+	int len, plen;
+	int hlimit = -1;
+	int err = 0;
 
 	if ((u8*)hdr < skb->head || (u8*)(hdr+1) > skb->tail)
 		return;
@@ -324,48 +342,64 @@
 	if (!icmpv6_xrlim_allow(sk, type, &fl))
 		goto out;
 
-	/*
-	 *	ok. kick it. checksum will be provided by the 
-	 *	getfrag_t callback.
-	 */
-
-	msg.icmph.icmp6_type = type;
-	msg.icmph.icmp6_code = code;
-	msg.icmph.icmp6_cksum = 0;
-	msg.icmph.icmp6_pointer = htonl(info);
-
-	msg.skb = skb;
-	msg.offset = skb->nh.raw - skb->data;
-	msg.csum = 0;
-	msg.daddr = &hdr->saddr;
-
-	len = skb->len - msg.offset + sizeof(struct icmp6hdr);
-	len = min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr));
+	tmp_hdr.icmp6_type = type;
+	tmp_hdr.icmp6_code = code;
+	tmp_hdr.icmp6_cksum = 0;
+	tmp_hdr.icmp6_pointer = htonl(info);
+
+	if (!fl.oif && ipv6_addr_is_multicast(fl.nl_u.ip6_u.daddr))
+		fl.oif = np->mcast_oif;
+
+	err = ip6_dst_lookup(sk, &dst, &fl, &tmp_saddr);
+	if (err) goto out;
+
+	if (hlimit < 0) {
+		if (ipv6_addr_is_multicast(fl.fl6_dst))
+			hlimit = np->mcast_hops;
+		else
+			hlimit = np->hop_limit;
+		if (hlimit < 0)
+			hlimit = ((struct rt6_info*)dst)->rt6i_hoplimit;
+	}
 
+	plen = skb->nh.raw - skb->data;
+	__skb_pull(skb, plen);
+	len = skb->len;
+	len = min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr) -sizeof(struct icmp6hdr));
 	if (len < 0) {
 		if (net_ratelimit())
 			printk(KERN_DEBUG "icmp: len problem\n");
+		__skb_push(skb, plen);
 		goto out;
 	}
 
-	msg.len = len;
+	err = ip6_append_data(sk, icmpv6_getfrag, skb, len + sizeof(struct icmp6hdr), sizeof(struct icmp6hdr),
+				hlimit, NULL, &fl, (struct rt6_info*)dst, MSG_DONTWAIT);
+	if (err)
+		ip6_flush_pending_frames(sk);
+	else 
+		err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, len + sizeof(struct icmp6hdr));
+	__skb_push(skb, plen);
 
-	ip6_build_xmit(sk, icmpv6_getfrag, &msg, &fl, len, NULL, -1,
-		       MSG_DONTWAIT);
 	if (type >= ICMPV6_DEST_UNREACH && type <= ICMPV6_PARAMPROB)
 		ICMP6_STATS_PTR_BH(Icmp6OutDestUnreachs) [type-ICMPV6_DEST_UNREACH]++;
 	ICMP6_INC_STATS_BH(Icmp6OutMsgs);
 out:
+	if (tmp_saddr) kfree(tmp_saddr);
 	icmpv6_xmit_unlock();
 }
 
 static void icmpv6_echo_reply(struct sk_buff *skb)
 {
 	struct sock *sk = icmpv6_socket->sk;
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct in6_addr *saddr = NULL, *tmp_saddr = NULL;
 	struct icmp6hdr *icmph = (struct icmp6hdr *) skb->h.raw;
-	struct in6_addr *saddr;
-	struct icmpv6_msg msg;
+	struct icmp6hdr tmp_hdr;
 	struct flowi fl;
+	struct dst_entry *dst;
+	int err = 0;
+	int hlimit = -1;
 
 	saddr = &skb->nh.ipv6h->daddr;
 
@@ -373,20 +407,11 @@
 	    ipv6_chk_acast_addr(0, saddr)) 
 		saddr = NULL;
 
-	msg.icmph.icmp6_type = ICMPV6_ECHO_REPLY;
-	msg.icmph.icmp6_code = 0;
-	msg.icmph.icmp6_cksum = 0;
-	msg.icmph.icmp6_identifier = icmph->icmp6_identifier;
-	msg.icmph.icmp6_sequence = icmph->icmp6_sequence;
-
-	msg.skb = skb;
-	msg.offset = 0;
-	msg.csum = 0;
-	msg.len = skb->len + sizeof(struct icmp6hdr);
-	msg.daddr =  &skb->nh.ipv6h->saddr;
+	memcpy(&tmp_hdr, icmph, sizeof(tmp_hdr));
+	tmp_hdr.icmp6_type = ICMPV6_ECHO_REPLY;
 
 	fl.proto = IPPROTO_ICMPV6;
-	fl.nl_u.ip6_u.daddr = msg.daddr;
+	fl.nl_u.ip6_u.daddr = &skb->nh.ipv6h->saddr;
 	fl.nl_u.ip6_u.saddr = saddr;
 	fl.oif = skb->dev->ifindex;
 	fl.fl6_flowlabel = 0;
@@ -395,11 +420,36 @@
 
 	icmpv6_xmit_lock();
 
-	ip6_build_xmit(sk, icmpv6_getfrag, &msg, &fl, msg.len, NULL, -1,
-		       MSG_DONTWAIT);
+	if (!fl.oif && ipv6_addr_is_multicast(fl.nl_u.ip6_u.daddr))
+		fl.oif = np->mcast_oif;
+
+	err = ip6_dst_lookup(sk, &dst, &fl, &tmp_saddr);
+
+	if (err) goto out;
+
+	if (hlimit < 0) {
+		if (ipv6_addr_is_multicast(fl.fl6_dst))
+			hlimit = np->mcast_hops;
+		else
+			hlimit = np->hop_limit;
+		if (hlimit < 0)
+			hlimit = ((struct rt6_info*)dst)->rt6i_hoplimit;
+	}
+
+	err = ip6_append_data(sk, icmpv6_getfrag, skb, skb->len + sizeof(struct icmp6hdr),
+				sizeof(struct icmp6hdr), hlimit, NULL, &fl,
+				(struct rt6_info*)dst, MSG_DONTWAIT);
+
+	if (err)
+		ip6_flush_pending_frames(sk);
+	else 
+		err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, skb->len + sizeof(struct icmp6hdr));
+
+
 	ICMP6_INC_STATS_BH(Icmp6OutEchoReplies);
 	ICMP6_INC_STATS_BH(Icmp6OutMsgs);
-
+out: 
+	if (tmp_saddr) kfree(tmp_saddr);
 	icmpv6_xmit_unlock();
 }
 
Index: net/ipv6/ip6_output.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ip6_output.c,v
retrieving revision 1.1.1.8
retrieving revision 1.1.1.8.12.7
diff -u -u -r1.1.1.8 -r1.1.1.8.12.7
--- net/ipv6/ip6_output.c	2 Apr 2003 04:16:14 -0000	1.1.1.8
+++ net/ipv6/ip6_output.c	17 Apr 2003 02:01:29 -0000	1.1.1.8.12.7
@@ -23,6 +23,9 @@
  *
  *      H. von Brand    :       Added missing #include <linux/string.h>
  *	Imran Patel	: 	frag id should be in NBO
+ *      Kazunori MIYAZAWA @USAGI
+ *			:       add ip6_append_data and related functions
+ *				for datagram xmit
  */
 
 #include <linux/config.h>
@@ -52,6 +55,8 @@
 #include <net/icmp.h>
 #include <net/xfrm.h>
 
+static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*));
+
 static __inline__ void ipv6_select_ident(struct sk_buff *skb, struct frag_hdr *fhdr)
 {
 	static u32 ipv6_fragmentation_id = 1;
@@ -98,7 +103,7 @@
 }
 
 
-int ip6_output(struct sk_buff *skb)
+int ip6_output2(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct net_device *dev = dst->dev;
@@ -133,6 +138,13 @@
 	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb,NULL, skb->dev,ip6_output_finish);
 }
 
+int ip6_output(struct sk_buff *skb)
+{
+	if ((skb->len > skb->dst->dev->mtu || skb_shinfo(skb)->frag_list))
+		return ip6_fragment(skb, ip6_output2);
+	else
+		return ip6_output2(skb);
+}
 
 #ifdef CONFIG_NETFILTER
 int ip6_route_me_harder(struct sk_buff *skb)
@@ -844,4 +856,659 @@
 drop:
 	kfree_skb(skb);
 	return -EINVAL;
+}
+
+static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
+{
+	to->pkt_type = from->pkt_type;
+	to->priority = from->priority;
+	to->protocol = from->protocol;
+	to->security = from->security;
+	to->dst = dst_clone(from->dst);
+	to->dev = from->dev;
+
+#ifdef CONFIG_NET_SCHED
+	to->tc_index = from->tc_index;
+#endif
+#ifdef CONFIG_NETFILTER
+	to->nfmark = from->nfmark;
+	/* Connection association is same as pre-frag packet */
+	to->nfct = from->nfct;
+	nf_conntrack_get(to->nfct);
+#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
+	to->nf_bridge = from->nf_bridge;
+	nf_bridge_get(to->nf_bridge);
+#endif
+#ifdef CONFIG_NETFILTER_DEBUG
+	to->nf_debug = from->nf_debug;
+#endif
+#endif
+}
+
+static int ip6_found_nexthdr(struct sk_buff *skb, u8 **nexthdr)
+{
+	u16 offset = sizeof(struct ipv6hdr);
+	struct ipv6_opt_hdr *exthdr = (struct ipv6_opt_hdr*)(skb->nh.ipv6h + 1);
+	unsigned int packet_len = skb->tail - skb->nh.raw;
+	int found_rhdr = 0;
+	*nexthdr = &skb->nh.ipv6h->nexthdr;
+
+	while (offset + 1 <= packet_len) {
+
+		switch (**nexthdr) {
+
+		case NEXTHDR_HOP:
+		case NEXTHDR_ROUTING:
+		case NEXTHDR_DEST:
+			if (**nexthdr == NEXTHDR_ROUTING) found_rhdr = 1;
+			if (**nexthdr == NEXTHDR_DEST && found_rhdr) return offset;
+			offset += ipv6_optlen(exthdr);
+			*nexthdr = &exthdr->nexthdr;
+			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+			break;
+		default :
+			return offset;
+		}
+	}
+
+	return offset;
+}
+
+static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
+{
+	struct net_device *dev;
+	struct rt6_info *rt = (struct rt6_info*)skb->dst;
+	struct sk_buff *frag;
+	struct ipv6hdr *tmp_hdr;
+	struct frag_hdr *fh;
+	unsigned int mtu, hlen, left, len;
+	u32 frag_id = 0;
+	int ptr, offset = 0, err=0;
+	u8 *prevhdr, nexthdr = 0;
+
+	dev = rt->u.dst.dev;
+	hlen = ip6_found_nexthdr(skb, &prevhdr);
+	nexthdr = *prevhdr;
+
+	mtu = dst_pmtu(&rt->u.dst) - hlen - sizeof(struct frag_hdr);
+
+	if (skb_shinfo(skb)->frag_list) {
+		int first_len = 0;
+
+		if (first_len - hlen > mtu ||
+		    ((first_len - hlen) & 7) ||
+		    skb_cloned(skb))
+			goto slow_path;
+
+		for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+			/* Correct geometry. */
+			if (frag->len > mtu ||
+			    ((frag->len & 7) && frag->next) ||
+			    skb_headroom(frag) < hlen)
+			    goto slow_path;
+
+			/* Correct socket ownership. */
+			if (frag->sk == NULL)
+				goto slow_path;
+
+			/* Partially cloned skb? */
+			if (skb_shared(frag))
+				goto slow_path;
+		}
+
+		err = 0;
+		offset = 0;
+		frag = skb_shinfo(skb)->frag_list;
+		skb_shinfo(skb)->frag_list = 0;
+		/* BUILD HEADER */
+
+		tmp_hdr = kmalloc(hlen, GFP_ATOMIC);
+		if (!tmp_hdr) {
+			IP6_INC_STATS(Ip6FragFails);
+			return -ENOMEM;
+		}
+
+		*prevhdr = NEXTHDR_FRAGMENT;
+		memcpy(tmp_hdr, skb->nh.raw, hlen);
+		__skb_pull(skb, hlen);
+		fh = (struct frag_hdr*)__skb_push(skb, sizeof(struct frag_hdr));
+		skb->nh.raw = __skb_push(skb, hlen);
+		memcpy(skb->nh.raw, tmp_hdr, hlen);
+
+		ipv6_select_ident(skb, fh);
+		fh->nexthdr = nexthdr;
+		fh->reserved = 0;
+		fh->frag_off = htons(0x0001);
+		frag_id = fh->identification;
+
+		first_len = skb_pagelen(skb);
+		skb->data_len = first_len - skb_headlen(skb);
+		skb->len = first_len;
+		skb->nh.ipv6h->payload_len = htons(first_len - sizeof(struct ipv6hdr));
+ 
+
+		for (;;) {
+			/* Prepare header of the next frame,
+			 * before previous one went down. */
+			if (frag) {
+				frag->h.raw = frag->data;
+				fh = (struct frag_hdr*)__skb_push(frag, sizeof(struct frag_hdr));
+				frag->nh.raw = __skb_push(frag, hlen);
+				memcpy(frag->nh.raw, tmp_hdr, hlen);
+				offset += skb->len - hlen - sizeof(struct frag_hdr);
+				fh->nexthdr = nexthdr;
+				fh->reserved = 0;
+				if (frag->next != NULL)
+					offset |= 0x0001;
+				fh->frag_off = htons(offset);
+				fh->identification = frag_id;
+				frag->nh.ipv6h->payload_len = htons(frag->len - sizeof(struct ipv6hdr));
+				ip6_copy_metadata(frag, skb);
+			}
+			err = output(skb);
+
+			if (err || !frag)
+				break;
+
+			skb = frag;
+			frag = skb->next;
+			skb->next = NULL;
+		}
+
+		if (tmp_hdr)
+			kfree(tmp_hdr);
+
+		if (err == 0) {
+			IP6_INC_STATS(Ip6FragOKs);
+			return 0;
+		}
+
+		while (frag) {
+			skb = frag->next;
+			kfree_skb(frag);
+			frag = skb;
+		}
+
+		IP6_INC_STATS(Ip6FragFails);
+		return err;
+	}
+
+slow_path:
+	left = skb->len - hlen;		/* Space per frame */
+	ptr = hlen;			/* Where to start from */
+
+	/*
+	 *	Fragment the datagram.
+	 */
+
+	*prevhdr = NEXTHDR_FRAGMENT;
+
+	/*
+	 *	Keep copying data until we run out.
+	 */
+	while(left > 0)	{
+		len = left;
+		/* IF: it doesn't fit, use 'mtu' - the data space left */
+		if (len > mtu)
+			len = mtu;
+		/* IF: we are not sending upto and including the packet end
+		   then align the next start on an eight byte boundary */
+		if (len < left)	{
+			len &= ~7;
+		}
+		/*
+		 *	Allocate buffer.
+		 */
+
+		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_RESERVED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
+			NETDEBUG(printk(KERN_INFO "IPv6: frag: no memory for new fragment!\n"));
+			err = -ENOMEM;
+			goto fail;
+		}
+
+		/*
+		 *	Set up data on packet
+		 */
+
+		ip6_copy_metadata(frag, skb);
+		skb_reserve(frag, LL_RESERVED_SPACE(rt->u.dst.dev));
+		skb_put(frag, len + hlen + sizeof(struct frag_hdr));
+		frag->nh.raw = frag->data;
+		fh = (struct frag_hdr*)(frag->data + hlen);
+		frag->h.raw = frag->data + hlen + sizeof(struct frag_hdr);
+
+		/*
+		 *	Charge the memory for the fragment to any owner
+		 *	it might possess
+		 */
+		if (skb->sk)
+			skb_set_owner_w(frag, skb->sk);
+
+		/*
+		 *	Copy the packet header into the new buffer.
+		 */
+		memcpy(frag->nh.raw, skb->data, hlen);
+
+		/*
+		 *	Build fragment header.
+		 */
+		fh->nexthdr = nexthdr;
+		fh->reserved = 0;
+		if (frag_id) {
+			ipv6_select_ident(skb, fh);
+			frag_id = fh->identification;
+		} else
+			fh->identification = frag_id;
+
+		/*
+		 *	Copy a block of the IP datagram.
+		 */
+		if (skb_copy_bits(skb, ptr, frag->h.raw, len))
+			BUG();
+		left -= len;
+
+		fh->frag_off = htons( left > 0 ?  (offset | 0x0001) : offset);
+		frag->nh.ipv6h->payload_len = htons(frag->len - sizeof(struct ipv6hdr));
+
+		ptr += len;
+		offset += len;
+
+		/*
+		 *	Put this fragment into the sending queue.
+		 */
+
+		IP6_INC_STATS(Ip6FragCreates);
+
+		err = output(frag);
+		if (err)
+			goto fail;
+	}
+	kfree_skb(skb);
+	IP6_INC_STATS(Ip6FragOKs);
+	return err;
+
+fail:
+	kfree_skb(skb); 
+	IP6_INC_STATS(Ip6FragFails);
+	return err;
+}
+
+int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi *fl, struct in6_addr **saddr)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	int err = 0;
+
+	*dst = __sk_dst_check(sk, np->dst_cookie);
+	if (*dst) {
+		struct rt6_info *rt = (struct rt6_info*)*dst;
+
+			/* Yes, checking route validity in not connected
+			   case is not very simple. Take into account,
+			   that we do not support routing by source, TOS,
+			   and MSG_DONTROUTE 		--ANK (980726)
+
+			   1. If route was host route, check that
+			      cached destination is current.
+			      If it is network route, we still may
+			      check its validity using saved pointer
+			      to the last used address: daddr_cache.
+			      We do not want to save whole address now,
+			      (because main consumer of this service
+			       is tcp, which has not this problem),
+			      so that the last trick works only on connected
+			      sockets.
+			   2. oif also should be the same.
+			 */
+
+		if (((rt->rt6i_dst.plen != 128 ||
+		      ipv6_addr_cmp(fl->fl6_dst, &rt->rt6i_dst.addr))
+		     && (np->daddr_cache == NULL ||
+			 ipv6_addr_cmp(fl->fl6_dst, np->daddr_cache)))
+		    || (fl->oif && fl->oif != (*dst)->dev->ifindex)) {
+			*dst = NULL;
+		} else
+			dst_hold(*dst);
+	}
+
+	if (*dst == NULL)
+		*dst = ip6_route_output(sk, fl);
+
+	if ((*dst)->error) {
+		IP6_INC_STATS(Ip6OutNoRoutes);
+		dst_release(*dst);
+		return -ENETUNREACH;
+	}
+
+	if (fl->fl6_src == NULL) {
+		*saddr = kmalloc(sizeof(struct in6_addr), GFP_ATOMIC);
+		err = ipv6_get_saddr(*dst, fl->fl6_dst, *saddr);
+
+		if (err) {
+#if IP6_DEBUG >= 2
+			printk(KERN_DEBUG "ip6_build_xmit: "
+			       "no availiable source address\n");
+#endif
+			return err;
+		}
+		fl->fl6_src = *saddr;
+	}
+
+        if (*dst) {
+		if ((err = xfrm_lookup(dst, fl, sk, 0)) < 0) {
+			dst_release(*dst);	
+			return -ENETUNREACH;
+		}
+        }
+
+	return 0;
+}
+
+int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb),
+		    void *from, int length, int transhdrlen,
+		    int hlimit, struct ipv6_txoptions *opt, struct flowi *fl, struct rt6_info *rt,
+		    unsigned int flags)
+{
+	struct inet_opt *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct sk_buff *skb;
+	unsigned int maxfraglen, fragheaderlen;
+	int exthdrlen;
+	int hh_len;
+	int mtu;
+	int copy = 0;
+	int err;
+	int offset = 0;
+	int csummode = CHECKSUM_NONE;
+
+	if (flags&MSG_PROBE)
+		return 0;
+	if (skb_queue_empty(&sk->write_queue)) {
+		/*
+		 * setup for corking
+		 */
+		if (opt) {
+			if (np->cork.opt == NULL)
+				np->cork.opt = kmalloc(opt->tot_len, sk->allocation);
+			memcpy(np->cork.opt, opt, opt->tot_len);
+			inet->cork.flags |= IPCORK_OPT;
+			/* need source address above miyazawa*/
+			exthdrlen += opt->opt_flen ? opt->opt_flen : 0;
+		}
+		dst_hold(&rt->u.dst);
+		np->cork.rt = rt;
+		np->cork.fl = fl;
+		inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
+		inet->cork.length = 0;
+		inet->sndmsg_page = NULL;
+		inet->sndmsg_off = 0;
+		if ((exthdrlen = rt->u.dst.header_len) != 0) {
+			length += exthdrlen;
+			transhdrlen += exthdrlen;
+		}
+	} else {
+		rt = np->cork.rt;
+		if (inet->cork.flags & IPCORK_OPT)
+			opt = np->cork.opt;
+		transhdrlen = 0;
+		exthdrlen = 0;
+		mtu = inet->cork.fragsize;
+	}
+
+	hh_len = (rt->u.dst.dev->hard_header_len&~15) + 16;
+
+	fragheaderlen = sizeof(struct ipv6hdr) + (opt ? opt->opt_nflen : 0);
+	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
+
+	if (mtu < 65576) {
+		if (inet->cork.length + length > 0xFFFF - fragheaderlen) {
+			ipv6_local_error(sk, EMSGSIZE, fl, mtu-exthdrlen);
+			return -EMSGSIZE;
+		}
+	}
+
+	inet->cork.length += length;
+
+	if ((skb = skb_peek_tail(&sk->write_queue)) == NULL)
+		goto alloc_new_skb;
+
+	while (length > 0) {
+		if ((copy = maxfraglen - skb->len) <= 0) {
+			char *data;
+			unsigned int datalen;
+			unsigned int fraglen;
+			unsigned int alloclen;
+			BUG_TRAP(copy == 0);
+alloc_new_skb:
+			datalen = maxfraglen - fragheaderlen;
+			if (datalen > length)
+				datalen = length;
+			fraglen = datalen + fragheaderlen;
+			if ((flags & MSG_MORE) &&
+			    !(rt->u.dst.dev->features&NETIF_F_SG))
+				alloclen = maxfraglen;
+			else
+				alloclen = fraglen;
+			alloclen += sizeof(struct frag_hdr);
+			if (transhdrlen) {
+				skb = sock_alloc_send_skb(sk,
+						alloclen + hh_len + 15,
+						(flags & MSG_DONTWAIT), &err);
+			} else {
+				skb = NULL;
+				if (atomic_read(&sk->wmem_alloc) <= 2*sk->sndbuf)
+					skb = sock_wmalloc(sk,
+							   alloclen + hh_len + 15, 1,
+							   sk->allocation);
+				if (unlikely(skb == NULL))
+					err = -ENOBUFS;
+			}
+			if (skb == NULL)
+				goto error;
+			/*
+			 *	Fill in the control structures
+			 */
+			skb->ip_summed = csummode;
+			skb->csum = 0;
+			/* reserve 8 byte for fragmentation */
+			skb_reserve(skb, hh_len+sizeof(struct frag_hdr));
+
+			/*
+			 *	Find where to start putting bytes
+			 */
+			data = skb_put(skb, fraglen);
+			skb->nh.raw = data + exthdrlen;
+			data += fragheaderlen;
+			skb->h.raw = data + exthdrlen;
+			copy = datalen - transhdrlen;
+			if (copy > 0 && getfrag(from, data + transhdrlen, offset, copy, 0, skb) < 0) {
+				err = -EFAULT;
+				kfree_skb(skb);
+				goto error;
+			}
+
+			offset += copy;
+			length -= datalen;
+			transhdrlen = 0;
+			exthdrlen = 0;
+			csummode = CHECKSUM_NONE;
+
+			/*
+			 * Put the packet on the pending queue
+			 */
+			__skb_queue_tail(&sk->write_queue, skb);
+			continue;
+		}
+
+		if (copy > length)
+			copy = length;
+
+		if (!(rt->u.dst.dev->features&NETIF_F_SG)) {
+			unsigned int off;
+
+			off = skb->len;
+			if (getfrag(from, skb_put(skb, copy),
+						offset, copy, off, skb) < 0) {
+				__skb_trim(skb, off);
+				err = -EFAULT;
+				goto error;
+			}
+		} else {
+			int i = skb_shinfo(skb)->nr_frags;
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i-1];
+			struct page *page = inet->sndmsg_page;
+			int off = inet->sndmsg_off;
+			unsigned int left;
+
+			if (page && (left = PAGE_SIZE - off) > 0) {
+				if (copy >= left)
+					copy = left;
+				if (page != frag->page) {
+					if (i == MAX_SKB_FRAGS) {
+						err = -EMSGSIZE;
+						goto error;
+					}
+					get_page(page);
+					skb_fill_page_desc(skb, i, page, inet->sndmsg_off, 0);
+					frag = &skb_shinfo(skb)->frags[i];
+				}
+			} else if(i < MAX_SKB_FRAGS) {
+				if (copy > PAGE_SIZE)
+					copy = PAGE_SIZE;
+				page = alloc_pages(sk->allocation, 0);
+				if (page == NULL) {
+					err = -ENOMEM;
+					goto error;
+				}
+				inet->sndmsg_page = page;
+				inet->sndmsg_off = 0;
+
+				skb_fill_page_desc(skb, i, page, 0, 0);
+				frag = &skb_shinfo(skb)->frags[i];
+				skb->truesize += PAGE_SIZE;
+				atomic_add(PAGE_SIZE, &sk->wmem_alloc);
+			} else {
+				err = -EMSGSIZE;
+				goto error;
+			}
+			if (getfrag(from, page_address(frag->page)+frag->page_offset+frag->size, offset, copy, skb->len, skb) < 0) {
+				err = -EFAULT;
+				goto error;
+			}
+			inet->sndmsg_off += copy;
+			frag->size += copy;
+			skb->len += copy;
+			skb->data_len += copy;
+		}
+		offset += copy;
+		length -= copy;
+	}
+	return 0;
+error:
+	inet->cork.length -= length;
+	IP6_INC_STATS(Ip6OutDiscards);
+	return err;
+}
+
+int ip6_push_pending_frames(struct sock *sk)
+{
+	struct sk_buff *skb, *tmp_skb;
+	struct sk_buff **tail_skb;
+	struct in6_addr *final_dst = NULL;
+	struct inet_opt *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct ipv6hdr *hdr;
+	struct ipv6_txoptions *opt = np->cork.opt;
+	struct rt6_info *rt = np->cork.rt;
+	struct flowi *fl = np->cork.fl;
+	unsigned char proto = fl->proto;
+	int err = 0;
+
+	if ((skb = __skb_dequeue(&sk->write_queue)) == NULL)
+		goto out;
+	tail_skb = &(skb_shinfo(skb)->frag_list);
+
+	/* move skb->data to ip header from ext header */
+	if (skb->data < skb->nh.raw)
+		__skb_pull(skb, skb->nh.raw - skb->data);
+	while ((tmp_skb = __skb_dequeue(&sk->write_queue)) != NULL) {
+		__skb_pull(tmp_skb, skb->h.raw - skb->nh.raw);
+		*tail_skb = tmp_skb;
+		tail_skb = &(tmp_skb->next);
+		skb->len += tmp_skb->len;
+		skb->data_len += tmp_skb->len;
+#if 0 /* Logically correct, but useless work, ip_fragment() will have to undo */
+		skb->truesize += tmp_skb->truesize;
+		__sock_put(tmp_skb->sk);
+		tmp_skb->destructor = NULL;
+		tmp_skb->sk = NULL;
+#endif
+	}
+
+	final_dst = fl->fl6_dst;
+	__skb_pull(skb, skb->h.raw - skb->nh.raw);
+	if (opt && opt->opt_flen)
+		ipv6_push_frag_opts(skb, opt, &proto);
+	if (opt && opt->opt_nflen)
+		ipv6_push_nfrag_opts(skb, opt, &proto, &final_dst);
+
+	skb->nh.ipv6h = hdr = (struct ipv6hdr*) skb_push(skb, sizeof(struct ipv6hdr));
+	
+	*(u32*)hdr = fl->fl6_flowlabel | htonl(0x60000000);
+
+	if (skb->len < 65536)
+		hdr->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
+	else
+		hdr->payload_len = 0;
+	hdr->hop_limit = np->hop_limit;
+	hdr->nexthdr = proto;
+	memcpy(&hdr->saddr, fl->fl6_src, sizeof(struct in6_addr));
+	memcpy(&hdr->daddr, final_dst, sizeof(struct in6_addr));
+
+	skb->dst = dst_clone(&rt->u.dst);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
+	if (err) {
+		if (err > 0)
+			err = inet->recverr ? net_xmit_errno(err) : 0;
+		if (err)
+			goto error;
+	}
+
+out:
+	inet->cork.flags &= ~IPCORK_OPT;
+	if (np->cork.opt) {
+		kfree(np->cork.opt);
+		np->cork.opt = NULL;
+	}
+	if (np->cork.rt) {
+		np->cork.rt = NULL;
+	}
+	if (np->cork.fl) {
+		np->cork.fl = NULL;
+	}
+	return err;
+error:
+	goto out;
+}
+
+void ip6_flush_pending_frames(struct sock *sk)
+{
+	struct inet_opt *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue_tail(&sk->write_queue)) != NULL)
+		kfree_skb(skb);
+
+	inet->cork.flags &= ~IPCORK_OPT;
+
+	if (np->cork.opt) {
+		kfree(np->cork.opt);
+		np->cork.opt = NULL;
+	}
+	if (np->cork.rt) {
+		np->cork.rt = NULL;
+	}
+	if (np->cork.fl) {
+		np->cork.fl = NULL;
+	}
 }
Index: net/ipv6/raw.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/raw.c,v
retrieving revision 1.1.1.6
retrieving revision 1.1.1.6.12.5
diff -u -u -r1.1.1.6 -r1.1.1.6.12.5
--- net/ipv6/raw.c	2 Apr 2003 04:16:14 -0000	1.1.1.6
+++ net/ipv6/raw.c	17 Apr 2003 01:43:15 -0000	1.1.1.6.12.5
@@ -12,6 +12,7 @@
  *	Fixes:
  *	Hideaki YOSHIFUJI	:	sin6_scope_id support
  *	YOSHIFUJI,H.@USAGI	:	raw checksum (RFC2292(bis) compliance) 
+ *	Kazunori MIYAZAWA @USAGI:	change process style to use ip6_append_data
  *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
@@ -29,6 +30,8 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/icmpv6.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 
@@ -435,87 +438,116 @@
 	goto out_free;
 }
 
-/*
- *	Sending...
- */
-
-struct rawv6_fakehdr {
-	struct iovec	*iov;
-	struct sock	*sk;
-	__u32		len;
-	__u32		cksum;
-	__u32		proto;
-	struct in6_addr *daddr;
-};
-
-static int rawv6_getfrag(const void *data, struct in6_addr *saddr, 
-			  char *buff, unsigned int offset, unsigned int len)
+static int rawv6_push_pending_frames(struct sock *sk, struct flowi *fl, struct raw6_opt *opt, int len)
 {
-	struct iovec *iov = (struct iovec *) data;
+	struct sk_buff *skb;
+	int err = 0;
+	u16 *csum;
 
-	return memcpy_fromiovecend(buff, iov, offset, len);
-}
+	if ((skb = skb_peek(&sk->write_queue)) == NULL)
+		goto out;
 
-static int rawv6_frag_cksum(const void *data, struct in6_addr *addr,
-			     char *buff, unsigned int offset, 
-			     unsigned int len)
-{
-	struct rawv6_fakehdr *hdr = (struct rawv6_fakehdr *) data;
-	
-	if (csum_partial_copy_fromiovecend(buff, hdr->iov, offset, 
-						    len, &hdr->cksum))
-		return -EFAULT;
-	
-	if (offset == 0) {
-		struct sock *sk;
-		struct raw6_opt *opt;
-		struct in6_addr *daddr;
-		
-		sk = hdr->sk;
-		opt = raw6_sk(sk);
+	if (opt->offset + 1 < len)
+		csum = (u16 *)(skb->h.raw + opt->offset);
+	else {
+		err = -EINVAL;
+		goto out;
+	}
 
-		if (hdr->daddr)
-			daddr = hdr->daddr;
-		else
-			daddr = addr + 1;
-		
-		hdr->cksum = csum_ipv6_magic(addr, daddr, hdr->len,
-					     hdr->proto, hdr->cksum);
-		
-		if (opt->offset + 1 < len) {
-			__u16 *csum;
+	if (skb_queue_len(&sk->write_queue) == 1) {
+		/*
+		 * Only one fragment on the socket.
+		 */
+		/* should be check HW csum miyazawa */
+		*csum = csum_ipv6_magic(fl->fl6_src,
+					     fl->fl6_dst,
+					     len, fl->proto, skb->csum);
+	} else {
+		u32 tmp_csum = 0;
 
-			csum = (__u16 *) (buff + opt->offset);
-			if (*csum) {
-				/* in case cksum was not initialized */
-				__u32 sum = hdr->cksum;
-				sum += *csum;
-				*csum = hdr->cksum = (sum + (sum>>16));
-			} else {
-				*csum = hdr->cksum;
-			}
-		} else {
-			if (net_ratelimit())
-				printk(KERN_DEBUG "icmp: cksum offset too big\n");
-			return -EINVAL;
+		skb_queue_walk(&sk->write_queue, skb) {
+			tmp_csum = csum_add(tmp_csum, skb->csum);
 		}
-	}	
-	return 0; 
+
+		tmp_csum = csum_ipv6_magic(fl->fl6_src,
+					fl->fl6_dst,
+					len, fl->proto, tmp_csum);
+		*csum = tmp_csum;
+	}
+	if (*csum == 0)
+		*csum = -1;
+	ip6_push_pending_frames(sk);
+out:
+	return err;
 }
 
+static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
+			struct flowi *fl, struct rt6_info *rt, 
+			unsigned int flags)
+{
+	struct inet_opt *inet = inet_sk(sk);
+	struct ipv6hdr *iph;
+	struct sk_buff *skb;
+	unsigned int hh_len;
+	int err;
+
+	if (length > rt->u.dst.dev->mtu) {
+		ipv6_local_error(sk, EMSGSIZE, fl, rt->u.dst.dev->mtu);
+		return -EMSGSIZE;
+	}
+	if (flags&MSG_PROBE)
+		goto out;
+
+	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
+
+	skb = sock_alloc_send_skb(sk, length+hh_len+15,
+				  flags&MSG_DONTWAIT, &err);
+	if (skb == NULL)
+		goto error; 
+	skb_reserve(skb, hh_len);
+
+	skb->priority = sk->priority;
+	skb->dst = dst_clone(&rt->u.dst);
+
+	skb->nh.ipv6h = iph = (struct ipv6hdr *)skb_put(skb, length);
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	skb->h.raw = skb->nh.raw;
+	err = memcpy_fromiovecend((void *)iph, from, 0, length);
+	if (err)
+		goto error_fault;
+
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
+		      dst_output);
+	if (err > 0)
+		err = inet->recverr ? net_xmit_errno(err) : 0;
+	if (err)
+		goto error;
+out:
+	return 0;
+
+error_fault:
+	err = -EFAULT;
+	kfree_skb(skb);
+error:
+	IP6_INC_STATS(Ip6OutDiscards);
+	return err; 
+}
 
 static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg, int len)
 {
 	struct ipv6_txoptions opt_space;
 	struct sockaddr_in6 * sin6 = (struct sockaddr_in6 *) msg->msg_name;
+	struct in6_addr *daddr, *saddr = NULL;
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct raw6_opt *raw_opt = raw6_sk(sk);
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
+	struct dst_entry *dst = NULL;
 	struct flowi fl;
 	int addr_len = msg->msg_namelen;
-	struct in6_addr *daddr;
-	struct raw6_opt *raw_opt;
 	int hlimit = -1;
 	u16 proto;
 	int err;
@@ -549,6 +581,8 @@
 
 		if (!proto)
 			proto = inet->num;
+		else if (proto != inet->num)
+			return(-EINVAL);
 
 		if (proto > 255)
 			return(-EINVAL);
@@ -587,6 +621,7 @@
 		 * unspecfied destination address 
 		 * treated as error... is this correct ?
 		 */
+		fl6_sock_release(flowlabel);
 		return(-EINVAL);
 	}
 
@@ -616,39 +651,71 @@
 	if (flowlabel)
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 
-	raw_opt = raw6_sk(sk);
-
 	fl.proto = proto;
 	fl.fl6_dst = daddr;
 	if (fl.fl6_src == NULL && !ipv6_addr_any(&np->saddr))
 		fl.fl6_src = &np->saddr;
 	fl.uli_u.icmpt.type = 0;
 	fl.uli_u.icmpt.code = 0;
-	
-	if (raw_opt->checksum) {
-		struct rawv6_fakehdr hdr;
-		
-		hdr.iov = msg->msg_iov;
-		hdr.sk  = sk;
-		hdr.len = len;
-		hdr.cksum = 0;
-		hdr.proto = proto;
 
-		if (opt && opt->srcrt)
-			hdr.daddr = daddr;
+	/* merge ip6_build_xmit from ip6_output */
+	if (opt && opt->srcrt) {
+		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
+		fl.fl6_dst = rt0->addr;
+	}
+
+	if (!fl.oif && ipv6_addr_is_multicast(fl.nl_u.ip6_u.daddr))
+		fl.oif = np->mcast_oif;
+
+	err = ip6_dst_lookup(sk, &dst, &fl, &saddr);
+	if (err) goto out;
+
+	if (hlimit < 0) {
+		if (ipv6_addr_is_multicast(fl.fl6_dst))
+			hlimit = np->mcast_hops;
 		else
-			hdr.daddr = NULL;
+			hlimit = np->hop_limit;
+		if (hlimit < 0)
+			hlimit = ((struct rt6_info*)dst)->rt6i_hoplimit;
+	}
+
+	if (msg->msg_flags&MSG_CONFIRM)
+		goto do_confirm;
 
-		err = ip6_build_xmit(sk, rawv6_frag_cksum, &hdr, &fl, len,
-				     opt, hlimit, msg->msg_flags);
+back_from_confirm:
+	if (inet->hdrincl) {
+		err = rawv6_send_hdrinc(sk, msg->msg_iov, len, &fl, (struct rt6_info*)dst, msg->msg_flags);
 	} else {
-		err = ip6_build_xmit(sk, rawv6_getfrag, msg->msg_iov, &fl, len,
-				     opt, hlimit, msg->msg_flags);
+		lock_sock(sk);
+		err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov, len, 0,
+					hlimit, opt, &fl, (struct rt6_info*)dst, msg->msg_flags);
+
+		if (err)
+			ip6_flush_pending_frames(sk);
+		else if (!(msg->msg_flags & MSG_MORE)) {
+			if (raw_opt->checksum) {
+				err = rawv6_push_pending_frames(sk, &fl, raw_opt, len);
+			} else {
+				err = ip6_push_pending_frames(sk);
+			}
+		}
 	}
+done:
+	ip6_dst_store(sk, dst, fl.nl_u.ip6_u.daddr == &np->daddr ? &np->daddr : NULL);
+	if (err > 0)
+		err = np->recverr ? net_xmit_errno(err) : 0;
 
+	release_sock(sk);
+out:	
 	fl6_sock_release(flowlabel);
-
+	if (saddr) kfree(saddr);
 	return err<0?err:len;
+do_confirm:
+	dst_confirm(dst);
+	if (!(msg->msg_flags & MSG_PROBE) || len)
+		goto back_from_confirm;
+	err = 0;
+	goto done;
 }
 
 static int rawv6_seticmpfilter(struct sock *sk, int level, int optname, 
Index: net/ipv6/udp.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/udp.c,v
retrieving revision 1.1.1.9
retrieving revision 1.1.1.9.12.4
diff -u -u -r1.1.1.9 -r1.1.1.9.12.4
--- net/ipv6/udp.c	2 Apr 2003 04:16:14 -0000	1.1.1.9
+++ net/ipv6/udp.c	17 Apr 2003 01:43:15 -0000	1.1.1.9.12.4
@@ -14,6 +14,7 @@
  *	YOSHIFUJI Hideaki @USAGI and:	Support IPV6_V6ONLY socket option, which
  *	Alexey Kuznetsov		allow both IPv4 and IPv6 sockets to bind
  *					a single port at the same time.
+ *      Kazunori MIYAZAWA @USAGI:       change process style to use ip6_append_data
  *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
@@ -738,96 +739,117 @@
 	kfree_skb(skb);
 	return(0);	
 }
-
 /*
- *	Sending
+ * Throw away all pending data and cancel the corking. Socket is locked.
  */
-
-struct udpv6fakehdr 
+static void udp_v6_flush_pending_frames(struct sock *sk)
 {
-	struct udphdr	uh;
-	struct iovec	*iov;
-	__u32		wcheck;
-	__u32		pl_len;
-	struct in6_addr *daddr;
-};
+	struct udp_opt *up = udp_sk(sk);
+
+	if (up->pending) {
+		up->pending = 0;
+		ip6_flush_pending_frames(sk);
+        }
+}
 
 /*
- *	with checksum
+ *	Sending
  */
 
-static int udpv6_getfrag(const void *data, struct in6_addr *addr,
-			 char *buff, unsigned int offset, unsigned int len)
+static int udp_v6_push_pending_frames(struct sock *sk, struct udp_opt *up)
 {
-	struct udpv6fakehdr *udh = (struct udpv6fakehdr *) data;
-	char *dst;
-	int final = 0;
-	int clen = len;
+	struct sk_buff *skb;
+	struct udphdr *uh;
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct flowi *fl = np->cork.fl;
+	int err = 0;
 
-	dst = buff;
+	/* Grab the skbuff where UDP header space exists. */
+	if ((skb = skb_peek(&sk->write_queue)) == NULL)
+		goto out;
 
-	if (offset) {
-		offset -= sizeof(struct udphdr);
+	/*
+	 * Create a UDP header
+	 */
+	uh = skb->h.uh;
+	uh->source = fl->uli_u.ports.sport;
+	uh->dest = fl->uli_u.ports.dport;
+	uh->len = htons(up->len);
+	uh->check = 0;
+
+	if (sk->no_check == UDP_CSUM_NOXMIT) {
+		skb->ip_summed = CHECKSUM_NONE;
+		goto send;
+	}
+
+	if (skb_queue_len(&sk->write_queue) == 1) {
+		skb->csum = csum_partial((char *)uh,
+				sizeof(struct udphdr), skb->csum);
+		uh->check = csum_ipv6_magic(fl->fl6_src,
+					    fl->fl6_dst,
+					    up->len, fl->proto, skb->csum);
 	} else {
-		dst += sizeof(struct udphdr);
-		final = 1;
-		clen -= sizeof(struct udphdr);
-	}
-
-	if (csum_partial_copy_fromiovecend(dst, udh->iov, offset,
-					   clen, &udh->wcheck))
-		return -EFAULT;
+		u32 tmp_csum = 0;
 
-	if (final) {
-		struct in6_addr *daddr;
-		
-		udh->wcheck = csum_partial((char *)udh, sizeof(struct udphdr),
-					   udh->wcheck);
-
-		if (udh->daddr) {
-			daddr = udh->daddr;
-		} else {
-			/*
-			 *	use packet destination address
-			 *	this should improve cache locality
-			 */
-			daddr = addr + 1;
-		}
-		udh->uh.check = csum_ipv6_magic(addr, daddr,
-						udh->pl_len, IPPROTO_UDP,
-						udh->wcheck);
-		if (udh->uh.check == 0)
-			udh->uh.check = -1;
+		skb_queue_walk(&sk->write_queue, skb) {
+			tmp_csum = csum_add(tmp_csum, skb->csum);
+		}
+		tmp_csum = csum_partial((char *)uh,
+				sizeof(struct udphdr), tmp_csum);
+                tmp_csum = csum_ipv6_magic(fl->fl6_src,
+					   fl->fl6_dst,
+					   up->len, fl->proto, tmp_csum);
+                uh->check = tmp_csum;
 
-		memcpy(buff, udh, sizeof(struct udphdr));
 	}
-	return 0;
+	if (uh->check == 0)
+		uh->check = -1;
+
+send:
+	err = ip6_push_pending_frames(sk);
+out:
+	up->len = 0;
+	up->pending = 0;
+	return err;
 }
 
-static int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg, int ulen)
+static int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg, int len)
 {
 	struct ipv6_txoptions opt_space;
-	struct udpv6fakehdr udh;
+	struct udp_opt *up = udp_sk(sk);
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) msg->msg_name;
+	struct in6_addr *daddr, *saddr = NULL;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
 	struct flowi fl;
+	struct dst_entry *dst;
 	int addr_len = msg->msg_namelen;
-	struct in6_addr *daddr;
-	int len = ulen + sizeof(struct udphdr);
+	int ulen = len;
 	int addr_type;
 	int hlimit = -1;
-	
+	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int err;
 	
 	/* Rough check on arithmetic overflow,
 	   better check is made in ip6_build_xmit
 	   */
-	if (ulen < 0 || ulen > INT_MAX - sizeof(struct udphdr))
+	if (len < 0 || len > INT_MAX - sizeof(struct udphdr))
 		return -EMSGSIZE;
 	
+	if (up->pending) {
+		/*
+		 * There are pending frames.
+		 * The socket lock must be held while it's corked.
+		 */
+		lock_sock(sk);
+		if (likely(up->pending))
+			goto do_append_data;
+		release_sock(sk);
+	}
+	ulen += sizeof(struct udphdr);
+
 	fl.fl6_flowlabel = 0;
 	fl.oif = 0;
 
@@ -835,7 +857,7 @@
 		if (sin6->sin6_family == AF_INET) {
 			if (__ipv6_only_sock(sk))
 				return -ENETUNREACH;
-			return udp_sendmsg(iocb, sk, msg, ulen);
+			return udp_sendmsg(iocb, sk, msg, len);
 		}
 
 		if (addr_len < SIN6_LEN_RFC2133)
@@ -847,7 +869,7 @@
 		if (sin6->sin6_port == 0)
 			return -EINVAL;
 
-		udh.uh.dest = sin6->sin6_port;
+		up->dport = sin6->sin6_port;
 		daddr = &sin6->sin6_addr;
 
 		if (np->sndflow) {
@@ -873,7 +895,7 @@
 		if (sk->state != TCP_ESTABLISHED)
 			return -ENOTCONN;
 
-		udh.uh.dest = inet->dport;
+		up->dport = inet->dport;
 		daddr = &np->daddr;
 		fl.fl6_flowlabel = np->flow_label;
 	}
@@ -888,15 +910,14 @@
 
 		sin.sin_family = AF_INET;
 		sin.sin_addr.s_addr = daddr->s6_addr32[3];
-		sin.sin_port = udh.uh.dest;
+		sin.sin_port = up->dport;
 		msg->msg_name = (struct sockaddr *)(&sin);
 		msg->msg_namelen = sizeof(sin);
 		fl6_sock_release(flowlabel);
 
-		return udp_sendmsg(iocb, sk, msg, ulen);
+		return udp_sendmsg(iocb, sk, msg, len);
 	}
 
-	udh.daddr = NULL;
 	if (!fl.oif)
 		fl.oif = sk->bound_dev_if;
 	fl.fl6_src = NULL;
@@ -922,33 +943,172 @@
 		opt = np->opt;
 	if (flowlabel)
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
-	if (opt && opt->srcrt)
-		udh.daddr = daddr;
-
-	udh.uh.source = inet->sport;
-	udh.uh.len = len < 0x10000 ? htons(len) : 0;
-	udh.uh.check = 0;
-	udh.iov = msg->msg_iov;
-	udh.wcheck = 0;
-	udh.pl_len = len;
 
 	fl.proto = IPPROTO_UDP;
 	fl.fl6_dst = daddr;
 	if (fl.fl6_src == NULL && !ipv6_addr_any(&np->saddr))
 		fl.fl6_src = &np->saddr;
-	fl.uli_u.ports.dport = udh.uh.dest;
-	fl.uli_u.ports.sport = udh.uh.source;
+	fl.uli_u.ports.dport = up->dport;
+	fl.uli_u.ports.sport = inet->sport;
+	
+	/* merge ip6_build_xmit from ip6_output */
+	if (opt && opt->srcrt) {
+		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
+		fl.fl6_dst = rt0->addr;
+	}
 
-	err = ip6_build_xmit(sk, udpv6_getfrag, &udh, &fl, len, opt, hlimit,
-			     msg->msg_flags);
+	if (!fl.oif && ipv6_addr_is_multicast(fl.nl_u.ip6_u.daddr))
+		fl.oif = np->mcast_oif;
 
+	err = ip6_dst_lookup(sk, &dst, &fl, &saddr);
+	if (err) goto out;
+
+	if (hlimit < 0) {
+		if (ipv6_addr_is_multicast(fl.fl6_dst))
+			hlimit = np->mcast_hops;
+		else
+			hlimit = np->hop_limit;
+		if (hlimit < 0)
+			hlimit = ((struct rt6_info*)dst)->rt6i_hoplimit;
+	}
+
+	if (msg->msg_flags&MSG_CONFIRM)
+		goto do_confirm;
+back_from_confirm:
+
+	lock_sock(sk);
+	if (unlikely(up->pending)) {
+		/* The socket is already corked while preparing it. */
+		/* ... which is an evident application bug. --ANK */
+		release_sock(sk);
+
+		NETDEBUG(if (net_ratelimit()) printk(KERN_DEBUG "udp cork app bug 2\n"));
+		err = -EINVAL;
+		goto out;
+	}
+
+	up->pending = 1;
+
+do_append_data:
+	up->len += ulen;
+	err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov, ulen, sizeof(struct udphdr),
+			      hlimit, opt, &fl, (struct rt6_info*)dst,
+			      corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
+	if (err)
+		udp_v6_flush_pending_frames(sk);
+	else if (!corkreq)
+			err = udp_v6_push_pending_frames(sk, up);
+
+	ip6_dst_store(sk, dst, fl.nl_u.ip6_u.daddr == &np->daddr ? &np->daddr : NULL);
+	if (err > 0)
+		err = np->recverr ? net_xmit_errno(err) : 0;
+	release_sock(sk);
+out:
 	fl6_sock_release(flowlabel);
+	if (saddr) kfree(saddr);
+	if (!err) {
+		UDP_INC_STATS_USER(UdpOutDatagrams);
+		return len;
+	}
+	return err;
 
-	if (err < 0)
-		return err;
+do_confirm:
+	dst_confirm(dst);
+	if (!(msg->msg_flags&MSG_PROBE) || len)
+		goto back_from_confirm;
+	err = 0;
+	goto out;
+}
+
+static int udpv6_destroy_sock(struct sock *sk)
+{
+	lock_sock(sk);
+	udp_v6_flush_pending_frames(sk);
+	release_sock(sk);
+
+	inet6_destroy_sock(sk);
+
+	return 0;
+}
+
+/*
+ *	Socket option code for UDP
+ */
+static int udpv6_setsockopt(struct sock *sk, int level, int optname, 
+			  char *optval, int optlen)
+{
+	struct udp_opt *up = udp_sk(sk);
+	int val;
+	int err = 0;
+
+	if (level != SOL_UDP)
+		return ipv6_setsockopt(sk, level, optname, optval, optlen);
 
-	UDP6_INC_STATS_USER(UdpOutDatagrams);
-	return ulen;
+	if(optlen<sizeof(int))
+		return -EINVAL;
+
+	if (get_user(val, (int *)optval))
+		return -EFAULT;
+
+	switch(optname) {
+	case UDP_CORK:
+		if (val != 0) {
+			up->corkflag = 1;
+		} else {
+			up->corkflag = 0;
+			lock_sock(sk);
+			udp_v6_push_pending_frames(sk, up);
+			release_sock(sk);
+		}
+		break;
+		
+	case UDP_ENCAP:
+		up->encap_type = val;
+		break;
+
+	default:
+		err = -ENOPROTOOPT;
+		break;
+	};
+
+	return err;
+}
+
+static int udpv6_getsockopt(struct sock *sk, int level, int optname, 
+			  char *optval, int *optlen)
+{
+	struct udp_opt *up = udp_sk(sk);
+	int val, len;
+
+	if (level != SOL_UDP)
+		return ipv6_getsockopt(sk, level, optname, optval, optlen);
+
+	if(get_user(len,optlen))
+		return -EFAULT;
+
+	len = min_t(unsigned int, len, sizeof(int));
+	
+	if(len < 0)
+		return -EINVAL;
+
+	switch(optname) {
+	case UDP_CORK:
+		val = up->corkflag;
+		break;
+
+	case UDP_ENCAP:
+		val = up->encap_type;
+		break;
+
+	default:
+		return -ENOPROTOOPT;
+	};
+
+  	if(put_user(len, optlen))
+  		return -EFAULT;
+	if(copy_to_user(optval, &val,len))
+		return -EFAULT;
+  	return 0;
 }
 
 static struct inet6_protocol udpv6_protocol = {
@@ -1038,9 +1198,9 @@
 	.connect =	udpv6_connect,
 	.disconnect =	udp_disconnect,
 	.ioctl =	udp_ioctl,
-	.destroy =	inet6_destroy_sock,
-	.setsockopt =	ipv6_setsockopt,
-	.getsockopt =	ipv6_getsockopt,
+	.destroy =	udpv6_destroy_sock,
+	.setsockopt =	udpv6_setsockopt,
+	.getsockopt =	udpv6_getsockopt,
 	.sendmsg =	udpv6_sendmsg,
 	.recvmsg =	udpv6_recvmsg,
 	.backlog_rcv =	udpv6_queue_rcv_skb,
