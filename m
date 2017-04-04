From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 4 Apr 2017 11:13:57 +1000
Message-ID: <20170404111357.26975ab4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/core/flow_dissector.c

between commit:

  ac6a3722fed6 ("flow dissector: correct size of storage for ARP")

from the net tree and commit:

  9bf881ffc5c0 ("flow_dissector: Move ARP dissection into a separate function")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/core/flow_dissector.c
index d98d4998213d,5f3ae922fcd1..000000000000
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@@ -113,6 -113,216 +113,216 @@@ __be32 __skb_flow_get_ports(const struc
  }
  EXPORT_SYMBOL(__skb_flow_get_ports);
  
+ enum flow_dissect_ret {
+ 	FLOW_DISSECT_RET_OUT_GOOD,
+ 	FLOW_DISSECT_RET_OUT_BAD,
+ 	FLOW_DISSECT_RET_OUT_PROTO_AGAIN,
+ };
+ 
+ static enum flow_dissect_ret
+ __skb_flow_dissect_mpls(const struct sk_buff *skb,
+ 			struct flow_dissector *flow_dissector,
+ 			void *target_container, void *data, int nhoff, int hlen)
+ {
+ 	struct flow_dissector_key_keyid *key_keyid;
+ 	struct mpls_label *hdr, _hdr[2];
+ 
+ 	if (!dissector_uses_key(flow_dissector,
+ 				FLOW_DISSECTOR_KEY_MPLS_ENTROPY))
+ 		return FLOW_DISSECT_RET_OUT_GOOD;
+ 
+ 	hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data,
+ 				   hlen, &_hdr);
+ 	if (!hdr)
+ 		return FLOW_DISSECT_RET_OUT_BAD;
+ 
+ 	if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) >>
+ 	    MPLS_LS_LABEL_SHIFT == MPLS_LABEL_ENTROPY) {
+ 		key_keyid = skb_flow_dissector_target(flow_dissector,
+ 						      FLOW_DISSECTOR_KEY_MPLS_ENTROPY,
+ 						      target_container);
+ 		key_keyid->keyid = hdr[1].entry & htonl(MPLS_LS_LABEL_MASK);
+ 	}
+ 	return FLOW_DISSECT_RET_OUT_GOOD;
+ }
+ 
+ static enum flow_dissect_ret
+ __skb_flow_dissect_arp(const struct sk_buff *skb,
+ 		       struct flow_dissector *flow_dissector,
+ 		       void *target_container, void *data, int nhoff, int hlen)
+ {
+ 	struct flow_dissector_key_arp *key_arp;
+ 	struct {
+ 		unsigned char ar_sha[ETH_ALEN];
+ 		unsigned char ar_sip[4];
+ 		unsigned char ar_tha[ETH_ALEN];
+ 		unsigned char ar_tip[4];
+ 	} *arp_eth, _arp_eth;
+ 	const struct arphdr *arp;
 -	struct arphdr *_arp;
++	struct arphdr _arp;
+ 
+ 	if (!dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_ARP))
+ 		return FLOW_DISSECT_RET_OUT_GOOD;
+ 
+ 	arp = __skb_header_pointer(skb, nhoff, sizeof(_arp), data,
+ 				   hlen, &_arp);
+ 	if (!arp)
+ 		return FLOW_DISSECT_RET_OUT_BAD;
+ 
+ 	if (arp->ar_hrd != htons(ARPHRD_ETHER) ||
+ 	    arp->ar_pro != htons(ETH_P_IP) ||
+ 	    arp->ar_hln != ETH_ALEN ||
+ 	    arp->ar_pln != 4 ||
+ 	    (arp->ar_op != htons(ARPOP_REPLY) &&
+ 	     arp->ar_op != htons(ARPOP_REQUEST)))
+ 		return FLOW_DISSECT_RET_OUT_BAD;
+ 
+ 	arp_eth = __skb_header_pointer(skb, nhoff + sizeof(_arp),
+ 				       sizeof(_arp_eth), data,
+ 				       hlen, &_arp_eth);
+ 	if (!arp_eth)
+ 		return FLOW_DISSECT_RET_OUT_BAD;
+ 
+ 	key_arp = skb_flow_dissector_target(flow_dissector,
+ 					    FLOW_DISSECTOR_KEY_ARP,
+ 					    target_container);
+ 
+ 	memcpy(&key_arp->sip, arp_eth->ar_sip, sizeof(key_arp->sip));
+ 	memcpy(&key_arp->tip, arp_eth->ar_tip, sizeof(key_arp->tip));
+ 
+ 	/* Only store the lower byte of the opcode;
+ 	 * this covers ARPOP_REPLY and ARPOP_REQUEST.
+ 	 */
+ 	key_arp->op = ntohs(arp->ar_op) & 0xff;
+ 
+ 	ether_addr_copy(key_arp->sha, arp_eth->ar_sha);
+ 	ether_addr_copy(key_arp->tha, arp_eth->ar_tha);
+ 
+ 	return FLOW_DISSECT_RET_OUT_GOOD;
+ }
+ 
+ static enum flow_dissect_ret
+ __skb_flow_dissect_gre(const struct sk_buff *skb,
+ 		       struct flow_dissector_key_control *key_control,
+ 		       struct flow_dissector *flow_dissector,
+ 		       void *target_container, void *data,
+ 		       __be16 *p_proto, int *p_nhoff, int *p_hlen,
+ 		       unsigned int flags)
+ {
+ 	struct flow_dissector_key_keyid *key_keyid;
+ 	struct gre_base_hdr *hdr, _hdr;
+ 	int offset = 0;
+ 	u16 gre_ver;
+ 
+ 	hdr = __skb_header_pointer(skb, *p_nhoff, sizeof(_hdr),
+ 				   data, *p_hlen, &_hdr);
+ 	if (!hdr)
+ 		return FLOW_DISSECT_RET_OUT_BAD;
+ 
+ 	/* Only look inside GRE without routing */
+ 	if (hdr->flags & GRE_ROUTING)
+ 		return FLOW_DISSECT_RET_OUT_GOOD;
+ 
+ 	/* Only look inside GRE for version 0 and 1 */
+ 	gre_ver = ntohs(hdr->flags & GRE_VERSION);
+ 	if (gre_ver > 1)
+ 		return FLOW_DISSECT_RET_OUT_GOOD;
+ 
+ 	*p_proto = hdr->protocol;
+ 	if (gre_ver) {
+ 		/* Version1 must be PPTP, and check the flags */
+ 		if (!(*p_proto == GRE_PROTO_PPP && (hdr->flags & GRE_KEY)))
+ 			return FLOW_DISSECT_RET_OUT_GOOD;
+ 	}
+ 
+ 	offset += sizeof(struct gre_base_hdr);
+ 
+ 	if (hdr->flags & GRE_CSUM)
+ 		offset += sizeof(((struct gre_full_hdr *) 0)->csum) +
+ 			  sizeof(((struct gre_full_hdr *) 0)->reserved1);
+ 
+ 	if (hdr->flags & GRE_KEY) {
+ 		const __be32 *keyid;
+ 		__be32 _keyid;
+ 
+ 		keyid = __skb_header_pointer(skb, *p_nhoff + offset,
+ 					     sizeof(_keyid),
+ 					     data, *p_hlen, &_keyid);
+ 		if (!keyid)
+ 			return FLOW_DISSECT_RET_OUT_BAD;
+ 
+ 		if (dissector_uses_key(flow_dissector,
+ 				       FLOW_DISSECTOR_KEY_GRE_KEYID)) {
+ 			key_keyid = skb_flow_dissector_target(flow_dissector,
+ 							      FLOW_DISSECTOR_KEY_GRE_KEYID,
+ 							      target_container);
+ 			if (gre_ver == 0)
+ 				key_keyid->keyid = *keyid;
+ 			else
+ 				key_keyid->keyid = *keyid & GRE_PPTP_KEY_MASK;
+ 		}
+ 		offset += sizeof(((struct gre_full_hdr *) 0)->key);
+ 	}
+ 
+ 	if (hdr->flags & GRE_SEQ)
+ 		offset += sizeof(((struct pptp_gre_header *) 0)->seq);
+ 
+ 	if (gre_ver == 0) {
+ 		if (*p_proto == htons(ETH_P_TEB)) {
+ 			const struct ethhdr *eth;
+ 			struct ethhdr _eth;
+ 
+ 			eth = __skb_header_pointer(skb, *p_nhoff + offset,
+ 						   sizeof(_eth),
+ 						   data, *p_hlen, &_eth);
+ 			if (!eth)
+ 				return FLOW_DISSECT_RET_OUT_BAD;
+ 			*p_proto = eth->h_proto;
+ 			offset += sizeof(*eth);
+ 
+ 			/* Cap headers that we access via pointers at the
+ 			 * end of the Ethernet header as our maximum alignment
+ 			 * at that point is only 2 bytes.
+ 			 */
+ 			if (NET_IP_ALIGN)
+ 				*p_hlen = *p_nhoff + offset;
+ 		}
+ 	} else { /* version 1, must be PPTP */
+ 		u8 _ppp_hdr[PPP_HDRLEN];
+ 		u8 *ppp_hdr;
+ 
+ 		if (hdr->flags & GRE_ACK)
+ 			offset += sizeof(((struct pptp_gre_header *) 0)->ack);
+ 
+ 		ppp_hdr = __skb_header_pointer(skb, *p_nhoff + offset,
+ 					       sizeof(_ppp_hdr),
+ 					       data, *p_hlen, _ppp_hdr);
+ 		if (!ppp_hdr)
+ 			return FLOW_DISSECT_RET_OUT_BAD;
+ 
+ 		switch (PPP_PROTOCOL(ppp_hdr)) {
+ 		case PPP_IP:
+ 			*p_proto = htons(ETH_P_IP);
+ 			break;
+ 		case PPP_IPV6:
+ 			*p_proto = htons(ETH_P_IPV6);
+ 			break;
+ 		default:
+ 			/* Could probably catch some more like MPLS */
+ 			break;
+ 		}
+ 
+ 		offset += PPP_HDRLEN;
+ 	}
+ 
+ 	*p_nhoff += offset;
+ 	key_control->flags |= FLOW_DIS_ENCAPSULATION;
+ 	if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
+ 		return FLOW_DISSECT_RET_OUT_GOOD;
+ 
+ 	return FLOW_DISSECT_RET_OUT_PROTO_AGAIN;
+ }
+ 
  /**
   * __skb_flow_dissect - extract the flow_keys struct and return it
   * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
