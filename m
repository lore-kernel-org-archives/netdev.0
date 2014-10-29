From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [RFC] use smp_load_acquire()/smp_store_release()
Date: Wed, 29 Oct 2014 09:16:32 -0700
Message-ID: <545112E0.40106@redhat.com>
References: <1414594159.631.85.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jeffrey.t.kirsher@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49108 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932994AbaJ2QQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2014 12:16:35 -0400
In-Reply-To: <1414594159.631.85.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/29/2014 07:49 AM, Eric Dumazet wrote:
> Hi Alexander
>
> The memory barriers added in commit
> b37c0fbe3f6dfba1f8ad2aed47fb40578a254635
> ("net: Add memory barriers to prevent possible race in byte queue
> limits")
>
> have heavy cost.
>
> It seems we could use smp_load_acquire() and smp_store_release()
> instead ?
>
> I'll post a patch later today. I would be interested if someone was able
> to test it, as your commit apparently was tested and known to fix a
> reproducible race.
>
> Thanks !

Unfortunately Stephen left Intel before I did, so we will need to find 
someone else in the validation team to test this if possible. I have 
added Jeff to the CC so that he can give the appropriate validation 
people a heads up that this patch might be coming.

As I recall what was seen was random Tx hangs on systems with the 
original BQL code when interfaces were stressed.  It has been a while so 
I don't recall the exact set-up for all of it.  Also some less 
used/tested architectures such as PowerPC can be more susceptible to 
synchronization issues such as these as the memory model is more weakly 
ordered.

I'm wondering where you are seeing the barrier show up?  In 
netdev_tx_send_queue you should only hit the barrier if you actually are 
triggering the XOFF condition, and in netdev_tx_completed_queue the 
barrier should be coalesced in amongst a number of frames reducing the cost.

My concern with this would be that we are actually syncronizing multiple 
things, the __QUEUE_STATE_STACK_XOFF flag, dql->adj_limit, and 
dql->num_queued, and we might be trading off reducing the cost on x86 to 
result in it being increased on other architectures as we may have to 
actually add additional synchronization as I suspect we would need to 
use acquire/release on both adj_limit and num_queued.

Thanks,

Alex
