From: "Fastabend, John R" <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 7/7] net: ixgbe: add support for tc_u32 offload
Date: Wed, 3 Feb 2016 11:02:45 -0800
Message-ID: <56B24ED5.4010903@gmail.com>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203092959.1356.91778.stgit@john-Precision-Tower-5810>
 <20160203100716.GA20905@office.Home> <56B1D5D2.7040807@gmail.com>
 <56B1F689.5040609@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jiri@resnulli.us,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>, "Amir Vadai\"" <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:34229 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965408AbcBCTDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 14:03:06 -0500
Received: by mail-ob0-f180.google.com with SMTP id wb13so44216697obb.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 11:03:05 -0800 (PST)
In-Reply-To: <56B1F689.5040609@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/3/2016 4:46 AM, Jamal Hadi Salim wrote:
[...]

>>>>
>>>
>>> What are you doing w.r.t priorities? Are the filters processed by the
>>> order of the priorities?
>>>

In the same order as software processes filters. I tried to faithfully
translate the u32 classify and  u32_change loops into hardware. If I
missed some case its a bug and I'll fix it. My reading and experiments
of u32 indicate the ht:bucket:node build a handle and this is how we
order rules.

When I test this I create a veth pair and create the same rule set on
the veth pair as my hardware netdev. Then inject a skb into both
the veth and hardware netdev if you get different results its a bug.

>>
>> The rules are put in order by the handles which is populated in
>> my command above such that 'ht 1: order 3' gives handle 1::3 and
>> 'ht 800: order 1' gives 800::1. Take a look at this block in cls_u32
>>
>>          if (err == 0) {
>>                  struct tc_u_knode __rcu **ins;
>>                  struct tc_u_knode *pins;
>>
>>                  ins = &ht->ht[TC_U32_HASH(handle)];
>>                  for (pins = rtnl_dereference(*ins); pins;
>>                       ins = &pins->next, pins = rtnl_dereference(*ins))
>>                          if (TC_U32_NODE(handle) <
>> TC_U32_NODE(pins->handle))
>>                                  break;
>>
>>                  RCU_INIT_POINTER(n->next, pins);
>>                  rcu_assign_pointer(*ins, n);
>>                  u32_replace_hw_knode(tp, n);
>>                  *arg = (unsigned long)n;
>>                  return 0;
>>
>>
>> If you leave ht and order off the tc cli I believe 'tc' just
>> picks some semi-arbitrary ones for you. I've been in the habit
>> of always specifying them even for software filters.
>>
> 
> The default table id is essentially 0x800. Default bucket is 0.
> "order" essentially is the filter id. And given you can link tables
> (Nice work John!); essentially the ht:bucket:nodeid is an "address" to
> a specific filter on a specific table and when makes sense a specific
> hash bucket. Some other way to look at it is as a way to construct
> a mapping to a TCAM key.

Sure as long as your mapping works/looks like the software only case
it doesn't matter how you do the hardware mapping and my guess is this
is going to be highly device specific. Even with the handful of devices
I have it looks different depending on the device.

Note if you don't do the table links there really is no safe
way to get into the headers beyond the IP header because you need the
nexthdr stuff. Also just to stick this out there I have a patch to let
cls_u32 start processing at the ethernet header instead of the
transport header similar to how bpf works. This negative offset business
doesn't really work as best I can tell.

> What John is doing is essentially taking the nodeid and trying to use
> it as a priority. In otherwise the abstraction is reduced to a linked
> list in which the ordering is how the list is traversed.
> It may work in this case, but i am for being able to explicitly specify
> priorities.

But that doesn't exist in software today. If users want explicit order
today they build the ht, nodeid out correctly just use that. If you
are working on a TCAM just use the nodeid that should be equivalent to
priority.

And  although the ixgbe supports only a single table the mapping on more
complex devices will take it onto multiple tables if that optimizes
things.

Note I need to do a couple fixes on my existing code one to abort when
given a bad ifindex and two to hard abort when a hashtable is given
a higher order rule that I can't support. Both are fairly small tweaks
to the ixgbe code not to the infrastructure.

> 
> cheers,
> jamal
> 
