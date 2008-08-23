From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Fri, 22 Aug 2008 18:37:51 -0700
Message-ID: <5f2db9d90808221837h2f727478qf78bb6e6a2867802@mail.gmail.com>
References: <1219415417.4672.79.camel@localhost>
	 <20080822221913.GA2981@ami.dom.local>
	 <5f2db9d90808221701t4c576282m34a46999b76b6e83@mail.gmail.com>
	 <20080822.174032.117057862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	jeff@garzik.org, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:34412 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbYHWBhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 21:37:52 -0400
Received: by yx-out-2324.google.com with SMTP id 8so448679yxm.1
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 18:37:51 -0700 (PDT)
In-Reply-To: <20080822.174032.117057862.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 5:40 PM, David Miller <davem@davemloft.net> wrote:
> From: "Alexander Duyck" <alexander.duyck@gmail.com>
> Date: Fri, 22 Aug 2008 17:01:50 -0700
>
>> I am almost certain that David's approach using the hash will show
>> better performance than the multiqueue prio qdisc would.  The
>> multiqueue prio qdisc is meant to allow for classification of traffic
>> into separate traffic classes to support stuff like Enhanced Ethernet
>> for Data Center (EEDC) / Data Center Bridging (DCB).
>
> The only sensible way to implement this is to use the existing
> classifier technology in the packet scheduler to choose traffic,
> and then writing a TC actions or ematch module that sets the
> TX queue of the SKB based upon the classification result.
>
> The thing that was there before was very narrow in scope and
> we'll just have to keep adding more special purpose modules
> as more such uses come up.
>
> With the classifiers, it's generic and any scheme can be implemented
> by simply issuing different 'tc' commands.
>

I thought about doing just that but then I realized that there would
be a number of issues.

First if I just set the skb->queue_mapping for the packet without
moving it to a qdisc dedicated to that tx queue I run into
head-of-line issues since multiple qdiscs will stop if holding packets
for a single tx queue that is full.  That is over come in this patch
by the fact that each qdisc has a specific fifo per tx queue.

That issue led me to the thought of creating a redirect action that
would take the packet from one qdisc to the correct qdisc for the
transmit queue.  That setup has two issues.  First, all traffic would
need to go to one queue by default to avoid a possible deadlock
condition in the event that two queues try to enqueue packets on one
another at the same time.  That combined with the fact that one packet
would then have to grab two qdisc locks to be enqueued seems to be
rather expensive performance wise.  Second the the action of
redirecting the packet once already in a qdisc requires cloning the
skb which would be a serious performance drop over the previous prio
qdisc implementation.  I don't incur these performance penalties with
the mq prio qdisc and the locking is clean since the transition occurs
after dequeue but before grabbing the transmit queue lock.

There were only two workable ways I could see of doing this that
didn't make a total mess of things.  The first is what I implemented
in this patch.  The second would have been to add a pass-thru qdisc
prior to or as part of select_queue that had the tc action that set
the skb->queue_mapping.  The only reason why I didn't really feel
comfortable implementing the extra qdisc is because I felt it would
have added extra unnecessary overhead and require more changes to the
tx path.

Thanks,

Alex
