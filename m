From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: RFC: cleaning up struct sk_buff before halloween
Date: Mon, 30 Sep 2002 19:53:56 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020930225356.GC15297@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

	Please take a look at the patch below and tell me what are you thoughts
about it. The idea is similar to what I did with struct sock, i.e., get rid of
protocol specific stuff in generic networking data structures. This is already
how LLC and IPX works.

	The patch only deals with skb->nh.{arph,iph}, and it is surprisingly
small due to the fact that most of the code already did:

struct iphdr *iph = skb->nh.iph;

so I only had to replace with:

struct iphdr *iph = ip_hdr(skb);

	When everything would be finished, skb->nh would stop being a union and
become a void pointer.

	It'd be smaller if I had resisted the itch to do a
s/__constant_htons/htons/g where __constant_ is not needed 8)

	If you think that this is something doable for 2.6, I'll break the
changeset into smaller chunks, per subsystem, etc.

	I understand that with the ongoing USAGI merge this could cause some
clashes, but I don't think it would be that much of a problem, as most of the
places, as I stated above, already use iph-> style access, so the hunks are
rather localized.

	Now off to a party celebrating the birth of a close friend first
daughter :-)

Best Regards,

- Arnaldo

===== drivers/net/8139cp.c 1.33 vs edited =====
--- 1.33/drivers/net/8139cp.c	Mon Sep 30 03:09:02 2002
+++ edited/drivers/net/8139cp.c	Mon Sep 30 19:22:22 2002
@@ -792,7 +792,7 @@
 
 #ifdef CP_TX_CHECKSUM
 		if (skb->ip_summed == CHECKSUM_HW) {
-			const struct iphdr *ip = skb->nh.iph;
+			const struct iphdr *ip = ip_hdr(skb);
 			if (ip->protocol == IPPROTO_TCP)
 				txd->opts1 = cpu_to_le32(eor | len | DescOwn |
 							 FirstFrag | LastFrag |
@@ -819,7 +819,7 @@
 		dma_addr_t first_mapping;
 		int frag, first_entry = entry;
 #ifdef CP_TX_CHECKSUM
-		const struct iphdr *ip = skb->nh.iph;
+		const struct iphdr *ip = ip_hdr(skb);
 #endif
 
 		/* We must give this initial chunk to the device last.
===== drivers/net/loopback.c 1.7 vs edited =====
--- 1.7/drivers/net/loopback.c	Thu Aug 29 05:51:36 2002
+++ edited/drivers/net/loopback.c	Mon Sep 30 19:22:22 2002
@@ -65,7 +65,7 @@
 
 static void emulate_large_send_offload(struct sk_buff *skb)
 {
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *th = (struct tcphdr*)(skb->nh.raw + (iph->ihl * 4));
 	unsigned int doffset = (iph->ihl + th->doff) * 4;
 	unsigned int mtu = skb_shinfo(skb)->tso_size + doffset;
@@ -82,7 +82,7 @@
 		skb_reserve(nskb, 32);
 		nskb->mac.raw = nskb->data - 14;
 		nskb->nh.raw = nskb->data;
-		iph = nskb->nh.iph;
+		iph = ip_hdr(nskb);
 		memcpy(nskb->data, skb->nh.raw, doffset);
 		if (skb_copy_bits(skb,
 				  doffset + offset,
@@ -148,7 +148,7 @@
 #endif
 
 	if (skb_shinfo(skb)->tso_size) {
-		struct iphdr *iph = skb->nh.iph;
+		struct iphdr *iph = ip_hdr(skb);
 
 		if (skb->protocol != htons(ETH_P_IP))
 			BUG();
===== drivers/net/ns83820.c 1.15 vs edited =====
--- 1.15/drivers/net/ns83820.c	Fri Aug 30 22:32:17 2002
+++ edited/drivers/net/ns83820.c	Mon Sep 30 19:22:22 2002
@@ -1039,9 +1039,9 @@
 	extsts = 0;
 	if (skb->ip_summed == CHECKSUM_HW) {
 		extsts |= EXTSTS_IPPKT;
-		if (IPPROTO_TCP == skb->nh.iph->protocol)
+		if (IPPROTO_TCP == ip_hdr(skb)->protocol)
 			extsts |= EXTSTS_TCPPKT;
-		else if (IPPROTO_UDP == skb->nh.iph->protocol)
+		else if (IPPROTO_UDP == ip_hdr(skb)->protocol)
 			extsts |= EXTSTS_UDPPKT;
 	}
 
===== drivers/net/e100/e100_main.c 1.25 vs edited =====
--- 1.25/drivers/net/e100/e100_main.c	Thu Sep 19 20:58:59 2002
+++ edited/drivers/net/e100/e100_main.c	Mon Sep 30 19:22:22 2002
@@ -2244,7 +2244,7 @@
 	tcb->tcb_skb = skb;
 
 	if (skb->ip_summed == CHECKSUM_HW) {
-		const struct iphdr *ip = skb->nh.iph;
+		const struct iphdr *ip = ip_hdr(skb);
 
 		if ((ip->protocol == IPPROTO_TCP) ||
 		    (ip->protocol == IPPROTO_UDP)) {
===== drivers/net/e1000/e1000_main.c 1.31 vs edited =====
--- 1.31/drivers/net/e1000/e1000_main.c	Thu Aug 29 07:37:43 2002
+++ edited/drivers/net/e1000/e1000_main.c	Mon Sep 30 19:22:22 2002
@@ -1303,17 +1303,16 @@
 	uint16_t ipcse, tucse, mss;
 	
 	if(skb_shinfo(skb)->tso_size) {
+		struct iphdr *iph = ip_hdr(skb);
+
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
 		mss = skb_shinfo(skb)->tso_size;
-		skb->nh.iph->tot_len = 0;
-		skb->nh.iph->check = 0;
-		skb->h.th->check = ~csum_tcpudp_magic(skb->nh.iph->saddr,
-		                                      skb->nh.iph->daddr,
-		                                      0,
-		                                      IPPROTO_TCP,
-		                                      0);
+		iph->tot_len = 0;
+		iph->check = 0;
+		skb->h.th->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+		                                      0, IPPROTO_TCP, 0);
 		ipcss = skb->nh.raw - skb->data;
-		ipcso = (void *)&(skb->nh.iph->check) - (void *)skb->data;
+		ipcso = (void *)&(iph->check) - (void *)skb->data;
 		ipcse = skb->h.raw - skb->data - 1;
 		tucss = skb->h.raw - skb->data;
 		tucso = (void *)&(skb->h.th->check) - (void *)skb->data;
===== include/linux/if_arp.h 1.8 vs edited =====
--- 1.8/include/linux/if_arp.h	Tue Feb  5 13:23:43 2002
+++ edited/include/linux/if_arp.h	Mon Sep 30 19:35:34 2002
@@ -145,4 +145,6 @@
 
 };
 
+#define arp_hdr(skb) ((struct arphdr *)(skb)->nh.raw)
+
 #endif	/* _LINUX_IF_ARP_H */
===== include/linux/ip.h 1.3 vs edited =====
--- 1.3/include/linux/ip.h	Mon Mar 11 10:46:43 2002
+++ edited/include/linux/ip.h	Mon Sep 30 19:36:07 2002
@@ -176,4 +176,6 @@
 	/*The options start here. */
 };
 
+#define ip_hdr(skb) ((struct iphdr *)(skb)->nh.raw)
+
 #endif	/* _LINUX_IP_H */
===== include/linux/skbuff.h 1.14 vs edited =====
--- 1.14/include/linux/skbuff.h	Thu Aug 29 05:51:36 2002
+++ edited/include/linux/skbuff.h	Mon Sep 30 19:34:59 2002
@@ -189,9 +189,7 @@
 	} h;
 
 	union {
-		struct iphdr	*iph;
 		struct ipv6hdr	*ipv6h;
-		struct arphdr	*arph;
 		unsigned char	*raw;
 	} nh;
 
===== net/atm/mpc.c 1.5 vs edited =====
--- 1.5/net/atm/mpc.c	Fri Jul 19 03:16:19 2002
+++ edited/net/atm/mpc.c	Mon Sep 30 19:22:22 2002
@@ -726,7 +726,7 @@
 	new_skb->protocol = eth_type_trans(new_skb, dev);
 	new_skb->nh.raw = new_skb->data;
 
-	eg->latest_ip_addr = new_skb->nh.iph->saddr;
+	eg->latest_ip_addr = ip_hdr(new_skb)->saddr;
 	eg->packets_rcvd++;
 	mpc->eg_ops->put(eg);
 
===== net/bridge/netfilter/ebt_log.c 1.1 vs edited =====
--- 1.1/net/bridge/netfilter/ebt_log.c	Mon Sep 16 20:11:27 2002
+++ edited/net/bridge/netfilter/ebt_log.c	Mon Sep 30 19:41:29 2002
@@ -60,16 +60,16 @@
 
 	if ((info->bitmask & EBT_LOG_IP) && skb->mac.ethernet->h_proto ==
 	   htons(ETH_P_IP)){
-		struct iphdr *iph = skb->nh.iph;
+		struct iphdr *iph = ip_hdr(skb);
 		printk(" IP SRC=%u.%u.%u.%u IP DST=%u.%u.%u.%u,",
 		   NIPQUAD(iph->saddr), NIPQUAD(iph->daddr));
 		printk(" IP tos=0x%02X, IP proto=%d", iph->tos, iph->protocol);
 	}
 
 	if ((info->bitmask & EBT_LOG_ARP) &&
-	    ((skb->mac.ethernet->h_proto == __constant_htons(ETH_P_ARP)) ||
-	    (skb->mac.ethernet->h_proto == __constant_htons(ETH_P_RARP)))) {
-		struct arphdr * arph = skb->nh.arph;
+	    ((skb->mac.ethernet->h_proto == htons(ETH_P_ARP)) ||
+	    (skb->mac.ethernet->h_proto == htons(ETH_P_RARP)))) {
+		struct arphdr *arph = arp_hdr(skb);
 		printk(" ARP HTYPE=%d, PTYPE=0x%04x, OPCODE=%d",
 		   ntohs(arph->ar_hrd), ntohs(arph->ar_pro),
 		   ntohs(arph->ar_op));
===== net/core/netfilter.c 1.7 vs edited =====
--- 1.7/net/core/netfilter.c	Wed May  1 06:23:51 2002
+++ edited/net/core/netfilter.c	Mon Sep 30 19:22:22 2002
@@ -178,7 +178,7 @@
 	       skb->len);
 	switch (pf) {
 	case PF_INET: {
-		const struct iphdr *ip = skb->nh.iph;
+		const struct iphdr *ip = ip_hdr(skb);
 		__u32 *opt = (__u32 *) (ip + 1);
 		int opti;
 		__u16 src_port = 0, dst_port = 0;
@@ -561,7 +561,7 @@
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
 int ip_route_me_harder(struct sk_buff **pskb)
 {
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	struct rtable *rt;
 	struct rt_key key = { dst:iph->daddr,
 			      src:iph->saddr,
===== net/econet/af_econet.c 1.9 vs edited =====
--- 1.9/net/econet/af_econet.c	Wed Aug 28 10:42:25 2002
+++ edited/net/econet/af_econet.c	Mon Sep 30 19:22:22 2002
@@ -817,7 +817,7 @@
 
 static void aun_incoming(struct sk_buff *skb, struct aunhdr *ah, size_t len)
 {
-	struct iphdr *ip = skb->nh.iph;
+	struct iphdr *ip = ip_hdr(skb);
 	unsigned char stn = ntohl(ip->saddr) & 0xff;
 	struct sock *sk;
 	struct sk_buff *newskb;
@@ -915,7 +915,7 @@
 	data = skb->h.raw + sizeof(struct udphdr);
 	ah = (struct aunhdr *)data;
 	len = skb->len - sizeof(struct udphdr);
-	ip = skb->nh.iph;
+	ip = ip_hdr(skb);
 
 	switch (ah->code)
 	{
===== net/ipv4/arp.c 1.10 vs edited =====
--- 1.10/net/ipv4/arp.c	Fri Jul 19 03:16:19 2002
+++ edited/net/ipv4/arp.c	Mon Sep 30 19:22:22 2002
@@ -322,8 +322,8 @@
 	u32 target = *(u32*)neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
 
-	if (skb && inet_addr_type(skb->nh.iph->saddr) == RTN_LOCAL)
-		saddr = skb->nh.iph->saddr;
+	if (skb && inet_addr_type(ip_hdr(skb)->saddr) == RTN_LOCAL)
+		saddr = ip_hdr(skb)->saddr;
 	else
 		saddr = inet_select_addr(dev, target, RT_SCOPE_LINK);
 
@@ -624,7 +624,7 @@
 	if (in_dev == NULL)
 		goto out;
 
-	arp = skb->nh.arph;
+	arp = arp_hdr(skb);
 	arp_ptr= (unsigned char *)(arp+1);
 
 	switch (dev_type) {
@@ -823,7 +823,7 @@
 
 int arp_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt)
 {
-	struct arphdr *arp = skb->nh.arph;
+	struct arphdr *arp = arp_hdr(skb);
 
 	if (arp->ar_hln != dev->addr_len ||
 	    dev->flags & IFF_NOARP ||
===== net/ipv4/icmp.c 1.18 vs edited =====
--- 1.18/net/ipv4/icmp.c	Fri Jul 19 03:16:19 2002
+++ edited/net/ipv4/icmp.c	Mon Sep 30 19:22:22 2002
@@ -409,7 +409,7 @@
 	icmp_param->csum = 0;
 	icmp_out_count(icmp_param->data.icmph.type);
 
-	inet->tos = skb->nh.iph->tos;
+	inet->tos = ip_hdr(skb)->tos;
 	inet->ttl = sysctl_ip_default_ttl;
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
@@ -419,7 +419,7 @@
 			daddr = icmp_param->replyopts.faddr;
 	}
 	if (ip_route_output(&rt, daddr, rt->rt_spec_dst,
-			    RT_TOS(skb->nh.iph->tos), 0))
+			    RT_TOS(ip_hdr(skb)->tos), 0))
 		goto out_unlock;
 	if (icmpv4_xrlim_allow(rt, icmp_param->data.icmph.type,
 			       icmp_param->data.icmph.code)) {
@@ -463,7 +463,7 @@
 	 *	Check this, icmp_send is called from the most obscure devices
 	 *	sometimes.
 	 */
-	iph = skb_in->nh.iph;
+	iph = ip_hdr(skb_in);
 
 	if ((u8 *)iph < skb_in->head || (u8 *)(iph + 1) > skb_in->tail)
 		goto out;
@@ -682,7 +682,7 @@
 		if (net_ratelimit())
 			printk(KERN_WARNING "%u.%u.%u.%u sent an invalid ICMP "
 					    "error to a broadcast.\n",
-			       NIPQUAD(skb->nh.iph->saddr));
+			       NIPQUAD(ip_hdr(skb)->saddr));
 		goto out;
 	}
 
@@ -774,7 +774,7 @@
 			 */
 		case ICMP_REDIR_HOST:
 		case ICMP_REDIR_HOSTTOS:
-			ip_rt_redirect(skb->nh.iph->saddr,
+			ip_rt_redirect(ip_hdr(skb)->saddr,
 				       ip, skb->h.icmph->un.gateway,
 				       iph->saddr, iph->tos, skb->dev);
 			break;
===== net/ipv4/igmp.c 1.7 vs edited =====
--- 1.7/net/ipv4/igmp.c	Fri Aug 30 21:47:02 2002
+++ edited/net/ipv4/igmp.c	Mon Sep 30 19:22:22 2002
@@ -224,7 +224,7 @@
 
 	skb_reserve(skb, (dev->hard_header_len+15)&~15);
 
-	skb->nh.iph = iph = (struct iphdr *)skb_put(skb, sizeof(struct iphdr)+4);
+	iph = ip_hdr(skb) = (struct iphdr *)skb_put(skb, sizeof(*iph) + 4);
 
 	iph->version  = 4;
 	iph->ihl      = (sizeof(struct iphdr)+4)>>2;
===== net/ipv4/ip_forward.c 1.2 vs edited =====
--- 1.2/net/ipv4/ip_forward.c	Tue Feb  5 05:39:17 2002
+++ edited/net/ipv4/ip_forward.c	Mon Sep 30 19:22:22 2002
@@ -92,7 +92,7 @@
 	 *	that the packet's lifetime expired.
 	 */
 
-	iph = skb->nh.iph;
+	iph = ip_hdr(skb);
 	rt = (struct rtable*)skb->dst;
 
 	if (iph->ttl <= 1)
@@ -120,7 +120,7 @@
 	/* We are about to mangle packet. Copy it! */
 	if (skb_cow(skb, dev2->hard_header_len))
 		goto drop;
-	iph = skb->nh.iph;
+	iph = ip_hdr(skb);
 
 	/* Decrease ttl after skb cow done */
 	ip_decrease_ttl(iph);
===== net/ipv4/ip_fragment.c 1.6 vs edited =====
--- 1.6/net/ipv4/ip_fragment.c	Wed May 22 15:16:37 2002
+++ edited/net/ipv4/ip_fragment.c	Mon Sep 30 19:22:22 2002
@@ -377,11 +377,11 @@
 	if (qp->last_in & COMPLETE)
 		goto err;
 
- 	offset = ntohs(skb->nh.iph->frag_off);
+ 	offset = ntohs(ip_hdr(skb)->frag_off);
 	flags = offset & ~IP_OFFSET;
 	offset &= IP_OFFSET;
 	offset <<= 3;		/* offset is in 8-byte chunks */
- 	ihl = skb->nh.iph->ihl * 4;
+ 	ihl = ip_hdr(skb)->ihl * 4;
 
 	/* Determine the position of this fragment. */
  	end = offset + skb->len - ihl;
@@ -518,7 +518,7 @@
 	BUG_TRAP(FRAG_CB(head)->offset == 0);
 
 	/* Allocate a new buffer for the datagram. */
-	ihlen = head->nh.iph->ihl*4;
+	ihlen = ip_hdr(head)->ihl * 4;
 	len = ihlen + qp->len;
 
 	if(len > 65535)
@@ -570,7 +570,7 @@
 	head->dev = dev;
 	head->stamp = qp->stamp;
 
-	iph = head->nh.iph;
+	iph = ip_hdr(head);
 	iph->frag_off = 0;
 	iph->tot_len = htons(len);
 	IP_INC_STATS_BH(IpReasmOKs);
@@ -596,7 +596,7 @@
 /* Process an incoming IP datagram fragment. */
 struct sk_buff *ip_defrag(struct sk_buff *skb)
 {
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	struct ipq *qp;
 	struct net_device *dev;
 	
===== net/ipv4/ip_gre.c 1.9 vs edited =====
--- 1.9/net/ipv4/ip_gre.c	Fri Jul 19 03:16:19 2002
+++ edited/net/ipv4/ip_gre.c	Mon Sep 30 19:22:22 2002
@@ -538,8 +538,8 @@
 {
 	if (INET_ECN_is_ce(iph->tos)) {
 		if (skb->protocol == __constant_htons(ETH_P_IP)) {
-			if (INET_ECN_is_not_ce(skb->nh.iph->tos))
-				IP_ECN_set_ce(skb->nh.iph);
+			if (INET_ECN_is_not_ce(ip_hdr(skb)->tos))
+				IP_ECN_set_ce(ip_hdr(skb));
 		} else if (skb->protocol == __constant_htons(ETH_P_IPV6)) {
 			if (INET_ECN_is_not_ce(ip6_get_dsfield(skb->nh.ipv6h)))
 				IP6_ECN_set_ce(skb->nh.ipv6h);
@@ -572,7 +572,7 @@
 	if (!pskb_may_pull(skb, 16))
 		goto drop_nolock;
 
-	iph = skb->nh.iph;
+	iph = ip_hdr(skb);
 	h = skb->data;
 	flags = *(u16*)h;
 
@@ -677,7 +677,7 @@
 {
 	struct ip_tunnel *tunnel = (struct ip_tunnel*)dev->priv;
 	struct net_device_stats *stats = &tunnel->stat;
-	struct iphdr  *old_iph = skb->nh.iph;
+	struct iphdr  *old_iph = ip_hdr(skb);
 	struct iphdr  *tiph;
 	u8     tos;
 	u16    df;
@@ -837,7 +837,7 @@
 	 *	Push down and install the IPIP header.
 	 */
 
-	iph 			=	skb->nh.iph;
+	iph 			=	ip_hdr(skb);
 	iph->version		=	4;
 	iph->ihl		=	sizeof(struct iphdr) >> 2;
 	iph->frag_off		=	df;
===== net/ipv4/ip_input.c 1.6 vs edited =====
--- 1.6/net/ipv4/ip_input.c	Wed Mar 20 01:12:59 2002
+++ edited/net/ipv4/ip_input.c	Mon Sep 30 19:22:22 2002
@@ -156,7 +156,7 @@
 int ip_call_ra_chain(struct sk_buff *skb)
 {
 	struct ip_ra_chain *ra;
-	u8 protocol = skb->nh.iph->protocol;
+	u8 protocol = ip_hdr(skb)->protocol;
 	struct sock *last = NULL;
 
 	read_lock(&ip_ra_lock);
@@ -169,7 +169,7 @@
 		if (sk && inet_sk(sk)->num == protocol 
 		    && ((sk->bound_dev_if == 0) 
 			|| (sk->bound_dev_if == skb->dev->ifindex))) {
-			if (skb->nh.iph->frag_off & htons(IP_MF|IP_OFFSET)) {
+			if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 				skb = ip_defrag(skb);
 				if (skb == NULL) {
 					read_unlock(&ip_ra_lock);
@@ -218,7 +218,7 @@
 
 static inline int ip_local_deliver_finish(struct sk_buff *skb)
 {
-	int ihl = skb->nh.iph->ihl*4;
+	int ihl = ip_hdr(skb)->ihl * 4;
 
 #ifdef CONFIG_NETFILTER_DEBUG
 	nf_debug_ip_local_deliver(skb);
@@ -238,7 +238,7 @@
 
 	{
 		/* Note: See raw.c and net/raw.h, RAWV4_HTABLE_SIZE==MAX_INET_PROTOS */
-		int protocol = skb->nh.iph->protocol;
+		int protocol = ip_hdr(skb)->protocol;
 		int hash = protocol & (MAX_INET_PROTOS - 1);
 		struct sock *raw_sk = raw_v4_htable[hash];
 		struct inet_protocol *ipprot;
@@ -248,7 +248,7 @@
 		 * don't care less
 		 */
 		if(raw_sk != NULL)
-			raw_sk = raw_v4_input(skb, skb->nh.iph, hash);
+			raw_sk = raw_v4_input(skb, ip_hdr(skb), hash);
 
 		ipprot = (struct inet_protocol *) inet_protos[hash];
 		flag = 0;
@@ -263,7 +263,8 @@
 
 				return ret;
 			} else {
-				flag = ip_run_ipprot(skb, skb->nh.iph, ipprot, (raw_sk != NULL));
+				flag = ip_run_ipprot(skb, ip_hdr(skb), ipprot,
+						     (raw_sk != NULL));
 			}
 		}
 
@@ -293,7 +294,7 @@
 	 *	Reassemble IP fragments.
 	 */
 
-	if (skb->nh.iph->frag_off & htons(IP_MF|IP_OFFSET)) {
+	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 		skb = ip_defrag(skb);
 		if (!skb)
 			return 0;
@@ -306,7 +307,7 @@
 static inline int ip_rcv_finish(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 
 	/*
 	 *	Initialise the virtual path cache for the packet. It describes
@@ -341,7 +342,7 @@
 
 		if (skb_cow(skb, skb_headroom(skb)))
 			goto drop;
-		iph = skb->nh.iph;
+		iph = ip_hdr(skb);
 
 		if (ip_options_compile(NULL, skb))
 			goto inhdr_error;
@@ -394,7 +395,7 @@
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto inhdr_error;
 
-	iph = skb->nh.iph;
+	iph = ip_hdr(skb);
 
 	/*
 	 *	RFC1122: 3.1.2.2 MUST silently discard any IP frame that fails the checksum.
@@ -413,7 +414,7 @@
 	if (!pskb_may_pull(skb, iph->ihl*4))
 		goto inhdr_error;
 
-	iph = skb->nh.iph;
+	iph = ip_hdr(skb);
 
 	if (ip_fast_csum((u8 *)iph, iph->ihl) != 0)
 		goto inhdr_error; 
===== net/ipv4/ip_nat_dumb.c 1.2 vs edited =====
--- 1.2/net/ipv4/ip_nat_dumb.c	Tue Feb  5 05:39:17 2002
+++ edited/net/ipv4/ip_nat_dumb.c	Mon Sep 30 19:22:22 2002
@@ -47,7 +47,7 @@
 ip_do_nat(struct sk_buff *skb)
 {
 	struct rtable *rt = (struct rtable*)skb->dst;
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	u32 odaddr = iph->daddr;
 	u32 osaddr = iph->saddr;
 	u16	check;
===== net/ipv4/ip_options.c 1.3 vs edited =====
--- 1.3/net/ipv4/ip_options.c	Fri Sep 13 19:47:24 2002
+++ edited/net/ipv4/ip_options.c	Mon Sep 30 19:22:22 2002
@@ -106,7 +106,7 @@
 	if (skb->dst)
 		daddr = ((struct rtable*)skb->dst)->rt_spec_dst;
 	else
-		daddr = skb->nh.iph->daddr;
+		daddr = ip_hdr(skb)->daddr;
 
 	if (sopt->rr) {
 		optlen  = sptr[sopt->rr+1];
@@ -176,7 +176,7 @@
 			/*
 			 * RFC1812 requires to fix illegal source routes.
 			 */
-			if (memcmp(&skb->nh.iph->saddr, &start[soffset+3], 4) == 0)
+			if (!memcmp(&ip_hdr(skb)->saddr, &start[soffset + 3], 4))
 				doffset -= 4;
 		}
 		if (doffset > 3) {
@@ -259,7 +259,7 @@
 		optptr = iph + sizeof(struct iphdr);
 		opt->is_data = 0;
 	} else {
-		optptr = opt->is_data ? opt->__data : (unsigned char*)&(skb->nh.iph[1]);
+		optptr = opt->is_data ? opt->__data : (unsigned char*)&(ip_hdr(skb)[1]);
 		iph = optptr - sizeof(struct iphdr);
 	}
 
@@ -547,7 +547,7 @@
 		if (srrptr + 3 <= srrspace) {
 			opt->is_changed = 1;
 			ip_rt_get_source(&optptr[srrptr-1], rt);
-			skb->nh.iph->daddr = rt->rt_dst;
+			ip_hdr(skb)->daddr = rt->rt_dst;
 			optptr[2] = srrptr+4;
 		} else if (net_ratelimit())
 			printk(KERN_CRIT "ip_forward(): Argh! Destination lost!\n");
@@ -559,7 +559,7 @@
 	}
 	if (opt->is_changed) {
 		opt->is_changed = 0;
-		ip_send_check(skb->nh.iph);
+		ip_send_check(ip_hdr(skb));
 	}
 }
 
@@ -568,7 +568,7 @@
 	struct ip_options *opt = &(IPCB(skb)->opt);
 	int srrspace, srrptr;
 	u32 nexthop;
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	unsigned char * optptr = skb->nh.raw + opt->srr;
 	struct rtable *rt = (struct rtable*)skb->dst;
 	struct rtable *rt2;
===== net/ipv4/ip_output.c 1.14 vs edited =====
--- 1.14/net/ipv4/ip_output.c	Thu Aug 29 05:57:05 2002
+++ edited/net/ipv4/ip_output.c	Mon Sep 30 19:22:22 2002
@@ -145,7 +145,7 @@
 	iph->protocol = sk->protocol;
 	iph->tot_len  = htons(skb->len);
 	ip_select_ident(iph, &rt->u.dst, sk);
-	skb->nh.iph   = iph;
+	ip_hdr(skb)   = iph;
 
 	if (opt && opt->optlen) {
 		iph->ihl += opt->optlen>>2;
@@ -238,7 +238,7 @@
 
 		/* Multicasts with ttl 0 must not go beyond the host */
 
-		if (skb->nh.iph->ttl == 0) {
+		if (!ip_hdr(skb)->ttl) {
 			kfree_skb(skb);
 			return 0;
 		}
@@ -284,7 +284,7 @@
 	struct sock *sk = skb->sk;
 	struct rtable *rt = (struct rtable *)skb->dst;
 	struct net_device *dev;
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 
 	dev = rt->u.dst.dev;
 
@@ -303,7 +303,7 @@
 		if (sk)
 			skb_set_owner_w(skb2, sk);
 		skb = skb2;
-		iph = skb->nh.iph;
+		iph = ip_hdr(skb);
 	}
 
 	if (skb->len > rt->u.dst.pmtu) {
@@ -401,7 +401,7 @@
 	iph->protocol = sk->protocol;
 	iph->saddr    = rt->rt_src;
 	iph->daddr    = rt->rt_dst;
-	skb->nh.iph   = iph;
+	ip_hdr(skb)   = iph;
 	/* Transport layer set skb->h.foo itself. */
 
 	if(opt && opt->optlen) {
@@ -561,7 +561,7 @@
 		 */
 
 		data = skb_put(skb, fraglen);
-		skb->nh.iph = (struct iphdr *)data;
+		ip_hdr(skb) = (struct iphdr *)data;
 
 		/*
 		 *	Only write IP header onto non-raw packets 
@@ -711,7 +711,7 @@
 	skb->priority = sk->priority;
 	skb->dst = dst_clone(&rt->u.dst);
 
-	skb->nh.iph = iph = (struct iphdr *)skb_put(skb, length);
+	iph = ip_hdr(skb) = (struct iphdr *)skb_put(skb, length);
 
 	if (!inet->hdrincl) {
 		iph->version=4;
@@ -781,7 +781,7 @@
 	 *	Point into the IP datagram header.
 	 */
 
-	iph = skb->nh.iph;
+	iph = ip_hdr(skb);
 
 	/*
 	 *	Setup starting values.
@@ -862,7 +862,7 @@
 		/*
 		 *	Fill in the new header fields.
 		 */
-		iph = skb2->nh.iph;
+		iph = ip_hdr(skb2);
 		iph->frag_off = htons((offset >> 3));
 
 		/* ANK: dirty, but effective trick. Upgrade options only if
@@ -991,7 +991,7 @@
 			daddr = replyopts.opt.faddr;
 	}
 
-	if (ip_route_output(&rt, daddr, rt->rt_spec_dst, RT_TOS(skb->nh.iph->tos), 0))
+	if (ip_route_output(&rt, daddr, rt->rt_spec_dst, RT_TOS(ip_hdr(skb)->tos), 0))
 		return;
 
 	/* And let IP do all the hard work.
@@ -1001,9 +1001,9 @@
 	   with locally disabled BH and that sk cannot be already spinlocked.
 	 */
 	bh_lock_sock(sk);
-	inet->tos = skb->nh.iph->tos;
+	inet->tos = ip_hdr(skb)->tos;
 	sk->priority = skb->priority;
-	sk->protocol = skb->nh.iph->protocol;
+	sk->protocol = ip_hdr(skb)->protocol;
 	ip_build_xmit(sk, ip_reply_glue_bits, arg, len, &ipc, rt, MSG_DONTWAIT);
 	bh_unlock_sock(sk);
 
===== net/ipv4/ip_sockglue.c 1.8 vs edited =====
--- 1.8/net/ipv4/ip_sockglue.c	Mon Mar 11 10:46:43 2002
+++ edited/net/ipv4/ip_sockglue.c	Mon Sep 30 19:22:22 2002
@@ -58,7 +58,7 @@
 	struct in_pktinfo info;
 	struct rtable *rt = (struct rtable *)skb->dst;
 
-	info.ipi_addr.s_addr = skb->nh.iph->daddr;
+	info.ipi_addr.s_addr = ip_hdr(skb)->daddr;
 	if (rt) {
 		info.ipi_ifindex = rt->rt_iif;
 		info.ipi_spec_dst.s_addr = rt->rt_spec_dst;
@@ -72,13 +72,13 @@
 
 static void ip_cmsg_recv_ttl(struct msghdr *msg, struct sk_buff *skb)
 {
-	int ttl = skb->nh.iph->ttl;
+	int ttl = ip_hdr(skb)->ttl;
 	put_cmsg(msg, SOL_IP, IP_TTL, sizeof(int), &ttl);
 }
 
 static void ip_cmsg_recv_tos(struct msghdr *msg, struct sk_buff *skb)
 {
-	put_cmsg(msg, SOL_IP, IP_TOS, 1, &skb->nh.iph->tos);
+	put_cmsg(msg, SOL_IP, IP_TOS, 1, &ip_hdr(skb)->tos);
 }
 
 static void ip_cmsg_recv_opts(struct msghdr *msg, struct sk_buff *skb)
@@ -86,7 +86,8 @@
 	if (IPCB(skb)->opt.optlen == 0)
 		return;
 
-	put_cmsg(msg, SOL_IP, IP_RECVOPTS, IPCB(skb)->opt.optlen, skb->nh.iph+1);
+	put_cmsg(msg, SOL_IP, IP_RECVOPTS, IPCB(skb)->opt.optlen,
+		 ip_hdr(skb) + 1);
 }
 
 
@@ -276,8 +277,7 @@
 	if (!skb)
 		return;
 
-	iph = (struct iphdr*)skb_put(skb, sizeof(struct iphdr));
-	skb->nh.iph = iph;
+	iph = ip_hdr(skb) = (struct iphdr*)skb_put(skb, sizeof(struct iphdr));
 	iph->daddr = daddr;
 
 	serr = SKB_EXT_ERR(skb);  
@@ -346,7 +346,7 @@
 		struct inet_opt *inet = inet_sk(sk);
 
 		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = skb->nh.iph->saddr;
+		sin->sin_addr.s_addr = ip_hdr(skb)->saddr;
 		sin->sin_port = 0;
 		memset(&sin->sin_zero, 0, sizeof(sin->sin_zero));
 		if (inet->cmsg_flags)
===== net/ipv4/ipconfig.c 1.20 vs edited =====
--- 1.20/net/ipv4/ipconfig.c	Fri Aug 23 22:47:08 2002
+++ edited/net/ipv4/ipconfig.c	Mon Sep 30 19:22:22 2002
@@ -668,7 +668,7 @@
 	memset(b, 0, sizeof(struct bootp_pkt));
 
 	/* Construct IP header */
-	skb->nh.iph = h = &b->iph;
+	h = ip_hdr(skb) = &b->iph;
 	h->version = 4;
 	h->ihl = 5;
 	h->tot_len = htons(sizeof(struct bootp_pkt));
@@ -792,7 +792,7 @@
  */
 static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt)
 {
-	struct bootp_pkt *b = (struct bootp_pkt *) skb->nh.iph;
+	struct bootp_pkt *b = (struct bootp_pkt *)ip_hdr(skb);
 	struct iphdr *h = &b->iph;
 	struct ic_device *d;
 	int len;
===== net/ipv4/ipip.c 1.12 vs edited =====
--- 1.12/net/ipv4/ipip.c	Fri Jul 19 03:16:19 2002
+++ edited/net/ipv4/ipip.c	Mon Sep 30 19:22:22 2002
@@ -467,7 +467,7 @@
 static inline void ipip_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
 {
 	if (INET_ECN_is_ce(iph->tos) &&
-	    INET_ECN_is_not_ce(skb->nh.iph->tos))
+	    INET_ECN_is_not_ce(ip_hdr(skb)->tos))
 		IP_ECN_set_ce(iph);
 }
 
@@ -479,7 +479,7 @@
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto out;
 
-	iph = skb->nh.iph;
+	iph = ip_hdr(skb);
 	skb->mac.raw = skb->nh.raw;
 	skb->nh.raw = skb->data;
 	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
@@ -533,7 +533,7 @@
 	u16    df = tiph->frag_off;
 	struct rtable *rt;     			/* Route to the other host */
 	struct net_device *tdev;			/* Device to other host */
-	struct iphdr  *old_iph = skb->nh.iph;
+	struct iphdr  *old_iph = ip_hdr(skb);
 	struct iphdr  *iph;			/* Our new IP header */
 	int    max_headroom;			/* The extra header space needed */
 	u32    dst = tiph->daddr;
@@ -632,7 +632,7 @@
 	 *	Push down and install the IPIP header.
 	 */
 
-	iph 			=	skb->nh.iph;
+	iph 			=	ip_hdr(skb);
 	iph->version		=	4;
 	iph->ihl		=	sizeof(struct iphdr)>>2;
 	iph->frag_off		=	df;
===== net/ipv4/ipmr.c 1.9 vs edited =====
--- 1.9/net/ipv4/ipmr.c	Wed Mar 13 20:27:38 2002
+++ edited/net/ipv4/ipmr.c	Mon Sep 30 19:22:22 2002
@@ -294,7 +294,7 @@
 	atomic_dec(&cache_resolve_queue_len);
 
 	while((skb=skb_dequeue(&c->mfc_un.unres.unresolved))) {
-		if (skb->nh.iph->version == 0) {
+		if (!ip_hdr(skb)->version) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 			nlh->nlmsg_type = NLMSG_ERROR;
 			nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
@@ -499,7 +499,7 @@
 	 */
 
 	while((skb=__skb_dequeue(&uc->mfc_un.unres.unresolved))) {
-		if (skb->nh.iph->version == 0) {
+		if (!ip_hdr(skb)->version) {
 			int err;
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 
@@ -527,7 +527,7 @@
 static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
 {
 	struct sk_buff *skb;
-	int ihl = pkt->nh.iph->ihl<<2;
+	int ihl = ip_hdr(pkt)->ihl << 2;
 	struct igmphdr *igmp;
 	struct igmpmsg *msg;
 	int ret;
@@ -555,8 +555,9 @@
 		msg->im_msgtype = IGMPMSG_WHOLEPKT;
 		msg->im_mbz = 0;
  		msg->im_vif = reg_vif_num;
-		skb->nh.iph->ihl = sizeof(struct iphdr) >> 2;
-		skb->nh.iph->tot_len = htons(ntohs(pkt->nh.iph->tot_len) + sizeof(struct iphdr));
+		ip_hdr(skb)->ihl = sizeof(struct iphdr) >> 2;
+		ip_hdr(skb)->tot_len = htons(ntohs(ip_hdr(pkt)->tot_len) +
+					     sizeof(struct iphdr));
 	} else 
 #endif
 	{	
@@ -565,23 +566,23 @@
 	 *	Copy the IP header
 	 */
 
-	skb->nh.iph = (struct iphdr *)skb_put(skb, ihl);
-	memcpy(skb->data,pkt->data,ihl);
-	skb->nh.iph->protocol = 0;			/* Flag to the kernel this is a route add */
-	msg = (struct igmpmsg*)skb->nh.iph;
-	msg->im_vif = vifi;
-	skb->dst = dst_clone(pkt->dst);
+	struct iphdr *iph = ip_hdr(skb) = (struct iphdr *)skb_put(skb, ihl);
+
+	memcpy(skb->data, pkt->data, ihl);
+	iph->protocol	= 0; /* Flag to the kernel this is a route add */
+	msg		= (struct igmpmsg *)iph;
+	msg->im_vif	= vifi;
+	skb->dst	= dst_clone(pkt->dst);
 
 	/*
 	 *	Add our header
 	 */
 
 	igmp=(struct igmphdr *)skb_put(skb,sizeof(struct igmphdr));
-	igmp->type	=
-	msg->im_msgtype = assert;
-	igmp->code 	=	0;
-	skb->nh.iph->tot_len=htons(skb->len);			/* Fix the length */
-	skb->h.raw = skb->nh.raw;
+	igmp->type	= msg->im_msgtype = assert;
+	igmp->code 	= 0;
+	iph->tot_len	= htons(skb->len);			/* Fix the length */
+	skb->h.raw	= skb->nh.raw;
         }
 
 	if (mroute_socket == NULL) {
@@ -610,11 +611,12 @@
 {
 	int err;
 	struct mfc_cache *c;
+	struct iphdr *iph = ip_hdr(skb);
 
 	spin_lock_bh(&mfc_unres_lock);
 	for (c=mfc_unres_queue; c; c=c->next) {
-		if (c->mfc_mcastgrp == skb->nh.iph->daddr &&
-		    c->mfc_origin == skb->nh.iph->saddr)
+		if (c->mfc_mcastgrp == iph->daddr &&
+		    c->mfc_origin == iph->saddr)
 			break;
 	}
 
@@ -634,9 +636,9 @@
 		/*
 		 *	Fill in the new cache entry
 		 */
-		c->mfc_parent=-1;
-		c->mfc_origin=skb->nh.iph->saddr;
-		c->mfc_mcastgrp=skb->nh.iph->daddr;
+		c->mfc_parent	= -1;
+		c->mfc_origin	= iph->saddr;
+		c->mfc_mcastgrp	= iph->daddr;
 
 		/*
 		 *	Reflect first query at mrouted.
@@ -1083,8 +1085,8 @@
 	struct iphdr *iph = (struct iphdr *)skb_push(skb,sizeof(struct iphdr));
 
 	iph->version	= 	4;
-	iph->tos	=	skb->nh.iph->tos;
-	iph->ttl	=	skb->nh.iph->ttl;
+	iph->tos	=	ip_hdr(skb)->tos;
+	iph->ttl	=	ip_hdr(skb)->ttl;
 	iph->frag_off	=	0;
 	iph->daddr	=	daddr;
 	iph->saddr	=	saddr;
@@ -1094,8 +1096,8 @@
 	ip_select_ident(iph, skb->dst, NULL);
 	ip_send_check(iph);
 
-	skb->h.ipiph = skb->nh.iph;
-	skb->nh.iph = iph;
+	skb->h.ipiph = ip_hdr(skb);
+	ip_hdr(skb)  = iph;
 #ifdef CONFIG_NETFILTER
 	nf_conntrack_put(skb->nfct);
 	skb->nfct = NULL;
@@ -1119,7 +1121,7 @@
 static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c,
 			   int vifi, int last)
 {
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	struct vif_device *vif = &vif_table[vifi];
 	struct net_device *dev;
 	struct rtable *rt;
@@ -1183,7 +1185,7 @@
 
 	dst_release(skb2->dst);
 	skb2->dst = &rt->u.dst;
-	iph = skb2->nh.iph;
+	iph = ip_hdr(skb2);
 	ip_decrease_ttl(iph);
 
 	/* FIXME: forward and output firewalls used to be called here.
@@ -1278,7 +1280,7 @@
 	 *	Forward the frame
 	 */
 	for (ct = cache->mfc_un.res.maxvif-1; ct >= cache->mfc_un.res.minvif; ct--) {
-		if (skb->nh.iph->ttl > cache->mfc_un.res.ttls[ct]) {
+		if (ip_hdr(skb)->ttl > cache->mfc_un.res.ttls[ct]) {
 			if (psend != -1)
 				ipmr_queue_xmit(skb, cache, psend, 0);
 			psend=ct;
@@ -1313,7 +1315,7 @@
 		    if (IPCB(skb)->opt.router_alert) {
 			    if (ip_call_ra_chain(skb))
 				    return 0;
-		    } else if (skb->nh.iph->protocol == IPPROTO_IGMP){
+		    } else if (ip_hdr(skb)->protocol == IPPROTO_IGMP){
 			    /* IGMPv1 (and broken IGMPv2 implementations sort of
 			       Cisco IOS <= 11.2(8)) do not put router alert
 			       option to IGMP packets destined to routable
@@ -1331,7 +1333,7 @@
 	}
 
 	read_lock(&mrt_lock);
-	cache = ipmr_cache_find(skb->nh.iph->saddr, skb->nh.iph->daddr);
+	cache = ipmr_cache_find(ip_hdr(skb)->saddr, ip_hdr(skb)->daddr);
 
 	/*
 	 *	No usable cache entry
@@ -1431,7 +1433,7 @@
 
 	skb->mac.raw = skb->nh.raw;
 	skb_pull(skb, (u8*)encap - skb->data);
-	skb->nh.iph = (struct iphdr *)skb->data;
+	ip_hdr(skb) = (struct iphdr *)skb->data;
 	skb->dev = reg_dev;
 	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 	skb->protocol = __constant_htons(ETH_P_IP);
@@ -1498,7 +1500,7 @@
 
 	skb->mac.raw = skb->nh.raw;
 	skb_pull(skb, (u8*)encap - skb->data);
-	skb->nh.iph = (struct iphdr *)skb->data;
+	ip_hdr(skb) = (struct iphdr *)skb->data;
 	skb->dev = reg_dev;
 	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 	skb->protocol = __constant_htons(ETH_P_IP);
@@ -1564,6 +1566,7 @@
 
 	if (cache==NULL) {
 		struct net_device *dev;
+		struct iphdr *iph;
 		int vif;
 
 		if (nowait) {
@@ -1576,11 +1579,11 @@
 			read_unlock(&mrt_lock);
 			return -ENODEV;
 		}
-		skb->nh.raw = skb_push(skb, sizeof(struct iphdr));
-		skb->nh.iph->ihl = sizeof(struct iphdr)>>2;
-		skb->nh.iph->saddr = rt->rt_src;
-		skb->nh.iph->daddr = rt->rt_dst;
-		skb->nh.iph->version = 0;
+		iph = ip_hdr(skb) = skb_push(skb, sizeof(*iph));
+		iph->ihl     = sizeof(*iph) >> 2;
+		iph->saddr   = rt->rt_src;
+		iph->daddr   = rt->rt_dst;
+		iph->version = 0;
 		err = ipmr_cache_unresolved(vif, skb);
 		read_unlock(&mrt_lock);
 		return err;
===== net/ipv4/raw.c 1.10 vs edited =====
--- 1.10/net/ipv4/raw.c	Fri Jul 19 03:16:20 2002
+++ edited/net/ipv4/raw.c	Mon Sep 30 19:22:22 2002
@@ -525,7 +525,7 @@
 	/* Copy the address. */
 	if (sin) {
 		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = skb->nh.iph->saddr;
+		sin->sin_addr.s_addr = ip_hdr(skb)->saddr;
 		memset(&sin->sin_zero, 0, sizeof(sin->sin_zero));
 	}
 	if (inet->cmsg_flags)
===== net/ipv4/route.c 1.19 vs edited =====
--- 1.19/net/ipv4/route.c	Thu Aug 29 05:57:05 2002
+++ edited/net/ipv4/route.c	Mon Sep 30 19:22:22 2002
@@ -1142,7 +1142,7 @@
 static int ip_rt_bug(struct sk_buff *skb)
 {
 	printk(KERN_DEBUG "ip_rt_bug: %u.%u.%u.%u -> %u.%u.%u.%u, %s\n",
-		NIPQUAD(skb->nh.iph->saddr), NIPQUAD(skb->nh.iph->daddr),
+		NIPQUAD(ip_hdr(skb)->saddr), NIPQUAD(ip_hdr(skb)->daddr),
 		skb->dev ? skb->dev->name : "?");
 	kfree_skb(skb);
 	return 0;
===== net/ipv4/syncookies.c 1.8 vs edited =====
--- 1.8/net/ipv4/syncookies.c	Fri May 10 12:38:54 2002
+++ edited/net/ipv4/syncookies.c	Mon Sep 30 19:22:22 2002
@@ -60,7 +60,7 @@
 
 	NET_INC_STATS_BH(SyncookiesSent);
 
-	return secure_tcp_syn_cookie(skb->nh.iph->saddr, skb->nh.iph->daddr,
+	return secure_tcp_syn_cookie(ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
 				     skb->h.th->source, skb->h.th->dest,
 				     ntohl(skb->h.th->seq),
 				     jiffies / (HZ * 60), mssind);
@@ -79,14 +79,12 @@
  */
 static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 {
-	__u32 seq; 
-	__u32 mssind;
-
-	seq = ntohl(skb->h.th->seq)-1; 
-	mssind = check_tcp_syn_cookie(cookie,
-				      skb->nh.iph->saddr, skb->nh.iph->daddr,
-				      skb->h.th->source, skb->h.th->dest,
-				      seq, jiffies / (HZ * 60), COUNTER_TRIES);
+	struct iphdr *iph = ip_hdr(skb);
+	__u32 seq = ntohl(skb->h.th->seq) - 1; 
+	__u32 mssind = check_tcp_syn_cookie(cookie, iph->saddr, iph->daddr,
+					    skb->h.th->source, skb->h.th->dest,
+					    seq, jiffies / (HZ * 60),
+					    COUNTER_TRIES);
 
 	return mssind < NUM_MSS ? msstab[mssind] + 1 : 0;
 }
@@ -140,8 +138,8 @@
 	req->snt_isn		= cookie; 
 	req->mss		= mss;
  	req->rmt_port		= skb->h.th->source;
-	req->af.v4_req.loc_addr = skb->nh.iph->daddr;
-	req->af.v4_req.rmt_addr = skb->nh.iph->saddr;
+	req->af.v4_req.loc_addr = ip_hdr(skb)->daddr;
+	req->af.v4_req.rmt_addr = ip_hdr(skb)->saddr;
 	req->class		= &or_ipv4; /* for savety */
 	req->af.v4_req.opt	= NULL;
 
===== net/ipv4/tcp_ipv4.c 1.23 vs edited =====
--- 1.23/net/ipv4/tcp_ipv4.c	Thu Aug 29 05:57:05 2002
+++ edited/net/ipv4/tcp_ipv4.c	Mon Sep 30 19:22:22 2002
@@ -526,8 +526,8 @@
 
 static inline __u32 tcp_v4_init_sequence(struct sock *sk, struct sk_buff *skb)
 {
-	return secure_tcp_sequence_number(skb->nh.iph->daddr,
-					  skb->nh.iph->saddr,
+	return secure_tcp_sequence_number(ip_hdr(skb)->daddr,
+					  ip_hdr(skb)->saddr,
 					  skb->h.th->dest,
 					  skb->h.th->source);
 }
@@ -1184,8 +1184,8 @@
 	memset(&arg, 0, sizeof arg);
 	arg.iov[0].iov_base = (unsigned char *)&rth;
 	arg.iov[0].iov_len  = sizeof rth;
-	arg.csum = csum_tcpudp_nofold(skb->nh.iph->daddr,
-				      skb->nh.iph->saddr, /*XXX*/
+	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
+				      ip_hdr(skb)->saddr, /*XXX*/
 				      sizeof(struct tcphdr), IPPROTO_TCP, 0);
 	arg.n_iov = 1;
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
@@ -1235,8 +1235,8 @@
 	rep.th.ack     = 1;
 	rep.th.window  = htons(win);
 
-	arg.csum = csum_tcpudp_nofold(skb->nh.iph->daddr,
-				      skb->nh.iph->saddr, /*XXX*/
+	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
+				      ip_hdr(skb)->saddr, /*XXX*/
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 
@@ -1390,8 +1390,8 @@
 {
 	struct tcp_opt tp;
 	struct open_request *req;
-	__u32 saddr = skb->nh.iph->saddr;
-	__u32 daddr = skb->nh.iph->daddr;
+	__u32 saddr = ip_hdr(skb)->saddr;
+	__u32 daddr = ip_hdr(skb)->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
 	struct dst_entry *dst = NULL;
 #ifdef CONFIG_SYN_COOKIES
@@ -1569,7 +1569,7 @@
 	newinet->opt	      = req->af.v4_req.opt;
 	req->af.v4_req.opt    = NULL;
 	newinet->mc_index     = tcp_v4_iif(skb);
-	newinet->mc_ttl	      = skb->nh.iph->ttl;
+	newinet->mc_ttl	      = ip_hdr(skb)->ttl;
 	newtp->ext_header_len = 0;
 	if (newinet->opt)
 		newtp->ext_header_len = newinet->opt->optlen;
@@ -1595,7 +1595,7 @@
 static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcphdr *th = skb->h.th;
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct sock *nsk;
 	struct open_request **prev;
@@ -1605,9 +1605,9 @@
 	if (req)
 		return tcp_check_req(sk, skb, req, prev);
 
-	nsk = __tcp_v4_lookup_established(skb->nh.iph->saddr,
+	nsk = __tcp_v4_lookup_established(ip_hdr(skb)->saddr,
 					  th->source,
-					  skb->nh.iph->daddr,
+					  ip_hdr(skb)->daddr,
 					  ntohs(th->dest),
 					  tcp_v4_iif(skb));
 
@@ -1629,10 +1629,12 @@
 
 static int tcp_v4_checksum_init(struct sk_buff *skb)
 {
+	struct iphdr *iph = ip_hdr(skb);
+
 	if (skb->ip_summed == CHECKSUM_HW) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		if (!tcp_v4_check(skb->h.th, skb->len, skb->nh.iph->saddr,
-				  skb->nh.iph->daddr, skb->csum))
+		if (!tcp_v4_check(skb->h.th, skb->len, iph->saddr,
+				  iph->daddr, skb->csum))
 			return 0;
 
 		NETDEBUG(if (net_ratelimit())
@@ -1640,15 +1642,13 @@
 		skb->ip_summed = CHECKSUM_NONE;
 	}
 	if (skb->len <= 76) {
-		if (tcp_v4_check(skb->h.th, skb->len, skb->nh.iph->saddr,
-				 skb->nh.iph->daddr,
-				 skb_checksum(skb, 0, skb->len, 0)))
+		if (tcp_v4_check(skb->h.th, skb->len, iph->saddr,
+				 iph->daddr, skb_checksum(skb, 0, skb->len, 0)))
 			return -1;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else {
-		skb->csum = ~tcp_v4_check(skb->h.th, skb->len,
-					  skb->nh.iph->saddr,
-					  skb->nh.iph->daddr, 0);
+		skb->csum = ~tcp_v4_check(skb->h.th, skb->len, iph->saddr,
+					  iph->daddr, 0);
 	}
 	return 0;
 }
@@ -1724,6 +1724,7 @@
 int tcp_v4_rcv(struct sk_buff *skb)
 {
 	struct tcphdr *th;
+	struct iphdr *iph;
 	struct sock *sk;
 	int ret;
 
@@ -1752,17 +1753,17 @@
 		goto bad_packet;
 
 	th = skb->h.th;
+	iph = ip_hdr(skb);
 	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
 				    skb->len - th->doff * 4);
 	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
 	TCP_SKB_CB(skb)->when	 = 0;
-	TCP_SKB_CB(skb)->flags	 = skb->nh.iph->tos;
+	TCP_SKB_CB(skb)->flags	 = iph->tos;
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
-	sk = __tcp_v4_lookup(skb->nh.iph->saddr, th->source,
-			     skb->nh.iph->daddr, ntohs(th->dest),
-			     tcp_v4_iif(skb));
+	sk = __tcp_v4_lookup(iph->saddr, th->source, iph->daddr,
+			     ntohs(th->dest), tcp_v4_iif(skb));
 
 	if (!sk)
 		goto no_tcp_socket;
@@ -1814,7 +1815,7 @@
 	switch (tcp_timewait_state_process((struct tcp_tw_bucket *)sk,
 					   skb, th, skb->len)) {
 	case TCP_TW_SYN: {
-		struct sock *sk2 = tcp_v4_lookup_listener(skb->nh.iph->daddr,
+		struct sock *sk2 = tcp_v4_lookup_listener(iph->daddr,
 							  ntohs(th->dest),
 							  tcp_v4_iif(skb));
 		if (sk2) {
===== net/ipv4/udp.c 1.11 vs edited =====
--- 1.11/net/ipv4/udp.c	Fri Jul 19 03:16:20 2002
+++ edited/net/ipv4/udp.c	Mon Sep 30 19:22:22 2002
@@ -687,7 +687,7 @@
 	{
 		sin->sin_family = AF_INET;
 		sin->sin_port = skb->h.uh->source;
-		sin->sin_addr.s_addr = skb->nh.iph->saddr;
+		sin->sin_addr.s_addr = ip_hdr(skb)->saddr;
 		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
   	}
 	if (inet->cmsg_flags)
@@ -904,8 +904,8 @@
   	struct udphdr *uh;
 	unsigned short ulen;
 	struct rtable *rt = (struct rtable*)skb->dst;
-	u32 saddr = skb->nh.iph->saddr;
-	u32 daddr = skb->nh.iph->daddr;
+	u32 saddr = ip_hdr(skb)->saddr;
+	u32 daddr = ip_hdr(skb)->daddr;
 	int len = skb->len;
 
   	IP_INC_STATS_BH(IpInDelivers);
===== net/ipv4/netfilter/arp_tables.c 1.2 vs edited =====
--- 1.2/net/ipv4/netfilter/arp_tables.c	Tue Jun 18 03:25:22 2002
+++ edited/net/ipv4/netfilter/arp_tables.c	Mon Sep 30 19:41:48 2002
@@ -247,7 +247,7 @@
 {
 	static const char nulldevname[IFNAMSIZ] = { 0 };
 	unsigned int verdict = NF_DROP;
-	struct arphdr *arp = (*pskb)->nh.arph;
+	struct arphdr *arp = arp_hdr(*pskb);
 	int hotdrop = 0;
 	struct arpt_entry *e, *back;
 	const char *indev, *outdev;
@@ -314,7 +314,7 @@
 								     userdata);
 
 				/* Target might have changed stuff. */
-				arp = (*pskb)->nh.arph;
+				arp = arp_hdr(*pskb);
 
 				if (verdict == ARPT_CONTINUE)
 					e = (void *)e + e->next_offset;
===== net/ipv4/netfilter/ip_conntrack_core.c 1.12 vs edited =====
--- 1.12/net/ipv4/netfilter/ip_conntrack_core.c	Fri Aug 23 22:34:38 2002
+++ edited/net/ipv4/netfilter/ip_conntrack_core.c	Mon Sep 30 19:22:22 2002
@@ -508,7 +508,7 @@
 	IP_NF_ASSERT(iph->protocol == IPPROTO_ICMP);
 	IP_NF_ASSERT(skb->nfct == NULL);
 
-	iph = skb->nh.iph;
+	iph = ip_hdr(skb);
 	hdr = (struct icmphdr *)((u_int32_t *)iph + iph->ihl);
 	inner = (struct iphdr *)(hdr + 1);
 	datalen = skb->len - iph->ihl*4 - sizeof(*hdr);
@@ -680,7 +680,7 @@
 	for (i=0; i < IP_CT_NUMBER; i++)
 		conntrack->infos[i].master = &conntrack->ct_general;
 
-	if (!protocol->new(conntrack, skb->nh.iph, skb->len)) {
+	if (!protocol->new(conntrack, ip_hdr(skb), skb->len)) {
 		kmem_cache_free(ip_conntrack_cachep, conntrack);
 		return NULL;
 	}
@@ -747,9 +747,9 @@
 	struct ip_conntrack_tuple tuple;
 	struct ip_conntrack_tuple_hash *h;
 
-	IP_NF_ASSERT((skb->nh.iph->frag_off & htons(IP_OFFSET)) == 0);
+	IP_NF_ASSERT((ip_hdr(skb)->frag_off & htons(IP_OFFSET)) == 0);
 
-	if (!get_tuple(skb->nh.iph, skb->len, &tuple, proto))
+	if (!get_tuple(ip_hdr(skb), skb->len, &tuple, proto))
 		return NULL;
 
 	/* look for tuple match */
@@ -810,11 +810,11 @@
 	if ((*pskb)->pkt_type == PACKET_BROADCAST) {
 		printk("Broadcast packet!\n");
 		return NF_ACCEPT;
-	} else if (((*pskb)->nh.iph->daddr & htonl(0x000000FF)) 
+	} else if ((ip_hdr(*pskb)->daddr & htonl(0x000000FF)) 
 		   == htonl(0x000000FF)) {
 		printk("Should bcast: %u.%u.%u.%u->%u.%u.%u.%u (sk=%p, ptype=%u)\n",
-		       NIPQUAD((*pskb)->nh.iph->saddr),
-		       NIPQUAD((*pskb)->nh.iph->daddr),
+		       NIPQUAD(ip_hdr(*pskb)->saddr),
+		       NIPQUAD(ip_hdr(*pskb)->daddr),
 		       (*pskb)->sk, (*pskb)->pkt_type);
 	}
 #endif
@@ -825,17 +825,17 @@
 		return NF_ACCEPT;
 
 	/* Gather fragments. */
-	if ((*pskb)->nh.iph->frag_off & htons(IP_MF|IP_OFFSET)) {
+	if (ip_hdr(*pskb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 		*pskb = ip_ct_gather_frags(*pskb);
 		if (!*pskb)
 			return NF_STOLEN;
 	}
 
-	proto = ip_ct_find_proto((*pskb)->nh.iph->protocol);
+	proto = ip_ct_find_proto(ip_hdr(*pskb)->protocol);
 
 	/* It may be an icmp error... */
-	if ((*pskb)->nh.iph->protocol == IPPROTO_ICMP 
-	    && icmp_error_track(*pskb, &ctinfo, hooknum))
+	if (ip_hdr(*pskb)->protocol == IPPROTO_ICMP &&
+	    icmp_error_track(*pskb, &ctinfo, hooknum))
 		return NF_ACCEPT;
 
 	if (!(ct = resolve_normal_ct(*pskb, proto,&set_reply,hooknum,&ctinfo)))
@@ -848,7 +848,7 @@
 
 	IP_NF_ASSERT((*pskb)->nfct);
 
-	ret = proto->packet(ct, (*pskb)->nh.iph, (*pskb)->len, ctinfo);
+	ret = proto->packet(ct, ip_hdr(*pskb), (*pskb)->len, ctinfo);
 	if (ret == -1) {
 		/* Invalid */
 		nf_conntrack_put((*pskb)->nfct);
@@ -857,7 +857,7 @@
 	}
 
 	if (ret != NF_DROP && ct->helper) {
-		ret = ct->helper->help((*pskb)->nh.iph, (*pskb)->len,
+		ret = ct->helper->help(ip_hdr(*pskb), (*pskb)->len,
 				       ct, ctinfo);
 		if (ret == -1) {
 			/* Invalid */
@@ -1216,7 +1216,7 @@
 		sock_put(sk);
 	}
 
-	ip_send_check(skb->nh.iph);
+	ip_send_check(ip_hdr(skb));
 	skb->nfcache |= NFC_ALTERED;
 #ifdef CONFIG_NETFILTER_DEBUG
 	/* Packet path as if nothing had happened. */
===== net/ipv4/netfilter/ip_conntrack_proto_tcp.c 1.5 vs edited =====
--- 1.5/net/ipv4/netfilter/ip_conntrack_proto_tcp.c	Mon Sep 23 00:16:36 2002
+++ edited/net/ipv4/netfilter/ip_conntrack_proto_tcp.c	Mon Sep 30 19:22:22 2002
@@ -234,7 +234,7 @@
 static int tcp_exp_matches_pkt(struct ip_conntrack_expect *exp,
 			       struct sk_buff **pskb)
 {
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	struct tcphdr *tcph = (struct tcphdr *)((u_int32_t *)iph + iph->ihl);
 	unsigned int datalen;
 
===== net/ipv4/netfilter/ip_conntrack_standalone.c 1.9 vs edited =====
--- 1.9/net/ipv4/netfilter/ip_conntrack_standalone.c	Mon Aug 19 15:41:51 2002
+++ edited/net/ipv4/netfilter/ip_conntrack_standalone.c	Mon Sep 30 19:22:22 2002
@@ -217,7 +217,7 @@
 {
 	/* root is playing with raw sockets. */
 	if ((*pskb)->len < sizeof(struct iphdr)
-	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr)) {
+	    || ip_hdr(*pskb)->ihl * 4 < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("ipt_hook: happy cracking.\n");
 		return NF_ACCEPT;
===== net/ipv4/netfilter/ip_fw_compat.c 1.10 vs edited =====
--- 1.10/net/ipv4/netfilter/ip_fw_compat.c	Mon Aug 19 15:51:30 2002
+++ edited/net/ipv4/netfilter/ip_fw_compat.c	Mon Sep 30 19:22:22 2002
@@ -101,7 +101,7 @@
 					  (struct net_device *)in,
 					  (*pskb)->nh.raw, &redirpt, pskb);
 
-		if ((*pskb)->nh.iph->frag_off & htons(IP_MF|IP_OFFSET)) {
+		if (ip_hdr(*pskb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 			*pskb = ip_ct_gather_frags(*pskb);
 
 			if (!*pskb)
@@ -147,7 +147,7 @@
 		 * Generally, routing is THE FIRST thing to make, when
 		 * packet enters IP stack. Before packet is routed you
 		 * cannot call any service routines from IP stack.  */
-		struct iphdr *iph = (*pskb)->nh.iph;
+		struct iphdr *iph = ip_hdr(*pskb);
 
 		if ((*pskb)->dst != NULL
 		    || ip_route_input(*pskb, iph->daddr, iph->saddr, iph->tos,
@@ -165,7 +165,7 @@
 		} else if (hooknum == NF_IP_POST_ROUTING) {
 			check_for_unredirect(*pskb);
 			/* Handle ICMP errors from client here */
-			if ((*pskb)->nh.iph->protocol == IPPROTO_ICMP
+			if (ip_hdr(*pskb)->protocol == IPPROTO_ICMP
 			    && (*pskb)->nfct)
 				check_for_masq_error(*pskb);
 		}
===== net/ipv4/netfilter/ip_fw_compat_masq.c 1.4 vs edited =====
--- 1.4/net/ipv4/netfilter/ip_fw_compat_masq.c	Tue Mar 26 20:16:27 2002
+++ edited/net/ipv4/netfilter/ip_fw_compat_masq.c	Mon Sep 30 19:22:22 2002
@@ -35,7 +35,7 @@
 unsigned int
 do_masquerade(struct sk_buff **pskb, const struct net_device *dev)
 {
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	struct ip_nat_info *info;
 	enum ip_conntrack_info ctinfo;
 	struct ip_conntrack *ct;
@@ -123,7 +123,7 @@
 check_for_demasq(struct sk_buff **pskb)
 {
 	struct ip_conntrack_tuple tuple;
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	struct ip_conntrack_protocol *protocol;
 	struct ip_conntrack_tuple_hash *h;
 	enum ip_conntrack_info ctinfo;
@@ -157,7 +157,7 @@
 		/* Fall thru... */
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
-		IP_NF_ASSERT(((*pskb)->nh.iph->frag_off & htons(IP_OFFSET)) == 0);
+		IP_NF_ASSERT(!(ip_hdr(*pskb)->frag_off & htons(IP_OFFSET)));
 
 		if (!get_tuple(iph, (*pskb)->len, &tuple, protocol)) {
 			if (net_ratelimit())
===== net/ipv4/netfilter/ip_fw_compat_redir.c 1.5 vs edited =====
--- 1.5/net/ipv4/netfilter/ip_fw_compat_redir.c	Wed Feb 13 22:36:31 2002
+++ edited/net/ipv4/netfilter/ip_fw_compat_redir.c	Mon Sep 30 19:22:22 2002
@@ -95,7 +95,7 @@
 
 static void do_tcp_redir(struct sk_buff *skb, struct redir *redir)
 {
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *tcph = (struct tcphdr *)((u_int32_t *)iph
 						+ iph->ihl);
 
@@ -135,7 +135,7 @@
 /* `unredir' a reply packet. */
 static void do_tcp_unredir(struct sk_buff *skb, struct redir *redir)
 {
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *tcph = (struct tcphdr *)((u_int32_t *)iph
 						+ iph->ihl);
 
@@ -167,7 +167,7 @@
 	    const struct net_device *dev,
 	    u_int16_t redirpt)
 {
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	u_int32_t newdst;
 
 	/* Figure out address: not loopback. */
@@ -253,7 +253,7 @@
 void
 check_for_redirect(struct sk_buff *skb)
 {
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *tcph = (struct tcphdr *)((u_int32_t *)iph
 						+ iph->ihl);
 	struct redir *redir;
@@ -281,7 +281,7 @@
 void
 check_for_unredirect(struct sk_buff *skb)
 {
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *tcph = (struct tcphdr *)((u_int32_t *)iph
 						+ iph->ihl);
 	struct redir *redir;
===== net/ipv4/netfilter/ip_nat_core.c 1.14 vs edited =====
--- 1.14/net/ipv4/netfilter/ip_nat_core.c	Wed Aug 28 04:54:31 2002
+++ edited/net/ipv4/netfilter/ip_nat_core.c	Mon Sep 30 19:22:22 2002
@@ -739,7 +739,7 @@
 	int ret = 1;
 
 	MUST_BE_READ_LOCKED(&ip_conntrack_lock);
-	proto = ip_ct_find_proto((*pskb)->nh.iph->protocol);
+	proto = ip_ct_find_proto(ip_hdr(*pskb)->protocol);
 	if (proto->exp_matches_pkt)
 		ret = proto->exp_matches_pkt(exp, pskb);
 
@@ -757,7 +757,7 @@
 	unsigned int i;
 	struct ip_nat_helper *helper;
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
-	int is_tcp = (*pskb)->nh.iph->protocol == IPPROTO_TCP;
+	int is_tcp = ip_hdr(*pskb)->protocol == IPPROTO_TCP;
 
 	/* Need nat lock to protect against modification, but neither
 	   conntrack (referenced) and helper (deleted with
@@ -784,8 +784,8 @@
 			       ? "SRC" : "DST",
 			       NIPQUAD(info->manips[i].manip.ip),
 			       htons(info->manips[i].manip.u.all));
-			manip_pkt((*pskb)->nh.iph->protocol,
-				  (*pskb)->nh.iph,
+			manip_pkt(ip_hdr(*pskb)->protocol,
+				  ip_hdr(*pskb),
 				  (*pskb)->len,
 				  &info->manips[i].manip,
 				  info->manips[i].maniptype,
@@ -803,8 +803,8 @@
 		DEBUGP("do_bindings: helper existing for (%p)\n", ct);
 
 		/* Always defragged for helpers */
-		IP_NF_ASSERT(!((*pskb)->nh.iph->frag_off
-			       & __constant_htons(IP_MF|IP_OFFSET)));
+		IP_NF_ASSERT(!(ip_hdr(*pskb)->frag_off &
+			       htons(IP_MF | IP_OFFSET)));
 
 		/* Have to grab read lock before sibling_list traversal */
 		READ_LOCK(&ip_conntrack_lock);
@@ -864,7 +864,7 @@
 		       unsigned int hooknum,
 		       int dir)
 {
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	struct icmphdr *hdr = (struct icmphdr *)((u_int32_t *)iph + iph->ihl);
 	struct iphdr *inner = (struct iphdr *)(hdr + 1);
 	size_t datalen = skb->len - ((void *)inner - (void *)iph);
===== net/ipv4/netfilter/ip_nat_ftp.c 1.6 vs edited =====
--- 1.6/net/ipv4/netfilter/ip_nat_ftp.c	Mon Aug 19 15:51:30 2002
+++ edited/net/ipv4/netfilter/ip_nat_ftp.c	Mon Sep 30 19:22:22 2002
@@ -173,7 +173,7 @@
 			  struct ip_conntrack_expect *expect)
 {
 	u_int32_t newip;
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	struct tcphdr *tcph = (void *)iph + iph->ihl*4;
 	u_int16_t port;
 	struct ip_conntrack_tuple newtuple;
@@ -232,7 +232,7 @@
 			 unsigned int hooknum,
 			 struct sk_buff **pskb)
 {
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	struct tcphdr *tcph = (void *)iph + iph->ihl*4;
 	unsigned int datalen;
 	int dir;
===== net/ipv4/netfilter/ip_nat_helper.c 1.6 vs edited =====
--- 1.6/net/ipv4/netfilter/ip_nat_helper.c	Sun Sep  1 03:08:16 2002
+++ edited/net/ipv4/netfilter/ip_nat_helper.c	Mon Sep 30 19:22:22 2002
@@ -59,7 +59,7 @@
 	DEBUGP("ip_nat_resize_packet: old_size = %u, new_size = %u\n",
 		(*skb)->len, new_size);
 
-	iph = (*skb)->nh.iph;
+	iph = ip_hdr(*skb);
 	tcph = (void *)iph + iph->ihl*4;
 	data = (void *)tcph + tcph->doff*4;
 
@@ -83,7 +83,7 @@
 		}
 	}
 
-	iph = (*skb)->nh.iph;
+	iph = ip_hdr(*skb);
 	tcph = (void *)iph + iph->ihl*4;
 	data = (void *)tcph + tcph->doff*4;
 
@@ -129,7 +129,7 @@
 			 char *rep_buffer,
 			 unsigned int rep_len)
 {
-	struct iphdr *iph = (*skb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*skb);
 	struct tcphdr *tcph;
 	unsigned char *data;
 	u_int32_t tcplen, newlen, newtcplen;
@@ -170,7 +170,7 @@
 	}
 
 	/* skb may be copied !! */
-	iph = (*skb)->nh.iph;
+	iph = ip_hdr(*skb);
 	tcph = (void *)iph + iph->ihl*4;
 	data = (void *)tcph + tcph->doff*4;
 
@@ -261,12 +261,11 @@
 			struct ip_conntrack *ct,
 			enum ip_conntrack_info ctinfo)
 {
-	struct iphdr *iph;
+	struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *tcph;
 	unsigned char *ptr;
 	int length, dir, sack_adjusted = 0;
 
-	iph = skb->nh.iph;
 	tcph = (void *)iph + iph->ihl*4;
 	length = (tcph->doff*4)-sizeof(struct tcphdr);
 	ptr = (unsigned char *)(tcph+1);
@@ -311,12 +310,11 @@
 		  struct ip_conntrack *ct, 
 		  enum ip_conntrack_info ctinfo)
 {
-	struct iphdr *iph;
+	struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *tcph;
 	int dir, newseq, newack;
 	struct ip_nat_seq *this_way, *other_way;	
 	
-	iph = skb->nh.iph;
 	tcph = (void *)iph + iph->ihl*4;
 
 	dir = CTINFO2DIR(ctinfo);
===== net/ipv4/netfilter/ip_nat_irc.c 1.3 vs edited =====
--- 1.3/net/ipv4/netfilter/ip_nat_irc.c	Tue Mar 26 20:16:27 2002
+++ edited/net/ipv4/netfilter/ip_nat_irc.c	Mon Sep 30 19:22:22 2002
@@ -97,7 +97,7 @@
 {
 	u_int32_t newip;
 	struct ip_conntrack_tuple t;
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	struct tcphdr *tcph = (void *) iph + iph->ihl * 4;
 	int port;
 
@@ -161,7 +161,7 @@
 			 unsigned int hooknum, 
 			 struct sk_buff **pskb)
 {
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	struct tcphdr *tcph = (void *) iph + iph->ihl * 4;
 	unsigned int datalen;
 	int dir;
===== net/ipv4/netfilter/ip_nat_snmp_basic.c 1.4 vs edited =====
--- 1.4/net/ipv4/netfilter/ip_nat_snmp_basic.c	Mon Aug 19 15:51:30 2002
+++ edited/net/ipv4/netfilter/ip_nat_snmp_basic.c	Mon Sep 30 19:22:22 2002
@@ -1207,7 +1207,7 @@
                           unsigned int hooknum,
                           struct sk_buff **pskb)
 {
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	struct udphdr *udph = (struct udphdr *)((u_int32_t *)iph + iph->ihl);
 	u_int16_t udplen = ntohs(udph->len);
 	u_int16_t paylen = udplen - sizeof(struct udphdr);
@@ -1250,7 +1250,7 @@
                              struct sk_buff **pskb)
 {
 	int dir = CTINFO2DIR(ctinfo);
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	struct udphdr *udph = (struct udphdr *)((u_int32_t *)iph + iph->ihl);
 
 	spin_lock_bh(&snmp_lock);
===== net/ipv4/netfilter/ip_nat_standalone.c 1.13 vs edited =====
--- 1.13/net/ipv4/netfilter/ip_nat_standalone.c	Tue Mar 26 20:16:27 2002
+++ edited/net/ipv4/netfilter/ip_nat_standalone.c	Mon Sep 30 19:22:22 2002
@@ -74,8 +74,7 @@
 
 	/* We never see fragments: conntrack defrags on pre-routing
 	   and local-out, and ip_nat_out protects post-routing. */
-	IP_NF_ASSERT(!((*pskb)->nh.iph->frag_off
-		       & __constant_htons(IP_MF|IP_OFFSET)));
+	IP_NF_ASSERT(!(ip_hdr(*pskb)->frag_off & htons(IP_MF | IP_OFFSET)));
 
 	(*pskb)->nfcache |= NFC_UNKNOWN;
 
@@ -92,7 +91,7 @@
 		/* Exception: ICMP redirect to new connection (not in
                    hash table yet).  We must not let this through, in
                    case we're doing NAT to the same network. */
-		struct iphdr *iph = (*pskb)->nh.iph;
+		struct iphdr *iph = ip_hdr(*pskb);
 		struct icmphdr *hdr = (struct icmphdr *)
 			((u_int32_t *)iph + iph->ihl);
 		if (iph->protocol == IPPROTO_ICMP
@@ -104,7 +103,7 @@
 	switch (ctinfo) {
 	case IP_CT_RELATED:
 	case IP_CT_RELATED+IP_CT_IS_REPLY:
-		if ((*pskb)->nh.iph->protocol == IPPROTO_ICMP) {
+		if (ip_hdr(*pskb)->protocol == IPPROTO_ICMP) {
 			return icmp_reply_translation(*pskb, ct, hooknum,
 						      CTINFO2DIR(ctinfo));
 		}
@@ -173,7 +172,7 @@
 {
 	/* root is playing with raw sockets. */
 	if ((*pskb)->len < sizeof(struct iphdr)
-	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr))
+	    || ip_hdr(*pskb)->ihl * 4 < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
 	/* We can hit fragment here; forwarded packets get
@@ -186,7 +185,7 @@
 
 	   I'm starting to have nightmares about fragments.  */
 
-	if ((*pskb)->nh.iph->frag_off & __constant_htons(IP_MF|IP_OFFSET)) {
+	if (ip_hdr(*pskb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 		*pskb = ip_ct_gather_frags(*pskb);
 
 		if (!*pskb)
@@ -208,16 +207,16 @@
 
 	/* root is playing with raw sockets. */
 	if ((*pskb)->len < sizeof(struct iphdr)
-	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr))
+	    || ip_hdr(*pskb)->ihl * 4 < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	saddr = (*pskb)->nh.iph->saddr;
-	daddr = (*pskb)->nh.iph->daddr;
+	saddr = ip_hdr(*pskb)->saddr;
+	daddr = ip_hdr(*pskb)->daddr;
 
 	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN
-	    && ((*pskb)->nh.iph->saddr != saddr
-		|| (*pskb)->nh.iph->daddr != daddr))
+	    && (ip_hdr(*pskb)->saddr != saddr
+		|| ip_hdr(*pskb)->daddr != daddr))
 		return ip_route_me_harder(pskb) == 0 ? ret : NF_DROP;
 	return ret;
 }
===== net/ipv4/netfilter/ip_queue.c 1.8 vs edited =====
--- 1.8/net/ipv4/netfilter/ip_queue.c	Tue Jul 23 00:15:20 2002
+++ edited/net/ipv4/netfilter/ip_queue.c	Mon Sep 30 19:22:22 2002
@@ -286,7 +286,7 @@
 	entry->skb = skb;
 
 	if (entry->info->hook == NF_IP_LOCAL_OUT) {
-		struct iphdr *iph = skb->nh.iph;
+		struct iphdr *iph = ip_hdr(skb);
 
 		entry->rt_info.tos = iph->tos;
 		entry->rt_info.daddr = iph->daddr;
@@ -362,7 +362,7 @@
 	 * returns control to the table.
 	 */
 	if (e->info->hook == NF_IP_LOCAL_OUT) {
-		struct iphdr *iph = e->skb->nh.iph;
+		struct iphdr *iph = ip_hdr(e->skb);
 
 		if (!(iph->tos == e->rt_info.tos
 		      && iph->daddr == e->rt_info.daddr
===== net/ipv4/netfilter/ip_tables.c 1.9 vs edited =====
--- 1.9/net/ipv4/netfilter/ip_tables.c	Wed Aug 28 04:53:27 2002
+++ edited/net/ipv4/netfilter/ip_tables.c	Mon Sep 30 19:22:22 2002
@@ -272,7 +272,7 @@
 	struct ipt_entry *e, *back;
 
 	/* Initialization */
-	ip = (*pskb)->nh.iph;
+	ip = ip_hdr(*pskb);
 	protohdr = (u_int32_t *)ip + ip->ihl;
 	datalen = (*pskb)->len - ip->ihl * 4;
 	indev = in ? in->name : nulldevname;
@@ -377,7 +377,7 @@
 					= 0x57acc001;
 #endif
 				/* Target might have changed stuff. */
-				ip = (*pskb)->nh.iph;
+				ip = ip_hdr(*pskb);
 				protohdr = (u_int32_t *)ip + ip->ihl;
 				datalen = (*pskb)->len - ip->ihl * 4;
 
===== net/ipv4/netfilter/ipt_DSCP.c 1.1 vs edited =====
--- 1.1/net/ipv4/netfilter/ipt_DSCP.c	Mon Aug 19 15:48:13 2002
+++ edited/net/ipv4/netfilter/ipt_DSCP.c	Mon Sep 30 19:22:22 2002
@@ -29,7 +29,7 @@
        const void *targinfo,
        void *userinfo)
 {
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	const struct ipt_DSCP_info *dinfo = targinfo;
 	u_int8_t sh_dscp = ((dinfo->dscp << IPT_DSCP_SHIFT) & IPT_DSCP_MASK);
 
@@ -45,7 +45,7 @@
 				return NF_DROP;
 			kfree_skb(*pskb);
 			*pskb = nskb;
-			iph = (*pskb)->nh.iph;
+			iph = ip_hdr(*pskb);
 		}
 
 		diffs[0] = htons(iph->tos) ^ 0xFFFF;
===== net/ipv4/netfilter/ipt_ECN.c 1.1 vs edited =====
--- 1.1/net/ipv4/netfilter/ipt_ECN.c	Mon Aug 19 15:48:13 2002
+++ edited/net/ipv4/netfilter/ipt_ECN.c	Mon Sep 30 19:22:22 2002
@@ -38,7 +38,7 @@
 				return NF_DROP;
 			kfree_skb(*pskb);
 			*pskb = nskb;
-			iph = (*pskb)->nh.iph;
+			iph = ip_hdr(*pskb);
 		}
 
 		diffs[0] = htons(iph->tos) ^ 0xFFFF;
@@ -72,7 +72,7 @@
 			return NF_DROP;
 		kfree_skb(*pskb);
 		*pskb = nskb;
-		iph = (*pskb)->nh.iph;
+		iph = ip_hdr(*pskb);
 	}
 
 	diffs[0] = *tcpflags;
@@ -109,7 +109,7 @@
        const void *targinfo,
        void *userinfo)
 {
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	const struct ipt_ECN_info *einfo = targinfo;
 
 	if (einfo->operation & IPT_ECN_OP_SET_IP)
===== net/ipv4/netfilter/ipt_LOG.c 1.4 vs edited =====
--- 1.4/net/ipv4/netfilter/ipt_LOG.c	Tue Feb  5 13:24:40 2002
+++ edited/net/ipv4/netfilter/ipt_LOG.c	Mon Sep 30 19:22:22 2002
@@ -278,7 +278,7 @@
 	       const void *targinfo,
 	       void *userinfo)
 {
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	const struct ipt_log_info *loginfo = targinfo;
 	char level_string[4] = "< >";
 
===== net/ipv4/netfilter/ipt_MASQUERADE.c 1.5 vs edited =====
--- 1.5/net/ipv4/netfilter/ipt_MASQUERADE.c	Tue Feb  5 05:49:27 2002
+++ edited/net/ipv4/netfilter/ipt_MASQUERADE.c	Mon Sep 30 19:22:22 2002
@@ -84,9 +84,9 @@
 
 	mr = targinfo;
 
-	key.dst = (*pskb)->nh.iph->daddr;
+	key.dst = ip_hdr(*pskb)->daddr;
 	key.src = 0; /* Unknown: that's what we're trying to establish */
-	key.tos = RT_TOS((*pskb)->nh.iph->tos)|RTO_CONN;
+	key.tos = RT_TOS(ip_hdr(*pskb)->tos) | RTO_CONN;
 	key.oif = out->ifindex;
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	key.fwmark = (*pskb)->nfmark;
===== net/ipv4/netfilter/ipt_MIRROR.c 1.3 vs edited =====
--- 1.3/net/ipv4/netfilter/ipt_MIRROR.c	Tue Feb  5 13:23:43 2002
+++ edited/net/ipv4/netfilter/ipt_MIRROR.c	Mon Sep 30 19:22:22 2002
@@ -43,7 +43,7 @@
 
 static int route_mirror(struct sk_buff *skb)
 {
-        struct iphdr *iph = skb->nh.iph;
+        struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 
 	/* Backwards */
@@ -67,7 +67,7 @@
 static void
 ip_rewrite(struct sk_buff *skb)
 {
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph = ip_hdr(skb);
 	u32 odaddr = iph->saddr;
 	u32 osaddr = iph->daddr;
 
@@ -113,7 +113,7 @@
 		/* If we are not at FORWARD hook (INPUT/PREROUTING),
 		 * the TTL isn't decreased by the IP stack */
 		if (hooknum != NF_IP_FORWARD) {
-			struct iphdr *iph = (*pskb)->nh.iph;
+			struct iphdr *iph = ip_hdr(*pskb);
 			if (iph->ttl <= 1) {
 				/* this will traverse normal stack, and 
 				 * thus call conntrack on the icmp packet */
===== net/ipv4/netfilter/ipt_REJECT.c 1.8 vs edited =====
--- 1.8/net/ipv4/netfilter/ipt_REJECT.c	Mon Aug 19 15:51:30 2002
+++ edited/net/ipv4/netfilter/ipt_REJECT.c	Mon Sep 30 19:22:22 2002
@@ -36,6 +36,7 @@
 static void send_reset(struct sk_buff *oldskb, int local)
 {
 	struct sk_buff *nskb;
+	struct iphdr *iph, *oiph = ip_hdr(oldskb);
 	struct tcphdr *otcph, *tcph;
 	struct rtable *rt;
 	unsigned int otcplen;
@@ -44,21 +45,20 @@
 	int needs_ack;
 
 	/* IP header checks: fragment, too short. */
-	if (oldskb->nh.iph->frag_off & htons(IP_OFFSET)
-	    || oldskb->len < (oldskb->nh.iph->ihl<<2) + sizeof(struct tcphdr))
+	if (oiph->frag_off & htons(IP_OFFSET) ||
+	    oldskb->len < (oiph->ihl << 2) + sizeof(struct tcphdr))
 		return;
 
-	otcph = (struct tcphdr *)((u_int32_t*)oldskb->nh.iph + oldskb->nh.iph->ihl);
-	otcplen = oldskb->len - oldskb->nh.iph->ihl*4;
+	otcph = (struct tcphdr *)((u_int32_t*)oiph + oiph->ihl);
+	otcplen = oldskb->len - oiph->ihl * 4;
 
 	/* No RST for RST. */
 	if (otcph->rst)
 		return;
 
 	/* Check checksum. */
-	if (tcp_v4_check(otcph, otcplen, oldskb->nh.iph->saddr,
-			 oldskb->nh.iph->daddr,
-			 csum_partial((char *)otcph, otcplen, 0)) != 0)
+	if (tcp_v4_check(otcph, otcplen, oiph->saddr, oiph->daddr,
+			 csum_partial((char *)otcph, otcplen, 0)))
 		return;
 
 	/* Copy skb (even if skb is about to be dropped, we can't just
@@ -77,20 +77,21 @@
 #endif
 	nskb->nfmark = 0;
 
-	tcph = (struct tcphdr *)((u_int32_t*)nskb->nh.iph + nskb->nh.iph->ihl);
+	iph = ip_hdr(nskb);
+	tcph = (struct tcphdr *)((u_int32_t*)iph + iph->ihl);
 
 	/* Swap source and dest */
-	tmp_addr = nskb->nh.iph->saddr;
-	nskb->nh.iph->saddr = nskb->nh.iph->daddr;
-	nskb->nh.iph->daddr = tmp_addr;
+	tmp_addr = iph->saddr;
+	iph->saddr = iph->daddr;
+	iph->daddr = tmp_addr;
 	tmp_port = tcph->source;
 	tcph->source = tcph->dest;
 	tcph->dest = tmp_port;
 
 	/* Truncate to length (no data) */
-	tcph->doff = sizeof(struct tcphdr)/4;
-	skb_trim(nskb, nskb->nh.iph->ihl*4 + sizeof(struct tcphdr));
-	nskb->nh.iph->tot_len = htons(nskb->len);
+	tcph->doff = sizeof(*tcph) / 4;
+	skb_trim(nskb, iph->ihl * 4 + sizeof(*tcph));
+	iph->tot_len = htons(nskb->len);
 
 	if (tcph->ack) {
 		needs_ack = 0;
@@ -113,28 +114,22 @@
 
 	/* Adjust TCP checksum */
 	tcph->check = 0;
-	tcph->check = tcp_v4_check(tcph, sizeof(struct tcphdr),
-				   nskb->nh.iph->saddr,
-				   nskb->nh.iph->daddr,
-				   csum_partial((char *)tcph,
-						sizeof(struct tcphdr), 0));
+	tcph->check = tcp_v4_check(tcph, sizeof(*tcph), iph->saddr, iph->daddr,
+				   csum_partial((char *)tcph, sizeof(*tcph), 0));
 
 	/* Adjust IP TTL, DF */
-	nskb->nh.iph->ttl = MAXTTL;
+	iph->ttl = MAXTTL;
 	/* Set DF, id = 0 */
-	nskb->nh.iph->frag_off = htons(IP_DF);
-	nskb->nh.iph->id = 0;
+	iph->frag_off = htons(IP_DF);
+	iph->id = 0;
 
 	/* Adjust IP checksum */
-	nskb->nh.iph->check = 0;
-	nskb->nh.iph->check = ip_fast_csum((unsigned char *)nskb->nh.iph, 
-					   nskb->nh.iph->ihl);
+	iph->check = 0;
+	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 
 	/* Routing: if not headed for us, route won't like source */
-	if (ip_route_output(&rt, nskb->nh.iph->daddr,
-			    local ? nskb->nh.iph->saddr : 0,
-			    RT_TOS(nskb->nh.iph->tos) | RTO_CONN,
-			    0) != 0)
+	if (ip_route_output(&rt, iph->daddr, local ? iph->saddr : 0,
+			    RT_TOS(iph->tos) | RTO_CONN, 0))
 		goto free_nskb;
 
 	dst_release(nskb->dst);
@@ -172,7 +167,7 @@
 	if (!xrlim_allow(&rt->u.dst, 1*HZ))
 		return;
 
-	iph = skb_in->nh.iph;
+	iph = ip_hdr(skb_in);
 
 	/* No replies to physical multicast/broadcast */
 	if (skb_in->pkt_type!=PACKET_HOST)
@@ -231,8 +226,7 @@
 	skb_reserve(nskb, hh_len);
 
 	/* Set up IP header */
-	iph = nskb->nh.iph
-		= (struct iphdr *)skb_put(nskb, sizeof(struct iphdr));
+	iph = ip_hdr(skb_in) = (struct iphdr *)skb_put(nskb, sizeof(*iph));
 	iph->version=4;
 	iph->ihl=5;
 	iph->tos=tos;
@@ -261,10 +255,9 @@
 	data = skb_put(nskb,
 		       length - sizeof(struct iphdr) - sizeof(struct icmphdr));
 	/* FIXME: won't work with nonlinear skbs --RR */
-	memcpy(data, skb_in->nh.iph,
-	       length - sizeof(struct iphdr) - sizeof(struct icmphdr));
+	memcpy(data, ip_hdr(skb_in), length - sizeof(*iph) - sizeof(*icmph));
 	icmph->checksum = ip_compute_csum((unsigned char *)icmph,
-					  length - sizeof(struct iphdr));
+					  length - sizeof(*iph));
 
 	connection_attach(nskb, skb_in->nfct);
 
@@ -283,7 +276,7 @@
 
 	/* Our naive response construction doesn't deal with IP
            options, and probably shouldn't try. */
-	if ((*pskb)->nh.iph->ihl<<2 != sizeof(struct iphdr))
+	if (ip_hdr(*pskb)->ihl << 2 != sizeof(struct iphdr))
 		return NF_DROP;
 
 	/* WARNING: This code causes reentry within iptables.
===== net/ipv4/netfilter/ipt_TCPMSS.c 1.5 vs edited =====
--- 1.5/net/ipv4/netfilter/ipt_TCPMSS.c	Tue Feb  5 13:23:43 2002
+++ edited/net/ipv4/netfilter/ipt_TCPMSS.c	Mon Sep 30 19:22:22 2002
@@ -59,7 +59,7 @@
 		*pskb = nskb;
 	}
 
-	iph = (*pskb)->nh.iph;
+	iph = ip_hdr(*pskb);
 	tcplen = (*pskb)->len - iph->ihl*4;
 
 	tcph = (void *)iph + iph->ihl*4;
@@ -119,9 +119,9 @@
 			DEBUGP(KERN_INFO "ipt_tcpmss_target: %u.%u.%u.%u:%hu"
 			       "->%u.%u.%u.%u:%hu changed TCP MSS option"
 			       " (from %u to %u)\n", 
-			       NIPQUAD((*pskb)->nh.iph->saddr),
+			       NIPQUAD(ip_hdr(*pskb)->saddr),
 			       ntohs(tcph->source),
-			       NIPQUAD((*pskb)->nh.iph->daddr),
+			       NIPQUAD(ip_hdr(*pskb)->daddr),
 			       ntohs(tcph->dest),
 			       oldmss, newmss);
 			goto retmodified;
@@ -145,7 +145,7 @@
 
 		kfree_skb(*pskb);
 		*pskb = newskb;
-		iph = (*pskb)->nh.iph;
+		iph = ip_hdr(*pskb);
 		tcph = (void *)iph + iph->ihl*4;
 	}
 
@@ -177,9 +177,9 @@
 
 	DEBUGP(KERN_INFO "ipt_tcpmss_target: %u.%u.%u.%u:%hu"
 	       "->%u.%u.%u.%u:%hu added TCP MSS option (%u)\n",
-	       NIPQUAD((*pskb)->nh.iph->saddr),
+	       NIPQUAD(ip_hdr(*pskb)->saddr),
 	       ntohs(tcph->source),
-	       NIPQUAD((*pskb)->nh.iph->daddr),
+	       NIPQUAD(ip_hdr(*pskb)->daddr),
 	       ntohs(tcph->dest),
 	       newmss);
 
===== net/ipv4/netfilter/ipt_TOS.c 1.6 vs edited =====
--- 1.6/net/ipv4/netfilter/ipt_TOS.c	Tue Feb  5 13:23:43 2002
+++ edited/net/ipv4/netfilter/ipt_TOS.c	Mon Sep 30 19:22:22 2002
@@ -15,7 +15,7 @@
        const void *targinfo,
        void *userinfo)
 {
-	struct iphdr *iph = (*pskb)->nh.iph;
+	struct iphdr *iph = ip_hdr(*pskb);
 	const struct ipt_tos_target_info *tosinfo = targinfo;
 
 	if ((iph->tos & IPTOS_TOS_MASK) != tosinfo->tos) {
@@ -29,7 +29,7 @@
 				return NF_DROP;
 			kfree_skb(*pskb);
 			*pskb = nskb;
-			iph = (*pskb)->nh.iph;
+			iph = ip_hdr(*pskb);
 		}
 
 		diffs[0] = htons(iph->tos) ^ 0xFFFF;
===== net/ipv4/netfilter/ipt_ULOG.c 1.5 vs edited =====
--- 1.5/net/ipv4/netfilter/ipt_ULOG.c	Sun Sep 22 03:24:37 2002
+++ edited/net/ipv4/netfilter/ipt_ULOG.c	Mon Sep 30 19:22:22 2002
@@ -220,7 +220,7 @@
 		*(pm->prefix) = '\0';
 
 	if (in && in->hard_header_len > 0
-	    && (*pskb)->mac.raw != (void *) (*pskb)->nh.iph
+	    && (*pskb)->mac.raw != (void *)ip_hdr(*pskb)
 	    && in->hard_header_len <= ULOG_MAC_LEN) {
 		memcpy(pm->mac, (*pskb)->mac.raw, in->hard_header_len);
 		pm->mac_len = in->hard_header_len;
===== net/ipv4/netfilter/ipt_dscp.c 1.1 vs edited =====
--- 1.1/net/ipv4/netfilter/ipt_dscp.c	Mon Aug 19 15:48:13 2002
+++ edited/net/ipv4/netfilter/ipt_dscp.c	Mon Sep 30 19:22:22 2002
@@ -23,7 +23,7 @@
 		 int *hotdrop)
 {
 	const struct ipt_dscp_info *info = matchinfo;
-	const struct iphdr *iph = skb->nh.iph;
+	const struct iphdr *iph = ip_hdr(skb);
 
 	u_int8_t sh_dscp = ((info->dscp << IPT_DSCP_SHIFT) & IPT_DSCP_MASK);
 
===== net/ipv4/netfilter/ipt_ecn.c 1.1 vs edited =====
--- 1.1/net/ipv4/netfilter/ipt_ecn.c	Mon Aug 19 15:48:13 2002
+++ edited/net/ipv4/netfilter/ipt_ecn.c	Mon Sep 30 19:22:22 2002
@@ -60,7 +60,7 @@
 		 int *hotdrop)
 {
 	const struct ipt_ecn_info *info = matchinfo;
-	const struct iphdr *iph = skb->nh.iph;
+	const struct iphdr *iph = ip_hdr(skb);
 
 	if (info->operation & IPT_ECN_OP_MATCH_IP)
 		if (!match_ip(skb, iph, info))
===== net/ipv4/netfilter/ipt_length.c 1.1 vs edited =====
--- 1.1/net/ipv4/netfilter/ipt_length.c	Tue Feb  5 05:54:00 2002
+++ edited/net/ipv4/netfilter/ipt_length.c	Mon Sep 30 19:22:22 2002
@@ -20,7 +20,7 @@
       int *hotdrop)
 {
 	const struct ipt_length_info *info = matchinfo;
-	u_int16_t pktlen = ntohs(skb->nh.iph->tot_len);
+	u_int16_t pktlen = ntohs(ip_hdr(skb)->tot_len);
 	
 	return (pktlen >= info->min && pktlen <= info->max) ^ info->invert;
 }
===== net/ipv4/netfilter/ipt_tcpmss.c 1.2 vs edited =====
--- 1.2/net/ipv4/netfilter/ipt_tcpmss.c	Tue Feb  5 05:49:27 2002
+++ edited/net/ipv4/netfilter/ipt_tcpmss.c	Mon Sep 30 19:22:22 2002
@@ -53,10 +53,10 @@
       int *hotdrop)
 {
 	const struct ipt_tcpmss_match_info *info = matchinfo;
-	const struct tcphdr *tcph = (void *)skb->nh.iph + skb->nh.iph->ihl*4;
+	const struct tcphdr *tcph = (void *)ip_hdr(skb) + ip_hdr(skb)->ihl * 4;
 
 	return mssoption_match(info->mss_min, info->mss_max, tcph,
-			       skb->len - skb->nh.iph->ihl*4,
+			       skb->len - ip_hdr(skb)->ihl * 4,
 			       info->invert, hotdrop);
 }
 
===== net/ipv4/netfilter/ipt_tos.c 1.2 vs edited =====
--- 1.2/net/ipv4/netfilter/ipt_tos.c	Tue Feb  5 05:49:27 2002
+++ edited/net/ipv4/netfilter/ipt_tos.c	Mon Sep 30 19:22:22 2002
@@ -16,7 +16,7 @@
       int *hotdrop)
 {
 	const struct ipt_tos_info *info = matchinfo;
-	const struct iphdr *iph = skb->nh.iph;
+	const struct iphdr *iph = ip_hdr(skb);
 
 	return (iph->tos == info->tos) ^ info->invert;
 }
===== net/ipv4/netfilter/ipt_ttl.c 1.1 vs edited =====
--- 1.1/net/ipv4/netfilter/ipt_ttl.c	Tue Feb  5 05:54:00 2002
+++ edited/net/ipv4/netfilter/ipt_ttl.c	Mon Sep 30 19:22:22 2002
@@ -23,7 +23,7 @@
 		 int *hotdrop)
 {
 	const struct ipt_ttl_info *info = matchinfo;
-	const struct iphdr *iph = skb->nh.iph;
+	const struct iphdr *iph = ip_hdr(skb);
 
 	switch (info->mode) {
 		case IPT_TTL_EQ:
===== net/ipv4/netfilter/ipt_unclean.c 1.6 vs edited =====
--- 1.6/net/ipv4/netfilter/ipt_unclean.c	Sun Sep 22 03:24:37 2002
+++ edited/net/ipv4/netfilter/ipt_unclean.c	Mon Sep 30 19:22:22 2002
@@ -554,7 +554,7 @@
       u_int16_t datalen,
       int *hotdrop)
 {
-	return !check_ip(skb->nh.iph, skb->len, 0);
+	return !check_ip(ip_hdr(skb), skb->len, 0);
 }
 
 /* Called when user tries to insert an entry of this type. */
===== net/ipv4/netfilter/iptable_filter.c 1.3 vs edited =====
--- 1.3/net/ipv4/netfilter/iptable_filter.c	Tue Feb  5 13:24:40 2002
+++ edited/net/ipv4/netfilter/iptable_filter.c	Mon Sep 30 19:22:22 2002
@@ -105,7 +105,7 @@
 {
 	/* root is playing with raw sockets. */
 	if ((*pskb)->len < sizeof(struct iphdr)
-	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr)) {
+	    || ip_hdr(*pskb)->ihl * 4 < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("ipt_hook: happy cracking.\n");
 		return NF_ACCEPT;
===== net/ipv4/netfilter/iptable_mangle.c 1.7 vs edited =====
--- 1.7/net/ipv4/netfilter/iptable_mangle.c	Mon Feb 11 05:21:45 2002
+++ edited/net/ipv4/netfilter/iptable_mangle.c	Mon Sep 30 19:22:22 2002
@@ -136,6 +136,7 @@
 		   const struct net_device *out,
 		   int (*okfn)(struct sk_buff *))
 {
+	struct iphdr *iph = ip_hdr(*pskb);
 	unsigned int ret;
 	u_int8_t tos;
 	u_int32_t saddr, daddr;
@@ -143,7 +144,7 @@
 
 	/* root is playing with raw sockets. */
 	if ((*pskb)->len < sizeof(struct iphdr)
-	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr)) {
+	    || iph->ihl * 4 < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("ipt_hook: happy cracking.\n");
 		return NF_ACCEPT;
@@ -151,17 +152,17 @@
 
 	/* Save things which could affect route */
 	nfmark = (*pskb)->nfmark;
-	saddr = (*pskb)->nh.iph->saddr;
-	daddr = (*pskb)->nh.iph->daddr;
-	tos = (*pskb)->nh.iph->tos;
+	saddr  = iph->saddr;
+	daddr  = iph->daddr;
+	tos    = iph->tos;
 
 	ret = ipt_do_table(pskb, hook, in, out, &packet_mangler, NULL);
 	/* Reroute for ANY change. */
 	if (ret != NF_DROP && ret != NF_STOLEN && ret != NF_QUEUE
-	    && ((*pskb)->nh.iph->saddr != saddr
-		|| (*pskb)->nh.iph->daddr != daddr
+	    && (iph->saddr != saddr
+		|| iph->daddr != daddr
 		|| (*pskb)->nfmark != nfmark
-		|| (*pskb)->nh.iph->tos != tos))
+		|| iph->tos != tos))
 		return ip_route_me_harder(pskb) == 0 ? ret : NF_DROP;
 
 	return ret;
===== net/ipv6/datagram.c 1.4 vs edited =====
--- 1.4/net/ipv6/datagram.c	Mon Feb 11 05:06:54 2002
+++ edited/net/ipv6/datagram.c	Mon Sep 30 19:22:22 2002
@@ -172,9 +172,8 @@
 		} else {
 			struct inet_opt *inet = inet_sk(sk);
 
-			ipv6_addr_set(&sin->sin6_addr, 0, 0,
-				      __constant_htonl(0xffff),
-				      skb->nh.iph->saddr);
+			ipv6_addr_set(&sin->sin6_addr, 0, 0, htonl(0xffff),
+				      ip_hdr(skb)->saddr);
 			if (inet->cmsg_flags)
 				ip_cmsg_recv(msg, skb);
 		}
===== net/ipv6/sit.c 1.12 vs edited =====
--- 1.12/net/ipv6/sit.c	Fri Jul 19 03:16:20 2002
+++ edited/net/ipv6/sit.c	Mon Sep 30 19:22:22 2002
@@ -389,7 +389,7 @@
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto out;
 
-	iph = skb->nh.iph;
+	iph = ip_hdr(skb);
 
 	read_lock(&ipip6_lock);
 	if ((tunnel = ipip6_tunnel_lookup(iph->saddr, iph->daddr)) != NULL) {
@@ -584,11 +584,11 @@
 	 *	Push down and install the IPIP header.
 	 */
 
-	iph 			=	skb->nh.iph;
+	iph 			=	ip_hdr(skb);
 	iph->version		=	4;
 	iph->ihl		=	sizeof(struct iphdr)>>2;
 	if (mtu > IPV6_MIN_MTU)
-		iph->frag_off	=	__constant_htons(IP_DF);
+		iph->frag_off	=	htons(IP_DF);
 	else
 		iph->frag_off	=	0;
 
===== net/ipv6/tcp_ipv6.c 1.22 vs edited =====
--- 1.22/net/ipv6/tcp_ipv6.c	Thu Aug 29 05:57:05 2002
+++ edited/net/ipv6/tcp_ipv6.c	Mon Sep 30 19:22:22 2002
@@ -414,8 +414,8 @@
 						    skb->h.th->dest,
 						    skb->h.th->source);
 	} else {
-		return secure_tcp_sequence_number(skb->nh.iph->daddr,
-						  skb->nh.iph->saddr,
+		return secure_tcp_sequence_number(ip_hdr(skb)->daddr,
+						  ip_hdr(skb)->saddr,
 						  skb->h.th->dest,
 						  skb->h.th->source);
 	}
===== net/ipv6/udp.c 1.12 vs edited =====
--- 1.12/net/ipv6/udp.c	Sun Sep 22 16:15:33 2002
+++ edited/net/ipv6/udp.c	Mon Sep 30 19:22:22 2002
@@ -424,11 +424,11 @@
 		sin6->sin6_flowinfo = 0;
 		sin6->sin6_scope_id = 0;
 
-		if (skb->protocol == __constant_htons(ETH_P_IP)) {
+		if (skb->protocol == htons(ETH_P_IP)) {
 			struct inet_opt *inet = inet_sk(sk);
 
 			ipv6_addr_set(&sin6->sin6_addr, 0, 0,
-				      __constant_htonl(0xffff), skb->nh.iph->saddr);
+				      htonl(0xffff), ip_hdr(skb)->saddr);
 			if (inet->cmsg_flags)
 				ip_cmsg_recv(msg, skb);
 		} else {
===== net/ipv6/netfilter/ip6table_filter.c 1.3 vs edited =====
--- 1.3/net/ipv6/netfilter/ip6table_filter.c	Tue Feb  5 13:24:40 2002
+++ edited/net/ipv6/netfilter/ip6table_filter.c	Mon Sep 30 19:22:22 2002
@@ -106,7 +106,7 @@
 #if 0
 	/* root is playing with raw sockets. */
 	if ((*pskb)->len < sizeof(struct iphdr)
-	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr)) {
+	    || ip_hdr(*pskb)->ihl * 4 < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("ip6t_hook: happy cracking.\n");
 		return NF_ACCEPT;
===== net/ipv6/netfilter/ip6table_mangle.c 1.3 vs edited =====
--- 1.3/net/ipv6/netfilter/ip6table_mangle.c	Tue Feb  5 13:24:40 2002
+++ edited/net/ipv6/netfilter/ip6table_mangle.c	Mon Sep 30 19:22:22 2002
@@ -143,7 +143,7 @@
 #if 0
 	/* root is playing with raw sockets. */
 	if ((*pskb)->len < sizeof(struct iphdr)
-	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr)) {
+	    || ip_hdr(*pskb)->ihl * 4 < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("ip6t_hook: happy cracking.\n");
 		return NF_ACCEPT;
===== net/sched/cls_rsvp.h 1.2 vs edited =====
--- 1.2/net/sched/cls_rsvp.h	Tue Feb  5 13:24:36 2002
+++ edited/net/sched/cls_rsvp.h	Mon Sep 30 19:22:22 2002
@@ -146,7 +146,7 @@
 #if RSVP_DST_LEN == 4
 	struct ipv6hdr *nhptr = skb->nh.ipv6h;
 #else
-	struct iphdr *nhptr = skb->nh.iph;
+	struct iphdr *nhptr = ip_hdr(skb);
 #endif
 
 #if !defined( __i386__) && !defined(__mc68000__)
===== net/sched/sch_atm.c 1.3 vs edited =====
--- 1.3/net/sched/sch_atm.c	Tue Feb  5 13:24:36 2002
+++ edited/net/sched/sch_atm.c	Mon Sep 30 19:22:22 2002
@@ -497,7 +497,7 @@
 			}
 			D2PRINTK("atm_tc_deqeueue: sending on class %p\n",flow);
 			/* remove any LL header somebody else has attached */
-			skb_pull(skb,(char *) skb->nh.iph-(char *) skb->data);
+			skb_pull(skb, (char *)ip_hdr(skb) - (char *)skb->data);
 			if (skb_headroom(skb) < flow->hdr_len) {
 				struct sk_buff *new;
 
@@ -507,7 +507,7 @@
 				skb = new;
 			}
 			D2PRINTK("sch_atm_dequeue: ip %p, data %p\n",
-			    skb->nh.iph,skb->data);
+				 ip_hdr(skb), skb->data);
 			ATM_SKB(skb)->vcc = flow->vcc;
 			memcpy(skb_push(skb,flow->hdr_len),flow->hdr,
 			    flow->hdr_len);
===== net/sched/sch_dsmark.c 1.6 vs edited =====
--- 1.6/net/sched/sch_dsmark.c	Tue Feb  5 13:24:36 2002
+++ edited/net/sched/sch_dsmark.c	Mon Sep 30 19:22:22 2002
@@ -194,10 +194,10 @@
 	D2PRINTK("dsmark_enqueue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
 	if (p->set_tc_index) {
 		switch (skb->protocol) {
-			case __constant_htons(ETH_P_IP):
-				skb->tc_index = ipv4_get_dsfield(skb->nh.iph);
+			case htons(ETH_P_IP):
+				skb->tc_index = ipv4_get_dsfield(ip_hdr(skb));
 				break;
-			case __constant_htons(ETH_P_IPV6):
+			case htons(ETH_P_IPV6):
 				skb->tc_index = ipv6_get_dsfield(skb->nh.ipv6h);
 				break;
 			default:
@@ -262,13 +262,13 @@
 	index = skb->tc_index & (p->indices-1);
 	D2PRINTK("index %d->%d\n",skb->tc_index,index);
 	switch (skb->protocol) {
-		case __constant_htons(ETH_P_IP):
-			ipv4_change_dsfield(skb->nh.iph,
-			    p->mask[index],p->value[index]);
+		case htons(ETH_P_IP):
+			ipv4_change_dsfield(ip_hdr(skb), p->mask[index],
+					    p->value[index]);
 			break;
-		case __constant_htons(ETH_P_IPV6):
-			ipv6_change_dsfield(skb->nh.ipv6h,
-			    p->mask[index],p->value[index]);
+		case htons(ETH_P_IPV6):
+			ipv6_change_dsfield(skb->nh.ipv6h, p->mask[index],
+					    p->value[index]);
 			break;
 		default:
 			/*
===== net/sched/sch_red.c 1.4 vs edited =====
--- 1.4/net/sched/sch_red.c	Tue Feb  5 13:24:36 2002
+++ edited/net/sched/sch_red.c	Mon Sep 30 19:22:22 2002
@@ -164,26 +164,26 @@
 		return 0;
 
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 	{
-		u8 tos = skb->nh.iph->tos;
+		u8 tos = ip_hdr(skb)->tos;
 
 		if (!(tos & RED_ECN_ECT))
 			return 0;
 
 		if (!(tos & RED_ECN_CE))
-			IP_ECN_set_ce(skb->nh.iph);
+			IP_ECN_set_ce(ip_hdr(skb));
 
 		return 1;
 	}
 
-	case __constant_htons(ETH_P_IPV6):
+	case htons(ETH_P_IPV6):
 	{
 		u32 label = *(u32*)skb->nh.raw;
 
-		if (!(label & __constant_htonl(RED_ECN_ECT<<20)))
+		if (!(label & htonl(RED_ECN_ECT << 20)))
 			return 0;
-		label |= __constant_htonl(RED_ECN_CE<<20);
+		label |= htonl(RED_ECN_CE << 20);
 		return 1;
 	}
 
===== net/sched/sch_sfq.c 1.5 vs edited =====
--- 1.5/net/sched/sch_sfq.c	Wed May 22 15:16:37 2002
+++ edited/net/sched/sch_sfq.c	Mon Sep 30 19:22:22 2002
@@ -140,9 +140,9 @@
 	u32 h, h2;
 
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 	{
-		struct iphdr *iph = skb->nh.iph;
+		struct iphdr *iph = ip_hdr(skb);
 		h = iph->daddr;
 		h2 = iph->saddr^iph->protocol;
 		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
@@ -152,7 +152,7 @@
 			h2 ^= *(((u32*)iph) + iph->ihl);
 		break;
 	}
-	case __constant_htons(ETH_P_IPV6):
+	case htons(ETH_P_IPV6):
 	{
 		struct ipv6hdr *iph = skb->nh.ipv6h;
 		h = iph->daddr.s6_addr32[3];
===== net/sctp/input.c 1.5 vs edited =====
--- 1.5/net/sctp/input.c	Wed Sep 25 10:16:43 2002
+++ edited/net/sctp/input.c	Mon Sep 30 19:22:22 2002
@@ -76,13 +76,14 @@
 	__u16 *port;
 	size_t len;
 	struct sctphdr *sh;
+	struct iphdr *iph = ip_hdr(skb);
 
-	switch (skb->nh.iph->version) {
+	switch (iph->version) {
 	case 4:
 		to = &addr->v4.sin_addr.s_addr;
 		port = &addr->v4.sin_port;
-		saddr = &skb->nh.iph->saddr;
-		daddr = &skb->nh.iph->daddr;
+		saddr = &iph->saddr;
+		daddr = &iph->daddr;
 		len = sizeof(struct in_addr);
 		addr->v4.sin_family = AF_INET;
 		break;
===== net/sctp/protocol.c 1.7 vs edited =====
--- 1.7/net/sctp/protocol.c	Wed Sep 25 10:16:43 2002
+++ edited/net/sctp/protocol.c	Mon Sep 30 19:22:22 2002
@@ -387,7 +387,7 @@
 		sin = (struct sockaddr_in *)msgname;
 		sh = (struct sctphdr *)skb->h.raw;
 		sin->sin_port = sh->source;
-		sin->sin_addr.s_addr = skb->nh.iph->saddr;
+		sin->sin_addr.s_addr = ip_hdr(skb)->saddr;
 	}
 } 
 
===== net/sctp/sm_make_chunk.c 1.8 vs edited =====
--- 1.8/net/sctp/sm_make_chunk.c	Wed Sep 25 10:16:43 2002
+++ edited/net/sctp/sm_make_chunk.c	Mon Sep 30 19:22:22 2002
@@ -971,7 +971,7 @@
 
 	source = &chunk->source;
 	skb = chunk->skb;
-	ih4 = skb->nh.iph;
+	ih4 = ip_hdr(skb);
 	ih6 = skb->nh.ipv6h;
 	sh = chunk->sctp_hdr;
 
@@ -1186,20 +1186,20 @@
 {
 	sctp_association_t *asoc;
 	sctp_scope_t scope;
+	struct iphdr *iph;
 
 	/* Create the bare association.  */
 	scope = sctp_scope(sctp_source(chunk));
 	asoc = sctp_association_new(ep, ep->base.sk, scope, priority);
 	if (!asoc)
 		goto nodata;
-
+	iph = ip_hdr(chunk->skb);
 	/* Create an entry for the source address of the packet.  */
-	switch (chunk->skb->nh.iph->version) {
+	switch (iph->version) {
 	case 4:
 		asoc->c.peer_addr.v4.sin_family     = AF_INET;
 		asoc->c.peer_addr.v4.sin_port = ntohs(chunk->sctp_hdr->source);
-		asoc->c.peer_addr.v4.sin_addr.s_addr =
-			chunk->skb->nh.iph->saddr;
+		asoc->c.peer_addr.v4.sin_addr.s_addr = iph->saddr;
                 break;
 
 	case 6:
===== net/sctp/sm_statefuns.c 1.8 vs edited =====
--- 1.8/net/sctp/sm_statefuns.c	Wed Sep 25 10:16:43 2002
+++ edited/net/sctp/sm_statefuns.c	Mon Sep 30 19:22:22 2002
@@ -1926,7 +1926,7 @@
 
 	if (!chunk->ecn_ce_done) {
 		chunk->ecn_ce_done = 1;
-		if (INET_ECN_is_ce(chunk->skb->nh.iph->tos) &&
+		if (INET_ECN_is_ce(ip_hdr(chunk->skb)->tos) &&
 		    asoc->peer.ecn_capable) {
 			/* Do real work as sideffect. */
 			sctp_add_cmd_sf(commands, SCTP_CMD_ECN_CE,
@@ -2140,7 +2140,7 @@
 	 */
 	if (!chunk->ecn_ce_done) {
 		chunk->ecn_ce_done = 1;
-		if (INET_ECN_is_ce(chunk->skb->nh.iph->tos) &&
+		if (INET_ECN_is_ce(ip_hdr(chunk->skb)->tos) &&
 		    asoc->peer.ecn_capable) {
 			/* Do real work as sideffect. */
 			sctp_add_cmd_sf(commands, SCTP_CMD_ECN_CE,
===== net/sunrpc/svcsock.c 1.26 vs edited =====
--- 1.26/net/sunrpc/svcsock.c	Wed Sep 18 07:05:34 2002
+++ edited/net/sunrpc/svcsock.c	Mon Sep 30 19:22:22 2002
@@ -532,7 +532,7 @@
 	/* Get sender address */
 	rqstp->rq_addr.sin_family = AF_INET;
 	rqstp->rq_addr.sin_port = skb->h.uh->source;
-	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
+	rqstp->rq_addr.sin_addr.s_addr = ip_hdr(skb)->saddr;
 
 	if (serv->sv_stats)
 		serv->sv_stats->netudpcnt++;
