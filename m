From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/2] vhost: allow multiple workers threads
Date: Tue, 21 Feb 2012 12:51:46 +0800
Message-ID: <4F4322E2.6010308@redhat.com>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com> <1329519726-25763-2-git-send-email-aliguori@us.ibm.com> <20120219144145.GA16620@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <aliguori@us.ibm.com>, netdev@vger.kernel.org,
	Tom Lendacky <toml@us.ibm.com>,
	Cristian Viana <vianac@br.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752584Ab2BUEvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 23:51:53 -0500
In-Reply-To: <20120219144145.GA16620@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/19/2012 10:41 PM, Michael S. Tsirkin wrote:
> On Fri, Feb 17, 2012 at 05:02:05PM -0600, Anthony Liguori wrote:
>> >  This patch allows vhost to have multiple worker threads for devices such as
>> >  virtio-net which may have multiple virtqueues.
>> >  
>> >  Since virtqueues are a lockless ring queue, in an ideal world data is being
>> >  produced by the producer as fast as data is being consumed by the consumer.
>> >  These loops will continue to consume data until none is left.
>> >  
>> >  vhost currently multiplexes the consumer side of the queue on a single thread
>> >  by attempting to read from the queue until everything is read or it cannot
>> >  process anymore.  This means that activity on one queue may stall another queue.
> There's actually an attempt to address this: look up
> VHOST_NET_WEIGHT in the code. I take it, this isn't effective?
>
>> >  This is exacerbated when using any form of polling to read from the queues (as
>> >  we'll introduce in the next patch).  By spawning a thread per-virtqueue, this
>> >  is addressed.
>> >  
>> >  The only problem with this patch right now is how the wake up of the threads is
>> >  done.  It's essentially a broadcast and we have seen lock contention as a
>> >  result.
> On which lock?
>
>> >  We've tried some approaches to signal a single thread but I'm not
>> >  confident that that code is correct yet so I'm only sending the broadcast
>> >  version.
> Yes, that looks like an obvious question.
>
>> >  Here are some performance results from this change.  There's a modest
>> >  improvement with stream although a fair bit of variability too.
>> >  
>> >  With RR, there's pretty significant improvements as the instance rate drives up.
> Interesting. This was actually tested at one time and we saw
> a significant performance improvement from using
> a single thread especially with a single
> stream in the guest. Profiling indicated that
> with a single thread we get too many context
> switches between TX and RX, since guest networking
> tends to run TX and RX processing on the same
> guest VCPU.
>
> Maybe we were wrong or maybe this went away
> for some reason. I'll see if this can be reproduced.
>

I've tried a similar test in Jan. The test uses one dedicated vhost 
thread to handle tx requests and another one for rx. Test result shows 
much degradation as the both of the #exits and #irq are increased. There 
are some differences as I test between local host and guest, and the 
guest does not have very recent virtio changes ( unlocked kick and 
exposing index immediately ). I would try the recent kernel.
