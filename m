From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: Re: [PATCH net-next V17 3/3] 802.1AD: Flow handling, actions, vlan
 parsing and netlink attributes
Date: Fri, 23 Oct 2015 15:42:46 -0400
Message-ID: <562A8DB6.8000006@gmail.com>
References: <1445130748-27671-1-git-send-email-thomasfherbert@gmail.com>
 <1445130748-27671-4-git-send-email-thomasfherbert@gmail.com>
 <CALnjE+p1NdBmSZiGoNHw1C_u+D7s1o=7U68WHpx=5t+PQB=92g@mail.gmail.com>
 <56264F12.1050004@gmail.com>
 <CALnjE+rjNNwvuRRa2hktwHukTvnTx=AC4PegiAvwOT9UGtZKFw@mail.gmail.com>
 <5627A3A9.5010708@redhat.com>
 <CALnjE+puu=KCFPjYXQv=HyNpmVuisKCTNFxXz9eN_=VU9O7JeA@mail.gmail.com>
Reply-To: thomasfherbert@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>,
	Thomas F Herbert <therbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:36626 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbbJWTms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 15:42:48 -0400
Received: by qgad10 with SMTP id d10so75018342qga.3
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 12:42:48 -0700 (PDT)
In-Reply-To: <CALnjE+puu=KCFPjYXQv=HyNpmVuisKCTNFxXz9eN_=VU9O7JeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/15 3:26 PM, Pravin Shelar wrote:
> On Wed, Oct 21, 2015 at 7:39 AM, Thomas F Herbert <therbert@redhat.com> wrote:
>>
>> On 10/20/15 4:34 PM, Pravin Shelar wrote:
>>> On Tue, Oct 20, 2015 at 7:26 AM, Thomas F Herbert
>>> <thomasfherbert@gmail.com>  wrote:
>>>> On 10/19/15 2:28 PM, Pravin Shelar wrote:
>>>>> On Sat, Oct 17, 2015 at 6:12 PM, Thomas F Herbert
>>>>> <thomasfherbert@gmail.com>  wrote:
>>>>>> Add support for 802.1ad including the ability to push and pop double
>>>>>> tagged vlans. Add support for 802.1ad to netlink parsing and flow
>>>>>> conversion. Uses double nested encap attributes to represent double
>>>>>> tagged vlan. Inner TPID encoded along with ctci in nested attributes.
>>>>>>
>>>>>> Signed-off-by: Thomas F Herbert<thomasfherbert@gmail.com>
>>>>>> ---
>>>>>>     net/openvswitch/actions.c      |   6 +-
>>>>>>     net/openvswitch/flow.c         |  76 +++++++++++++-----
>>>>>>     net/openvswitch/flow.h         |   8 +-
>>>>>>     net/openvswitch/flow_netlink.c | 172
>>>>>> +++++++++++++++++++++++++++++++++++++----
>>>>>>     net/openvswitch/vport-netdev.c |   4 +-
>>>>>>     5 files changed, 227 insertions(+), 39 deletions(-)
>>>>>>
>>>>>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>>>>>> index 315f533..09cc1c9 100644
>>>>> ...
>>>>>
>>>>>> diff --git a/net/openvswitch/flow_netlink.c
>>>>>> b/net/openvswitch/flow_netlink.c
>>>>>> index c92d6a2..97a6d12 100644
>>>>>> --- a/net/openvswitch/flow_netlink.c
>>>>>> +++ b/net/openvswitch/flow_netlink.c
>>>>> ...
>>>>>
>>>>>> @@ -1320,6 +1443,7 @@ static int __ovs_nla_put_key(const struct
>>>>>> sw_flow_key *swkey,
>>>>>>     {
>>>>>>            struct ovs_key_ethernet *eth_key;
>>>>>>            struct nlattr *nla, *encap;
>>>>>> +       struct nlattr *in_encap = NULL;
>>>>>>
>>>>>>            if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID,
>>>>>> output->recirc_id))
>>>>>>                    goto nla_put_failure;
>>>>>> @@ -1368,17 +1492,29 @@ static int __ovs_nla_put_key(const struct
>>>>>> sw_flow_key *swkey,
>>>>>>            ether_addr_copy(eth_key->eth_src, output->eth.src);
>>>>>>            ether_addr_copy(eth_key->eth_dst, output->eth.dst);
>>>>>>
>>>>>> -       if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
>>>>>> -               __be16 eth_type;
>>>>>> -               eth_type = !is_mask ? htons(ETH_P_8021Q) :
>>>>>> htons(0xffff);
>>>>>> -               if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type)
>>>>>> ||
>>>>>> -                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN,
>>>>>> output->eth.tci))
>>>>>> +       if (swkey->eth.vlan.tci || eth_type_vlan(swkey->eth.type)) {
>>>>>> +               if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
>>>>>> +                                output->eth.vlan.tpid) ||
>>>>>> +                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN,
>>>>>> output->eth.vlan.tci))
>>>>>>                            goto nla_put_failure;
>>>>>>                    encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
>>>>>> -               if (!swkey->eth.tci)
>>>>>> +               if (!swkey->eth.vlan.tci)
>>>>>>                            goto unencap;
>>>>>> -       } else
>>>>>> +               if (swkey->eth.cvlan.tci) {
>>>>>> +                       /* Customer tci is nested but uses same key
>>>>>> attribute.
>>>>>> +                        */
>>>>>> +                       if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
>>>>>> +                                        output->eth.cvlan.tpid) ||
>>>>>> +                           nla_put_be16(skb, OVS_KEY_ATTR_VLAN,
>>>>>> +                                        output->eth.cvlan.tci))
>>>>>> +                               goto nla_put_failure;
>>>>>> +                       in_encap = nla_nest_start(skb,
>>>>>> OVS_KEY_ATTR_ENCAP);
>>>>>> +                       if (!swkey->eth.cvlan.tci)
>>>>>> +                               goto unencap;
>>>>>> +               }
>>>>>> +       } else {
>>>>>>                    encap = NULL;
>>>>>> +       }
>>>>> After the vlan parsing changes, we need to encode cvlan in outer
>>>>> netlink attribute and then encode regular vlan.
>>>> I don't understand this. cvlan is inner vlan, why would it be encoded in
>>>> outer vlan without the 2nd layer of encapsulation?
>>>>
>>> Lets start with double tagged packet.
>>> packet: eth, vlan 10, inner vlan 20, ip.
>>> flow key would be:
>>> flow_key: vlan = 10, cvlan = 20
>>> That would get serialize over netlink like:
>>>
>>> eth_type(0x8100),vlan(vid=10,pcp=0),encap(eth_type(0x8100),vlan(vid=20,pcp=0),
>>> encap(eth_type(0x0800),ipv4(frag=no))...
>>> So far looks good.
>>>
>>> Now userspace sends back same key and installs flow in kernel
>>> datapath. But ovs_nla_get_match() parses netink key and sets vlan in
>>> reverse order. After parsing netlink in ovs_nla_get_match() vlans
>>> flow-key would look like:
>>> flow_key: vlan = 20, cvlan = 10. This is not what we started with.
>>>
>>> Now I think rather than fixing __ovs_nla_put_key (), we need to fix
>>> ovs_nla_get_match() to keep vlan order.
>>> I also noticed that eth.vlan.tpid is never initialized from netlink
>>> attributes.
>> Yes, you are right. The code in master never encoded the tpid in the key and
>> I didn't add it when I modified the swkey for the addition of the vlan
>> struct.
>>
>> Yes, you are right the code is wrong. The intention was to leave the old
>> code which left the outer tci in the key for later processing. In the code
>> in master, after checking proper vlan the function ovs_key_from_nlattrs()
>> encoded the tci.
>>
>> Now I see that I must refactor the code in ovs_nla_get_match() and
>> parse_vlan_from_nlattrs to explicitly encode the outer vlan including tpid
>> before the inner vlan.
>>> Call to parse_flow_nlattrs  in parse_vlan_from_nlattrs() has no effect
>>> so it should be removed
>> parse_flow_nlattrs() is called for each level of encapsulation. It sets
>> v_attrs with the keys found in the flow key. This is to insure that I am
>> looking only at the keys for the current level of encapsulation. Then it is
>> called a final time to parse out the l3 attributes for encoding.
> ovs_nla_get_match() calls parse_flow_nlattrs() and then again in
> parse_vlan_from_nlattrs(), second parse_flow_nlattr() can potentially
> overwrite vlan attributes. Therefore it should called after the outer
> vlan attributes are read.
Thanks! Yes, I agree. I am fixing this with the refactoring I am doing now.
