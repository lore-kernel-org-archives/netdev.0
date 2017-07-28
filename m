From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH V2 3/4] net-next: dsa: fix flow dissection
Date: Fri, 28 Jul 2017 21:40:42 +0200
Message-ID: <82b46393-6c63-eedf-25e4-2bd2278c0d16@phrozen.org>
References: <20170721085813.30789-1-john@phrozen.org>
 <20170721085813.30789-3-john@phrozen.org> <20170726151013.GD12049@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726151013.GD12049@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 26/07/17 17:10, Andrew Lunn wrote:
> On Fri, Jul 21, 2017 at 10:58:12AM +0200, John Crispin wrote:
>> RPS and probably other kernel features are currently broken on some if not
>> all DSA devices. The root cause of this is that skb_hash will call the
>> flow_dissector. At this point the skb still contains the magic switch header
>> and the skb->protocol field is not set up to the correct 802.3 value yet.
>> By the time the tag specific code is called, removing the header and
>> properly setting the protocol an invalid hash is already set. In the case
>> of the mt7530 this will result in all flows always having the same hash.
>>
>> This patch makes the flow dissector honour the nh and protocol offset
>> defined by the dsa tag driver thus fixing dissection, hashing and RPS.
>>
>> Signed-off-by: John Crispin <john@phrozen.org>
>> ---
>>   net/core/flow_dissector.c | 12 ++++++++++++
>>   1 file changed, 12 insertions(+)
>>
>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index fc5fc4594c90..1268ae75c3b3 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -4,6 +4,7 @@
>>   #include <linux/ip.h>
>>   #include <linux/ipv6.h>
>>   #include <linux/if_vlan.h>
>> +#include <net/dsa.h>
>>   #include <net/ip.h>
>>   #include <net/ipv6.h>
>>   #include <net/gre.h>
>> @@ -440,6 +441,17 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>>   			 skb->vlan_proto : skb->protocol;
>>   		nhoff = skb_network_offset(skb);
>>   		hlen = skb_headlen(skb);
>> +
>> +		if (unlikely(netdev_uses_dsa(skb->dev))) {
>> +			const struct dsa_device_ops *ops;
>> +			u8 *p = (u8 *)data;
>> +
>> +			ops = skb->dev->dsa_ptr->tag_ops;
>> +			if (ops->hash_proto_off)
>> +				proto = (u16)p[ops->hash_proto_off];
> Hi John
>
> Unfortunately, this is not generic enough to work for DSA and EDSA
> tagging. With these tagging protocols, the size of the tag depends on
> the presence or not of a VLAN header.
>
> To make this work for all tagging protocols, we are going to need to
> add an a new op to tag_ops.
>
>      Andrew
Hi Andrew,

thanks for the feedback. should I add 2 callbacks for each of the 2 
parameters ?

     John
