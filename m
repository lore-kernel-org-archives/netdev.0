From: Mark Huth <mhuth@mvista.com>
Subject: Re: [Kgdb-bugreport] [PATCH 2.6.20-rc7] 8139too KGDBoE fix
Date: Fri, 23 Feb 2007 11:10:40 -0700
Message-ID: <45DF2E20.305@mvista.com>
References: <200701312144.56497.sshtylyov@ru.mvista.com> <45DDBD96.10000@ru.mvista.com> <45DDC7C0.8050100@ru.mvista.com> <200702231238.40474.amitkale@linsyssoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	Mithlesh Thukral <mithlesh@linsyssoft.com>,
	Vitaly Wool <vwool@ru.mvista.com>
To: "Amit S. Kale" <amitkale@linsyssoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:36329 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932478AbXBWSLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Feb 2007 13:11:03 -0500
In-Reply-To: <200702231238.40474.amitkale@linsyssoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit S. Kale wrote:
> Hi Net Gurus,
>
> This thread came up on kgdb-bugreport mailing list. Could you please suggest 
> us what's the correct way of fixing this problem?
>
> 1. When running a kgdb on RTL8139 ethernet interface: 8139too driver prints 
> too many "Out-of-sync dirty pointer" messages on console and gdb can't 
> connect to kgdb stub. These messages can be suppressed, though it still 
> results in connection failures frequently. 
>   
We think this comes from calling the driver while the queue is stopped.  
Drivers should not do horrible things when hard start is called with the 
queue stopped, but unfortunately, at this time, at least some drivers 
do  explode or complain under that condition.
> 2. Here is how kgdb uses polling mechanism for communication to gdb.  kgdb 
> calls netpoll_set_trap(1) just before entering a loop where it communicates 
> to gdb. It calls netpoll_set_trap(0) after it is done and wants to resume a 
> kernel. The communication to gdb goes through netpoll_poll (which calls kgdb 
> rx_hook) and netpoll_send_udp functions.
>
> 3. A queue for an interface may have been stopped by it's driver by calling 
> netif_stop_queue. After this if kgdb attempts to enter communication with 
> gdb, it'll call netpoll_set_trap(1), after which the queue can't be started 
> again. This is a potential deadlock situation. Is there a way out of this?
>   
We are trying without setting the CONFIG_NETPOLL_TRAP option.  This 
option is what turns off the function of the netif_stop/wake_queue 
calls, which breaks the usual flow control mechanism used by netpoll 
transmit function.  It also prevents the netif_schedule call, which will 
puts the device on the tx softirq queue.  However, in the case where 
interupts are off and scheduling is not allowed - which would be the 
netpoll_set_trap(1) condition, the softirq will not run until netpoll is 
done and the user of netpoll returns the system to normal operation.  So 
I am unclear that allowing the schedule is a problem.  There may be some 
obscure race conditions on smp, so we are trying to analyze that part, 
but for the moment are testing with the netif_schedule call allowed in 
the event of queuing the device.
> 4. Is it necessary to call netpoll_set_trap(1) at all before entering gdb 
> communication loop? Even if a driver stops the queue in middle of the 
> communication netpoll_poll and netpoll_send_udp calls can recover from that 
> by calling driver's interrupt and poll routines. Is this a valid statement?
>   
netpoll_set_trap() is necessary, as it informs the netpoll code to 
respond to arp requests on behalf of the netpoll user, as well as making 
sure that skbs are freed without needing the completion queue stuff to 
run (I think)
> Thanks a lot.
> -Amit
>
>
>
> On Thursday 22 February 2007 22:11, Sergei Shtylyov wrote:
>   
>> Hello, I wrote:
>>     
>>>>>>>>> Even with this patch, the packets probably get stuck somewhere in
>>>>>>>>> the driver, as cross-gdb sees tail of the $g packet reply only in
>>>>>>>>> reply to next packet...
>>>>>>>>>                   
>>>>>  This wasn;t happeing on x86 probably because the register packet
>>>>> should be much shorted there than on PPC...
>>>>>
>>>>>           
>>>>>>>>  Argh! That's all because of the CONFIG_NETPOLL_TRAP that
>>>>>>>> CONFIG_KGDBOE* options select -- since the initial breakpoint enables
>>>>>>>> trapping via KGDBoE's pre_exception() handler,
>>>>>>>> netif_{stop/wake}_queue() stop to work and that causes KGDBoE to
>>>>>>>> literally flood 8139too with packets (although it can't queue up
>>>>>>>> more than 4). Looks like a general design issue to me... :-/
>>>>>>>>                 
>>>>>>> Well, maybe not. But many drivers are surely unprepared to their
>>>>>>> hard_start_xmit() method being called with queue alraedy stopped and
>>>>>>> those with small TX queue (like natsemi with which we're also having
>>>>>>> trouble) would get flooded as well. I'm going to submit a patch to
>>>>>>> netdev adding extra check for TX ring being full -- after/if it gets
>>>>>>> accepted, this patch won't be needed anymore.
>>>>>>>               
>>>>>> Here is what comes to my mind right away. It might need some more
>>>>>> polishing or cleaning up:
>>>>>>
>>>>>> A potential solution will be to check the if hard_start_xmit() returns
>>>>>> NETDEV_TX_BUSY. In case transmit queue is busy (due to lot of threads
>>>>>> or queue getting full), we should wait in netpoll_send_skb(), call a
>>>>>> cleanup through poll() and then retry sending packet.
>>>>>>             
>>>>>   This is already being done by netpoll iself. The thing is that
>>>>> hard_start_xmit() doesdn't return NETDEV_TX_BUSY in those drivers. :-/
>>>>>           
>>>> In addition to that we set trapped. I wonder whether it is possible that
>>>> a queue is stopped and we enter kgdb. It would be a deadlock.
>>>> -Amit
>>>>         
>>>     Why? Netpoll does call the driver's interrupt and NAPI handlers in
>>> that case (until the retry count is 0).
>>>       
>>     Ah, got it -- since the traffic trapping (when enabled) effectively
>> bypasses netif_wake_queue(), a queue would never be actually woken up.
>> Maybe it's worth to always return 0 from netif_queue_stopped() in this
>> case? Or maybe the correct thing to do when trapping is to just thiddle the
>> __LINK_STATE_XOFF bit, bypassing call to netif_schedule()?
>>
>>     
>>>>>> Regards,
>>>>>> Mithlesh Thukral
>>>>>>             
>> WBR, Sergei
>>
>> -------------------------------------------------------------------------
>> Take Surveys. Earn Cash. Influence the Future of IT
>> Join SourceForge.net's Techsay panel and you'll get the chance to share
>> your opinions on IT & business topics through brief surveys-and earn cash
>> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
>> _______________________________________________
>> Kgdb-bugreport mailing list
>> Kgdb-bugreport@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport
>>     
>
>   

