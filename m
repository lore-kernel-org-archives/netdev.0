From: Thomas F Herbert <therbert@redhat.com>
Subject: Re: [PATCH net-next V10 4/4] 8021AD: Flow key parsing and netlink
 attributes.
Date: Tue, 09 Jun 2015 20:13:14 -0400
Message-ID: <5577811A.502@redhat.com>
References: <1433267444-26025-1-git-send-email-thomasfherbert@gmail.com>	<1433267444-26025-5-git-send-email-thomasfherbert@gmail.com> <CALnjE+ocDvv3q4Jx0rc8TCk2TmJkK3cU5EBnZ14T6HSteU1JXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>,
	Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751700AbbFJANP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 20:13:15 -0400
In-Reply-To: <CALnjE+ocDvv3q4Jx0rc8TCk2TmJkK3cU5EBnZ14T6HSteU1JXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/8/15 11:45 PM, Pravin Shelar wrote:
> On Tue, Jun 2, 2015 at 10:50 AM, Thomas F Herbert
> <thomasfherbert@gmail.com> wrote:
>> Add support for 802.1ad to netlink parsing and flow conversation. Uses
>> double nested encap attributes to represent double tagged vlan.
>>
> This patch needs to be merged with earlier patch since it is part of
> qinq support.
>
>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
>> ---
>>   net/openvswitch/flow_netlink.c | 186 ++++++++++++++++++++++++++++++++++-------
>>   1 file changed, 157 insertions(+), 29 deletions(-)
>>
>> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
>> index c691b1a..8fd4f63 100644
>> --- a/net/openvswitch/flow_netlink.c
>> +++ b/net/openvswitch/flow_netlink.c
>> @@ -771,6 +771,28 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
> ...
>>                  err = ovs_key_from_nlattrs(match, mask_attrs, a, true, log);
>> @@ -1331,6 +1439,25 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
>>                  encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
>>                  if (!swkey->eth.tci)
>>                          goto unencap;
>> +       } else if (swkey->eth.ctci || swkey->eth.type == htons(ETH_P_8021AD)) {
>> +               __be16 eth_type;
>> +
>> +               eth_type = !is_mask ? htons(ETH_P_8021AD) : htons(0xffff);
>> +               if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
>> +                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
>> +                       goto nla_put_failure;
>> +               encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
>> +               if (!swkey->eth.tci)
>> +                       goto unencap;
>> +               /* Customer tci is nested but uses same key attribute.
>> +                */
>> +               eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
>> +               if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
>> +                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.ctci))
>> +                       goto nla_put_failure;
>> +               encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
>> +               if (!swkey->eth.ctci)
>> +                       goto unencap;
>>          } else
>>                  encap = NULL;
>>
> For qinq we need to keep track of two encap attributes to finalize
> nesting of attributes.
Thanks! This was an oversight on my part and I am fixing it in V11.
>
