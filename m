From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: Re: [PATCH 1/5] try parent numa_node at first before using default
Date: Wed, 11 Jul 2007 14:28:50 -0700
Message-ID: <46954B92.8000407@sun.com>
References: <200707101641.17672.yinghai.lu@sun.com>
 <200707101652.31378.yinghai.lu@sun.com> <4694B702.2050507@s5r6.in-berlin.de>
 <20070711210833.GA22745@kroah.com>
Reply-To: Yinghai.Lu@Sun.COM
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:34737 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbXGKVZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 17:25:34 -0400
In-reply-to: <20070711210833.GA22745@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH wrote:
> On Wed, Jul 11, 2007 at 12:54:58PM +0200, Stefan Richter wrote:
>> Yinghai Lu wrote:
>>> --- a/drivers/base/core.c
>>> +++ b/drivers/base/core.c
>>> @@ -547,6 +547,8 @@ static void klist_children_put(struct klist_node *n)
>>>  
>>>  void device_initialize(struct device *dev)
>>>  {
>>> +	int node;
>>> +
>>>  	kobj_set_kset_s(dev, devices_subsys);
>>>  	kobject_init(&dev->kobj);
>>>  	klist_init(&dev->klist_children, klist_children_get,
>>> @@ -557,7 +559,9 @@ void device_initialize(struct device *dev)
>>>  	spin_lock_init(&dev->devres_lock);
>>>  	INIT_LIST_HEAD(&dev->devres_head);
>>>  	device_init_wakeup(dev, 0);
>>> -	set_dev_node(dev, -1);
>>> +
>>> +	node = dev->parent ? dev_to_node(dev->parent) : -1;
>>> +	set_dev_node(dev, node);
>>>  }
>> Two remarks:
>>
>>   - device_add() is perhaps a better place to do this.  Otherwise you
>>     had to change code like drivers/input/gameport/gameport.c::
>>     gameport_init_port() which sets the parent device *after* the
>>     call to device_initialize().
if other device overwrite that, it is OK.
even for all pci_dev, pci_device_add will call set_dev_node(&dev->dev, pcibus_to_node(bus));
to overwrite it.
but for netdev under pci_dev, it will get node from pci_dev directly.

> 
> I agree, lots of code sets up the parent pointer after initialize and
> before add.  One such example is the whole USB subsystem.
> 
> Which makes me wonder how this code was really tested at all to show
> that it actually had an affect...

original default is -1, and this patch just try to use parent's node as default.

YH
