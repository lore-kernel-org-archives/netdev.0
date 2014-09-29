From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH] xen/xenbus: Use 'void' instead of 'int' for the return
 of xenbus_switch_state()
Date: Mon, 29 Sep 2014 18:14:18 +0100
Message-ID: <5429936A.7050905@citrix.com>
References: <5425961A.5000604@gmail.com> <20140929140229.GA28279@laptop.dumpdata.com> <542969E6.1010104@citrix.com> <20140929154055.GA31952@laptop.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chen Gang <gang.chen.5i5j@gmail.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <boris.ostrovsky@oracle.com>,
	<bhelgaas@google.com>, <jgross@suse.com>,
	<yongjun_wei@trendmicro.com.cn>, <mukesh.rathor@oracle.com>,
	<xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140929154055.GA31952@laptop.dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29/09/14 16:40, Konrad Rzeszutek Wilk wrote:
> On Mon, Sep 29, 2014 at 03:17:10PM +0100, David Vrabel wrote:
>> On 29/09/14 15:02, Konrad Rzeszutek Wilk wrote:
>>> On Sat, Sep 27, 2014 at 12:36:42AM +0800, Chen Gang wrote:
>>>> When xenbus_switch_state() fails, it will call xenbus_switch_fatal()
>>>
>>> Only on the first depth, not on the subsequent ones (as in if
>>> the first xenbus_switch_fail fails, it won't try to call
>>> xenbus_switch_state again and again).
>>>
>>>> internally, so need not return any status value, then use 'void' instead
>>>> of 'int' for xenbus_switch_state() and __xenbus_switch_state().
>>>
>>> When that switch occurs (to XenbusStateConnected) won't the watches
>>> fire - meaning we MUST make sure that the watch functions - if they
>>> use the xenbus_switch_state() they MUST not hold any locks - because
>>> they could be executed once more?
>>>
>>> Oh wait, we don't have to worry about that right now as the callbacks
>>> that pick up the messages from the XenBus are all gated on one mutex
>>> anyhow.
>>>
>>> Hm, anyhow, I would add this extra piece of information to the patch:
>>>
>>>
>>> diff --git a/drivers/xen/xen-pciback/xenbus.c b/drivers/xen/xen-pciback/xenbus.c
>>> index c214daa..f7399fd 100644
>>> --- a/drivers/xen/xen-pciback/xenbus.c
>>> +++ b/drivers/xen/xen-pciback/xenbus.c
>>> @@ -661,6 +661,12 @@ static void xen_pcibk_be_watch(struct xenbus_watch *watch,
>>>  
>>>  	switch (xenbus_read_driver_state(pdev->xdev->nodename)) {
>>>  	case XenbusStateInitWait:
>>> +		/*
>>> +		 * xenbus_switch_state can call xenbus_switch_fatal which will
>>> +		 * immediately set the state to XenbusStateClosing which
>>> +		 * means if we were reading for it here we MUST drop any
>>> +		 * locks so that we don't dead-lock.
>>> +		 */
>>
>> Watches are asynchronous and serialised by the xenwatch thread.  I can't
>> see what deadlock you're talking about here.  Particularly since the
>> backend doesn't watch its own state node (it watches the frontend one).
>>
>>>  		xen_pcibk_setup_backend(pdev);
>>>  		break;
>>>  
>>>>
>>>> Also need be sure that all callers which check the return value must let
>>>> 'err' be 0.
>>>
>>> I am bit uncomfortable with that, that is due to:
>>>
>>>
>>> .. snip..
>>>> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
>>>> index 9c47b89..b5c3d47 100644
>>>> --- a/drivers/net/xen-netback/xenbus.c
>>>> +++ b/drivers/net/xen-netback/xenbus.c
>>>> @@ -337,10 +337,7 @@ static int netback_probe(struct xenbus_device *dev,
>>>>  	if (err)
>>>>  		pr_debug("Error writing multi-queue-max-queues\n");
>>>>  
>>>> -	err = xenbus_switch_state(dev, XenbusStateInitWait);
>>>> -	if (err)
>>>> -		goto fail;
>>>> -
>>>> +	xenbus_switch_state(dev, XenbusStateInitWait);
>>>
>>> Which if it fails it won't call:
>>>
>>> 354 fail:                                                                           
>>> 355         pr_debug("failed\n");                                                   
>>> 356         netback_remove(dev);                                                    
>>> 357         return err;         
>>>
>>>
>>> And since there is no watch on the backend state to go in Closing it won't
>>> ever call those and we leak memory.
>>
>> It's not leaking the memory.  All resources will be recovered when the
>> device is removed.
> 
> I presume you mean when the XenBus entries are torn down? It does look
> like it would call the .remove functionality. That should take care of that.
> 
> In which case we can just remove all of the 'netback_remove()' and also
> remove some of the labels.

No.  If the final xenbus_switch_state() fails then at least the device
is in a consistent state, waiting for the other end to notice.

We don't want to return success from a probe with a half-setup device.

David
