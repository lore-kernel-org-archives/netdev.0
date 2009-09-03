From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc: Fix unitialized kernel memory leak
Date: Wed, 02 Sep 2009 22:51:08 -0700 (PDT)
Message-ID: <20090902.225108.168195116.davem@davemloft.net>
References: <4A9E67A9.7090205@gmail.com>
	<20090902120540.34e2a198@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49081
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754246AbZICFux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 01:50:53 -0400
In-Reply-To: <20090902120540.34e2a198@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 2 Sep 2009 12:05:40 -0700

> On Wed, 02 Sep 2009 14:40:09 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> Three bytes of uninitialized kernel memory are currently leaked to user
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
>> index 24d17ce..fdb694e 100644
>> --- a/net/sched/sch_api.c
>> +++ b/net/sched/sch_api.c
>> @@ -1456,6 +1456,8 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
>>  	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
>>  	tcm = NLMSG_DATA(nlh);
>>  	tcm->tcm_family = AF_UNSPEC;
>> +	tcm->tcm__pad1 = 0;
>> +	tcm->tcm__pad2 = 0;
>>  	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
>>  	tcm->tcm_parent = q->handle;
>>  	tcm->tcm_handle = q->handle;
> 
> Perhaps __nlmsg_put should just always call memset() for the whole
> added chunk. It is not like it is critical path in any way, and
> avoid any of this possible class of errors.

Doing it in __nlmsg_put would effect a lot of code paths.  I don't
think you can say with certainty that it won't matter, tree wide.

What about things like the netfilter conntrack event monitor?  Doesn't
that emit hundreds of thousands of events per second on a busy
firewall?
