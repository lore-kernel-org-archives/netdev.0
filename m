From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: Re: [PATCH net-next V16 3/3] openvswitch: 802.1AD: Flow handling,
 actions, vlan parsing and netlink attributes
Date: Thu, 15 Oct 2015 22:03:25 -0400
Message-ID: <56205AED.5030802@gmail.com>
References: <1444917715-27093-1-git-send-email-thomasfherbert@gmail.com>
 <1444917715-27093-4-git-send-email-thomasfherbert@gmail.com>
 <CALnjE+o4o1RWf12F9wyeZfb9=Y+nw+Bta=NA+we1zQ+4yGLYNA@mail.gmail.com>
 <56203B38.2040806@gmail.com>
 <CALnjE+p8A-NDJj8UnALHVvyT=a0Uq=AftVu5duRXdbBLOsVeeA@mail.gmail.com>
Reply-To: thomasfherbert@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:36047 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbbJPCD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 22:03:27 -0400
Received: by ykdt21 with SMTP id t21so35254756ykd.3
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 19:03:27 -0700 (PDT)
In-Reply-To: <CALnjE+p8A-NDJj8UnALHVvyT=a0Uq=AftVu5duRXdbBLOsVeeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/15 8:37 PM, Pravin Shelar wrote:
> On Thu, Oct 15, 2015 at 4:48 PM, Thomas F Herbert
> <thomasfherbert@gmail.com> wrote:
>> On 10/15/15 7:02 PM, Pravin Shelar wrote:
>> Thanks for the review. See my comment below.
>>
>> --TFH
>>
>>
>>> On Thu, Oct 15, 2015 at 7:01 AM, Thomas F Herbert
>>> <thomasfherbert@gmail.com> wrote:
>>>> Add support for 802.1ad including the ability to push and pop double
>>>> tagged vlans. Add support for 802.1ad to netlink parsing and flow
>>>> conversion. Uses double nested encap attributes to represent double
>>>> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>>>>
>>>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
>>>> ---
>>>>    net/openvswitch/actions.c      |   6 +-
>>>>    net/openvswitch/flow.c         |  75 ++++++++++++++----
>>>>    net/openvswitch/flow.h         |   8 +-
>>>>    net/openvswitch/flow_netlink.c | 169
>>>> +++++++++++++++++++++++++++++++++++++----
>>>>    net/openvswitch/vport-netdev.c |   4 +-
>>>>    5 files changed, 228 insertions(+), 34 deletions(-)
>>>>
>>>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>>>> index 315f533..09cc1c9 100644
>>>> --- a/net/openvswitch/actions.c
>>>> +++ b/net/openvswitch/actions.c
>>>> @@ -236,7 +236,8 @@ static int pop_vlan(struct sk_buff *skb, struct
>>>> sw_flow_key *key)
>>>>           if (skb_vlan_tag_present(skb))
>>>>                   invalidate_flow_key(key);
>>>>           else
>>>> -               key->eth.tci = 0;
>>>> +               key->eth.vlan.tci = 0;
>>>> +               key->eth.vlan.tpid = 0;
>>>>           return err;
>>>>    }
>>>>
>>>> @@ -246,7 +247,8 @@ static int push_vlan(struct sk_buff *skb, struct
>>>> sw_flow_key *key,
>>>>           if (skb_vlan_tag_present(skb))
>>>>                   invalidate_flow_key(key);
>>>>           else
>>>> -               key->eth.tci = vlan->vlan_tci;
>>>> +               key->eth.vlan.tci = vlan->vlan_tci;
>>>> +               key->eth.vlan.tpid = vlan->vlan_tpid;
>>>>           return skb_vlan_push(skb, vlan->vlan_tpid,
>>>>                                ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
>>>>    }
>>>> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
>>>> index c8db44a..8a4e298 100644
>>>> --- a/net/openvswitch/flow.c
>>>> +++ b/net/openvswitch/flow.c
>>>> @@ -302,24 +302,69 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
>>>>                                     sizeof(struct icmp6hdr));
>>>>    }
>>>>
>>>> -static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>>>> +struct qtag_prefix {
>>>> +       __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>>>> +       __be16 tci;
>>>> +};
>>>> +
>>> Now we can just use newly defined struct vlan_header here.
>>>
>>>> +/* Parse vlan tag from vlan header.
>>>> + * Returns ERROR on memory error.
>>>> + * Returns 0 if it encounters a non-vlan or incomplete packet.
>>>> + * Returns 1 after successfully parsing vlan tag.
>>>> + */
>>>> +
>>>> +static int parse_vlan_tag(struct sk_buff *skb, __be16 vlan_proto,
>>>> +                         __be16 vlan_tci, struct vlan_head *vlan)
>>>>    {
>>>> -       struct qtag_prefix {
>>>> -               __be16 eth_type; /* ETH_P_8021Q */
>>>> -               __be16 tci;
>>>> -       };
>>>> -       struct qtag_prefix *qp;
>>>> +       if (likely(!eth_type_vlan(vlan_proto)))
>>>> +               return 0;
>>>>
>>>>           if (unlikely(skb->len < sizeof(struct qtag_prefix) +
>>>> sizeof(__be16)))
>>>>                   return 0;
>>>>
>>>>           if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
>>>> -                                        sizeof(__be16))))
>>>> +                                sizeof(__be16))))
>>>>                   return -ENOMEM;
>>>>
>>>> -       qp = (struct qtag_prefix *) skb->data;
>>>> -       key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
>>>> +       vlan->tci = vlan_tci | htons(VLAN_TAG_PRESENT);
>>>> +       vlan->tpid = vlan_proto;
>>>> +
>>>>           __skb_pull(skb, sizeof(struct qtag_prefix));
>>>> +       return 1;
>>>> +}
>>>> +
>>>> +static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>>>> +{
>>>> +       struct qtag_prefix *qp = (struct qtag_prefix *)skb->data;
>>>> +       int res;
>>>> +
>>>> +       if (likely(skb_vlan_tag_present(skb))) {
>>>> +               key->eth.vlan.tci = htons(skb->vlan_tci);
>>>> +               key->eth.vlan.tpid = skb->vlan_proto;
>>>> +
>>>> +               /* Case where ingress processing has already stripped
>>>> +                * the outer vlan tag.
>>>> +                */
>>>> +               res = parse_vlan_tag(skb, qp->eth_type, qp->tci,
>>>> +                                    &key->eth.cvlan);
>>>> +               if (res < 0)
>>>> +                       return res;
>>>> +               /* For inner tag, return 0 because neither
>>>> +                * non-existant nor partial inner tag is an error.
>>>> +                */
>>>> +               return 0;
>>>> +       }
>>>> +       res = parse_vlan_tag(skb, qp->eth_type, qp->tci, &key->eth.vlan);
>>>> +       if (res <= 0)
>>>> +               /* This is an outer tag in the non-accelerated VLAN
>>>> +                * case. Return error unless it is a complete vlan tag.
>>>> +                */
>>>> +               return res;
>>>> +
>>>> +       /* Parse inner vlan tag if present for non-accelerated case. */
>>>> +       res = parse_vlan_tag(skb, qp->eth_type, qp->tci,
>>>> &key->eth.cvlan);
>>>> +       if (res <= 0)
>>>> +               return res;
>>>>
>>> same qp pointer is passed for inner and outer vlan parameters here. It
>>> is better to just pass skb and keep qp inside parse_vlan_tag()
>>> function.
>>>
>>>>           return 0;
>>>>    }
>>>> @@ -480,12 +525,12 @@ static int key_extract(struct sk_buff *skb, struct
>>>> sw_flow_key *key)
>>>>            * update skb->csum here.
>>>>            */
>>>>
>>>> -       key->eth.tci = 0;
>>>> -       if (skb_vlan_tag_present(skb))
>>>> -               key->eth.tci = htons(skb->vlan_tci);
>>>> -       else if (eth->h_proto == htons(ETH_P_8021Q))
>>>> -               if (unlikely(parse_vlan(skb, key)))
>>>> -                       return -ENOMEM;
>>>> +       key->eth.vlan.tci = 0;
>>>> +       key->eth.vlan.tpid = 0;
>>>> +       key->eth.cvlan.tci = 0;
>>>> +       key->eth.cvlan.tpid = 0;
>>> Lets move this over to parse_vlan().
>>>
>>>> +       if (unlikely(parse_vlan(skb, key)))
>>>> +               return -ENOMEM;
>>>>
>>>>           key->eth.type = parse_ethertype(skb);
>>>>           if (unlikely(key->eth.type == htons(0)))
>>>> diff --git a/net/openvswitch/flow_netlink.c
>>>> b/net/openvswitch/flow_netlink.c
>>>> index c92d6a2..5cff83c 100644
>>>> --- a/net/openvswitch/flow_netlink.c
>>>> +++ b/net/openvswitch/flow_netlink.c
>>> ...
>>>
>>>
>>>>    static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match
>>>> *match,
>>>>                                   u64 attrs, const struct nlattr **a,
>>>>                                   bool is_mask, bool log)
>>>> @@ -845,7 +875,7 @@ static int ovs_key_from_nlattrs(struct net *net,
>>>> struct sw_flow_match *match,
>>>>                           return -EINVAL;
>>>>                   }
>>>>
>>>> -               SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
>>>> +               SW_FLOW_KEY_PUT(match, eth.vlan.tci, tci, is_mask);
>>>>                   attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
>>>>           }
>>>>
>>>> @@ -1064,6 +1094,86 @@ static void mask_set_nlattr(struct nlattr *attr,
>>>> u8 val)
>>>>           nlattr_set(attr, val, ovs_key_lens);
>>>>    }
>>>>
>>>> +static int parse_vlan_from_nlattrs(const struct nlattr **nla,
>>>> +                                  struct sw_flow_match *match,
>>>> +                                  u64 *key_attrs, bool *ie_valid,
>>>> +                                  const struct nlattr **a, bool is_mask,
>>>> +                                  bool log)
>>>> +{
>>>> +       int err;
>>>> +       const struct nlattr *encap;
>>>> +
>>>> +       if (!is_mask) {
>>>> +               u64 v_attrs = 0;
>>>> +
>>> attributes does not need 64 bits, 32 bits are sufficient.
>> Yes, there certainly not more then 32 attributes in this layer of nesting
>> but in the parse_flow_nlattrs()  function argument 3 is a u64 *
>> Don't you think this might be dangerous? Maybe are you saying that I should
>> rewrite that generic function to only support a maximum of 32 netlink
>> attributes per level of nesting. The current OVS kernel module is optimized
>> for 64 bit architectures where there is no extra cost for a 64 bit value and
>> I think what you are suggesting might go beyond the scope of this patch. If
>> it is a good idea, shouldn't it be considered for a separate patch?
>>
> OK. Lets keep it as it is.
>
>> --TFH
>>>> +               err = parse_flow_nlattrs(*nla, a, &v_attrs, log);
>>>> +               if (err)
>>>> +                       return err;
>>>> +               /* Another encap attribute here indicates
>>>> +                * the presence of a double tagged vlan.
>>>> +                */
>>>> +               if ((v_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
>>>> +
>>>> eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
>>>> +                       if (!((v_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) &&
>>>> +                             (v_attrs & (1ULL << OVS_KEY_ATTR_ENCAP))))
>>>> {
>>> After changing v_attrs type, there is no need to use 1ULL.
>> See remark above.
>>
> Just to be consistent, lets use 32 bit value of one here and other
> such instances.
OK, I agree. The 1ULL is not necessary in my opinion.
