From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 3/5] slab.c: remove branch hint
Date: Mon, 30 Nov 2009 11:05:06 +0200
Message-ID: <4B138AC2.7080008@cs.helsinki.fi>
References: <cover.1259059549.git.tim@klingt.org> <4B0BBBA8.2090604@klingt.org>	 <20091124112058.GA23765@elte.hu> <84144f020911240328l3d36d347o6c91b2b1a0f50f2a@mail.gmail.com> <4B125CC2.7000202@klingt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Nick Piggin <npiggin@suse.de>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Tim Blechmann <tim@klingt.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752794AbZK3JFD@vger.kernel.org>
In-Reply-To: <4B125CC2.7000202@klingt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tim Blechmann kirjoitti:
> On 11/24/2009 12:28 PM, Pekka Enberg wrote:
>> On Tue, Nov 24, 2009 at 1:20 PM, Ingo Molnar <mingo@elte.hu> wrote:
>>> (Pekka Cc:-ed)
>>>
>>> * Tim Blechmann <tim@klingt.org> wrote:
>>>
>>>> branch profiling on my nehalem machine showed 99% incorrect branch hints:
>>>>
>>>>    28459  7678524  99 __cache_alloc_node             slab.c
>>>>   3551
>>>>
>>>> Signed-off-by: Tim Blechmann <tim@klingt.org>
>>>> ---
>>>>  mm/slab.c |    2 +-
>>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/mm/slab.c b/mm/slab.c
>>>> index f70b326..4125fcd 100644
>>>> --- a/mm/slab.c
>>>> +++ b/mm/slab.c
>>>> @@ -3548,7 +3548,7 @@ __cache_alloc_node(struct kmem_cache *cachep,
>>>> gfp_t flags, int nodeid,
>>>>       slab_irq_save(save_flags, this_cpu);
>>>>       this_node = cpu_to_node(this_cpu);
>>>> -     if (unlikely(nodeid == -1))
>>>> +     if (nodeid == -1)
>>>>               nodeid = this_node;
>>>>       if (unlikely(!cachep->nodelists[nodeid])) {
>> That sounds odd to me. Can you see where the incorrectly predicted
>> calls are coming from? Calling kmem_cache_alloc_node() with node set
>> to -1 most of the time could be a real bug somewhere.
> 
> when dumping the stack for the incorrectly hinted branches, i get the
> attached stack traces...
> 
> hth, tim
> 
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3548,8 +3548,10 @@ __cache_alloc_node(struct kmem_cache *cachep,
> gfp_t flags, int nodeid,
>         slab_irq_save(save_flags, this_cpu);
> 
>         this_node = cpu_to_node(this_cpu);
> -       if (nodeid == -1)
> +       if (nodeid == -1) {
> +               dump_stack();
>                 nodeid = this_node;
> +       }
> 
>         if (unlikely(!cachep->nodelists[nodeid])) {
>                 /* Node not bootstrapped yet */
> 
> 
> 

OK, so it's the generic alloc_skb() function that keeps hitting 
kmem_cache_alloc_node() with "-1". Christoph, are you okay with removing 
the unlikely() annotation from __cache_alloc_node()?

			Pekka
