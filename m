From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 3/3] ipv4: Remove inet_lro library
Date: Mon, 15 Feb 2016 21:25:57 +0000
Message-ID: <20160215212557.GE5231@decadent.org.uk>
References: <20160215212351.GB5231@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="so9zsI5B81VjUb/o"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36461 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751924AbcBOV0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 16:26:00 -0500
Received: from ben by shadbolt.decadent.org.uk with local (Exim 4.84)
	(envelope-from <ben@decadent.org.uk>)
	id 1aVQeb-0001iJ-S2
	for netdev@vger.kernel.org; Mon, 15 Feb 2016 21:25:58 +0000
Content-Disposition: inline
In-Reply-To: <20160215212351.GB5231@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--so9zsI5B81VjUb/o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

There are no longer any in-tree drivers that use it.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/inet_lro.h | 142 ------------------
 net/ipv4/Kconfig         |   8 -
 net/ipv4/Makefile        |   1 -
 net/ipv4/inet_lro.c      | 374 -------------------------------------------=
----
 4 files changed, 525 deletions(-)
 delete mode 100644 include/linux/inet_lro.h
 delete mode 100644 net/ipv4/inet_lro.c

diff --git a/include/linux/inet_lro.h b/include/linux/inet_lro.h
deleted file mode 100644
index 9a715cfa1fe3..000000000000
--- a/include/linux/inet_lro.h
+++ /dev/null
@@ -1,142 +0,0 @@
-/*
- *  linux/include/linux/inet_lro.h
- *
- *  Large Receive Offload (ipv4 / tcp)
- *
- *  (C) Copyright IBM Corp. 2007
- *
- *  Authors:
- *       Jan-Bernd Themann <themann@de.ibm.com>
- *       Christoph Raisch <raisch@de.ibm.com>
- *
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2, or (at your option)
- * any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- */
-
-#ifndef __INET_LRO_H_
-#define __INET_LRO_H_
-
-#include <net/ip.h>
-#include <net/tcp.h>
-
-/*
- * LRO statistics
- */
-
-struct net_lro_stats {
-	unsigned long aggregated;
-	unsigned long flushed;
-	unsigned long no_desc;
-};
-
-/*
- * LRO descriptor for a tcp session
- */
-struct net_lro_desc {
-	struct sk_buff *parent;
-	struct sk_buff *last_skb;
-	struct skb_frag_struct *next_frag;
-	struct iphdr *iph;
-	struct tcphdr *tcph;
-	__wsum  data_csum;
-	__be32 tcp_rcv_tsecr;
-	__be32 tcp_rcv_tsval;
-	__be32 tcp_ack;
-	u32 tcp_next_seq;
-	u32 skb_tot_frags_len;
-	u16 ip_tot_len;
-	u16 tcp_saw_tstamp; 		/* timestamps enabled */
-	__be16 tcp_window;
-	int pkt_aggr_cnt;		/* counts aggregated packets */
-	int vlan_packet;
-	int mss;
-	int active;
-};
-
-/*
- * Large Receive Offload (LRO) Manager
- *
- * Fields must be set by driver
- */
-
-struct net_lro_mgr {
-	struct net_device *dev;
-	struct net_lro_stats stats;
-
-	/* LRO features */
-	unsigned long features;
-#define LRO_F_NAPI            1  /* Pass packets to stack via NAPI */
-#define LRO_F_EXTRACT_VLAN_ID 2  /* Set flag if VLAN IDs are extracted
-				    from received packets and eth protocol
-				    is still ETH_P_8021Q */
-
-	/*
-	 * Set for generated SKBs that are not added to
-	 * the frag list in fragmented mode
-	 */
-	u32 ip_summed;
-	u32 ip_summed_aggr; /* Set in aggregated SKBs: CHECKSUM_UNNECESSARY
-			     * or CHECKSUM_NONE */
-
-	int max_desc; /* Max number of LRO descriptors  */
-	int max_aggr; /* Max number of LRO packets to be aggregated */
-
-	int frag_align_pad; /* Padding required to properly align layer 3
-			     * headers in generated skb when using frags */
-
-	struct net_lro_desc *lro_arr; /* Array of LRO descriptors */
-
-	/*
-	 * Optimized driver functions
-	 *
-	 * get_skb_header: returns tcp and ip header for packet in SKB
-	 */
-	int (*get_skb_header)(struct sk_buff *skb, void **ip_hdr,
-			      void **tcpudp_hdr, u64 *hdr_flags, void *priv);
-
-	/* hdr_flags: */
-#define LRO_IPV4 1 /* ip_hdr is IPv4 header */
-#define LRO_TCP  2 /* tcpudp_hdr is TCP header */
-
-	/*
-	 * get_frag_header: returns mac, tcp and ip header for packet in SKB
-	 *
-	 * @hdr_flags: Indicate what kind of LRO has to be done
-	 *             (IPv4/IPv6/TCP/UDP)
-	 */
-	int (*get_frag_header)(struct skb_frag_struct *frag, void **mac_hdr,
-			       void **ip_hdr, void **tcpudp_hdr, u64 *hdr_flags,
-			       void *priv);
-};
-
-/*
- * Processes a SKB
- *
- * @lro_mgr: LRO manager to use
- * @skb: SKB to aggregate
- * @priv: Private data that may be used by driver functions
- *        (for example get_tcp_ip_hdr)
- */
-
-void lro_receive_skb(struct net_lro_mgr *lro_mgr,
-		     struct sk_buff *skb,
-		     void *priv);
-/*
- * Forward all aggregated SKBs held by lro_mgr to network stack
- */
-
-void lro_flush_all(struct net_lro_mgr *lro_mgr);
-
-#endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 775824720b6b..6c4b79c98fda 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -405,14 +405,6 @@ config INET_XFRM_MODE_BEET
=20
 	  If unsure, say Y.
=20
-config INET_LRO
-	tristate "Large Receive Offload (ipv4/tcp)"
-	default y
-	---help---
-	  Support for Large Receive Offload (ipv4/tcp).
-
-	  If unsure, say Y.
-
 config INET_DIAG
 	tristate "INET: socket monitoring interface"
 	default y
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 62c049b647e9..bfa133691cde 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -32,7 +32,6 @@ obj-$(CONFIG_INET_ESP) +=3D esp4.o
 obj-$(CONFIG_INET_IPCOMP) +=3D ipcomp.o
 obj-$(CONFIG_INET_XFRM_TUNNEL) +=3D xfrm4_tunnel.o
 obj-$(CONFIG_INET_XFRM_MODE_BEET) +=3D xfrm4_mode_beet.o
-obj-$(CONFIG_INET_LRO) +=3D inet_lro.o
 obj-$(CONFIG_INET_TUNNEL) +=3D tunnel4.o
 obj-$(CONFIG_INET_XFRM_MODE_TRANSPORT) +=3D xfrm4_mode_transport.o
 obj-$(CONFIG_INET_XFRM_MODE_TUNNEL) +=3D xfrm4_mode_tunnel.o
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
deleted file mode 100644
index f17ea49b28fb..000000000000
--- a/net/ipv4/inet_lro.c
+++ /dev/null
@@ -1,374 +0,0 @@
-/*
- *  linux/net/ipv4/inet_lro.c
- *
- *  Large Receive Offload (ipv4 / tcp)
- *
- *  (C) Copyright IBM Corp. 2007
- *
- *  Authors:
- *       Jan-Bernd Themann <themann@de.ibm.com>
- *       Christoph Raisch <raisch@de.ibm.com>
- *
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2, or (at your option)
- * any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- */
-
-
-#include <linux/module.h>
-#include <linux/if_vlan.h>
-#include <linux/inet_lro.h>
-#include <net/checksum.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Jan-Bernd Themann <themann@de.ibm.com>");
-MODULE_DESCRIPTION("Large Receive Offload (ipv4 / tcp)");
-
-#define TCP_HDR_LEN(tcph) (tcph->doff << 2)
-#define IP_HDR_LEN(iph) (iph->ihl << 2)
-#define TCP_PAYLOAD_LENGTH(iph, tcph) \
-	(ntohs(iph->tot_len) - IP_HDR_LEN(iph) - TCP_HDR_LEN(tcph))
-
-#define IPH_LEN_WO_OPTIONS 5
-#define TCPH_LEN_WO_OPTIONS 5
-#define TCPH_LEN_W_TIMESTAMP 8
-
-#define LRO_MAX_PG_HLEN 64
-
-#define LRO_INC_STATS(lro_mgr, attr) { lro_mgr->stats.attr++; }
-
-/*
- * Basic tcp checks whether packet is suitable for LRO
- */
-
-static int lro_tcp_ip_check(const struct iphdr *iph, const struct tcphdr *=
tcph,
-			    int len, const struct net_lro_desc *lro_desc)
-{
-        /* check ip header: don't aggregate padded frames */
-	if (ntohs(iph->tot_len) !=3D len)
-		return -1;
-
-	if (TCP_PAYLOAD_LENGTH(iph, tcph) =3D=3D 0)
-		return -1;
-
-	if (iph->ihl !=3D IPH_LEN_WO_OPTIONS)
-		return -1;
-
-	if (tcph->cwr || tcph->ece || tcph->urg || !tcph->ack ||
-	    tcph->rst || tcph->syn || tcph->fin)
-		return -1;
-
-	if (INET_ECN_is_ce(ipv4_get_dsfield(iph)))
-		return -1;
-
-	if (tcph->doff !=3D TCPH_LEN_WO_OPTIONS &&
-	    tcph->doff !=3D TCPH_LEN_W_TIMESTAMP)
-		return -1;
-
-	/* check tcp options (only timestamp allowed) */
-	if (tcph->doff =3D=3D TCPH_LEN_W_TIMESTAMP) {
-		__be32 *topt =3D (__be32 *)(tcph + 1);
-
-		if (*topt !=3D htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16)
-				   | (TCPOPT_TIMESTAMP << 8)
-				   | TCPOLEN_TIMESTAMP))
-			return -1;
-
-		/* timestamp should be in right order */
-		topt++;
-		if (lro_desc && after(ntohl(lro_desc->tcp_rcv_tsval),
-				      ntohl(*topt)))
-			return -1;
-
-		/* timestamp reply should not be zero */
-		topt++;
-		if (*topt =3D=3D 0)
-			return -1;
-	}
-
-	return 0;
-}
-
-static void lro_update_tcp_ip_header(struct net_lro_desc *lro_desc)
-{
-	struct iphdr *iph =3D lro_desc->iph;
-	struct tcphdr *tcph =3D lro_desc->tcph;
-	__be32 *p;
-	__wsum tcp_hdr_csum;
-
-	tcph->ack_seq =3D lro_desc->tcp_ack;
-	tcph->window =3D lro_desc->tcp_window;
-
-	if (lro_desc->tcp_saw_tstamp) {
-		p =3D (__be32 *)(tcph + 1);
-		*(p+2) =3D lro_desc->tcp_rcv_tsecr;
-	}
-
-	csum_replace2(&iph->check, iph->tot_len, htons(lro_desc->ip_tot_len));
-	iph->tot_len =3D htons(lro_desc->ip_tot_len);
-
-	tcph->check =3D 0;
-	tcp_hdr_csum =3D csum_partial(tcph, TCP_HDR_LEN(tcph), 0);
-	lro_desc->data_csum =3D csum_add(lro_desc->data_csum, tcp_hdr_csum);
-	tcph->check =3D csum_tcpudp_magic(iph->saddr, iph->daddr,
-					lro_desc->ip_tot_len -
-					IP_HDR_LEN(iph), IPPROTO_TCP,
-					lro_desc->data_csum);
-}
-
-static __wsum lro_tcp_data_csum(struct iphdr *iph, struct tcphdr *tcph, in=
t len)
-{
-	__wsum tcp_csum;
-	__wsum tcp_hdr_csum;
-	__wsum tcp_ps_hdr_csum;
-
-	tcp_csum =3D ~csum_unfold(tcph->check);
-	tcp_hdr_csum =3D csum_partial(tcph, TCP_HDR_LEN(tcph), tcp_csum);
-
-	tcp_ps_hdr_csum =3D csum_tcpudp_nofold(iph->saddr, iph->daddr,
-					     len + TCP_HDR_LEN(tcph),
-					     IPPROTO_TCP, 0);
-
-	return csum_sub(csum_sub(tcp_csum, tcp_hdr_csum),
-			tcp_ps_hdr_csum);
-}
-
-static void lro_init_desc(struct net_lro_desc *lro_desc, struct sk_buff *s=
kb,
-			  struct iphdr *iph, struct tcphdr *tcph)
-{
-	int nr_frags;
-	__be32 *ptr;
-	u32 tcp_data_len =3D TCP_PAYLOAD_LENGTH(iph, tcph);
-
-	nr_frags =3D skb_shinfo(skb)->nr_frags;
-	lro_desc->parent =3D skb;
-	lro_desc->next_frag =3D &(skb_shinfo(skb)->frags[nr_frags]);
-	lro_desc->iph =3D iph;
-	lro_desc->tcph =3D tcph;
-	lro_desc->tcp_next_seq =3D ntohl(tcph->seq) + tcp_data_len;
-	lro_desc->tcp_ack =3D tcph->ack_seq;
-	lro_desc->tcp_window =3D tcph->window;
-
-	lro_desc->pkt_aggr_cnt =3D 1;
-	lro_desc->ip_tot_len =3D ntohs(iph->tot_len);
-
-	if (tcph->doff =3D=3D 8) {
-		ptr =3D (__be32 *)(tcph+1);
-		lro_desc->tcp_saw_tstamp =3D 1;
-		lro_desc->tcp_rcv_tsval =3D *(ptr+1);
-		lro_desc->tcp_rcv_tsecr =3D *(ptr+2);
-	}
-
-	lro_desc->mss =3D tcp_data_len;
-	lro_desc->active =3D 1;
-
-	lro_desc->data_csum =3D lro_tcp_data_csum(iph, tcph,
-						tcp_data_len);
-}
-
-static inline void lro_clear_desc(struct net_lro_desc *lro_desc)
-{
-	memset(lro_desc, 0, sizeof(struct net_lro_desc));
-}
-
-static void lro_add_common(struct net_lro_desc *lro_desc, struct iphdr *ip=
h,
-			   struct tcphdr *tcph, int tcp_data_len)
-{
-	struct sk_buff *parent =3D lro_desc->parent;
-	__be32 *topt;
-
-	lro_desc->pkt_aggr_cnt++;
-	lro_desc->ip_tot_len +=3D tcp_data_len;
-	lro_desc->tcp_next_seq +=3D tcp_data_len;
-	lro_desc->tcp_window =3D tcph->window;
-	lro_desc->tcp_ack =3D tcph->ack_seq;
-
-	/* don't update tcp_rcv_tsval, would not work with PAWS */
-	if (lro_desc->tcp_saw_tstamp) {
-		topt =3D (__be32 *) (tcph + 1);
-		lro_desc->tcp_rcv_tsecr =3D *(topt + 2);
-	}
-
-	lro_desc->data_csum =3D csum_block_add(lro_desc->data_csum,
-					     lro_tcp_data_csum(iph, tcph,
-							       tcp_data_len),
-					     parent->len);
-
-	parent->len +=3D tcp_data_len;
-	parent->data_len +=3D tcp_data_len;
-	if (tcp_data_len > lro_desc->mss)
-		lro_desc->mss =3D tcp_data_len;
-}
-
-static void lro_add_packet(struct net_lro_desc *lro_desc, struct sk_buff *=
skb,
-			   struct iphdr *iph, struct tcphdr *tcph)
-{
-	struct sk_buff *parent =3D lro_desc->parent;
-	int tcp_data_len =3D TCP_PAYLOAD_LENGTH(iph, tcph);
-
-	lro_add_common(lro_desc, iph, tcph, tcp_data_len);
-
-	skb_pull(skb, (skb->len - tcp_data_len));
-	parent->truesize +=3D skb->truesize;
-
-	if (lro_desc->last_skb)
-		lro_desc->last_skb->next =3D skb;
-	else
-		skb_shinfo(parent)->frag_list =3D skb;
-
-	lro_desc->last_skb =3D skb;
-}
-
-
-static int lro_check_tcp_conn(struct net_lro_desc *lro_desc,
-			      struct iphdr *iph,
-			      struct tcphdr *tcph)
-{
-	if ((lro_desc->iph->saddr !=3D iph->saddr) ||
-	    (lro_desc->iph->daddr !=3D iph->daddr) ||
-	    (lro_desc->tcph->source !=3D tcph->source) ||
-	    (lro_desc->tcph->dest !=3D tcph->dest))
-		return -1;
-	return 0;
-}
-
-static struct net_lro_desc *lro_get_desc(struct net_lro_mgr *lro_mgr,
-					 struct net_lro_desc *lro_arr,
-					 struct iphdr *iph,
-					 struct tcphdr *tcph)
-{
-	struct net_lro_desc *lro_desc =3D NULL;
-	struct net_lro_desc *tmp;
-	int max_desc =3D lro_mgr->max_desc;
-	int i;
-
-	for (i =3D 0; i < max_desc; i++) {
-		tmp =3D &lro_arr[i];
-		if (tmp->active)
-			if (!lro_check_tcp_conn(tmp, iph, tcph)) {
-				lro_desc =3D tmp;
-				goto out;
-			}
-	}
-
-	for (i =3D 0; i < max_desc; i++) {
-		if (!lro_arr[i].active) {
-			lro_desc =3D &lro_arr[i];
-			goto out;
-		}
-	}
-
-	LRO_INC_STATS(lro_mgr, no_desc);
-out:
-	return lro_desc;
-}
-
-static void lro_flush(struct net_lro_mgr *lro_mgr,
-		      struct net_lro_desc *lro_desc)
-{
-	if (lro_desc->pkt_aggr_cnt > 1)
-		lro_update_tcp_ip_header(lro_desc);
-
-	skb_shinfo(lro_desc->parent)->gso_size =3D lro_desc->mss;
-
-	if (lro_mgr->features & LRO_F_NAPI)
-		netif_receive_skb(lro_desc->parent);
-	else
-		netif_rx(lro_desc->parent);
-
-	LRO_INC_STATS(lro_mgr, flushed);
-	lro_clear_desc(lro_desc);
-}
-
-static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
-			  void *priv)
-{
-	struct net_lro_desc *lro_desc;
-	struct iphdr *iph;
-	struct tcphdr *tcph;
-	u64 flags;
-	int vlan_hdr_len =3D 0;
-
-	if (!lro_mgr->get_skb_header ||
-	    lro_mgr->get_skb_header(skb, (void *)&iph, (void *)&tcph,
-				    &flags, priv))
-		goto out;
-
-	if (!(flags & LRO_IPV4) || !(flags & LRO_TCP))
-		goto out;
-
-	lro_desc =3D lro_get_desc(lro_mgr, lro_mgr->lro_arr, iph, tcph);
-	if (!lro_desc)
-		goto out;
-
-	if ((skb->protocol =3D=3D htons(ETH_P_8021Q)) &&
-	    !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
-		vlan_hdr_len =3D VLAN_HLEN;
-
-	if (!lro_desc->active) { /* start new lro session */
-		if (lro_tcp_ip_check(iph, tcph, skb->len - vlan_hdr_len, NULL))
-			goto out;
-
-		skb->ip_summed =3D lro_mgr->ip_summed_aggr;
-		lro_init_desc(lro_desc, skb, iph, tcph);
-		LRO_INC_STATS(lro_mgr, aggregated);
-		return 0;
-	}
-
-	if (lro_desc->tcp_next_seq !=3D ntohl(tcph->seq))
-		goto out2;
-
-	if (lro_tcp_ip_check(iph, tcph, skb->len, lro_desc))
-		goto out2;
-
-	lro_add_packet(lro_desc, skb, iph, tcph);
-	LRO_INC_STATS(lro_mgr, aggregated);
-
-	if ((lro_desc->pkt_aggr_cnt >=3D lro_mgr->max_aggr) ||
-	    lro_desc->parent->len > (0xFFFF - lro_mgr->dev->mtu))
-		lro_flush(lro_mgr, lro_desc);
-
-	return 0;
-
-out2: /* send aggregated SKBs to stack */
-	lro_flush(lro_mgr, lro_desc);
-
-out:
-	return 1;
-}
-
-void lro_receive_skb(struct net_lro_mgr *lro_mgr,
-		     struct sk_buff *skb,
-		     void *priv)
-{
-	if (__lro_proc_skb(lro_mgr, skb, priv)) {
-		if (lro_mgr->features & LRO_F_NAPI)
-			netif_receive_skb(skb);
-		else
-			netif_rx(skb);
-	}
-}
-EXPORT_SYMBOL(lro_receive_skb);
-
-void lro_flush_all(struct net_lro_mgr *lro_mgr)
-{
-	int i;
-	struct net_lro_desc *lro_desc =3D lro_mgr->lro_arr;
-
-	for (i =3D 0; i < lro_mgr->max_desc; i++) {
-		if (lro_desc[i].active)
-			lro_flush(lro_mgr, &lro_desc[i]);
-	}
-}
-EXPORT_SYMBOL(lro_flush_all);

--so9zsI5B81VjUb/o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBVsJCZee/yOyVhhEJAQqXpQ/+PTs4ng4CIysBCDrjoHY+/NE2GS0R+cd5
2EwE2S8jLsXQ/ifAg9SZgmGxA4+Z/cWDdoMRIUR5+JUJGRce/6ak82iQE8gqwOHR
W0IYXSxN4WrJZObNIPX6u+Hbbo2OLjZiI5ht5T3e5QD5R4wjVPuDDXVQWJFp6Jhi
T+bfoV8qZjFSh7Sf/UlF5bHa1H/y/hjxaWrHE/Mv7b5FlK0nthzBn3dwchdFogJx
y7ezzK7HUDGGQCf6p+ul6meJmu+MwVwWwY+MY17gpSxA0SWX163Y3zC1Hbt5nn8X
a9HaAv4eyU1DSMBV8nKrIWoTjntdicZkmpgFBP2yn0dP1FrFKbKCAcUZkm1LY/g9
rtCprLcq6ixTYnbt75Fr92vtzCUQAK3JS4PVr8H25k1mCK9pM7amUUKDkwBpkx6J
+X0L/RvyRVbL/PGxBHA3V7oR3C8usLb+SDp324an0idnPW0E0Y9PxT39Da6U1Tgj
mjQ6Q+pcxZLEOc2aZEgk1RUsz+9Em/VNoXYkuBYyJWQDsEAanCQnvIJYt6GYLjHW
RouLYDikQSqiCYVY0cXKKTv13fBCGU84UpqNgvFTcM8kqXELNb9X87YmzkZU3Op5
ta5GsSJXSaMt8M0WCP3fAq3NND7iZ9K46VdVh5ZGukkJBqxApYkmaDgYrQUcOCNZ
lzaygoZF6Ts=
=ap1/
-----END PGP SIGNATURE-----

--so9zsI5B81VjUb/o--
