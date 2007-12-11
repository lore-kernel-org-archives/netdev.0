From: Dor Laor <dor.laor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH resent] virtio_net: Fix stalled inbound
 trafficon early packets
Date: Tue, 11 Dec 2007 14:57:17 +0200
Message-ID: <475E892D.9060400@qumranet.com>
References: <200712111242.28843.borntraeger@de.ibm.com>
	<475E8716.2010500@qumranet.com>
Reply-To: dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel <kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <475E8716.2010500-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This time I send in text so netdev list won't reject it; sorry.
Dor Laor wrote:
> Christian Borntraeger wrote:
>>
>> Hello Rusty,
>>
>> while implementing and testing virtio on s390 I found a problem in
>> virtio_net: The current virtio_net driver has a startup race, which
>> prevents any incoming traffic:
>>
>> If try_fill_recv submits buffers to the host system data might be
>> filled in and an interrupt is sent, before napi_enable finishes.
>> In that case the interrupt will kick skb_recv_done which will then
>> call netif_rx_schedule. netif_rx_schedule checks, if NAPI_STATE_SCHED
>> is set - which is not as we did not run napi_enable. No poll routine
>> is scheduled. Furthermore, skb_recv_done returns false, we disables
>> interrupts for this device.
>>
>> One solution is the enable napi before inbound buffer are available.
>>
> But then you might get recv interrupt without a buffer.
> The way other physical NICs doing it is by dis/en/abling interrupt 
> using registers (look at e1000).
> I suggest we can export add_status and use the original code but
> before enabling napi add a call to add_status(dev, 
> VIRTIO_CONFIG_DEV_OPEN).
> The host won't trigger an irq until it sees the above.
>
> BTW: Rusty is on vacation and that's probably the reason he didn't 
> respond.
> Regards,
> Dor.
>>
>> Signed-off-by: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
>> ---
>>  drivers/net/virtio_net.c |    6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> Index: kvm/drivers/net/virtio_net.c
>> ===================================================================
>> --- kvm.orig/drivers/net/virtio_net.c
>> +++ kvm/drivers/net/virtio_net.c
>> @@ -285,13 +285,15 @@ static int virtnet_open(struct net_devic
>>  {
>>         struct virtnet_info *vi = netdev_priv(dev);
>>
>> +       napi_enable(&vi->napi);
>>         try_fill_recv(vi);
>>
>>         /* If we didn't even get one input buffer, we're useless. */
>> -       if (vi->num == 0)
>> +       if (vi->num == 0) {
>> +               napi_disable(&vi->napi);
>>                 return -ENOMEM;
>> +       }
>>
>> -       napi_enable(&vi->napi);
>>         return 0;
>>  }
>>
>>
>> -------------------------------------------------------------------------
>> SF.Net email is sponsored by:
>> Check out the new SourceForge.net Marketplace.
>> It's the best place to buy or sell services for
>> just about anything Open Source.
>> http://sourceforge.net/services/buy/index.php
>> _______________________________________________
>> kvm-devel mailing list
>> kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
>> https://lists.sourceforge.net/lists/listinfo/kvm-devel
>>
>


-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
