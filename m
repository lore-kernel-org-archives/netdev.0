From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Sat,  4 Jan 2014 20:37:59 -0800
Message-ID: <1388896679-23152-1-git-send-email-hkchu@google.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jerry Chu <hkchu@google.com>
To: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:60761 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbaAEEiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 23:38:04 -0500
Received: by mail-qa0-f73.google.com with SMTP id o15so139129qap.2
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 20:38:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

This patch built on top of Commit 299603e8370a93dd5d8e8d800f0dff1ce2c53d36
("net-gro: Prepare GRO stack for the upcoming tunneling support") to add
the support of the standard GRE (RFC1701/RFC2784/RFC2890) to the GRO
stack. It also serves as an example for supporting other encapsulation
protocols in the GRO stack in the future.

The patch supports version 0 and all the flags (key, csum, seq#) but
will flush any pkt with the S (seq#) flag. This is because the S flag
is not support by GSO, and a GRO pkt may end up in the forwarding path,
thus requiring GSO support to break it up correctly.

Currently the "packet_offload" structure only contains L3 (ETH_P_IP/
ETH_P_IPV6) GRO offload support so the encapped pkts are limited to
IP pkts (i.e., w/o L2 hdr). But support for other protocol type can
be easily added, so is the support for GRE variations like NVGRE.

The patch also support csum offload. Specifically if the csum flag is on
and the h/w is capable of checksumming the payload (CHECKSUM_COMPLETE),
the code will take advantage of the csum computed by the h/w when
validating the GRE csum.

Note that commit 60769a5dcd8755715c7143b4571d5c44f01796f1 "ipv4: gre:
add GRO capability" already introduces GRO capability to IPv4 GRE
tunnels, using the gro_cells infrastructure. But GRO is done after
GRE hdr has been removed (i.e., decapped). The following patch applies
GRO when pkts first come in (before hitting the GRE tunnel code). There
is some performance advantage for applying GRO as early as possible.
Also this approach is transparent to other subsystem like Open vSwitch
where GRE decap is handled outside of the IP stack hence making it
harder for the gro_cells stuff to apply. On the other hand, some NICs
are still not capable of hashing on the inner hdr of a GRE pkt (RSS).
In that case the GRO processing of pkts from the same remote host will
all happen on the same CPU and the performance may be suboptimal.

I'm including some rough preliminary performance numbers below. Note
that the performance will be highly dependent on traffic load, mix as
usual. Moreover it also depends on NIC offload features hence the
following is by no means a comprehesive study. Local testing and tuning
will be needed to decide the best setting.

All tests spawned 50 copies of netperf TCP_STREAM and ran for 30 secs.
(super_netperf 50 -H 192.168.1.18 -l 30)

An IP GRE tunnel with only the key flag on (e.g., ip tunnel add gre1
mode gre local 10.246.17.18 remote 10.246.17.17 ttl 255 key 123)
is configured.

The GRO support for pkts AFTER decap are controlled through the device
feature of the GRE device (e.g., ethtool -K gre1 gro on/off).

1.1 ethtool -K gre1 gro off; ethtool -K eth0 gro off
thruput: 9.16Gbps
CPU utilization: 19%

1.2 ethtool -K gre1 gro on; ethtool -K eth0 gro off
thruput: 5.9Gbps
CPU utilization: 15%

1.3 ethtool -K gre1 gro off; ethtool -K eth0 gro on
thruput: 9.26Gbps
CPU utilization: 12-13%

1.4 ethtool -K gre1 gro on; ethtool -K eth0 gro on
thruput: 9.26Gbps
CPU utilization: 10%

The following tests were performed on a different NIC that is capable of
csum offload. I.e., the h/w is capable of computing IP payload csum
(CHECKSUM_COMPLETE).

2.1 ethtool -K gre1 gro on (hence will use gro_cells)

2.1.1 ethtool -K eth0 gro off; csum offload disabled
thruput: 8.53Gbps
CPU utilization: 9%

2.1.2 ethtool -K eth0 gro off; csum offload enabled
thruput: 8.97Gbps
CPU utilization: 7-8%

2.1.3 ethtool -K eth0 gro on; csum offload disabled
thruput: 8.83Gbps
CPU utilization: 5-6%

2.1.4 ethtool -K eth0 gro on; csum offload enabled
thruput: 8.98Gbps
CPU utilization: 5%

2.2 ethtool -K gre1 gro off

2.2.1 ethtool -K eth0 gro off; csum offload disabled
thruput: 5.93Gbps
CPU utilization: 9%

2.2.2 ethtool -K eth0 gro off; csum offload enabled
thruput: 5.62Gbps
CPU utilization: 8%

2.2.3 ethtool -K eth0 gro on; csum offload disabled
thruput: 7.69Gbps
CPU utilization: 8%

2.2.4 ethtool -K eth0 gro on; csum offload enabled
thruput: 8.96Gbps
CPU utilization: 5-6%

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
Reviewed-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |  18 +++++-
 net/core/dev.c            |  26 ++++++++
 net/ipv4/Makefile         |   4 +-
 net/ipv4/af_inet.c        |  10 ++-
 net/ipv4/gre_offload.c    | 160 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_offload.c    |   7 +-
 net/ipv6/ip6_offload.c    |   2 +-
 7 files changed, 218 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 88afa80..ef5a193 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1632,7 +1632,10 @@ struct napi_gro_cb {
 	int data_offset;
 
 	/* This is non-zero if the packet cannot be merged with the new skb. */
-	int flush;
+	u16	flush;
+
+	/* Save the IP ID here and check when we get to the transport layer */
+	u16	flush_id;
 
 	/* Number of segments aggregated. */
 	u16	count;
@@ -1651,6 +1654,9 @@ struct napi_gro_cb {
 	/* Used in ipv6_gro_receive() */
 	int	proto;
 
+	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
+	__wsum	csum;
+
 	/* used in skb_gro_receive() slow path */
 	struct sk_buff *last;
 };
@@ -1894,6 +1900,14 @@ static inline void *skb_gro_network_header(struct sk_buff *skb)
 	       skb_network_offset(skb);
 }
 
+static inline void skb_gro_postpull_rcsum(struct sk_buff *skb,
+					const void *start, unsigned int len)
+{
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		NAPI_GRO_CB(skb)->csum = csum_sub(NAPI_GRO_CB(skb)->csum,
+						  csum_partial(start, len, 0));
+}
+
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
@@ -2425,6 +2439,8 @@ gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb);
 void napi_gro_flush(struct napi_struct *napi, bool flush_old);
 struct sk_buff *napi_get_frags(struct napi_struct *napi);
 gro_result_t napi_gro_frags(struct napi_struct *napi);
+struct packet_offload *gro_find_receive_by_type(__be16 type);
+struct packet_offload *gro_find_complete_by_type(__be16 type);
 
 static inline void napi_free_frags(struct napi_struct *napi)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 973c236..260b3fe 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3847,6 +3847,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 
 	skb_gro_reset_offset(skb);
 	gro_list_prepare(napi, skb);
+	NAPI_GRO_CB(skb)->csum = skb->csum; /* Needed for CHECKSUM_COMPLETE */
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
@@ -3923,6 +3924,31 @@ normal:
 	goto pull;
 }
 
+struct packet_offload *gro_find_receive_by_type(__be16 type)
+{
+	struct list_head *offload_head = &offload_base;
+	struct packet_offload *ptype;
+
+	list_for_each_entry_rcu(ptype, offload_head, list) {
+		if (ptype->type != type || !ptype->callbacks.gro_receive)
+			continue;
+		return ptype;
+	}
+	return NULL;
+}
+
+struct packet_offload *gro_find_complete_by_type(__be16 type)
+{
+	struct list_head *offload_head = &offload_base;
+	struct packet_offload *ptype;
+
+	list_for_each_entry_rcu(ptype, offload_head, list) {
+		if (ptype->type != type || !ptype->callbacks.gro_complete)
+			continue;
+		return ptype;
+	}
+	return NULL;
+}
 
 static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 {
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 4b81e91..f8c49ce 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -11,7 +11,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
 	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
-	     inet_fragment.o ping.o ip_tunnel_core.o
+	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o
 
 obj-$(CONFIG_NET_IP_TUNNEL) += ip_tunnel.o
 obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
@@ -19,7 +19,7 @@ obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
-gre-y := gre_demux.o gre_offload.o
+gre-y := gre_demux.o
 obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
 obj-$(CONFIG_NET_IPVTI) += ip_vti.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index b8bc1a3..6268a47 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1391,9 +1391,15 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 		NAPI_GRO_CB(p)->flush |=
 			(iph->ttl ^ iph2->ttl) |
 			(iph->tos ^ iph2->tos) |
-			(__force int)((iph->frag_off ^ iph2->frag_off) & htons(IP_DF)) |
-			((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) ^ id);
+			((iph->frag_off ^ iph2->frag_off) & htons(IP_DF));
 
+		/* Save the IP ID check to be included later when we get to
+		 * the transport layer so only the inner most IP ID is checked.
+		 * This is because some GSO/TSO implementations do not
+		 * correctly increment the IP ID for the outer hdrs.
+		 */
+		NAPI_GRO_CB(p)->flush_id =
+			    ((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) ^ id);
 		NAPI_GRO_CB(p)->flush |= flush;
 	}
 
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index e5d4361..3388d69 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -113,10 +113,170 @@ out:
 	return segs;
 }
 
+/* Compute the whole skb csum in s/w and store it, then verify GRO csum
+ * starting from gro_offset.
+ */
+static __sum16 gro_skb_checksum(struct sk_buff *skb)
+{
+	__sum16 sum;
+
+	skb->csum = skb_checksum(skb, 0, skb->len, 0);
+	NAPI_GRO_CB(skb)->csum = csum_sub(skb->csum,
+		csum_partial(skb->data, skb_gro_offset(skb), 0));
+	sum = csum_fold(NAPI_GRO_CB(skb)->csum);
+	if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE)) {
+		if (unlikely(!sum))
+			netdev_rx_csum_fault(skb->dev);
+	} else
+		skb->ip_summed = CHECKSUM_COMPLETE;
+
+	return sum;
+}
+
+static struct sk_buff **gre_gro_receive(struct sk_buff **head,
+					struct sk_buff *skb)
+{
+	struct sk_buff **pp = NULL;
+	struct sk_buff *p;
+	const struct gre_base_hdr *greh;
+	unsigned int hlen, grehlen;
+	unsigned int off;
+	int flush = 1;
+	struct packet_offload *ptype;
+	__be16 type;
+
+	off = skb_gro_offset(skb);
+	hlen = off + sizeof(*greh);
+	greh = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, hlen)) {
+		greh = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!greh))
+			goto out;
+	}
+
+	/* Only support version 0 and K (key), C (csum) flags. Note that
+	 * although the support for the S (seq#) flag can be added easily
+	 * for GRO, this is problematic for GSO hence can not be enabled
+	 * here because a GRO pkt may end up in the forwarding path, thus
+	 * requiring GSO support to break it up correctly.
+	 */
+	if ((greh->flags & ~(GRE_KEY|GRE_CSUM)) != 0)
+		goto out;
+
+	type = greh->protocol;
+
+	rcu_read_lock();
+	ptype = gro_find_receive_by_type(type);
+	if (ptype == NULL)
+		goto out_unlock;
+
+	grehlen = GRE_HEADER_SECTION;
+
+	if (greh->flags & GRE_KEY)
+		grehlen += GRE_HEADER_SECTION;
+
+	if (greh->flags & GRE_CSUM)
+		grehlen += GRE_HEADER_SECTION;
+
+	hlen = off + grehlen;
+	if (skb_gro_header_hard(skb, hlen)) {
+		greh = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!greh))
+			goto out_unlock;
+	}
+	if (greh->flags & GRE_CSUM) { /* Need to verify GRE csum first */
+		__sum16 csum = 0;
+
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			csum = csum_fold(NAPI_GRO_CB(skb)->csum);
+		/* Don't trust csum error calculated/reported by h/w */
+		if (skb->ip_summed == CHECKSUM_NONE || csum != 0)
+			csum = gro_skb_checksum(skb);
+
+		/* GRE CSUM is the 1's complement of the 1's complement sum
+		 * of the GRE hdr plus payload so it should add up to 0xffff
+		 * (and 0 after csum_fold()) just like the IPv4 hdr csum.
+		 */
+		if (csum)
+			goto out_unlock;
+	}
+	flush = 0;
+
+	for (p = *head; p; p = p->next) {
+		const struct gre_base_hdr *greh2;
+
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		/* The following checks are needed to ensure only pkts
+		 * from the same tunnel are considered for aggregation.
+		 * The criteria for "the same tunnel" includes:
+		 * 1) same version (we only support version 0 here)
+		 * 2) same protocol (we only support ETH_P_IP for now)
+		 * 3) same set of flags
+		 * 4) same key if the key field is present.
+		 */
+		greh2 = (struct gre_base_hdr *)(p->data + off);
+
+		if (greh2->flags != greh->flags ||
+		    greh2->protocol != greh->protocol) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+		if (greh->flags & GRE_KEY) {
+			/* compare keys */
+			if (*(__be32 *)(greh2+1) != *(__be32 *)(greh+1)) {
+				NAPI_GRO_CB(p)->same_flow = 0;
+				continue;
+			}
+		}
+	}
+
+	skb_gro_pull(skb, grehlen);
+
+	/* Adjusted NAPI_GRO_CB(skb)->csum after skb_gro_pull()*/
+	skb_gro_postpull_rcsum(skb, greh, grehlen);
+
+	pp = ptype->callbacks.gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+int gre_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	struct gre_base_hdr *greh = (struct gre_base_hdr *)(skb->data + nhoff);
+	struct packet_offload *ptype;
+	unsigned int grehlen = sizeof(*greh);
+	int err = -ENOENT;
+	__be16 type;
+
+	type = greh->protocol;
+	if (greh->flags & GRE_KEY)
+		grehlen += GRE_HEADER_SECTION;
+
+	if (greh->flags & GRE_CSUM)
+		grehlen += GRE_HEADER_SECTION;
+
+	rcu_read_lock();
+	ptype = gro_find_complete_by_type(type);
+	if (ptype != NULL)
+		err = ptype->callbacks.gro_complete(skb, nhoff + grehlen);
+
+	rcu_read_unlock();
+	return err;
+}
+
 static const struct net_offload gre_offload = {
 	.callbacks = {
 		.gso_send_check = gre_gso_send_check,
 		.gso_segment = gre_gso_segment,
+		.gro_receive = gre_gro_receive,
+		.gro_complete = gre_gro_complete,
 	},
 };
 
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 2658a27..771a395 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -197,7 +197,8 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	goto out_check_final;
 
 found:
-	flush = NAPI_GRO_CB(p)->flush;
+	/* Include the IP ID check below from the inner most IP hdr */
+	flush = NAPI_GRO_CB(p)->flush | NAPI_GRO_CB(p)->flush_id;
 	flush |= (__force int)(flags & TCP_FLAG_CWR);
 	flush |= (__force int)((flags ^ tcp_flag_word(th2)) &
 		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH));
@@ -230,7 +231,7 @@ out_check_final:
 		pp = head;
 
 out:
-	NAPI_GRO_CB(skb)->flush |= flush;
+	NAPI_GRO_CB(skb)->flush |= (flush != 0);
 
 	return pp;
 }
@@ -280,7 +281,7 @@ static struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *
 	if (NAPI_GRO_CB(skb)->flush)
 		goto skip_csum;
 
-	wsum = skb->csum;
+	wsum = NAPI_GRO_CB(skb)->csum;
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_NONE:
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 6fb4162..1e8683b 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -190,7 +190,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	unsigned int nlen;
 	unsigned int hlen;
 	unsigned int off;
-	int flush = 1;
+	u16 flush = 1;
 	int proto;
 	__wsum csum;
 
-- 
1.8.5.1
