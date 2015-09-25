From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: Re: [PATCH 3/3] 802.1AD: Flow handling, actions, vlan parsing and
 netlink attributes
Date: Fri, 25 Sep 2015 15:18:59 -0400
Message-ID: <56059E23.3010201@gmail.com>
References: <1443117498-19123-1-git-send-email-thomasfherbert@gmail.com>
 <1443117498-19123-4-git-send-email-thomasfherbert@gmail.com>
 <CALnjE+q6s=D2P5+=1U6RsLC8FqhANP5j8MKqzHpuYvpT-eW3_w@mail.gmail.com>
Reply-To: thomasfherbert@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:35923 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932955AbbIYTTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 15:19:03 -0400
Received: by qgx61 with SMTP id 61so77484514qgx.3
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 12:19:01 -0700 (PDT)
In-Reply-To: <CALnjE+q6s=D2P5+=1U6RsLC8FqhANP5j8MKqzHpuYvpT-eW3_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pravin,

Thanks for the review,

Comments in line below.

--TFH

On 9/24/15 7:42 PM, Pravin Shelar wrote:
> On Thu, Sep 24, 2015 at 10:58 AM, Thomas F Herbert
> <thomasfherbert@gmail.com> wrote:
>> Add support for 802.1ad including the ability to push and pop double
>> tagged vlans. Add support for 802.1ad to netlink parsing and flow
>> conversion. Uses double nested encap attributes to represent double
>> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>>
>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
>> ---
>>   net/openvswitch/flow.c         |  83 +++++++++++++++++----
>>   net/openvswitch/flow.h         |   5 ++
>>   net/openvswitch/flow_netlink.c | 166 ++++++++++++++++++++++++++++++++++++++---
>>   3 files changed, 230 insertions(+), 24 deletions(-)
>>
>> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
>> index c8db44a..db58e47 100644
>> --- a/net/openvswitch/flow.c
>> +++ b/net/openvswitch/flow.c
>> @@ -305,21 +305,77 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
>>   static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>>   {
>>          struct qtag_prefix {
>> -               __be16 eth_type; /* ETH_P_8021Q */
>> +               __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>>                  __be16 tci;
>>          };
>> -       struct qtag_prefix *qp;
>> +       struct qtag_prefix *qp = (struct qtag_prefix *)skb->data;
>>
>> -       if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
>> +       struct qinqtag_prefix {
>> +               __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>> +               __be16 tci;
>> +               __be16 inner_tpid; /* ETH_P_8021Q */
>> +               __be16 ctci;
>> +       };
>> +
>> +       if (likely(skb_vlan_tag_present(skb))) {
>> +               key->eth.tci = htons(skb->vlan_tci);
>> +
>> +               /* Case where upstream
>> +                * processing has already stripped the outer vlan tag.
>> +                */
>> +               if (unlikely(skb->vlan_proto == htons(ETH_P_8021AD))) {
>> +                       if (unlikely(skb->len < sizeof(struct qtag_prefix) +
>> +                                       sizeof(__be16))) {
>> +                               key->eth.tci = 0;
>> +                               return 0;
>> +                       }
>> +
>> +                       if (unlikely(!pskb_may_pull(skb,
>> +                                                   sizeof(struct qtag_prefix) +
>> +                                                   sizeof(__be16))))
>> +                               return -ENOMEM;
>> +
> qp pointer is no longer valid after pskb_may_pull() call.
>
>> +                       key->eth.cvlan.ctci =
>> +                               qp->tci | htons(VLAN_TAG_PRESENT);
>> +                       key->eth.cvlan.c_tpid = qp->eth_type;
>> +
>> +                       __skb_pull(skb, sizeof(struct qtag_prefix));
>> +               }
>>                  return 0;
>> +       }
>>
>> -       if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
>> -                                        sizeof(__be16))))
>> -               return -ENOMEM;
>>
>> -       qp = (struct qtag_prefix *) skb->data;
>> -       key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
>> -       __skb_pull(skb, sizeof(struct qtag_prefix));
>
> qp access is done without skb_may_pull() call.
>> +       if (qp->eth_type == htons(ETH_P_8021AD)) {
>> +               struct qinqtag_prefix *qinqp =
>> +                                       (struct qinqtag_prefix *)skb->data;
>> +
>> +               if (unlikely(skb->len < sizeof(struct qinqtag_prefix) +
>> +                                       sizeof(__be16)))
>> +                       return 0;
>> +
>> +               if (unlikely(!pskb_may_pull(skb, sizeof(struct qinqtag_prefix) +
>> +                               sizeof(__be16))))
>> +                       return -ENOMEM;
>
> same as above qinqp pointer is not valid after psk_may_pull().
>
>> +               key->eth.tci = qinqp->tci | htons(VLAN_TAG_PRESENT);
>> +               key->eth.cvlan.ctci = qinqp->ctci | htons(VLAN_TAG_PRESENT);
>> +               key->eth.cvlan.c_tpid = qinqp->inner_tpid;
>> +
>> +               __skb_pull(skb, sizeof(struct qinqtag_prefix));
>> +
>> +               return 0;
>> +       }
>> +       if (qp->eth_type == htons(ETH_P_8021Q)) {
>> +               if (unlikely(skb->len < sizeof(struct qtag_prefix) +
>> +                                       sizeof(__be16)))
>> +                       return -ENOMEM;
>> +
>> +               if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
>> +                               sizeof(__be16))))
>> +                       return 0;
> same issue as above.
>
>> +               key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
>> +
>> +               __skb_pull(skb, sizeof(struct qtag_prefix));
>> +       }
>>
>>          return 0;
>>   }
> ...
>
>> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
>> index fe527d2..2c491e8 100644
>> --- a/net/openvswitch/flow.h
>> +++ b/net/openvswitch/flow.h
>> @@ -69,6 +69,11 @@ struct sw_flow_key {
>>                  u8     src[ETH_ALEN];   /* Ethernet source address. */
>>                  u8     dst[ETH_ALEN];   /* Ethernet destination address. */
>>                  __be16 tci;             /* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
>> +               struct {
>> +                       __be16 c_tpid;  /* Vlan DL_type 802.1q or 802.1ad */
>> +                       __be16 ctci;    /* 0 if no CVLAN, VLAN_TAG_PRESENT */
> Lets call c_tpid type and ctci tci, to keep naming consistent with outer vlan.
>> +                                       /* set otherwise. */
>> +               } cvlan;
>>                  __be16 type;            /* Ethernet frame type. */
>>          } eth;
>>          union {
>> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
>> index c92d6a2..5fe415d 100644
>> --- a/net/openvswitch/flow_netlink.c
>> +++ b/net/openvswitch/flow_netlink.c
> ...
>
>> @@ -1064,6 +1085,80 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
>>          nlattr_set(attr, val, ovs_key_lens);
>>   }
>>
>> +static int parse_vlan_from_nlattrs(const struct nlattr **nla,
>> +                                  struct sw_flow_match *match,
>> +                                  u64 *key_attrs, bool *ie_valid,
>> +                                  const struct nlattr **a, bool is_mask,
>> +                                  bool log)
>> +{
>> +       int err;
>> +       const struct nlattr *encap;
>> +
>> +       *ie_valid = false;
>> +       if (!is_mask) {
>> +               u64 v_attrs = 0;
>> +
>> +               err = parse_flow_nlattrs(*nla, a, &v_attrs, log);
>> +               if (err)
>> +                       return err;
>> +               /* Another encap attribute here indicates
>> +                * the presence of a double tagged vlan.
>> +                */
>> +               if ((v_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
>> +                   eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
>> +                       if (!((v_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) &&
>> +                             (v_attrs & (1ULL << OVS_KEY_ATTR_ENCAP)))) {
>> +                               OVS_NLERR(log, "Invalid Inner VLAN frame");
>> +                               return -EINVAL;
>> +                       }
>> +                       encap = a[OVS_KEY_ATTR_ENCAP];
>> +                       v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
>> +
>> +                       err = cust_vlan_from_nlattrs(match, a, is_mask, log);
>> +                       if (err)
>> +                               return err;
>> +                       *ie_valid = true;
>> +                       *nla = encap;
>> +
>> +                       /* Insure that tci key attribute isn't
>> +                        * overwritten by encapsulated customer tci.
>> +                        * Ethertype is cleared because it is c_tpid.
>> +                        */
>> +                       v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
>> +                       v_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
>> +               }
>> +               *key_attrs |= v_attrs;
>> +
>> +       } else {
>> +               u64 mask_v_attrs = 0;
>> +
>> +               err = parse_flow_mask_nlattrs(*nla, a, &mask_v_attrs, log);
>> +               if (err)
>> +                       return err;
>> +
>> +               if (mask_v_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
>> +                       if (!*ie_valid) {
>> +                               OVS_NLERR(log, "Encap mask attribute is set for non-CVLAN frame.");
>> +                               err = -EINVAL;
> No need to set err it is not read again.
Pravin, thanks for your review.

err is set so the caller knows to has to free the new mask if one was 
created. With the change you suggested below, calling 
parse_flow_nlattrs() from this function, this return won't be necessary 
anyway.
>
>> +                               return err;
>> +                       }
> At the beginning of this same function ie_valid is set to false. So
> this case always return error resulting failure in flow install. This
> make me wonder if you ever tested this code with multiple encap
> traffic.
Yes, you are correct. ie_valid is initialized already in parent 
function. I have tested with double tagged and single tagged traffic. I 
don't know why the Encap mask error didn't show up with this version of 
the patch. I will verify that mask attribute is initialized correctly 
before this function is called.
>
>> +                       encap = a[OVS_KEY_ATTR_ENCAP];
>> +                       mask_v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
>> +
>> +                       err = cust_vlan_from_nlattrs(match, a, is_mask, log);
>> +                       if (err)
>> +                               return err;
>> +                       *nla = encap;
>> +
>> +                       mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_VLAN);
>> +                       mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_ETHERTYPE);
>> +               }
>> +
>> +               *key_attrs |= mask_v_attrs;
>> +       }
>> +       return 0;
>> +}
>> +
>>   /**
>>    * ovs_nla_get_match - parses Netlink attributes into a flow key and
>>    * mask. In case the 'mask' is NULL, the flow is treated as exact match
>> @@ -1091,6 +1186,7 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
>>          u64 key_attrs = 0;
>>          u64 mask_attrs = 0;
>>          bool encap_valid = false;
>> +       bool i_encap_valid = false;
>>          int err;
>>
>>          err = parse_flow_nlattrs(nla_key, a, &key_attrs, log);
>> @@ -1099,11 +1195,11 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
>>
>>          if ((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
>>              (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
>> -           (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q))) {
>> +           eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
>>                  __be16 tci;
>>
>> -               if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
>> -                     (key_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
>> +               if (!((key_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) &&
>> +                     (key_attrs & (1ULL << OVS_KEY_ATTR_ENCAP)))) {
>>                          OVS_NLERR(log, "Invalid Vlan frame.");
>>                          return -EINVAL;
>>                  }
>> @@ -1115,9 +1211,19 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
>>                  encap_valid = true;
>>
>>                  if (tci & htons(VLAN_TAG_PRESENT)) {
>> -                       err = parse_flow_nlattrs(encap, a, &key_attrs, log);
>> +                       err = parse_vlan_from_nlattrs(&encap, match, &key_attrs,
>> +                                                     &i_encap_valid, a, false,
>> +                                                     log);
>>                          if (err)
>>                                  return err;
>> +
>> +                       if (i_encap_valid) {
>> +                               err = parse_flow_nlattrs(encap, a,
>> +                                                        &key_attrs,
>> +                                                        log);
>> +                               if (err)
>> +                                       return err;
>> +                       }
> Can you call this function from parse_vlan_from_nlattrs()? This will
> eliminate following call site too.
>
>>                  } else if (!tci) {
>>                          /* Corner case for truncated 802.1Q header. */
>>                          if (nla_len(encap)) {
>> @@ -1188,10 +1294,21 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
>>                          if (eth_type == htons(0xffff)) {
>>                                  mask_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
>>                                  encap = a[OVS_KEY_ATTR_ENCAP];
>> -                               err = parse_flow_mask_nlattrs(encap, a,
>> -                                                             &mask_attrs, log);
>> +                               err = parse_vlan_from_nlattrs(&encap, match,
>> +                                                             &mask_attrs,
>> +                                                             &i_encap_valid,
>> +                                                             a, true, log);
>>                                  if (err)
>>                                          goto free_newmask;
>> +
>> +                               if (i_encap_valid) {
>> +                                       err =
>> +                                           parse_flow_mask_nlattrs(encap, a,
>> +                                                                   &mask_attrs,
>> +                                                                   log);
>> +                                       if (err)
>> +                                               goto free_newmask;
>> +                               }
>>                          } else {
>>                                  OVS_NLERR(log, "VLAN frames must have an exact match on the TPID (mask=%x).",
>>                                            ntohs(eth_type));
>> @@ -1320,6 +1437,7 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>>   {
>>          struct ovs_key_ethernet *eth_key;
>>          struct nlattr *nla, *encap;
>> +       struct nlattr *in_encap = NULL;
>>
>>          if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
>>                  goto nla_put_failure;
>> @@ -1368,17 +1486,42 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>>          ether_addr_copy(eth_key->eth_src, output->eth.src);
>>          ether_addr_copy(eth_key->eth_dst, output->eth.dst);
>>
>> -       if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
>> +       if (swkey->eth.tci || eth_type_vlan(swkey->eth.type)) {
>>                  __be16 eth_type;
>> -               eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
>> +
>> +               if (swkey->eth.cvlan.ctci ||
>> +                   eth_type_vlan(swkey->eth.cvlan.c_tpid))
>> +                       eth_type = !is_mask ? htons(ETH_P_8021AD) :
>> +                                             htons(0xffff);
>> +               else
>> +                       eth_type = !is_mask ? htons(ETH_P_8021Q) :
>> +                                             htons(0xffff);
>> +
> Here we can directly dump output->eth.type to netlink. No need to
> check for inner encap.
>
>>                  if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
>>                      nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
>>                          goto nla_put_failure;
>>                  encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
>>                  if (!swkey->eth.tci)
>>                          goto unencap;
>> -       } else
>> +               if (swkey->eth.cvlan.ctci || eth_type_vlan(swkey->eth.type)) {
>> +                       __be16 eth_type;
>> +
>> +                       /* Customer tci is nested but uses same key attribute.
>> +                        */
>> +                       eth_type = !is_mask ? htons(ETH_P_8021Q) :
>> +                                             htons(0xffff);
>
> We can just dump eth_type from output key into netlink attribute
> rather than deriving it from other values.
>
>> +                       if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
>> +                                        eth_type) ||
>> +                           nla_put_be16(skb, OVS_KEY_ATTR_VLAN,
>> +                                        output->eth.cvlan.ctci))
>> +                               goto nla_put_failure;
>> +                       in_encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
>> +                       if (!swkey->eth.cvlan.ctci)
>> +                               goto unencap;
>> +               }
>> +       } else {
>>                  encap = NULL;
>> +       }
>>
>>          if (swkey->eth.type == htons(ETH_P_802_2)) {
>>                  /*
>> @@ -1525,6 +1668,8 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>>   unencap:
>>          if (encap)
>>                  nla_nest_end(skb, encap);
>> +       if (in_encap)
>> +               nla_nest_end(skb, in_encap);
>>
>>          return 0;
>>
>> @@ -2174,7 +2319,8 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
>>
>>                  case OVS_ACTION_ATTR_PUSH_VLAN:
>>                          vlan = nla_data(a);
>> -                       if (vlan->vlan_tpid != htons(ETH_P_8021Q))
>> +                       if ((vlan->vlan_tpid != htons(ETH_P_8021Q)) &&
>> +                           (vlan->vlan_tpid != htons(ETH_P_8021AD)))
>>                                  return -EINVAL;
>
> This is open coded negative eth_type_vlan() function.
>
> You also need to update packet_length() in vport-netdev.c
>
