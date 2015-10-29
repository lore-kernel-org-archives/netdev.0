From: Thomas F Herbert <therbert@redhat.com>
Subject: Re: [PATCH net-next V18 3/3] 802.1AD: Flow handling, actions, vlan
 parsing and netlink attributes
Date: Thu, 29 Oct 2015 19:47:15 -0400
Message-ID: <5632B003.7050206@redhat.com>
References: <1445818286-4870-1-git-send-email-thomasfherbert@gmail.com>
 <1445818286-4870-4-git-send-email-thomasfherbert@gmail.com>
 <CALnjE+rcP1trUt2zSSGoUF9r1XwNgtRiLgsS2soejhd4j0zyHQ@mail.gmail.com>
 <562FAA0E.4090908@gmail.com>
 <CALnjE+pBSdjVt0AvyK9ziL_tDEzaxEDEbW_Eqk=cKABi9vFCAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>,
	Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758437AbbJ2XrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 19:47:17 -0400
In-Reply-To: <CALnjE+pBSdjVt0AvyK9ziL_tDEzaxEDEbW_Eqk=cKABi9vFCAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pravin, please look at comment inline below:

On 10/27/15 1:22 PM, Pravin Shelar wrote:
> On Tue, Oct 27, 2015 at 9:45 AM, Thomas F Herbert
> <thomasfherbert@gmail.com> wrote:
>> On 10/26/15 10:10 PM, Pravin Shelar wrote:
>> Thanks for the review.
>>> On Sun, Oct 25, 2015 at 5:11 PM, Thomas F Herbert
>>> <thomasfherbert@gmail.com> wrote:
>>>> Add support for 802.1ad including the ability to push and pop double
>>>> tagged vlans. Add support for 802.1ad to netlink parsing and flow
>>>> conversion. Uses double nested encap attributes to represent double
>>>> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>>>> Outer
>>>> TPID is also encoded in the flow key.
>>>>
>>>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
>>> This patch does not apply on current master due to conflicts related
>>> net-branch merge.
>> OK, I will rebase.
Pravin, I implemented all reviewer comments and completing rebasing to 
latest net-next upstream. The patch works well and flows install 
properly. However, there may be one remaining issue. The vport-dev 
transmit function now calls dev_queue_transmit() directly because it is 
registered as the vport send op. The affect of this is that the vlan mtu 
adjustment code in ovs_netdev_send() that was patched for mtu adjustment 
for single and double tagged vlans is gone.Could you please verify that 
the size adjustment is no longer needed.
>>
>>>> ---
>>>>    net/openvswitch/actions.c      |   6 +-
>>>>    net/openvswitch/flow.c         |  76 ++++++++++++----
>>>>    net/openvswitch/flow.h         |   8 +-
>>>>    net/openvswitch/flow_netlink.c | 199
>>>> +++++++++++++++++++++++++++++++++++++----
>>>>    net/openvswitch/vport-netdev.c |   4 +-
>>>>    5 files changed, 252 insertions(+), 41 deletions(-)
>>>>
>>>> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
>>>> index c8db44a..ed19e2b 100644
>>>> --- a/net/openvswitch/flow.c
>>>> +++ b/net/openvswitch/flow.c
>>>> @@ -302,24 +302,68 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
>>>>                                     sizeof(struct icmp6hdr));
>>>>    }
>>>>
>>>> -static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>>>> +/* Parse vlan tag from vlan header.
>>>> + * Returns ERROR on memory error.
>>>> + * Returns 0 if it encounters a non-vlan or incomplete packet.
>>>> + * Returns 1 after successfully parsing vlan tag.
>>>> + */
>>>> +
>>>> +static int parse_vlan_tag(struct sk_buff *skb, struct vlan_head *vlan)
>>>>    {
>>>> -       struct qtag_prefix {
>>>> -               __be16 eth_type; /* ETH_P_8021Q */
>>>> -               __be16 tci;
>>>> -       };
>>>> -       struct qtag_prefix *qp;
>>>> +       struct vlan_head *qp = (struct vlan_head *)skb->data;
>>>> +
>>>> +       if (likely(!eth_type_vlan(qp->tpid)))
>>>> +               return 0;
>>>>
>>>> -       if (unlikely(skb->len < sizeof(struct qtag_prefix) +
>>>> sizeof(__be16)))
>>>> +       if (unlikely(skb->len < sizeof(struct vlan_head) +
>>>> sizeof(__be16)))
>>>>                   return 0;
>>> Why do we need extra sizeof(__be16) bytes here?
>> I don't have an answer to your question. I didn't write this code and have
>> wondered about why the extra two bytes were reserved. I don't know why it
>> should be necessarily for inner or outer vlans or the HW accelerated case or
>> for the non-accelerated case. If no reviewer can state a case for it, I will
>> remove it with the next version of this patch.
>>
> Looks like it is optimization for parsing ethertype, So lets keep it.
>
>>>>                   } else if (!tci) {
>>>>                           /* Corner case for truncated 802.1Q header. */
>>>>                           if (nla_len(encap)) {
>>>> @@ -1169,7 +1312,7 @@ int ovs_nla_get_match(struct net *net, struct
>>>> sw_flow_match *match,
>>>>                           goto free_newmask;
>>>>
>>>>                   /* Always match on tci. */
>>>> -               SW_FLOW_KEY_PUT(match, eth.tci, htons(0xffff), true);
>>>> +               SW_FLOW_KEY_PUT(match, eth.vlan.tci, htons(0xffff),
>>>> true);
>>> Also need to exact match on inner tci.
>> This code sets a match on tci even if no vlan is present. Is this is for the
>> case where there is no explicit mask specified in the netlink encoded flow?
>> If that is correct, then it does need to be done for the inner vlan too.
> Yes, By default it needs to be matched. userspace can overwrite it
> with different wildcard.

-- 
Thomas F Herbert Red Hat
