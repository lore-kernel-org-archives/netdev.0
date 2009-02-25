From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [Powerpc / eHEA] Circular dependency with 2.6.29-rc6
Date: Wed, 25 Feb 2009 18:07:05 +0100
Message-ID: <49A57AB9.3000502@de.ibm.com>
References: <49A26290.60607@in.ibm.com>  <49A55E54.4080304@de.ibm.com> <1235577013.4645.3548.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: TKLEIN@de.ibm.com, Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Mel Gorman <mel@csn.ul.ie>, netdev <netdev@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev@ozlabs.org, Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:43744 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbZBYRHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 12:07:10 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.14.3/8.13.8) with ESMTP id n1PH77lN356940
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 17:07:07 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1PH77qe1110196
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 18:07:07 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1PH76ki025699
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 18:07:07 +0100
In-Reply-To: <1235577013.4645.3548.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

yes, sorry for the funny wrapping... and thanks for your quick answer!

Peter Zijlstra wrote:
> On Wed, 2009-02-25 at 16:05 +0100, Jan-Bernd Themann wrote:
>
>   
>> - When "open" is called for a registered network device, port->port_lock
>> is taken first,
>>   then ehea_fw_handles.lock
>> - When "open" is left these locks are released in a proper way (inverse
>> order)
>>     
>
> So this has:
>
>   port->port_lock
>     ehea_fw_handles.lock
>
> This would be the case that is generating the warning.
>
>   
>> - In addition: ehea_fw_handles.lock is held by the function
>> "driver_probe_device"
>>   that registers all available network devices (register_netdev)
>> - When multiple network devices are registered, it is possible that
>> "open" is
>>   called on an already registered network device while further
>> netdevices are still registered
>>   in "driver_probe_device". ---> "open" will take port->port_lock, but
>> won't get ehea_fw_handles.lock
>>     
>
> Right, so here you have 
>
>   ehea_fw_handles.lock
>     port->port_lock
>
> Overlay these two cases and you have AB-BA deadlocks.
>
>   
The thing here is that I did not see that "open" is called from this
"probe" function,
this happens probably indirectly as each new device causes a notifier chain
to be called --> If I got it right then a userspace tool triggers the
"open".
In that case the open would run in an other task/thread and thus when
the kernel
preemts the task/thread the probe function would continue and free the lock.

Lets assume that it is actually possible that "open" is called in the
same context as
"probe", wound't that mean that we actually need to hit a deadlock?
(probe helds
the lock all the time). We have never observed a deadlock so far.

Is there a way to find out if all these locks are actually taken in the
same context
(kthread, tasklet...)?

>> - However, ehea_fw_handles.lock is freed once all netdevices are registered.
>> - When the second netdevice is registered in "driver_probe_device", it
>> will also try to get
>>   the port->port_lock (which in fact is a different one, as there is one
>> per netdevice).
>> - Does the mutex debug mechanism distinguish between the different
>> port->port_lock instances?
>>     
>
> Not unless you tell it to.
>   
> Are you really sure the port->port_lock in this AB-BA scenario are never
> the same? The above explanation didn't convince me (also very hard to
> read due to funny wrapping).
>   
I'm not sure, especially as I just ran the same test with just one port
and we still
get the warning. But having two instances of port accessing the locks
does not
look like a problem to me as they allocate and free the locks properly
(right order).

> Suppose you do an open concurrently with a re-probe, which apparently
> takes port->port_lock's of existing devices, in the above scenario that
> deadlocks.
>
>   

