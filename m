From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] reduce netfilte sk_buff enlargement
Date: Sat, 16 Jul 2005 21:40:58 +0000 (UTC)
Message-ID: <20050717220451.GB13434@rama.risq.ericsson.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MW5yreqqjyrRcusr"
Cc: Linux Netdev List <netdev@vger.kernel.org>, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
Date: Mon, 18 Jul 2005 00:04:51 +0200
To: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline
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


--MW5yreqqjyrRcusr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

As discussed at netconf'05, we're trying to save every bit in sk_buff.
The patch below makes sk_buff 8 bytes smaller.  I did some basic testing
on my notebook and it seems to work.

The only real in-tree user of nfcache was IPVS, who only needs a single
bit.  Unfortunately I couldn't find some other free bit in sk_buff to
stuff that bit into, so I introduced a separate field for them.  Maybe
the IPVS guys can resolve that to further save space.

Initially I wanted to shrink pkt_type to three bits (PACKET_HOST and
alike are only 6 values defined), but unfortunately the bluetooth code
overloads pkt_type :(

The conntrack-event-api (out-of-tree) uses nfcache, but Rusty just came
up with a way how to do it without any skb fields, so it's safe to
remove it.


- remove all never-implemented 'nfcache' code
- don't have ipvs code abuse 'nfcache' field. currently get's their own
  compile-conditional skb->ipvs_property field.  IPVS maintainers can
  decide to move this bit elswhere, but nfcache needs to die.
- remove skb->nfcache field to save 4 bytes
- move skb->nfctinfo into three unused bits to save further 4 bytes

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 11f0f1a381dd525aa9b48b64e8fb4dee22ef3520
tree c058108477e708ff81c63318168b6355356e9e6d
parent 1f78366f895151f38c15a2b22b9d4b988dd351e9
author laforge <laforge@netfilter.org> Sun, 17 Jul 2005 23:32:58 +0200
committer laforge <laforge@netfilter.org> Sun, 17 Jul 2005 23:32:58 +0200

 include/linux/netfilter.h              |    5 -----
 include/linux/netfilter_decnet.h       |   10 ----------
 include/linux/netfilter_ipv4.h         |   28 ----------------------------
 include/linux/netfilter_ipv6.h         |   30 ----------------------------=
--
 include/linux/skbuff.h                 |   10 +++++-----
 net/bridge/netfilter/ebt_mark.c        |    5 ++---
 net/core/skbuff.c                      |    2 --
 net/ipv4/ip_output.c                   |    1 -
 net/ipv4/ipvs/ip_vs_core.c             |    9 +++++----
 net/ipv4/ipvs/ip_vs_xmit.c             |    2 +-
 net/ipv4/netfilter/ip_conntrack_core.c |    7 +------
 net/ipv4/netfilter/ip_nat_core.c       |    1 -
 net/ipv4/netfilter/ip_nat_standalone.c |    2 --
 net/ipv4/netfilter/ip_queue.c          |    1 -
 net/ipv4/netfilter/ip_tables.c         |    1 -
 net/ipv4/netfilter/ipt_CLASSIFY.c      |    4 +---
 net/ipv4/netfilter/ipt_CONNMARK.c      |    4 +---
 net/ipv4/netfilter/ipt_DSCP.c          |    1 -
 net/ipv4/netfilter/ipt_ECN.c           |    2 --
 net/ipv4/netfilter/ipt_MARK.c          |   10 ++++------
 net/ipv4/netfilter/ipt_REJECT.c        |    1 -
 net/ipv4/netfilter/ipt_TCPMSS.c        |    1 -
 net/ipv4/netfilter/ipt_TOS.c           |    1 -
 net/ipv6/ip6_output.c                  |   16 ++--------------
 net/ipv6/netfilter/ip6_queue.c         |    1 -
 net/ipv6/netfilter/ip6_tables.c        |    1 -
 net/ipv6/netfilter/ip6t_MARK.c         |    5 ++---
 27 files changed, 24 insertions(+), 137 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -21,11 +21,6 @@
 #define NF_STOP 5
 #define NF_MAX_VERDICT NF_STOP
=20
-/* Generic cache responses from hook functions.
-   <=3D 0x2000 is used for protocol-flags. */
-#define NFC_UNKNOWN 0x4000
-#define NFC_ALTERED 0x8000
-
 #ifdef __KERNEL__
 #include <linux/config.h>
 #ifdef CONFIG_NETFILTER
diff --git a/include/linux/netfilter_decnet.h b/include/linux/netfilter_dec=
net.h
--- a/include/linux/netfilter_decnet.h
+++ b/include/linux/netfilter_decnet.h
@@ -9,16 +9,6 @@
=20
 #include <linux/netfilter.h>
=20
-/* IP Cache bits. */
-/* Src IP address. */
-#define NFC_DN_SRC		0x0001
-/* Dest IP address. */
-#define NFC_DN_DST		0x0002
-/* Input device. */
-#define NFC_DN_IF_IN		0x0004
-/* Output device. */
-#define NFC_DN_IF_OUT		0x0008
-
 /* DECnet Hooks */
 /* After promisc drops, checksum checks. */
 #define NF_DN_PRE_ROUTING	0
diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -8,34 +8,6 @@
 #include <linux/config.h>
 #include <linux/netfilter.h>
=20
-/* IP Cache bits. */
-/* Src IP address. */
-#define NFC_IP_SRC		0x0001
-/* Dest IP address. */
-#define NFC_IP_DST		0x0002
-/* Input device. */
-#define NFC_IP_IF_IN		0x0004
-/* Output device. */
-#define NFC_IP_IF_OUT		0x0008
-/* TOS. */
-#define NFC_IP_TOS		0x0010
-/* Protocol. */
-#define NFC_IP_PROTO		0x0020
-/* IP options. */
-#define NFC_IP_OPTIONS		0x0040
-/* Frag & flags. */
-#define NFC_IP_FRAG		0x0080
-
-/* Per-protocol information: only matters if proto match. */
-/* TCP flags. */
-#define NFC_IP_TCPFLAGS		0x0100
-/* Source port. */
-#define NFC_IP_SRC_PT		0x0200
-/* Dest port. */
-#define NFC_IP_DST_PT		0x0400
-/* Something else about the proto */
-#define NFC_IP_PROTO_UNKNOWN	0x2000
-
 /* IP Hooks */
 /* After promisc drops, checksum checks. */
 #define NF_IP_PRE_ROUTING	0
diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -10,36 +10,6 @@
=20
 #include <linux/netfilter.h>
=20
-/* IP Cache bits. */
-/* Src IP address. */
-#define NFC_IP6_SRC              0x0001
-/* Dest IP address. */
-#define NFC_IP6_DST              0x0002
-/* Input device. */
-#define NFC_IP6_IF_IN            0x0004
-/* Output device. */
-#define NFC_IP6_IF_OUT           0x0008
-/* TOS. */
-#define NFC_IP6_TOS              0x0010
-/* Protocol. */
-#define NFC_IP6_PROTO            0x0020
-/* IP options. */
-#define NFC_IP6_OPTIONS          0x0040
-/* Frag & flags. */
-#define NFC_IP6_FRAG             0x0080
-
-
-/* Per-protocol information: only matters if proto match. */
-/* TCP flags. */
-#define NFC_IP6_TCPFLAGS         0x0100
-/* Source port. */
-#define NFC_IP6_SRC_PT           0x0200
-/* Dest port. */
-#define NFC_IP6_DST_PT           0x0400
-/* Something else about the proto */
-#define NFC_IP6_PROTO_UNKNOWN    0x2000
-
-
 /* IP6 Hooks */
 /* After promisc drops, checksum checks. */
 #define NF_IP6_PRE_ROUTING	0
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -190,7 +190,6 @@ struct skb_shared_info {
  *	@end: End pointer
  *	@destructor: Destruct function
  *	@nfmark: Can be used for communication between hooks
- *	@nfcache: Cache info
  *	@nfct: Associated connection, if any
  *	@nfctinfo: Relationship of this skb to the connection
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
@@ -252,17 +251,18 @@ struct sk_buff {
 	__u8			local_df:1,
 				cloned:1,
 				ip_summed:2,
-				nohdr:1;
-				/* 3 bits spare */
+				nohdr:1,
+				nfctinfo:3;
 	__u8			pkt_type;
 	__u16			protocol;
=20
 	void			(*destructor)(struct sk_buff *skb);
 #ifdef CONFIG_NETFILTER
 	__u32			nfmark;
-	__u32			nfcache;
-	__u32			nfctinfo;
 	struct nf_conntrack	*nfct;
+#if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
+	__u8			ipvs_property:1;
+#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	struct nf_bridge_info	*nf_bridge;
 #endif
diff --git a/net/bridge/netfilter/ebt_mark.c b/net/bridge/netfilter/ebt_mar=
k.c
--- a/net/bridge/netfilter/ebt_mark.c
+++ b/net/bridge/netfilter/ebt_mark.c
@@ -23,10 +23,9 @@ static int ebt_target_mark(struct sk_buf
 {
 	struct ebt_mark_t_info *info =3D (struct ebt_mark_t_info *)data;
=20
-	if ((*pskb)->nfmark !=3D info->mark) {
+	if ((*pskb)->nfmark !=3D info->mark)
 		(*pskb)->nfmark =3D info->mark;
-		(*pskb)->nfcache |=3D NFC_ALTERED;
-	}
+
 	return info->target;
 }
=20
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -361,7 +361,6 @@ struct sk_buff *skb_clone(struct sk_buff
 	n->destructor =3D NULL;
 #ifdef CONFIG_NETFILTER
 	C(nfmark);
-	C(nfcache);
 	C(nfct);
 	nf_conntrack_get(skb->nfct);
 	C(nfctinfo);
@@ -424,7 +423,6 @@ static void copy_skb_header(struct sk_bu
 	new->destructor =3D NULL;
 #ifdef CONFIG_NETFILTER
 	new->nfmark	=3D old->nfmark;
-	new->nfcache	=3D old->nfcache;
 	new->nfct	=3D old->nfct;
 	nf_conntrack_get(old->nfct);
 	new->nfctinfo	=3D old->nfctinfo;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -392,7 +392,6 @@ static void ip_copy_metadata(struct sk_b
 #endif
 #ifdef CONFIG_NETFILTER
 	to->nfmark =3D from->nfmark;
-	to->nfcache =3D from->nfcache;
 	/* Connection association is same as pre-frag packet */
 	nf_conntrack_put(to->nfct);
 	to->nfct =3D from->nfct;
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -22,6 +22,7 @@
  *
  * Changes:
  *	Paul `Rusty' Russell		properly handle non-linear skbs
+ *	Harald Welte			don't use nfcache
  *
  */
=20
@@ -529,7 +530,7 @@ static unsigned int ip_vs_post_routing(u
 				       const struct net_device *out,
 				       int (*okfn)(struct sk_buff *))
 {
-	if (!((*pskb)->nfcache & NFC_IPVS_PROPERTY))
+	if (!((*pskb)->ipvs_property))
 		return NF_ACCEPT;
=20
 	/* The packet was sent from IPVS, exit this chain */
@@ -701,7 +702,7 @@ static int ip_vs_out_icmp(struct sk_buff
 	/* do the statistics and put it back */
 	ip_vs_out_stats(cp, skb);
=20
-	skb->nfcache |=3D NFC_IPVS_PROPERTY;
+	skb->ipvs_property =3D 1;
 	verdict =3D NF_ACCEPT;
=20
   out:
@@ -739,7 +740,7 @@ ip_vs_out(unsigned int hooknum, struct s
=20
 	EnterFunction(11);
=20
-	if (skb->nfcache & NFC_IPVS_PROPERTY)
+	if (skb->ipvs_property)
 		return NF_ACCEPT;
=20
 	iph =3D skb->nh.iph;
@@ -821,7 +822,7 @@ ip_vs_out(unsigned int hooknum, struct s
 	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
 	ip_vs_conn_put(cp);
=20
-	skb->nfcache |=3D NFC_IPVS_PROPERTY;
+	skb->ipvs_property =3D 1;
=20
 	LeaveFunction(11);
 	return NF_ACCEPT;
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -127,7 +127,7 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
=20
 #define IP_VS_XMIT(skb, rt)				\
 do {							\
-	(skb)->nfcache |=3D NFC_IPVS_PROPERTY;		\
+	(skb)->ipvs_property =3D 1;			\
 	(skb)->ip_summed =3D CHECKSUM_NONE;		\
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, (skb), NULL,	\
 		(rt)->u.dst.dev, dst_output);		\
diff --git a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip=
_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c
+++ b/net/ipv4/netfilter/ip_conntrack_core.c
@@ -627,9 +627,6 @@ unsigned int ip_conntrack_in(unsigned in
 		return NF_DROP;
 	}
=20
-	/* FIXME: Do this right please. --RR */
-	(*pskb)->nfcache |=3D NFC_UNKNOWN;
-
 /* Doesn't cover locally-generated broadcast, so not worth it. */
 #if 0
 	/* Ignore broadcast: no `connection'. */
@@ -942,10 +939,8 @@ ip_ct_gather_frags(struct sk_buff *skb,=20
 	skb =3D ip_defrag(skb, user);
 	local_bh_enable();
=20
-	if (skb) {
+	if (skb)
 		ip_send_check(skb->nh.iph);
-		skb->nfcache |=3D NFC_ALTERED;
-	}
 	return skb;
 }
=20
diff --git a/net/ipv4/netfilter/ip_nat_core.c b/net/ipv4/netfilter/ip_nat_c=
ore.c
--- a/net/ipv4/netfilter/ip_nat_core.c
+++ b/net/ipv4/netfilter/ip_nat_core.c
@@ -321,7 +321,6 @@ manip_pkt(u_int16_t proto,
 {
 	struct iphdr *iph;
=20
-	(*pskb)->nfcache |=3D NFC_ALTERED;
 	if (!skb_ip_make_writable(pskb, iphdroff + sizeof(*iph)))
 		return 0;
=20
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip=
_nat_standalone.c
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -73,8 +73,6 @@ ip_nat_fn(unsigned int hooknum,
 	IP_NF_ASSERT(!((*pskb)->nh.iph->frag_off
 		       & htons(IP_MF|IP_OFFSET)));
=20
-	(*pskb)->nfcache |=3D NFC_UNKNOWN;
-
 	/* If we had a hardware checksum before, it's now invalid */
 	if ((*pskb)->ip_summed =3D=3D CHECKSUM_HW)
 		if (skb_checksum_help(*pskb, (out =3D=3D NULL)))
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -385,7 +385,6 @@ ipq_mangle_ipv4(ipq_verdict_msg_t *v, st
 	if (!skb_ip_make_writable(&e->skb, v->data_len))
 		return -ENOMEM;
 	memcpy(e->skb->data, v->payload, v->data_len);
-	e->skb->nfcache |=3D NFC_ALTERED;
=20
 	/*
 	 * Extra routing may needed on local out, as the QUEUE target never
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -312,7 +312,6 @@ ipt_do_table(struct sk_buff **pskb,
 	do {
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
-		(*pskb)->nfcache |=3D e->nfcache;
 		if (ip_packet_match(ip, indev, outdev, &e->ip, offset)) {
 			struct ipt_entry_target *t;
=20
diff --git a/net/ipv4/netfilter/ipt_CLASSIFY.c b/net/ipv4/netfilter/ipt_CLA=
SSIFY.c
--- a/net/ipv4/netfilter/ipt_CLASSIFY.c
+++ b/net/ipv4/netfilter/ipt_CLASSIFY.c
@@ -32,10 +32,8 @@ target(struct sk_buff **pskb,
 {
 	const struct ipt_classify_target_info *clinfo =3D targinfo;
=20
-	if((*pskb)->priority !=3D clinfo->priority) {
+	if((*pskb)->priority !=3D clinfo->priority)=20
 		(*pskb)->priority =3D clinfo->priority;
-		(*pskb)->nfcache |=3D NFC_ALTERED;
-	}
=20
 	return IPT_CONTINUE;
 }
diff --git a/net/ipv4/netfilter/ipt_CONNMARK.c b/net/ipv4/netfilter/ipt_CON=
NMARK.c
--- a/net/ipv4/netfilter/ipt_CONNMARK.c
+++ b/net/ipv4/netfilter/ipt_CONNMARK.c
@@ -61,10 +61,8 @@ target(struct sk_buff **pskb,
 	    case IPT_CONNMARK_RESTORE:
 		nfmark =3D (*pskb)->nfmark;
 		diff =3D (ct->mark ^ nfmark) & markinfo->mask;
-		if (diff !=3D 0) {
+		if (diff !=3D 0)
 		    (*pskb)->nfmark =3D nfmark ^ diff;
-		    (*pskb)->nfcache |=3D NFC_ALTERED;
-		}
 		break;
 	    }
 	}
diff --git a/net/ipv4/netfilter/ipt_DSCP.c b/net/ipv4/netfilter/ipt_DSCP.c
--- a/net/ipv4/netfilter/ipt_DSCP.c
+++ b/net/ipv4/netfilter/ipt_DSCP.c
@@ -51,7 +51,6 @@ target(struct sk_buff **pskb,
 						 sizeof(diffs),
 						 (*pskb)->nh.iph->check
 						 ^ 0xFFFF));
-		(*pskb)->nfcache |=3D NFC_ALTERED;
 	}
 	return IPT_CONTINUE;
 }
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -43,7 +43,6 @@ set_ect_ip(struct sk_buff **pskb, const=20
 						 sizeof(diffs),
 						 (*pskb)->nh.iph->check
 						 ^0xFFFF));
-		(*pskb)->nfcache |=3D NFC_ALTERED;
 	}=20
 	return 1;
 }
@@ -86,7 +85,6 @@ set_ect_tcp(struct sk_buff **pskb, const
 	else
 		if (skb_checksum_help(*pskb, inward))
 			return 0;
-	(*pskb)->nfcache |=3D NFC_ALTERED;
 	return 1;
 }
=20
diff --git a/net/ipv4/netfilter/ipt_MARK.c b/net/ipv4/netfilter/ipt_MARK.c
--- a/net/ipv4/netfilter/ipt_MARK.c
+++ b/net/ipv4/netfilter/ipt_MARK.c
@@ -29,10 +29,9 @@ target_v0(struct sk_buff **pskb,
 {
 	const struct ipt_mark_target_info *markinfo =3D targinfo;
=20
-	if((*pskb)->nfmark !=3D markinfo->mark) {
+	if((*pskb)->nfmark !=3D markinfo->mark)
 		(*pskb)->nfmark =3D markinfo->mark;
-		(*pskb)->nfcache |=3D NFC_ALTERED;
-	}
+
 	return IPT_CONTINUE;
 }
=20
@@ -61,10 +60,9 @@ target_v1(struct sk_buff **pskb,
 		break;
 	}
=20
-	if((*pskb)->nfmark !=3D mark) {
+	if((*pskb)->nfmark !=3D mark)
 		(*pskb)->nfmark =3D mark;
-		(*pskb)->nfcache |=3D NFC_ALTERED;
-	}
+
 	return IPT_CONTINUE;
 }
=20
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJEC=
T.c
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -156,7 +156,6 @@ static void send_reset(struct sk_buff *o
=20
 	/* This packet will not be the same as the other: clear nf fields */
 	nf_reset(nskb);
-	nskb->nfcache =3D 0;
 	nskb->nfmark =3D 0;
 #ifdef CONFIG_BRIDGE_NETFILTER
 	nf_bridge_put(nskb->nf_bridge);
diff --git a/net/ipv4/netfilter/ipt_TCPMSS.c b/net/ipv4/netfilter/ipt_TCPMS=
S.c
--- a/net/ipv4/netfilter/ipt_TCPMSS.c
+++ b/net/ipv4/netfilter/ipt_TCPMSS.c
@@ -189,7 +189,6 @@ ipt_tcpmss_target(struct sk_buff **pskb,
 	/* We never hw checksum SYN packets.  */
 	BUG_ON((*pskb)->ip_summed =3D=3D CHECKSUM_HW);
=20
-	(*pskb)->nfcache |=3D NFC_UNKNOWN | NFC_ALTERED;
 	return IPT_CONTINUE;
 }
=20
diff --git a/net/ipv4/netfilter/ipt_TOS.c b/net/ipv4/netfilter/ipt_TOS.c
--- a/net/ipv4/netfilter/ipt_TOS.c
+++ b/net/ipv4/netfilter/ipt_TOS.c
@@ -46,7 +46,6 @@ target(struct sk_buff **pskb,
 						 sizeof(diffs),
 						 (*pskb)->nh.iph->check
 						 ^0xFFFF));
-		(*pskb)->nfcache |=3D NFC_ALTERED;
 	}
 	return IPT_CONTINUE;
 }
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -185,19 +185,6 @@ int ip6_route_me_harder(struct sk_buff *
 }
 #endif
=20
-static inline int ip6_maybe_reroute(struct sk_buff *skb)
-{
-#ifdef CONFIG_NETFILTER
-	if (skb->nfcache & NFC_ALTERED){
-		if (ip6_route_me_harder(skb) !=3D 0){
-			kfree_skb(skb);
-			return -EINVAL;
-		}
-	}
-#endif /* CONFIG_NETFILTER */
-	return dst_output(skb);
-}
-
 /*
  *	xmit an sk_buff (used by TCP)
  */
@@ -266,7 +253,8 @@ int ip6_xmit(struct sock *sk, struct sk_
 	mtu =3D dst_mtu(dst);
 	if ((skb->len <=3D mtu) || ipfragok) {
 		IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
-		return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_mayb=
e_reroute);
+		return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev,
+				dst_output);
 	}
=20
 	if (net_ratelimit())
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -379,7 +379,6 @@ ipq_mangle_ipv6(ipq_verdict_msg_t *v, st
 	if (!skb_ip_make_writable(&e->skb, v->data_len))
 		return -ENOMEM;
 	memcpy(e->skb->data, v->payload, v->data_len);
-	e->skb->nfcache |=3D NFC_ALTERED;
=20
 	/*
 	 * Extra routing may needed on local out, as the QUEUE target never
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_table=
s.c
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -401,7 +401,6 @@ ip6t_do_table(struct sk_buff **pskb,
 	do {
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
-		(*pskb)->nfcache |=3D e->nfcache;
 		if (ip6_packet_match(*pskb, indev, outdev, &e->ipv6,
 			&protoff, &offset)) {
 			struct ip6t_entry_target *t;
diff --git a/net/ipv6/netfilter/ip6t_MARK.c b/net/ipv6/netfilter/ip6t_MARK.c
--- a/net/ipv6/netfilter/ip6t_MARK.c
+++ b/net/ipv6/netfilter/ip6t_MARK.c
@@ -28,10 +28,9 @@ target(struct sk_buff **pskb,
 {
 	const struct ip6t_mark_target_info *markinfo =3D targinfo;
=20
-	if((*pskb)->nfmark !=3D markinfo->mark) {
+	if((*pskb)->nfmark !=3D markinfo->mark)
 		(*pskb)->nfmark =3D markinfo->mark;
-		(*pskb)->nfcache |=3D NFC_ALTERED;
-	}
+
 	return IP6T_CONTINUE;
 }
=20
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--MW5yreqqjyrRcusr
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC2tYCXaXGVTD0i/8RArDKAJ9mLGzPccISg04MikRjLzkZ+EWligCeLnVC
spEdF5Ae/sLzxrvWz751wZQ=
=SM0Z
-----END PGP SIGNATURE-----

--MW5yreqqjyrRcusr--
