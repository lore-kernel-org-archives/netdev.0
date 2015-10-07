From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH] ovs: do not allocate memory from offline numa node
Date: Tue, 6 Oct 2015 18:01:06 -0700
Message-ID: <CAEP_g=9JB2GptbZn9ayTPRGPbuOvVujCQ1Hui7fOijUX10HURg@mail.gmail.com>
References: <20151002101822.12499.27658.stgit@buzz> <56128238.8010305@suse.cz> <5612DCC8.4040605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	"dev@openvswitch.org" <dev@openvswitch.org>, Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
To: Alexander Duyck <alexander.duyck@gmail.com>, Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <5612DCC8.4040605@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 5, 2015 at 1:25 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On 10/05/2015 06:59 AM, Vlastimil Babka wrote:
>>
>> On 10/02/2015 12:18 PM, Konstantin Khlebnikov wrote:
>>>
>>> When openvswitch tries allocate memory from offline numa node 0:
>>> stats = kmem_cache_alloc_node(flow_stats_cache, GFP_KERNEL | __GFP_ZERO,
>>> 0)
>>> It catches VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid))
>>> [ replaced with VM_WARN_ON(!node_online(nid)) recently ] in linux/gfp.h
>>> This patch disables numa affinity in this case.
>>>
>>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>
>>
>> ...
>>
>>> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
>>> index f2ea83ba4763..c7f74aab34b9 100644
>>> --- a/net/openvswitch/flow_table.c
>>> +++ b/net/openvswitch/flow_table.c
>>> @@ -93,7 +93,8 @@ struct sw_flow *ovs_flow_alloc(void)
>>>
>>>       /* Initialize the default stat node. */
>>>       stats = kmem_cache_alloc_node(flow_stats_cache,
>>> -                      GFP_KERNEL | __GFP_ZERO, 0);
>>> +                      GFP_KERNEL | __GFP_ZERO,
>>> +                      node_online(0) ? 0 : NUMA_NO_NODE);
>>
>>
>> Stupid question: can node 0 become offline between this check, and the
>> VM_WARN_ON? :) BTW what kind of system has node 0 offline?
>
>
> Another question to ask would be is it possible for node 0 to be online, but
> be a memoryless node?
>
> I would say you are better off just making this call kmem_cache_alloc.  I
> don't see anything that indicates the memory has to come from node 0, so
> adding the extra overhead doesn't provide any value.

I agree that this at least makes me wonder, though I actually have
concerns in the opposite direction - I see assumptions about this
being on node 0 in net/openvswitch/flow.c.

Jarno, since you original wrote this code, can you take a look to see
if everything still makes sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
