From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 3/7] [PATCH 3/8] can: CAN Network device driver and
 Netlink interface
Date: Wed, 13 May 2009 13:39:39 +0200
Message-ID: <4A0AB17B.3080308@grandegger.com>
References: <20090512092757.048938233@denx.de><20090512092757.574693100@denx.de> <20090512233052.ecd600f1.akpm@linux-foundation.org> <4A0A9AC1.2090603@volkswagen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:52755 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbZEMLjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 07:39:40 -0400
In-Reply-To: <4A0A9AC1.2090603@volkswagen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp wrote:
> Andrew Morton wrote:
>> On Tue, 12 May 2009 11:28:00 +0200 Wolfgang Grandegger
>> <wg@grandegger.com> wrote:
>>
>>  
>>> +int can_restart_now(struct net_device *dev)
>>> +{
>>> +    struct can_priv *priv = netdev_priv(dev);
>>> +    struct net_device_stats *stats = &dev->stats;
>>> +    struct sk_buff *skb;
>>> +    struct can_frame *cf;
>>> +    int err;
>>> +
>>> +    /* Synchronize with dev->hard_start_xmit() */
>>> +    netif_tx_lock(dev);
>>> +
>>> +    /* Ensure that no more messages can go out */
>>> +    if (netif_carrier_ok(dev))
>>> +        netif_carrier_off(dev);
>>> +
>>> +    /* Ensure that no more messages can come in */
>>> +    err = priv->do_set_mode(dev, CAN_MODE_STOP);
>>> +    if (err)
>>> +        return err;
>>> +
>>> +    /*  Now it's save to clean up */
>>> +    del_timer_sync(&priv->restart_timer);
>>>     
>>
>> This is deadlockable.
>>
>> It calls del_timer_sync() while holding netif_tx_lock().  But the timer
>> handler (can_restart_now()) also takes netif_tx_lock().  So if the
>> timer handler is presently running, it's sitting there spinning in
>> netif_tx_lock().  And del_timer_sync() is sitting there waiting for the
>> timer handler to complete.
>>
>>
>>   
> 
> Hi Wolfgang,
> 
> would it be an appropriate solution, just to invoke
> 
> netif_stop_queue() in can_bus_off()
> 
> and invoke
> 
> netif_wake_queue() in can_restart_now()
> 
> ???
> 
> In a BUSOFF condition we're not able to send CAN frames anyway, so  we
> can disable the device queue and the we won't  need any netif_tx_lock()
> right?
> 
> AFAIK this was the original implementation before some of the latest
> improvement with the netif_carrier stuff.
> 
> What do you think?

The problem is the "manual" restart triggered via the netlink interface,
which can occur in the middle of ndo_start_xmit().

Wolfgang.

