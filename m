From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH v2 net-next 2/2] openvswitch: Fix skb->protocol for vlan frames.
Date: Tue, 29 Nov 2016 15:32:50 -0800
Message-ID: <8D71D8D7-9C09-4833-AF25-3110E7927186@ovn.org>
References: <1480387276-123557-1-git-send-email-jarno@ovn.org> <1480387276-123557-2-git-send-email-jarno@ovn.org> <CAOrHB_B15uBYL-nVhsCoRKzZ1Akmn0ZDcee57VUXGAjMNEAAWQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34473 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755059AbcK2Xcx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 18:32:53 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so9007750pfb.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 15:32:52 -0800 (PST)
In-Reply-To: <CAOrHB_B15uBYL-nVhsCoRKzZ1Akmn0ZDcee57VUXGAjMNEAAWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Nov 28, 2016, at 11:21 PM, Pravin Shelar <pshelar@ovn.org> wrote:
> 
> On Mon, Nov 28, 2016 at 6:41 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
>> Do not set skb->protocol to be the ethertype of the L3 header, unless
>> the packet only has the L3 header.  For a non-hardware offloaded VLAN
>> frame skb->protocol needs to be one of the VLAN ethertypes.
>> 
>> Any VLAN offloading is undone on the OVS netlink interface.  Also any
>> VLAN tags added by userspace are non-offloaded.
>> 
>> Incorrect skb->protocol value on a full-size non-offloaded VLAN skb
>> causes packet drop due to failing MTU check, as the VLAN header should
>> not be counted in when considering MTU in ovs_vport_send().
>> 
> I think we should move to is_skb_forwardable() type of packet length
> check in vport-send and get rid of skb-protocol checks altogether.
> 

I added a new patch to do this, thanks for the suggestion.

>> Fixes: 5108bbaddc ("openvswitch: add processing of L3 packets")
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
>> ---
>> v2: Set skb->protocol when an ETH_P_TEB frame is received via ARPHRD_NONE
>>    interface.
>> 
>> net/openvswitch/datapath.c |  1 -
>> net/openvswitch/flow.c     | 30 ++++++++++++++++++++++--------
>> 2 files changed, 22 insertions(+), 9 deletions(-)
> ...
> ...
>> @@ -531,15 +538,22 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>>                if (unlikely(parse_vlan(skb, key)))
>>                        return -ENOMEM;
>> 
>> -               skb->protocol = parse_ethertype(skb);
>> -               if (unlikely(skb->protocol == htons(0)))
>> +               key->eth.type = parse_ethertype(skb);
>> +               if (unlikely(key->eth.type == htons(0)))
>>                        return -ENOMEM;
>> 
>> +               if (skb->protocol == htons(ETH_P_TEB)) {
>> +                       if (key->eth.vlan.tci & htons(VLAN_TAG_PRESENT)
>> +                           && !skb_vlan_tag_present(skb))
>> +                               skb->protocol = key->eth.vlan.tpid;
>> +                       else
>> +                               skb->protocol = key->eth.type;
>> +               }
>> +
> 
> I am not sure if this work in case of nested vlans.
> Can we move skb-protocol assignment to parse_vlan() to avoid checking
> for non-accelerated vlan case again here?

I did this for the v3 that I sent out a moment ago.

Thanks for the review,

  Jarno
