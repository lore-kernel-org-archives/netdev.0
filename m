From: Thomas F Herbert <therbert@redhat.com>
Subject: Re: [ovs-dev] [PATCH net-next 3/3] openvswitch: 802.1AD: Flow handling,
 actions, vlan parsing and netlink attributes
Date: Fri, 31 Jul 2015 09:28:25 -0700
Message-ID: <55BBA229.6080704@redhat.com>
References: <1437922355-3809-1-git-send-email-thomasfherbert@gmail.com> <1437922355-3809-4-git-send-email-thomasfherbert@gmail.com> <SG2PR03MB0796167A00F3C2E6C69B6540E48A0@SG2PR03MB0796.apcprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org
To: ravulakollu.kumar@wipro.com, thomasfherbert@gmail.com,
	netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57313 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751687AbbGaQ20 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jul 2015 12:28:26 -0400
In-Reply-To: <SG2PR03MB0796167A00F3C2E6C69B6540E48A0@SG2PR03MB0796.apcprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 7/31/15 5:34 AM, ravulakollu.kumar@wipro.com wrote:
> Hi Thomas,
>
> I have applied your  below mentioned 1ad patch to ovs-master code. Compiled successfully. I am running ovs in a centos machine.
> I have created bridge and configured ports using below commands.
>
> ovs-vsctl --no-wait add-br br0
> ovs-vsctl --no-wait add-port br0 eth0 tag=100 vlan_mode=native-tagged /access
> ovs-vsctl --no-wait add-port br0 eth1
>
> Configured the bridge to work in legacy bridge mode
> $ ovs-ofctl dump-flows br0
>   NXST_FLOW reply (xid=0x4):
>   cookie=0x0, duration=15.458s, table=0, n_packets=0, n_bytes=0, idle_age=15, priority=0 actions=NORMAL
>
> And started running vswitchd
>
> $ ovs-vswitchd --pidfile
>
> Started pumping traffic from outside using ostinato packet generator for Phy-Phy scenario(sending to eth0 ,receiving back on eth1)
> My observation is
> 1) For untagged packet received on eth0 pushing vid 100 and packet flow is fine
> 2) For already tagged (1q) packet received on eth0 packet is dropped , I could see vswitchd log throwing below error(duplicate eth_type attribute in flow key)
>
> 2015-07-31T12:13:59Z|00001|ovs_numa|INFO|Discovered 4 CPU cores on NUMA node 0
> 2015-07-31T12:13:59Z|00002|ovs_numa|INFO|Discovered 1 NUMA nodes and 4 CPU cores
> 2015-07-31T12:13:59Z|00003|reconnect|INFO|unix:/usr/local/var/run/openvswitch/db.sock: connecting...
> 2015-07-31T12:13:59Z|00004|reconnect|INFO|unix:/usr/local/var/run/openvswitch/db.sock: connected
> 2015-07-31T12:13:59Z|00005|ofproto_dpif|INFO|system@ovs-system: Datapath supports recirculation
> 2015-07-31T12:13:59Z|00006|ofproto_dpif|INFO|system@ovs-system: MPLS label stack length probed as 1
> 2015-07-31T12:13:59Z|00007|ofproto_dpif|INFO|system@ovs-system: Datapath supports unique flow ids
> 2015-07-31T12:13:59Z|00001|ofproto_dpif_upcall(handler1)|INFO|received packet on unassociated datapath port 0
> 2015-07-31T12:13:59Z|00008|bridge|INFO|bridge br0: added interface eth0 on port 1
> 2015-07-31T12:13:59Z|00009|bridge|INFO|bridge br0: added interface br0 on port 65534
> 2015-07-31T12:13:59Z|00010|bridge|INFO|bridge br0: added interface eth1 on port 2
> 2015-07-31T12:13:59Z|00011|bridge|INFO|bridge br0: using datapath ID 0000eac07aea5143
> 2015-07-31T12:13:59Z|00012|connmgr|INFO|br0: added service controller "punix:/usr/local/var/run/openvswitch/br0.mgmt"
> 2015-07-31T12:13:59Z|00013|bridge|INFO|ovs-vswitchd (Open vSwitch) 2.3.90
> 2015-07-31T12:14:09Z|00014|memory|INFO|2420 kB peak resident set size after 10.0 seconds
> 2015-07-31T12:14:09Z|00015|memory|INFO|handlers:2 ports:3 revalidators:2 rules:5
> 2015-07-31T12:16:31Z|00001|odp_util(handler6)|ERR|duplicate eth_type attribute in flow key
> 2015-07-31T12:26:51Z|00002|odp_util(handler6)|ERR|duplicate eth_type attribute in flow key
I believe this may be a bug in the patch.

Also, what you are doing above should work without the patch.
>
>
> Please, let me know whether I missed anything in the configuration. It would be helpful  if someone could let me
> Know how I can insert 1ad tag on ingress.

The patch supports pushing and popping outer tags for 802.1ad. The 
previously submitted user space patch is required as well.

To test: take the switch out of NORMAL mode so it won't flood packets, 
set up veths, bridges and ports. The test should accept  untagged 
traffic in eth p1p1 and double tagged traffic in eth em4

sudo ip link add type veth
sudo ifconfig veth0 up
sudo ifconfig veth1 up

sudo ovs-vsctl add-br br0

sudo ovs-vsctl -- set bridge br0 fail-mode=secure

sudo ovs-vsctl -- set bridge br0 protocols=[OpenFlow11]

sudo ovs-vsctl add-port br0 em4

sudo ovs-vsctl add-port br0 veth0
#
# Add Customer bridge
#
sudo ovs-vsctl add-br br1

sudo ovs-vsctl -- set bridge br1 fail-mode=secure

sudo ovs-vsctl -- set bridge br1 protocols=[OpenFlow11]

sudo ovs-vsctl add-port br1 veth1

sudo ovs-vsctl add-port br1 p1p2


Then add flows to push and pop vlans as follows.

sudo ovs-ofctl --protocols=OpenFlow11 add-flow br0 
in_port=1,dl_vlan=100,actions=pop_vlan,output:2
#
# Packets to Core
#
sudo ovs-ofctl --protocols=OpenFlow11 add-flow br0 
in_port=2,actions=push_vlan:0x88a8,load:100-\>OXM_OF_VLAN_VID[],output:1
#
# Strip c-tag
#
# Ctag Packets from br0,VID:998
#
sudo ovs-ofctl --protocols=OpenFlow11 add-flow br1 
in_port=1,dl_vlan=998,actions=pop_vlan,output:2
#
# Ctag Packets from  cpe to VID:998
#
sudo ovs-ofctl --protocols=OpenFlow11 add-flow br1 
in_port=2,actions=push_vlan:0x8100,load:998-\>OXM_OF_VLAN_VID[],output:1


--TFH

>
> Thanks & Regards,
> Uday
>
>
> -----Original Message-----
> From: dev [mailto:dev-bounces@openvswitch.org] On Behalf Of Thomas F Herbert
> Sent: Sunday, July 26, 2015 8:23 PM
> To: netdev@vger.kernel.org; pshelar@nicira.com
> Cc: dev@openvswitch.org; therbert@redhat.com
> Subject: [ovs-dev] [PATCH net-next 3/3] openvswitch: 802.1AD: Flow handling, actions, vlan parsing and netlink attributes
>
> Add support for 802.1ad including the ability to push and pop double tagged vlans. Add support for 802.1ad to netlink parsing and flow conversion. Uses double nested encap attributes to represent double tagged vlan. Inner TPID encoded along with ctci in nested attributes. Allows either 0x8100 or 0x88a8 on inner or outer tags.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>   net/openvswitch/flow.c         |  84 +++++++++++++++---
>   net/openvswitch/flow.h         |   5 ++
>   net/openvswitch/flow_netlink.c | 196 ++++++++++++++++++++++++++++++++++-------
>   3 files changed, 243 insertions(+), 42 deletions(-)
>
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c index 8db22ef..0abab37 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -298,21 +298,80 @@ static bool icmp6hdr_ok(struct sk_buff *skb)  static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)  {
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
> +		key->eth.tci = htons(skb->vlan_tci);
> +
> +		/* Case where upstream
> +		 * processing has already stripped the outer vlan tag.
> +		 */
> +		if (unlikely(skb->vlan_proto == htons(ETH_P_8021AD))) {
> +			if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +					sizeof(__be16))) {
> +				key->eth.tci = 0;
> +				return 0;
> +			}
> +
> +			if (unlikely(!pskb_may_pull(skb,
> +						    sizeof(struct qtag_prefix) +
> +						    sizeof(__be16)))) {
> +				return -ENOMEM;
> +			}
> +
> +			if (likely(qp->eth_type == htons(ETH_P_8021Q))) {
> +				key->eth.cvlan.ctci =
> +					qp->tci | htons(VLAN_TAG_PRESENT);
> +				key->eth.cvlan.c_tpid = qp->eth_type;
> +				__skb_pull(skb, sizeof(struct qtag_prefix));
> +			}
> +		}
>   		return 0;
> +	}
>
> -	if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> -					 sizeof(__be16))))
> -		return -ENOMEM;
>
> -	qp = (struct qtag_prefix *) skb->data;
> -	key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> -	__skb_pull(skb, sizeof(struct qtag_prefix));
> +	if (qp->eth_type == htons(ETH_P_8021AD)) {
> +		struct qinqtag_prefix *qinqp =
> +					(struct qinqtag_prefix *)skb->data;
> +
> +		if (unlikely(skb->len < sizeof(struct qinqtag_prefix) +
> +					sizeof(__be16)))
> +			return 0;
> +
> +		if (unlikely(!pskb_may_pull(skb, sizeof(struct qinqtag_prefix) +
> +				sizeof(__be16)))) {
> +			return -ENOMEM;
> +		}
> +		key->eth.tci = qinqp->tci | htons(VLAN_TAG_PRESENT);
> +		key->eth.cvlan.ctci = qinqp->ctci | htons(VLAN_TAG_PRESENT);
> +		key->eth.cvlan.c_tpid = qinqp->inner_tpid;
> +
> +		__skb_pull(skb, sizeof(struct qinqtag_prefix));
> +
> +		return 0;
> +	}
> +	if (qp->eth_type == htons(ETH_P_8021Q)) {
> +		if (unlikely(skb->len < sizeof(struct qtag_prefix) +
> +					sizeof(__be16)))
> +			return -ENOMEM;
> +
> +		if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
> +				sizeof(__be16))))
> +			return 0;
> +		key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
> +
> +		__skb_pull(skb, sizeof(struct qtag_prefix));
> +	}
>
>   	return 0;
>   }
> @@ -474,9 +533,10 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>   	 */
>
>   	key->eth.tci = 0;
> -	if (skb_vlan_tag_present(skb))
> -		key->eth.tci = htons(skb->vlan_tci);
> -	else if (eth->h_proto == htons(ETH_P_8021Q))
> +	key->eth.cvlan.ctci = 0;
> +	key->eth.cvlan.c_tpid = 0;
> +	if ((skb_vlan_tag_present(skb)) ||
> +	    eth_type_vlan(eth->h_proto))
>   		if (unlikely(parse_vlan(skb, key)))
>   			return -ENOMEM;
>
> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h index b62cdb3..69c48c6 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -69,6 +69,11 @@ struct sw_flow_key {
>   		u8     src[ETH_ALEN];	/* Ethernet source address. */
>   		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
>   		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
> +		struct {
> +			__be16 c_tpid;	/* Vlan DL_type 802.1q or 802.1ad */
> +			__be16 ctci;	/* 0 if no CVLAN, VLAN_TAG_PRESENT */
> +					/* set otherwise. */
> +		} cvlan;
>   		__be16 type;		/* Ethernet frame type. */
>   	} eth;
>   	union {
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c index a6eb77a..946f99d 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -771,6 +771,31 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
>   	return 0;
>   }
>
> +static int cust_vlan_from_nlattrs(struct sw_flow_match *match, u64 attrs,
> +				  const struct nlattr **a, bool is_mask,
> +				  bool log)
> +{
> +	/* This should be nested inner or "customer" tci" */
> +	if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
> +		__be16 ctci;
> +		__be16 c_tpid;
> +
> +		ctci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> +		if (!(ctci & htons(VLAN_TAG_PRESENT))) {
> +			if (is_mask)
> +				OVS_NLERR(log, "VLAN CTCI mask does not have exact match for VLAN_TAG_PRESENT bit.");
> +			else
> +				OVS_NLERR(log, "VLAN CTCI does not have VLAN_TAG_PRESENT bit
> +set.");
> +
> +			return -EINVAL;
> +		}
> +		c_tpid = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
> +		SW_FLOW_KEY_PUT(match, eth.cvlan.c_tpid, ctci, is_mask);
> +		SW_FLOW_KEY_PUT(match, eth.cvlan.ctci, ctci, is_mask);
> +	}
> +	return 0;
> +}
> +
>   static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
>   				const struct nlattr **a, bool is_mask,
>   				bool log)
> @@ -1024,6 +1049,104 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
>   	nlattr_set(attr, val, ovs_key_lens);
>   }
>
> +static int parse_vlan_from_nlattrs(const struct nlattr *nla,
> +				   struct sw_flow_match *match,
> +				   u64 *key_attrs, bool *ie_valid,
> +				   const struct nlattr **a, bool is_mask,
> +				   bool log)
> +{
> +	int err;
> +	__be16 tci;
> +	const struct nlattr *encap;
> +
> +	*ie_valid = false;
> +	if (!is_mask) {
> +		u64 v_attrs = 0;
> +
> +		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> +
> +		if (tci & htons(VLAN_TAG_PRESENT)) {
> +			err = parse_flow_nlattrs(nla, a, &v_attrs, log);
> +			if (err)
> +				return err;
> +			if (!v_attrs)
> +				return -EINVAL;
> +			/* Another encap attribute here indicates
> +			 * a double tagged vlan.
> +			 */
> +			if (v_attrs & (1ULL << OVS_KEY_ATTR_ENCAP)) {
> +				if (!(v_attrs & (1ULL << OVS_KEY_ATTR_VLAN))) {
> +					OVS_NLERR(log, "Inner encap attr is set for non VLAN frame");
> +					return -EINVAL;
> +				}
> +				v_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
> +				encap = a[OVS_KEY_ATTR_ENCAP];
> +				v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
> +				*ie_valid = true;
> +
> +				err = cust_vlan_from_nlattrs(match, v_attrs,
> +							     &encap, is_mask,
> +							     log);
> +				if (err)
> +					return err;
> +				/* Insure that tci key attribute isn't
> +				 * overwritten by encapsulated customer tci.
> +				 */
> +				v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
> +				*key_attrs |= v_attrs;
> +			} else {
> +				*key_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
> +				err = parse_flow_nlattrs(nla, a, key_attrs,
> +							 log);
> +				if (err)
> +					return err;
> +			}
> +		} else if (!tci) {
> +			/* Corner case for truncated 802.1Q header. */
> +			if (nla_len(nla)) {
> +				OVS_NLERR(log, "Truncated 802.1Q header has non-zero encap attribute.");
> +				return -EINVAL;
> +			}
> +		} else {
> +			OVS_NLERR(log, "Encap attr is set for non-VLAN frame");
> +			return  -EINVAL;
> +		}
> +
> +	} else {
> +		u64 mask_v_attrs = 0;
> +
> +		tci = 0;
> +		if (a[OVS_KEY_ATTR_VLAN])
> +			tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> +
> +		if (!(tci & htons(VLAN_TAG_PRESENT))) {
> +			OVS_NLERR(log, "VLAN tag present bit must have an exact match (tci_mask=%x).",
> +				  ntohs(tci));
> +			err = -EINVAL;
> +			return err;
> +		}
> +		err = parse_flow_mask_nlattrs(nla, a, &mask_v_attrs,
> +					      log);
> +		if (err)
> +			return err;
> +
> +		if (mask_v_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) {
> +			err = cust_vlan_from_nlattrs(match, mask_v_attrs,
> +						     a, is_mask, log);
> +			if (err)
> +				return err;
> +
> +			mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_VLAN);
> +			*key_attrs |= mask_v_attrs;
> +	       } else {
> +			*key_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
> +			if (err)
> +				return err;
> +		}
> +	}
> +	return 0;
> +}
> +
>   /**
>    * ovs_nla_get_match - parses Netlink attributes into a flow key and
>    * mask. In case the 'mask' is NULL, the flow is treated as exact match @@ -1050,6 +1173,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>   	u64 key_attrs = 0;
>   	u64 mask_attrs = 0;
>   	bool encap_valid = false;
> +	bool i_encap_valid = false;
>   	int err;
>
>   	err = parse_flow_nlattrs(nla_key, a, &key_attrs, log); @@ -1058,35 +1182,24 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>
>   	if ((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
>   	    (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
> -	    (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q))) {
> -		__be16 tci;
> +	    eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
>
> -		if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
> -		      (key_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
> +		if (!((key_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) &&
> +		      (key_attrs & (1ULL << OVS_KEY_ATTR_ENCAP)))) {
>   			OVS_NLERR(log, "Invalid Vlan frame.");
>   			return -EINVAL;
>   		}
>
>   		key_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
> -		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
>   		encap = a[OVS_KEY_ATTR_ENCAP];
>   		key_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
>   		encap_valid = true;
>
> -		if (tci & htons(VLAN_TAG_PRESENT)) {
> -			err = parse_flow_nlattrs(encap, a, &key_attrs, log);
> -			if (err)
> -				return err;
> -		} else if (!tci) {
> -			/* Corner case for truncated 802.1Q header. */
> -			if (nla_len(encap)) {
> -				OVS_NLERR(log, "Truncated 802.1Q header has non-zero encap attribute.");
> -				return -EINVAL;
> -			}
> -		} else {
> -			OVS_NLERR(log, "Encap attr is set for non-VLAN frame");
> -			return  -EINVAL;
> -		}
> +		err = parse_vlan_from_nlattrs(encap, match, &key_attrs,
> +					      &i_encap_valid, a, false, log);
> +		if (err)
> +			return err;
> +
>   	}
>
>   	err = ovs_key_from_nlattrs(match, key_attrs, a, false, log); @@ -1132,7 +1245,6 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>
>   		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
>   			__be16 eth_type = 0;
> -			__be16 tci = 0;
>
>   			if (!encap_valid) {
>   				OVS_NLERR(log, "Encap mask attribute is set for non-VLAN frame."); @@ -1158,15 +1270,13 @@ int ovs_nla_get_match(struct sw_flow_match *match,
>   				goto free_newmask;
>   			}
>
> -			if (a[OVS_KEY_ATTR_VLAN])
> -				tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> -
> -			if (!(tci & htons(VLAN_TAG_PRESENT))) {
> -				OVS_NLERR(log, "VLAN tag present bit must have an exact match (tci_mask=%x).",
> -					  ntohs(tci));
> -				err = -EINVAL;
> +			err = parse_vlan_from_nlattrs(encap, match,
> +						      &mask_attrs,
> +						      &i_encap_valid, a, true,
> +						      log);
> +			if (err)
>   				goto free_newmask;
> -			}
> +
>   		}
>
>   		err = ovs_key_from_nlattrs(match, mask_attrs, a, true, log); @@ -1277,6 +1387,7 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,  {
>   	struct ovs_key_ethernet *eth_key;
>   	struct nlattr *nla, *encap;
> +	struct nlattr *in_encap = NULL;
>
>   	if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
>   		goto nla_put_failure;
> @@ -1331,8 +1442,30 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>   		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
>   		if (!swkey->eth.tci)
>   			goto unencap;
> -	} else
> +	} else if (swkey->eth.cvlan.ctci || swkey->eth.type ==
> +		   htons(ETH_P_8021AD)) {
> +		__be16 eth_type;
> +
> +		eth_type = !is_mask ? htons(ETH_P_8021AD) : htons(0xffff);
> +		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
> +		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
> +			goto nla_put_failure;
> +		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
> +		if (!swkey->eth.tci)
> +			goto unencap;
> +		/* Customer tci is nested but uses same key attribute.
> +		 */
> +		eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
> +		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
> +		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN,
> +				 output->eth.cvlan.ctci))
> +			goto nla_put_failure;
> +		in_encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
> +		if (!swkey->eth.cvlan.ctci)
> +			goto unencap;
> +	} else {
>   		encap = NULL;
> +	}
>
>   	if (swkey->eth.type == htons(ETH_P_802_2)) {
>   		/*
> @@ -1479,6 +1612,8 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>   unencap:
>   	if (encap)
>   		nla_nest_end(skb, encap);
> +	if (in_encap)
> +		nla_nest_end(skb, in_encap);
>
>   	return 0;
>
> @@ -2127,7 +2262,8 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
>
>   		case OVS_ACTION_ATTR_PUSH_VLAN:
>   			vlan = nla_data(a);
> -			if (vlan->vlan_tpid != htons(ETH_P_8021Q))
> +			if ((vlan->vlan_tpid != htons(ETH_P_8021Q)) &&
> +			    (vlan->vlan_tpid != htons(ETH_P_8021AD)))
>   				return -EINVAL;
>   			if (!(vlan->vlan_tci & htons(VLAN_TAG_PRESENT)))
>   				return -EINVAL;
> --
> 2.4.3
>
> _______________________________________________
> dev mailing list
> dev@openvswitch.org
> http://openvswitch.org/mailman/listinfo/dev
>

-- 
Thomas F Herbert Red Hat
