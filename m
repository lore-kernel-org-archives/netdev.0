From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: ixgbe: normalize frag_list usage
Date: Thu, 07 Oct 2010 12:59:14 -0700
Message-ID: <4CAE2692.8020401@intel.com>
References: <4CAA1722.7070405@intel.com>	<20101004.113258.212671454.davem@davemloft.net>	<80769D7B14936844A23C0C43D9FBCF0F25B97A24B5@orsmsx501.amr.corp.intel.com> <20101006.235837.241424681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44629 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754684Ab0JGT7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 15:59:20 -0400
In-Reply-To: <20101006.235837.241424681.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/6/2010 11:58 PM, David Miller wrote:
> From: "Duyck, Alexander H"<alexander.h.duyck@intel.com>
> Date: Tue, 5 Oct 2010 15:45:32 -0700
>
>> The patch below is kind of what I had in mind for a way to do RSC and maintain
>> the pointer scheme you are looking for.  Consider this patch an RFC for now
>> since I based this off of Jeff's internal testing tree and so it would need
>> some modification to apply cleanly to net-next.
>
> Can you really not remember the head somewhere?

I can track it in the RSC_CB if that works for you.  Right now though I 
guess I am not seeing the difference between tracking this in 
skb->frag_next vs IXGBE_RSC_CB(skb)->frag_head.  I think it might help 
if you were to provide some functions that demonstrate exactly what you 
had in mind for frag list handling.  Specifically if you were to add a 
function for merging a frag into the frag list, and for how you want to 
approach cleaning up the skb->prev/frag_tail_tracker pointer when you 
are cleaning up an active frag_list.

> What I wanted is for everyone to build their frag list SKBs from head to tail,
> always.  So that I could, as I mentioned in my original posting, do something
> like:

My change is doing just that.  It is building from head to tail.  The 
only difference is that tail is tracking head since it has to be updated 
after the tail is added, and then I can drop next/frag_next back to NULL.

> struct sk_buff {
> 	union {
> 		struct list_head list;
> 		struct {
> 			struct sk_buff	*frag_next;
> 			struct sk_buff	*frag_tail_tracker;
> 		};
> 	};
> };
>
> The ->frag_tail_tracker is only used in the head SKB to maintain where the
> last SKB in the frag list is.

That is what I was doing in the head skb.

> You're tracking the head from the inner SKBs, such that my intended
> conventions are not being followed.

What I am doing is tracking the head from the tail skb.  The reason for 
this is that I need some way to update the len, data_len, and truesize 
after I have placed data in the tail via skb_put.  All of the other SKBs 
in the frag list are just tracking the next like any other SKB in the 
frag_list.

Now that I think about it I guess the issue is that I am adding the SKB 
to the frag_list before it is complete.  I will send another patch out 
in the next couple of hours that should address most of the issues.

Thanks,

Alex





