From: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Subject: Re: [PATCH v2 3/7] [PATCH 3/8] can: CAN Network device driver and
 Netlink interface
Date: Fri, 15 May 2009 09:15:03 +0200
Message-ID: <4A0D1677.4020209@volkswagen.de>
References: <20090512092757.048938233@denx.de><20090512092757.574693100@denx.de> <20090512233052.ecd600f1.akpm@linux-foundation.org> <4A0A9AC1.2090603@volkswagen.de> <4A0AB17B.3080308@grandegger.com> <4A0AB824.40702@volkswagen.de> <4A0ABBD3.2030605@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxout1.volkswagen.de ([194.114.62.41]:27781 "EHLO
	mxout1.volkswagen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754716AbZEOHPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 03:15:20 -0400
In-Reply-To: <4A0ABBD3.2030605@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Oliver Hartkopp wrote:
>   
>> Wolfgang Grandegger wrote:
>>     
>>> Oliver Hartkopp wrote:
>>>  
>>>       
>>>> Andrew Morton wrote:
>>>>    
>>>>         
>>>>> On Tue, 12 May 2009 11:28:00 +0200 Wolfgang Grandegger
>>>>> <wg@grandegger.com> wrote:
>>>>>
>>>>>  
>>>>>      
>>>>>           
>>>>>> +int can_restart_now(struct net_device *dev)
>>>>>> +{
>>>>>> +    struct can_priv *priv = netdev_priv(dev);
>>>>>> +    struct net_device_stats *stats = &dev->stats;
>>>>>> +    struct sk_buff *skb;
>>>>>> +    struct can_frame *cf;
>>>>>> +    int err;
>>>>>> +
>>>>>> +    /* Synchronize with dev->hard_start_xmit() */
>>>>>> +    netif_tx_lock(dev);
>>>>>> +
>>>>>> +    /* Ensure that no more messages can go out */
>>>>>> +    if (netif_carrier_ok(dev))
>>>>>> +        netif_carrier_off(dev);
>>>>>> +
>>>>>> +    /* Ensure that no more messages can come in */
>>>>>> +    err = priv->do_set_mode(dev, CAN_MODE_STOP);
>>>>>> +    if (err)
>>>>>> +        return err;
>>>>>> +
>>>>>> +    /*  Now it's save to clean up */
>>>>>> +    del_timer_sync(&priv->restart_timer);
>>>>>>             
>>>>>>             
>>>>> This is deadlockable.
>>>>>
>>>>> It calls del_timer_sync() while holding netif_tx_lock().  But the timer
>>>>> handler (can_restart_now()) also takes netif_tx_lock().  So if the
>>>>> timer handler is presently running, it's sitting there spinning in
>>>>> netif_tx_lock().  And del_timer_sync() is sitting there waiting for the
>>>>> timer handler to complete.
>>>>>
>>>>>
>>>>>         
>>>>>           
>>>> Hi Wolfgang,
>>>>
>>>> would it be an appropriate solution, just to invoke
>>>>
>>>> netif_stop_queue() in can_bus_off()
>>>>
>>>> and invoke
>>>>
>>>> netif_wake_queue() in can_restart_now()
>>>>
>>>> ???
>>>>
>>>> In a BUSOFF condition we're not able to send CAN frames anyway, so  we
>>>> can disable the device queue and the we won't  need any netif_tx_lock()
>>>> right?
>>>>
>>>> AFAIK this was the original implementation before some of the latest
>>>> improvement with the netif_carrier stuff.
>>>>
>>>> What do you think?
>>>>     
>>>>         
>>> The problem is the "manual" restart triggered via the netlink interface,
>>> which can occur in the middle of ndo_start_xmit().
>>>
>>>   
>>>       
>> Ah, i see.
>>
>> What if the manual restart via netlink would also stop the queue and
>> start the timer?
>>     
>
> It will not help if the restart is triggered in the middle of
> ndo_start_xmit().
>
>   

Hi Wolfgang,

i think, i found a solution that removes the locking problem completely:

When a bus-off occurs in the controller, the communication on the CAN 
bus can be treated as unusable for this controller (let's say it is dead).
E.g. the SJA1000 set's its reset bit for that reason and waits to be 
initialized by the CPU again.

So IMO restarting the CAN controller while in operational state is not a 
valid use case.

When a bus-off (interrupt) occurs, we should

- invoke netif_carrier_off(dev)
- invoke netif_stop_queue(dev)
- set the state to CAN_STATE_BUS_OFF

and of course create the error message, clear the interrupts(!) and then 
leave the irq service function.

That's it.

When the automatic CAN controller restart is enabled: start the timer.

For the manual netlink function: Test for CAN_STATE_BUS_OFF (!) and 
invoke the current can_restart_now(dev) or start the timer with e.g. 1ms ...

This approach should make it and fulfills the bus-off intention of the 
CAN controllers ("disabled and wait for re-initialisation").

And there's no locking of the tx_queue needed anymore as the tx_queue is 
already stopped, when the restart is performed.

What do you think about this approach?

Regards,
Oliver

