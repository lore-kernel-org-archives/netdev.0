From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration - V2
Date: Wed, 01 Oct 2008 23:06:22 +0200
Message-ID: <48E3E64E.50106@fr.ibm.com>
References: <48E24341.5050609@bull.net> <20081001.025935.257260146.davem@davemloft.net> <48E34C82.2040306@fr.ibm.com> <20081001.031243.255655293.davem@davemloft.net> <20081001141432.470106980@theryb.frec.bull.fr> <20081001194825.GA2520@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:52339 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189AbYJAVGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 17:06:34 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id m91L6Wkp029984
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 21:06:32 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91L6WKR4300894
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 22:06:32 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91L6VY6028450
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 22:06:32 +0100
In-Reply-To: <20081001194825.GA2520@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Oct 01, 2008 at 04:14:35PM +0200, Benjamin Thery wrote:
>> This is the second version of a patch aimed at fixing a deadlock that
>> can occur when unregistering net devices. 
>>
>> This new version of the patch ensures the garbage collector 
>> dst_gc_task() is run when waiting in netdev_wait_allrefs(), by calling
>> it in the netdevice notifier dst_dev_event() when receiving a 
>> NETDEV_UNREGISTER event.
>>
>> Thanks to Jarek Poplawski for proposing this fix.
> 
> Not at all! Actually, I'm sorry for this mess... (Read below.)
> 
>> (The previous version proposed to replace in linkwatch_event()
>> the call to rntl_unlock() by __rtnl_lock())
> ...
>> --- net-next-2.6.orig/net/core/dst.c
>> +++ net-next-2.6/net/core/dst.c
>> @@ -328,6 +328,10 @@ static int dst_dev_event(struct notifier
>>  			dst_ifdown(dst, dev, event != NETDEV_DOWN);
>>  		}
>>  		mutex_unlock(&dst_gc_mutex);
>> +
>> +		if (event == NETDEV_UNREGISTER &&
>> +		    cancel_delayed_work(&dst_gc_work))
>> +			dst_gc_task(&dst_gc_work.work);
> 
> Hmm... It seems this shouldn't work yet: cancel_delayed_work() can only
> kill this while on timer, but not when queued and maybe blocked already.

Perhaps, I am misunderstanding but, dst_gc_work is always called with 
schedule_delayed_work. If the task is not running, we can cancel it and 
if the task is running, no need to trigger the gc, no ?

> Probably cancel_delayed_work_sync() should be considered instead, but
> since this needs more checking, and David is waiting for this, I think
> it's safer to use this previous (__rtnl_unlock) patch for now
> (especially for -stable).



