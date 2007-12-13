From: Dor Laor <dor.laor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH resent] virtio_net: Fix stalled inbound
 trafficon early packets
Date: Thu, 13 Dec 2007 15:24:07 +0200
Message-ID: <47613277.3060403@qumranet.com>
References: <200712111242.28843.borntraeger@de.ibm.com>
	<200712121239.51435.borntraeger@de.ibm.com>
	<476002E7.5050301@qumranet.com>
	<200712121914.38135.borntraeger@de.ibm.com>
Reply-To: dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel <kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <200712121914.38135.borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
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

Christian Borntraeger wrote:
> Am Mittwoch, 12. Dezember 2007 schrieb Dor Laor:
>   
>> I think the change below handles the race. Otherwise please detail the 
>> use case.
>>     
> [...]
>   
>>> @@ -292,6 +292,9 @@ static int virtnet_open(struct net_devic
>>>                 return -ENOMEM;
>>>
>>>         napi_enable(&vi->napi);
>>> +
>>> +       vi->rvq->vq_ops->enable(vi->rvq);
>>> +       vi->svq->vq_ops->enable(vi->svq);
>>>
>>>       
>> If you change it to:
>> if (!vi->rvq->vq_ops->enable(vi->rvq))
>>     vi->rvq->vq_ops->kick(vi->rvq);
>> if (!vi->rvq->vq_ops->enable(vi->svq))
>>     vi->rvq->vq_ops->kick(vi->svq);
>>
>> You solve the race of packets already waiting in the queue without 
>> triggering the irq.
>>     
>
> Hmm, I dont fully understand your point. I think this will work as long as 
> the host has not consumed all inbound buffers. It will also require that 
> the host sends an additional packet, no? If no additional packet comes the 
> host has no reason to send an interrupt just because it got a notify 
> hypercall. kick inside a guest also does not trigger the poll routine. 
>
> It also wont work on the following scenario:
> in virtnet open we will allocate buffers and send them to the host using the 
> kick callback. The host can now use _all_ buffers for incoming data while 
> interrupts are still disabled and the guest is not running.( Lets say the 
> host bridge has lots of multicast traffic and the guest gets not scheduled 
> for a while). When the guest now continues and enables the interrupts 
> nothing happens. Doing a kick does not help, as the host code will bail out 
> with "no dma memory for transfer".
>   
> Christian
>
>   
You're right I got confused somehow.
So in that case setting the driver status field on open in addition to 
your enable will do the trick.
On DRIVER_OPEN the host will trigger an interrupt if the queue is not 
empty..
Thanks,
Dor

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
