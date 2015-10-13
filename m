From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V15 3/3] 802.1AD: Flow handling, actions, vlan
 parsing and netlink attributes
Date: Tue, 13 Oct 2015 11:14:05 -0700
Message-ID: <CALnjE+rFgnRZ0awed1eox62zEeFKaCXoAucv6wS4MVBFK_RLRA@mail.gmail.com>
References: <1444520433-1958-1-git-send-email-thomasfherbert@gmail.com>
	<1444520433-1958-4-git-send-email-thomasfherbert@gmail.com>
	<CALnjE+qdqBrzZ_p6RCHLr63tSWTKPnTWhQuWsJ8dvAmq-bf9rQ@mail.gmail.com>
	<561D41BA.7030300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33369 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270AbbJMSOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 14:14:10 -0400
Received: by igbkq10 with SMTP id kq10so96476676igb.0
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 11:14:10 -0700 (PDT)
In-Reply-To: <561D41BA.7030300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2015 at 10:39 AM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> Pravin,
>
> Thanks for the review.
>
>
> On 10/13/15 7:47 AM, Pravin Shelar wrote:
>>
>> On Sat, Oct 10, 2015 at 4:40 PM, Thomas F Herbert
>> <thomasfherbert@gmail.com> wrote:
>>>
>>> Add support for 802.1ad including the ability to push and pop double
>>> tagged vlans. Add support for 802.1ad to netlink parsing and flow
>>> conversion. Uses double nested encap attributes to represent double
>>> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>>>
>>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
>>> ---
>>>   net/openvswitch/actions.c      |   6 +-
>>>   net/openvswitch/flow.c         |  92 +++++++++++++++++++----
>>>   net/openvswitch/flow.h         |  11 ++-
>>>   net/openvswitch/flow_netlink.c | 166
>>> +++++++++++++++++++++++++++++++++++++----
>>>   net/openvswitch/vport-netdev.c |   4 +-
>>>   5 files changed, 245 insertions(+), 34 deletions(-)
>>>
>> ...
>>
...

>>
>> I see lot of duplicate code here. How about code below:
>>
>> struct qtag_prefix {
>>          __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>>          __be16 tci;
>> };
>>
>> /* Return  < 0 on memory error
>>   * Return   == 0 on non vlan or incomplete packet packet
>>   * Return > 0 on successfully parsing vlan tag.
>>   */
>> static int parse_vlan_tag(__be16 vlan_proto, struct sk_buff *skb,
>>                            struct vlan_tag *cvlan)
>> {
>>          if (likely(!eth_type_vlan(skb->vlan_proto)))
>>                  return 0;
>>
>>          if (unlikely(skb->len < sizeof(struct qtag_prefix) +
>> sizeof(__be16))) {
>>                  vlan->tci = 0;
>>                  return 0;
>>          }
>>
>>          if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
>> sizeof(__be16))))
>>                          return -ENOMEM;
>>
>>          qp = (struct qtag_prefix *)skb->data;
>>          key->eth.cvlan.tci = qp->tci | htons(VLAN_TAG_PRESENT);
>>          key->eth.cvlan.tpid = qp->eth_type;
>>
>>          __skb_pull(skb, sizeof(struct qtag_prefix));
>>          return 1;
>> }
>
> This makes for cleaner code and certainly better for maintainability so I
> have just implemented it for this next revision. However, note that with
> this change, we incur the overhead of an additional function call for single
> tagged vlan packets.
>
If there is any performance issue we can fix the code later.

>>
>> static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>> {
>>          struct qtag_prefix *qp = (struct qtag_prefix *)skb->data;
...

>>> +               u64 mask_v_attrs = 0;
>>> +
>>> +               err = parse_flow_mask_nlattrs(*nla, a, &mask_v_attrs,
>>> log);
>>> +               if (err)
>>> +                       return err;
>>> +
>>> +               if (mask_v_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
>>> +                       if (!*ie_valid) {
>>> +                               OVS_NLERR(log, "Encap mask attribute is
>>> set for non-CVLAN frame.");
>>> +                               err = -EINVAL;
>>> +                               return err;
>>> +                       }
>>> +                       encap = a[OVS_KEY_ATTR_ENCAP];
>>> +
>>> +                       err = cust_vlan_from_nlattrs(match, a, is_mask,
>>> log);
>>> +                       if (err)
>>> +                               return err;
>>> +                       *nla = encap;
>>> +
>>
>> There is no checking for ATTR_VLAN or ATTR_ETHERTYPE. This can result
>> in null pointer deference in cust_vlan_from_nlattrs().
>
> The original vlan code does not check for these attribs in the masked case.
> It does check for them in the non-masked case and then sets a boolean and
> checks it in the masked case. I do the same thing for the inner vlan. I
> check for the attributes in the non-masked case and set a boolean and check
> the boolean in the masked case. Why is this not sufficient?

Original code is checking for attributes before referencing them. For
example  in function ovs_nla_get_match() before extracting eth_type,
it does check a[OVS_KEY_ATTR_ETHERTYPE]. But If you spot bug in
current code please send fix for net tree.
Regarding the Boolean, it is for presence of inner vlan for key
attribute, mask attribute still could be missing vlan attribute.
For vlan mask, we can keep check sanity check as outer vlan. It means
eth_type must be specified and should be 0xffff, and tci mask is
optional and by default initialized to 0xffff.
