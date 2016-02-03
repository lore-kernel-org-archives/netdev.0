From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 7/7] net: ixgbe: add support for tc_u32 offload
Date: Wed, 3 Feb 2016 07:46:01 -0500
Message-ID: <56B1F689.5040609@mojatatu.com>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203092959.1356.91778.stgit@john-Precision-Tower-5810>
 <20160203100716.GA20905@office.Home> <56B1D5D2.7040807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jiri@resnulli.us,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>,
	"Amir Vadai\"" <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:35452 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757574AbcBCMqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 07:46:04 -0500
Received: by mail-ig0-f170.google.com with SMTP id hb3so10018732igb.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 04:46:03 -0800 (PST)
In-Reply-To: <56B1D5D2.7040807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-03 05:26 AM, John Fastabend wrote:
> On 16-02-03 02:07 AM, Amir Vadai" wrote:
>> On Wed, Feb 03, 2016 at 01:29:59AM -0800, John Fastabend wrote:
>>> This adds initial support for offloading the u32 tc classifier. This
>>> initial implementation only implements a few base matches and actions
>>> to illustrate the use of the infrastructure patches.
>>>
>>> However it is an interesting subset because it handles the u32 next
>>> hdr logic to correctly map tcp packets from ip headers using the ihl
>>> and protocol fields. After this is accepted we can extend the match
>>> and action fields easily by updating the model header file.
>>>
>>> Also only the drop action is supported initially.
>>>
>>> Here is a short test script,
>>>
>>>   #tc qdisc add dev eth4 ingress
>>>   #tc filter add dev eth4 parent ffff: protocol ip \
>>> 	u32 ht 800: order 1 \
>>> 	match ip dst 15.0.0.1/32 match ip src 15.0.0.2/32 action drop
>>>
>>> <-- hardware has dst/src ip match rule installed -->
>>>
>>>   #tc filter del dev eth4 parent ffff: prio 49152
>>>   #tc filter add dev eth4 parent ffff: protocol ip prio 99 \
>>> 	handle 1: u32 divisor 1
>>>   #tc filter add dev eth4 protocol ip parent ffff: prio 99 \
>>> 	u32 ht 800: order 1 link 1: \
>>> 	offset at 0 mask 0f00 shift 6 plus 0 eat match ip protocol 6 ff
>>>   #tc filter add dev eth4 parent ffff: protocol ip \
>>> 	u32 ht 1: order 3 match tcp src 23 ffff action drop
>>>
>>> <-- hardware has tcp src port rule installed -->
>>>
>>>   #tc qdisc del dev eth4 parent ffff:
>>>
>>> <-- hardware cleaned up -->
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>> ---
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    6 -
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  196 ++++++++++++++++++++++
>>>   3 files changed, 198 insertions(+), 7 deletions(-)
>>>
>>
>> What are you doing w.r.t priorities? Are the filters processed by the
>> order of the priorities?
>>
>
> The rules are put in order by the handles which is populated in
> my command above such that 'ht 1: order 3' gives handle 1::3 and
> 'ht 800: order 1' gives 800::1. Take a look at this block in cls_u32
>
>          if (err == 0) {
>                  struct tc_u_knode __rcu **ins;
>                  struct tc_u_knode *pins;
>
>                  ins = &ht->ht[TC_U32_HASH(handle)];
>                  for (pins = rtnl_dereference(*ins); pins;
>                       ins = &pins->next, pins = rtnl_dereference(*ins))
>                          if (TC_U32_NODE(handle) < TC_U32_NODE(pins->handle))
>                                  break;
>
>                  RCU_INIT_POINTER(n->next, pins);
>                  rcu_assign_pointer(*ins, n);
>                  u32_replace_hw_knode(tp, n);
>                  *arg = (unsigned long)n;
>                  return 0;
>
>
> If you leave ht and order off the tc cli I believe 'tc' just
> picks some semi-arbitrary ones for you. I've been in the habit
> of always specifying them even for software filters.
>

The default table id is essentially 0x800. Default bucket is 0.
"order" essentially is the filter id. And given you can link tables
(Nice work John!); essentially the ht:bucket:nodeid is an "address" to
a specific filter on a specific table and when makes sense a specific
hash bucket. Some other way to look at it is as a way to construct
a mapping to a TCAM key.
What John is doing is essentially taking the nodeid and trying to use
it as a priority. In otherwise the abstraction is reduced to a linked
list in which the ordering is how the list is traversed.
It may work in this case, but i am for being able to explicitly specify
priorities.

cheers,
jamal
