From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration - V2
Date: Wed, 1 Oct 2008 23:52:44 +0200
Message-ID: <20081001215244.GB2520@ami.dom.local>
References: <48E24341.5050609@bull.net> <20081001.025935.257260146.davem@davemloft.net> <48E34C82.2040306@fr.ibm.com> <20081001.031243.255655293.davem@davemloft.net> <20081001141432.470106980@theryb.frec.bull.fr> <20081001194825.GA2520@ami.dom.local> <48E3E64E.50106@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:55896 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937AbYJAVwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 17:52:50 -0400
Received: by ug-out-1314.google.com with SMTP id k3so919730ugf.37
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2008 14:52:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48E3E64E.50106@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 01, 2008 at 11:06:22PM +0200, Daniel Lezcano wrote:
> Jarek Poplawski wrote:
>> On Wed, Oct 01, 2008 at 04:14:35PM +0200, Benjamin Thery wrote:
...
>>> --- net-next-2.6.orig/net/core/dst.c
>>> +++ net-next-2.6/net/core/dst.c
>>> @@ -328,6 +328,10 @@ static int dst_dev_event(struct notifier
>>>  			dst_ifdown(dst, dev, event != NETDEV_DOWN);
>>>  		}
>>>  		mutex_unlock(&dst_gc_mutex);
>>> +
>>> +		if (event == NETDEV_UNREGISTER &&
>>> +		    cancel_delayed_work(&dst_gc_work))
>>> +			dst_gc_task(&dst_gc_work.work);
>>
>> Hmm... It seems this shouldn't work yet: cancel_delayed_work() can only
>> kill this while on timer, but not when queued and maybe blocked already.
>
> Perhaps, I am misunderstanding but, dst_gc_work is always called with  
> schedule_delayed_work. If the task is not running, we can cancel it and  
> if the task is running, no need to trigger the gc, no ?

Right, but cancel_delayed_work() can't cancel it reliably even if the
task is not running (but e.g. queued already just after us - linkwatch).
Of course, this should be OK most of the time, especially with such long
schedule delays, but, on the other hand, not as sure as the first patch
with __rtnl_unlock. So doing this right could take more time.

Jarek P.
