From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next PATCH 1/6] enic: Bug fix: use safe queue shutdown in
 dev->stop
Date: Sat, 19 Dec 2009 12:44:19 -0800
Message-ID: <C7527B23.1B005%scofeldm@cisco.com>
References: <1261236899.2418.93.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:42526 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbZLSUoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2009 15:44:22 -0500
In-Reply-To: <1261236899.2418.93.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/09 7:34 AM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:

> On Fri, 2009-12-18 at 18:09 -0800, Scott Feldman wrote:
>> enic: Bug fix: use safe queue shutdown in dev->stop
>> 
>> Fix dev->stop shutdown bug where driver was stopping xmit queue and then
>> disabling intrs.  Fix is to disable intrs first and then stop the xmit
>> queue, otherwise an interrupt could cause the queue to be rewoken.  Also,
>> no need to explicitly do queue servicing because queues are cleaned and
>> reset back to initial state at end of dev->stop.  Servicing queues also
>> had the side-effect of also rewakening the xmit queue, which is not what
>> we want.
> [...]
>> @@ -1409,16 +1382,18 @@ static int enic_stop(struct net_device *netdev)
>> unsigned int i;
>> int err;
>>  
>> + for (i = 0; i < enic->intr_count; i++)
>> +  vnic_intr_mask(&enic->intr[i]);
>> +
> 
> I think you need to use synchronize_irq() after this.

I think you're right.  That's what I want: all intrs masked and no IRQs
running.  I also need to add a PIO read to flush the PIO write to mask.

I want intrs shut down from here on.
 
>> del_timer_sync(&enic->notify_timer);
>>  
>> spin_lock(&enic->devcmd_lock);
>> vnic_dev_disable(enic->vdev);
>> spin_unlock(&enic->devcmd_lock);
>> napi_disable(&enic->napi);
>> - netif_stop_queue(netdev);
>> -
>> - for (i = 0; i < enic->intr_count; i++)
>> -  vnic_intr_mask(&enic->intr[i]);
>> + netif_tx_disable(netdev);
>> + msleep(10);
> 
> This sleep is suspicious.

Ya, that can go.  Netif_tx_disable grabs netif_tx_lock, so we should be
synced with xmit_hard_start.  Forgot to delete that when we had
netif_stop_queue.
 
>> + netif_carrier_off(netdev);
> [...]
> 
> And this should be unnecessary.

We don't have any way to get true link status when the interface is down, so
this forces us to always report link status down when the interface is down.

-scott

