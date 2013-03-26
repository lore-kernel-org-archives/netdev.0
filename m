From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: Active URB submitted twice in pegasus driver
Date: Tue, 26 Mar 2013 19:28:53 +0200 (EET)
Message-ID: <alpine.DEB.2.02.1303261909260.4226@fry.nucleusys.com>
References: <20130325223834.GF6869@xanatos> <alpine.DEB.2.02.1303261655450.3724@fry.nucleusys.com> <20130326170140.GC10317@xanatos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: linux-usb@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:60341 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752941Ab3CZR3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 13:29:04 -0400
In-Reply-To: <20130326170140.GC10317@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Mar 2013, Sarah Sharp wrote:

> On Tue, Mar 26, 2013 at 05:22:07PM +0200, Petko Manolov wrote:
>> On Mon, 25 Mar 2013, Sarah Sharp wrote:
>>
>>> Hi Petko,
>>>
>>> I'm testing a USB to ethernet adapter with Greg's usb-linus branch (based
>>> on 3.9-rc4).  I'm seeing an odd behavior, and I'm suspicious that a
>>> second behavior found by Stephen Hemminger may also be related:
>>>
>>> http://marc.info/?l=linux-usb&m=136364625519235&w=2
>>>
>>> When I load the pegasus driver for this adapter (without an ethernet
>>> cable hooked to it), and this is on a cold system boot or a complete
>>> unloading and reloading of the usbcore, I get the following warning:
>>
>> Unfortunately the machine i ran my tests on does not have xHCI nor i
>> used Greg's tree.  I did not observe this warning on both 3.8.4 and
>> Linus' 3.9-rc4.  It looks like to me that the issue is outside the
>> driver code.
>
> Or it could be a race condition that's only triggered by the xHCI driver
> (or me having xHCI debugging turned on).  Control transfer completions
> may be delayed when I have debug turned on.

They most likely are.  However, considering the stuff below these delays 
may not be the real cause.

> The only other USB to ethernet adapter I have is also an ADMteck device:
>
> Bus 001 Device 008: ID 07a6:8513 ADMtek, Inc. AN8513 Ethernet

I've got another one, rtl8150 based adapter.  The way things look i'll 
have to do some testing on my own.

> What do you mean by an asynchronous call?  Do you mean that
> xxx_set_multicast() could be called at any time?

Yep.  The first call to pegasus_set_multicast() is done by the network 
layer upon device insertion and those often happen outside process 
context.

> After taking a brief glance at the pegasus code, pegasus_set_multicast 
> looks broken.  It sets the control URB status to zero and calls 
> ctrl_callback(), which does some stuff if the URB status is zero.  It 
> doesn't look like pegasus_set_multicast() is an URB callback function, 
> so why in the world is it touching a control URB that could possibly be 
> in flight else where?

Beats me, i've got nothing to do with this driver. :-P

Anyway, playing with the URB status looks rather stupid and is definitely 
a bug.  I'll make a patch that fixes the problem.

> It looks like the control URB is used to do things like get or set 
> registers, so what's stopping the upper layers from calling get 
> registers (which will submit the control URB and schedule a wait queue), 
> and then pegasus_set_multicast(), which will go overwrite the active URB 
> status?  USB device drivers should not be writing or reading fields in a 
> submitted URB until the completion handler's callback function is 
> called.

Err, see my previous comment.  It can't be me.  Maybe i've been too drunk. 
Or stupid.  Or both... :-)
