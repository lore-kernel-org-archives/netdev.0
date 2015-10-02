From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: Re: [PATCH net-next V14 3/3] openvswitch: 802.1ad: Flow handling,
 actions, vlan parsing and netlink attributes
Date: Fri, 2 Oct 2015 17:48:34 -0400
Message-ID: <560EFBB2.707@gmail.com>
References: <1443670380-4245-1-git-send-email-thomasfherbert@gmail.com>
 <1443670380-4245-4-git-send-email-thomasfherbert@gmail.com>
Reply-To: thomasfherbert@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@redhat.com, dev@openvswitch.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:35511 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbJBVsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 17:48:40 -0400
Received: by qkap81 with SMTP id p81so48847146qka.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 14:48:39 -0700 (PDT)
In-Reply-To: <1443670380-4245-4-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/30/15 11:33 PM, Thomas F Herbert wrote:
> Add support for 802.1ad including the ability to push and pop double
> tagged vlans. Add support for 802.1ad to netlink parsing and flow
> conversion. Uses double nested encap attributes to represent double
> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>   net/openvswitch/actions.c      |   4 +-
>   net/openvswitch/flow.c         |  87 +++++++++++++++++----
>   net/openvswitch/flow.h         |  11 ++-
>   net/openvswitch/flow_netlink.c | 167 +++++++++++++++++++++++++++++++++++++----
>   net/openvswitch/vport-netdev.c |   4 +-
>   5 files changed, 239 insertions(+), 34 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 315f533..c544371 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -236,7 +236,7 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>   	if (skb_vlan_tag_present(skb))
>   		invalidate_flow_key(key);
>   	else
> -		key->eth.tci = 0;
> +		key->eth.vlan.tci = 0;
>   	return err;
>   }
>   
> @@ -246,7 +246,7 @@ static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
>   	if (skb_vlan_tag_present(skb))
>   		invalidate_flow_key(key);
>   	else
> -		key->eth.tci = vlan->vlan_tci;
> +		key->eth.vlan.tci = vlan->vlan_tci;
>   	return skb_vlan_push(skb, vlan->vlan_tpid,
>   			     ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
>   }
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index c8db44a..86a2cb0 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -305,21 +305,78 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
>   static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>   {
>   	struct qtag_prefix {
> -		__be16 eth_type; /* ETH_P_8021Q */
> +		__be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>   		__be16 tci;
>   	};
> -	struct qtag_prefix *qp;
> +	struct qtag_prefix *qp = (struct qtag_prefix *)skb->data;
>   
> -	if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
> +	struct qinqtag_prefix {
> +		__be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
> +		__be16 tci;
> +		__be16 inner_tpid; /* ETH_P_8021Q */
> +		__be16 ctci;
> +	};
> +
> +	if (likely(skb_vlan_tag_present(skb))) {
> +		key->eth.vlan.tci = htons(skb->vlan_tci);
> +		key->eth.vlan.tpid = skb->vlan_proto;
> +
> +		/* Case where upstream
> +		 * processing has already stripped the outer vlan tag.
> +		 */
> +		if (unlikely(skb->vlan_proto == htons(ETH_P_8021AD))) {
> +			if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +					sizeof(__be16))) {
> +				key->eth.vlan.tci = 0;
> +				return 0;
> +			}
> +
> +			if (unlikely(!pskb_may_pull(skb,
> +						    sizeof(struct qtag_prefix) +
> +						    sizeof(__be16))))
> +				return -ENOMEM;
> +
> +			key->eth.cvlan.tci =
> +				qp->tci | htons(VLAN_TAG_PRESENT);
> +			key->eth.cvlan.tpid = qp->eth_type;
> +
> +			__skb_pull(skb, sizeof(struct qtag_prefix));
> +		}
>   		return 0;
>   
> -	if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> -					 sizeof(__be16))))
> -		return -ENOMEM;
> +	} else if (qp->eth_type == htons(ETH_P_8021AD)) {
> +		struct qinqtag_prefix *qinqp =
> +					(struct qinqtag_prefix *)skb->data;
> +
> +		if (unlikely(skb->len < sizeof(struct qinqtag_prefix) +
> +					sizeof(__be16)))
> +			return 0;
> +
> +		if (unlikely(!pskb_may_pull(skb, sizeof(struct qinqtag_prefix) +
> +				sizeof(__be16))))
> +			return -ENOMEM;
> +		key->eth.vlan.tci = qinqp->tci | htons(VLAN_TAG_PRESENT);
> +		key->eth.vlan.tpid = qp->eth_type;
> +		key->eth.cvlan.tci = qinqp->ctci | htons(VLAN_TAG_PRESENT);
> +		key->eth.cvlan.tpid = qinqp->inner_tpid;
> +
> +		__skb_pull(skb, sizeof(struct qinqtag_prefix));
>   
> -	qp = (struct qtag_prefix *) skb->data;
> -	key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> -	__skb_pull(skb, sizeof(struct qtag_prefix));
> +		return 0;
> +
> +	} else if (qp->eth_type == htons(ETH_P_8021Q)) {
> +		if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +					sizeof(__be16)))
> +			return 0;
> +
> +		if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> +				sizeof(__be16))))
> +			return -ENOMEM;
> +		key->eth.vlan.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> +		key->eth.vlan.tpid = qp->eth_type;
> +
> +		__skb_pull(skb, sizeof(struct qtag_prefix));
> +	}
>   
>   	return 0;
>   }
> @@ -480,12 +537,12 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>   	 * update skb->csum here.
>   	 */
>   
> -	key->eth.tci = 0;
> -	if (skb_vlan_tag_present(skb))
> -		key->eth.tci = htons(skb->vlan_tci);
> -	else if (eth->h_proto == htons(ETH_P_8021Q))
> -		if (unlikely(parse_vlan(skb, key)))
> -			return -ENOMEM;
> +	key->eth.vlan.tci = 0;
> +	key->eth.vlan.tpid = 0;
> +	key->eth.cvlan.tci = 0;
> +	key->eth.cvlan.tpid = 0;
> +	if (unlikely(parse_vlan(skb, key)))
> +		return -ENOMEM;
>   
>   	key->eth.type = parse_ethertype(skb);
>   	if (unlikely(key->eth.type == htons(0)))
> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index fe527d2..539494e 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -68,7 +68,16 @@ struct sw_flow_key {
>   	struct {
>   		u8     src[ETH_ALEN];	/* Ethernet source address. */
>   		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
> -		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
> +		struct {
> +			__be16 tpid;	/* Outer Vlan type 802.1q or 802.1ad.*/
> +			__be16 tci;	/* 0 if no VLAN, VLAN_TAG_PRESENT */
> +					/* set otherwise. */
> +		} vlan;
> +		struct {
> +			__be16 tpid;	/* Inner Vlan DL_type 802.1q.*/
> +			__be16 tci;	/* 0 if no CVLAN, VLAN_TAG_PRESENT */
> +					/* set otherwise. */
> +		} cvlan;
>   		__be16 type;		/* Ethernet frame type. */
>   	} eth;
>   	union {
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index c92d6a2..08f56ab 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -811,6 +811,27 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
>   	return 0;
>   }
>   
> +static int cust_vlan_from_nlattrs(struct sw_flow_match *match,
> +				  const struct nlattr *a[],
> +				  bool is_mask, bool log)
> +{
> +	__be16 ctci = 0;
> +	__be16 c_tpid = 0;
> +
> +	ctci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> +	if (!(ctci & htons(VLAN_TAG_PRESENT))) {
> +		if (is_mask)
> +			OVS_NLERR(log, "VLAN CTCI mask does not have exact match for VLAN_TAG_PRESENT bit.");
> +		else
> +			OVS_NLERR(log, "VLAN CTCI does not have VLAN_TAG_PRESENT bit set.");
> +		return -EINVAL;
> +	}
> +	c_tpid = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
> +	SW_FLOW_KEY_PUT(match, eth.cvlan.tpid, c_tpid, is_mask);
> +	SW_FLOW_KEY_PUT(match, eth.cvlan.tci, ctci, is_mask);
> +	return 0;
> +}
> +
>   static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
>   				u64 attrs, const struct nlattr **a,
>   				bool is_mask, bool log)
> @@ -845,7 +866,7 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
>   			return -EINVAL;
>   		}
>   
> -		SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
> +		SW_FLOW_KEY_PUT(match, eth.vlan.tci, tci, is_mask);
>   		attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
>   	}
>   
> @@ -1064,6 +1085,93 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
>   	nlattr_set(attr, val, ovs_key_lens);
>   }
>   
> +static int parse_vlan_from_nlattrs(const struct nlattr **nla,
> +				   struct sw_flow_match *match,
> +				   u64 *key_attrs, bool *ie_valid,
> +				   const struct nlattr **a, bool is_mask,
> +				   bool log)
> +{
> +	int err;
> +	const struct nlattr *encap;
> +
> +	if (!is_mask) {
> +		u64 v_attrs = 0;
> +
> +		err = parse_flow_nlattrs(*nla, a, &v_attrs, log);
> +		if (err)
> +			return err;
> +		/* Another encap attribute here indicates
> +		 * the presence of a double tagged vlan.
> +		 */
> +		if ((v_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
> +		    eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
> +			if (!((v_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) &&
> +			      (v_attrs & (1ULL << OVS_KEY_ATTR_ENCAP)))) {
> +				OVS_NLERR(log, "Invalid Inner VLAN frame");
> +				return -EINVAL;
> +			}
> +			SW_FLOW_KEY_PUT(match, eth.vlan.tpid,
> +					nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]),
> +						     is_mask);
> +			encap = a[OVS_KEY_ATTR_ENCAP];
> +			v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
> +
> +			err = cust_vlan_from_nlattrs(match, a, is_mask, log);
> +			if (err)
> +				return err;
> +			*ie_valid = true;
> +			*nla = encap;
> +
> +			/* Insure that tci key attribute isn't
> +			 * overwritten by encapsulated customer tci.
> +			 * Ethertype is cleared because it is c_tpid.
> +			 */
> +			v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
> +			v_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
> +		}
> +		*key_attrs |= v_attrs;
> +
> +		if (*ie_valid) {
> +			err = parse_flow_nlattrs(*nla, a, key_attrs, log);
> +			if (err)
> +				return err;
> +		}
> +
> +	} else {
> +		u64 mask_v_attrs = 0;
> +
> +		err = parse_flow_mask_nlattrs(*nla, a, &mask_v_attrs, log);
> +		if (err)
> +			return err;
> +
> +		if (mask_v_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
> +			if (!*ie_valid) {
> +				OVS_NLERR(log, "Encap mask attribute is set for non-CVLAN frame.");
> +				err = -EINVAL;
> +				return err;
> +			}
> +			encap = a[OVS_KEY_ATTR_ENCAP];
> +			mask_v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
> +
> +			err = cust_vlan_from_nlattrs(match, a, is_mask, log);
> +			if (err)
> +				return err;
> +			*nla = encap;
> +
> +			mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_VLAN);
> +			mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_ETHERTYPE);
> +		}
> +
> +		*key_attrs |= mask_v_attrs;
> +		if (*ie_valid) {
Pravin, could you please review the above code encoding the netmask of 
the tpids. I am seeing a duplicate key (Type 6, ethertype key) 
discovered by parse_vlan_from_nlattrs() below which I noticed (chagrined 
I am) only after submitting this patch.
> +			err = parse_flow_mask_nlattrs(*nla, a, key_attrs, log);
> +			if (err)
> +				return err;
> +		}
> +	}
> +	return 0;
> +}
> +
>   /**
>    * ovs_nla_get_match - parses Netlink attributes into a flow key and
>    * mask. In case the 'mask' is NULL, the flow is treated as exact match
> @@ -1091,6 +1199,7 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
>   	u64 key_attrs = 0;
>   	u64 mask_attrs = 0;
>   	bool encap_valid = false;
> +	bool i_encap_valid = false;
>   	int err;
>   
>   	err = parse_flow_nlattrs(nla_key, a, &key_attrs, log);
> @@ -1099,11 +1208,11 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
>   
>   	if ((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
>   	    (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
> -	    (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q))) {
> +	    eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
>   		__be16 tci;
>   
> -		if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
> -		      (key_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
> +		if (!((key_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) &&
> +		      (key_attrs & (1ULL << OVS_KEY_ATTR_ENCAP)))) {
>   			OVS_NLERR(log, "Invalid Vlan frame.");
>   			return -EINVAL;
>   		}
> @@ -1115,9 +1224,12 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
>   		encap_valid = true;
>   
>   		if (tci & htons(VLAN_TAG_PRESENT)) {
> -			err = parse_flow_nlattrs(encap, a, &key_attrs, log);
> +			err = parse_vlan_from_nlattrs(&encap, match, &key_attrs,
> +						      &i_encap_valid, a, false,
> +						      log);
>   			if (err)
>   				return err;
> +
>   		} else if (!tci) {
>   			/* Corner case for truncated 802.1Q header. */
>   			if (nla_len(encap)) {
> @@ -1169,7 +1281,7 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
>   			goto free_newmask;
>   
>   		/* Always match on tci. */
> -		SW_FLOW_KEY_PUT(match, eth.tci, htons(0xffff), true);
> +		SW_FLOW_KEY_PUT(match, eth.vlan.tci, htons(0xffff), true);
>   
>   		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
>   			__be16 eth_type = 0;
> @@ -1188,10 +1300,13 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
>   			if (eth_type == htons(0xffff)) {
>   				mask_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
>   				encap = a[OVS_KEY_ATTR_ENCAP];
> -				err = parse_flow_mask_nlattrs(encap, a,
> -							      &mask_attrs, log);
> +				err = parse_vlan_from_nlattrs(&encap, match,
> +							      &mask_attrs,
> +							      &i_encap_valid,
> +							      a, true, log);
>   				if (err)
>   					goto free_newmask;
> +
>   			} else {
>   				OVS_NLERR(log, "VLAN frames must have an exact match on the TPID (mask=%x).",
>   					  ntohs(eth_type));
> @@ -1320,6 +1435,7 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>   {
>   	struct ovs_key_ethernet *eth_key;
>   	struct nlattr *nla, *encap;
> +	struct nlattr *in_encap = NULL;
>   
>   	if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
>   		goto nla_put_failure;
> @@ -1368,17 +1484,36 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>   	ether_addr_copy(eth_key->eth_src, output->eth.src);
>   	ether_addr_copy(eth_key->eth_dst, output->eth.dst);
>   
> -	if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
> +	if (swkey->eth.vlan.tci || eth_type_vlan(swkey->eth.type)) {
>   		__be16 eth_type;
> -		eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
> +
> +		eth_type = !is_mask ? output->eth.vlan.tpid : htons(0xffff);
> +
>   		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
> -		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
> +		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.vlan.tci))
>   			goto nla_put_failure;
>   		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
> -		if (!swkey->eth.tci)
> +		if (!swkey->eth.vlan.tci)
>   			goto unencap;
> -	} else
> +		if (swkey->eth.cvlan.tci) {
> +			__be16 eth_type;
> +
> +			/* Customer tci is nested but uses same key attribute.
> +			 */
> +			eth_type = !is_mask ? output->eth.cvlan.tpid :
> +					      htons(0xffff);
> +			if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
> +					 eth_type) ||
> +			    nla_put_be16(skb, OVS_KEY_ATTR_VLAN,
> +					 output->eth.cvlan.tci))
> +				goto nla_put_failure;
> +			in_encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
> +			if (!swkey->eth.cvlan.tci)
> +				goto unencap;
> +		}
> +	} else {
>   		encap = NULL;
> +	}
>   
>   	if (swkey->eth.type == htons(ETH_P_802_2)) {
>   		/*
> @@ -1525,6 +1660,8 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>   unencap:
>   	if (encap)
>   		nla_nest_end(skb, encap);
> +	if (in_encap)
> +		nla_nest_end(skb, in_encap);
>   
>   	return 0;
>   
> @@ -2174,7 +2311,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
>   
>   		case OVS_ACTION_ATTR_PUSH_VLAN:
>   			vlan = nla_data(a);
> -			if (vlan->vlan_tpid != htons(ETH_P_8021Q))
> +			if (!eth_type_vlan(vlan->vlan_tpid))
>   				return -EINVAL;
>   			if (!(vlan->vlan_tci & htons(VLAN_TAG_PRESENT)))
>   				return -EINVAL;
> @@ -2279,7 +2416,7 @@ int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
>   
>   	(*sfa)->orig_len = nla_len(attr);
>   	err = __ovs_nla_copy_actions(net, attr, key, 0, sfa, key->eth.type,
> -				     key->eth.tci, log);
> +				     key->eth.vlan.tci, log);
>   	if (err)
>   		ovs_nla_free_flow_actions(*sfa);
>   
> diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
> index f7e8dcc..d2581b7 100644
> --- a/net/openvswitch/vport-netdev.c
> +++ b/net/openvswitch/vport-netdev.c
> @@ -194,7 +194,9 @@ static unsigned int packet_length(const struct sk_buff *skb)
>   {
>   	unsigned int length = skb->len - ETH_HLEN;
>   
> -	if (skb->protocol == htons(ETH_P_8021Q))
> +	if (eth_type_vlan(skb->protocol))
> +		length -= VLAN_HLEN;
> +	if (skb->protocol == htons(ETH_P_8021AD))
>   		length -= VLAN_HLEN;
>   
>   	return length;
