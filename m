From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: Re: [PATCH 3/3] 802.1AD: Flow handling, actions, vlan parsing and
 netlink attributes
Date: Tue, 29 Sep 2015 19:52:30 -0400
Message-ID: <560B243E.4090602@gmail.com>
References: <1443117498-19123-1-git-send-email-thomasfherbert@gmail.com>
 <1443117498-19123-4-git-send-email-thomasfherbert@gmail.com>
 <CALnjE+q6s=D2P5+=1U6RsLC8FqhANP5j8MKqzHpuYvpT-eW3_w@mail.gmail.com>
 <5605CC2F.1010700@gmail.com>
 <CALnjE+oqFNGUNHbXgkr8+gWM1TDFSi-jbuL+kggrqZD+AaDK1A@mail.gmail.com>
Reply-To: thomasfherbert@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35892 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbbI2Xwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:52:32 -0400
Received: by qgx61 with SMTP id 61so21314581qgx.3
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 16:52:31 -0700 (PDT)
In-Reply-To: <CALnjE+oqFNGUNHbXgkr8+gWM1TDFSi-jbuL+kggrqZD+AaDK1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/29/15 6:56 PM, Pravin Shelar wrote:
> On Fri, Sep 25, 2015 at 3:35 PM, Thomas F Herbert
> <thomasfherbert@gmail.com> wrote:
>> Pravin,
>>
>> Another comment and question. Please seen inline below.
>>
>> Thanks,
>>
>> --Tom
>>
>> On 9/24/15 7:42 PM, Pravin Shelar wrote:
>>> On Thu, Sep 24, 2015 at 10:58 AM, Thomas F Herbert
>>> <thomasfherbert@gmail.com> wrote:
>>>> Add support for 802.1ad including the ability to push and pop double
>>>> tagged vlans. Add support for 802.1ad to netlink parsing and flow
>>>> conversion. Uses double nested encap attributes to represent double
>>>> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>>>>
>>>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
>>>> ---
>>>>    net/openvswitch/flow.c         |  83 +++++++++++++++++----
>>>>    net/openvswitch/flow.h         |   5 ++
>>>>    net/openvswitch/flow_netlink.c | 166
>>>> ++++++++++++++++++++++++++++++++++++++---
>>>>    3 files changed, 230 insertions(+), 24 deletions(-)
>>>>
> ...
>
>>>> @@ -1320,6 +1437,7 @@ static int __ovs_nla_put_key(const struct
>>>> sw_flow_key *swkey,
>>>>    {
>>>>           struct ovs_key_ethernet *eth_key;
>>>>           struct nlattr *nla, *encap;
>>>> +       struct nlattr *in_encap = NULL;
>>>>
>>>>           if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
>>>>                   goto nla_put_failure;
>>>> @@ -1368,17 +1486,42 @@ static int __ovs_nla_put_key(const struct
>>>> sw_flow_key *swkey,
>>>>           ether_addr_copy(eth_key->eth_src, output->eth.src);
>>>>           ether_addr_copy(eth_key->eth_dst, output->eth.dst);
>>>>
>>>> -       if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
>>>> +       if (swkey->eth.tci || eth_type_vlan(swkey->eth.type)) {
>>>>                   __be16 eth_type;
>>>> -               eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
>>>> +
>>>> +               if (swkey->eth.cvlan.ctci ||
>>>> +                   eth_type_vlan(swkey->eth.cvlan.c_tpid))
>>>> +                       eth_type = !is_mask ? htons(ETH_P_8021AD) :
>>>> +                                             htons(0xffff);
>>>> +               else
>>>> +                       eth_type = !is_mask ? htons(ETH_P_8021Q) :
>>>> +                                             htons(0xffff);
>>>> +
>>> Here we can directly dump output->eth.type to netlink. No need to
>>> check for inner encap.
>> The eth.type is set to the inner encapsulated protocol not to the tpid. We
>> don't "know" what the outer tpid so I assume it is 802.1Q. To address this
>> situation, do you think I should add the outer tpid to sw_flow_key?
>> Also see comment above in flow.h.
>>
> With the addition of nested vlan, we need to add outer tpid. This will
> simplify vlan netlink serialization too.
Yes, thanks. I agree that this is the sensible approach.
