From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Fri, 01 Jan 2010 08:51:23 +0900
Message-ID: <4B3D38FB.40105@ring3k.org>
References: <4B3C8323.1080301@ring3k.org> <4B3CF2C4.5070203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	flyboy@gmail.com, dhazelton@enter.net, mbreuer@majjas.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.216.174]:54867 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbZLaXyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 18:54:52 -0500
Received: by pxi4 with SMTP id 4so9662348pxi.33
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2009 15:54:51 -0800 (PST)
In-Reply-To: <4B3CF2C4.5070203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Jarek,

This is based on my analysis of the oops at:

http://bugzilla.kernel.org/show_bug.cgi?id=14925

Specifically:

>>> [ 8673.345873] sky2 eth0: receiver hang detected
>>> [ 8673.350368] sky2 eth0: disabling interface
>>> [ 8673.354749] BUG: unable to handle kernel NULL pointer dereference at
>>> 0000000000000010
>>> [ 8673.359748] IP: [<ffffffffa00373d3>] sky2_xmit_frame+0x321/0x5d8 
>>> [sky2]

netif_device_detach() does not guarantee that all transmits have completed 
after it returns.

CPU 1 stack will look like:

  dev_queue_xmit()
     HARD_TX_LOCK() -> __netif_tx_lock()
     ...
     dev_hard_start_xmit()
        ops->ndo_start_xmit()  -> sky2_xmit_frame()
        sky2_xmit_frame() pushing skb to hardware
          use NULL tx_ring here


CPU 2 stack will look like:
           
  sky2_restart()
     rtnl_lock()
     sky2_detach()
        netif_device_detach()
        sky2_down()
          printk("sky2 eth0: disabling interface")
          ...
          sky2_free_buffers(sky2);
            sky2->tx_ring = NULL;
          ...

Another way to solve the problem would be to take the transmit lock in 
netif_device_detach() to make sure that any in progress transmits have
completed before returning.

Note that most of these backtraces are using the nvidia binary only 
module.  This may change the timings and make the sky2 race more likely,
or be involved in the "tx timeout" condition that triggers a sky2_restart().

Will test with netif_tx_lock_bh and resubmit.

thanks,

Mike
     
  
   

Jarek Poplawski wrote:
> Mike McCormack wrote, On 12/31/2009 11:55 AM:
> 
>> netif_device_detach() does not take the tx_lock, so it's
>>  possible that a call to sky2_xmit_frame is still in
>>  progress after netif_device_detach() is complete.
>>
>> Take netif_tx_lock() to make sure all transmits have
>>  stopped while we're disabling the devices and that
>>  no other CPU is still transmitting a frame after
>>  we've disabling the device.
>>
>> Proposed fix for "sky2 panic under load" reported by Berck E. Nash.
> 
> Could you give some scenario of the oops/fix?
> Btw, even if it worked, you should use netif_tx_lock_bh
> version considering sky2_detach use contexts, I guess.
> 
> Jarek P.
> 
>> Signed-off-by: Mike McCormack <mikem@ring3k.org>
>> ---
>>  drivers/net/sky2.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
>> index faa4841..8ae8520 100644
>> --- a/drivers/net/sky2.c
>> +++ b/drivers/net/sky2.c
>> @@ -3176,7 +3176,9 @@ static void sky2_reset(struct sky2_hw *hw)
>>  static void sky2_detach(struct net_device *dev)
>>  {
>>  	if (netif_running(dev)) {
>> +		netif_tx_lock(dev);
>>  		netif_device_detach(dev);	/* stop txq */
>> +		netif_tx_unlock(dev);
>>  		sky2_down(dev);
>>  	}
>>  }
> 
> 

