From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Fri, 18 Jul 2008 01:58:02 +0200
Message-ID: <487FDC8A.9090101@trash.net>
References: <487F4327.1000107@trash.net>	<20080717.061239.51839567.davem@davemloft.net>	<487F4DA6.6010009@trash.net> <20080717.153609.142867331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080717.153609.142867331.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> Date: Thu, 17 Jul 2008 15:48:22 +0200
> 
>> One thought that occured to me - we could avoid all the visiblity
>> issues wrt. dev->qdisc_list by simply getting rid of it :)
>>
>> If we move the qdisc list from the device to the root Qdisc itself,
>> it would become invisible automatically as soon as we assign a new
>> root qdisc to the netdev_queue. Iteration would become slightly
>> more complicated since we'd have to iterate over all netdev_queues,
>> but I think it should avoid most of the problems I mentioned
>> (besides the u32_list thing).
> 
> What might make sense is to have a special Qdisc_root structure which
> is simply:
> 
> struct Qdisc_root {
> 	struct Qdisc		qd;
> 	struct list_head	qdisc_list;
> };
> 
> Everything about tree level synchronization would be type explicit.

Device level grafting is also explicit, so that looks like
a clean way.

> Yes, as you say, the qdisc iteration would get slightly ugly.  But
> that doesn't seem to be a huge deal.
> 
> But it seems a clean solution to the child qdisc visibility problem.
> 
> About u32_list, that thing definitely needs some spinlock.  The
> consultation of that list, and refcount mods, only occur during config
> operations.  So it's not like we have to grab this lock in the data
> paths.
> 
> If we really want to sweep this problem under the rug, there is another
> way.  Have the qdisc_destroy() RCU handler kick off a workqueue, and
> grab the RTNL semaphore there during the final destruction calls. :-)

That would be the safe way. The RCU destruction used to cause us
bugs for at least two years, but I actually believe the Qdisc_root
thing will work :)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
