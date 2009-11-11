From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/10] AOE: use rcu to find network device
Date: Tue, 10 Nov 2009 22:48:40 -0800 (PST)
Message-ID: <20091110.224840.64461109.davem@davemloft.net>
References: <8ffe0a1df67d13a45a413f40d00dd80a@coraid.com>
	<20091110150617.0e6920f0@nehalam>
	<20091110155316.2c3d7b6e@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: karaluh@karaluh.pl, ecashin@coraid.com, roel.kluin@gmail.com,
	harvey.harrison@gmail.com, bzolnier@gmail.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40911
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753227AbZKKGsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:48:13 -0500
In-Reply-To: <20091110155316.2c3d7b6e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 10 Nov 2009 15:53:16 -0800

> On Tue, 10 Nov 2009 15:06:17 -0800
> Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
>> On Tue, 10 Nov 2009 15:01:49 -0500
>> Ed Cashin <ecashin@coraid.com> wrote:
>> 
>> > On Tue Nov 10 13:07:37 EST 2009, shemminger@vyatta.com wrote:
>> > > This gets rid of another use of read_lock(&dev_base_lock) by using
>> > > RCU. Also, it only increments the reference count of the device actually
>> > > used rather than holding and releasing every device
>> > > 
>> > > Compile tested only.
>> > 
>> > This function runs once a minute when the aoe driver is loaded,
>> > if you'd like to test it a bit more.
>> > 
>> > It looks like there's no dev_put corresponding to the dev_hold
>> > after the changes.
>> > 
>> 
>> Hmm, looks like AOE actually is not ref counting the network device.
>> So my patch is incorrect. 
>> 
>> As it stands (before my patch), it is UNSAFE. It can decide to queue
>> packets to a device that is removed out from underneath it causing
>> reference to freed memory.
>> 
>> Moving the rcu_read_lock up to aoecmd_cfg() would solve that but the
>> whole driver appears to be unsafe about device refcounting and handling
>> device removal properly.  
>> 
>> It needs to:
>> 
>> 1. Get a device ref count when it remembers a device: (ie addif)
>> 2. Install a notifier that looks for device removal events
>> 3. In notifier, remove interface, including flushing all pending
>>    skb's for that device.
>> 
>> This obviously is beyond the scope of the RCU stuff.
> 
> Here is a patch to get you going, it does compile but it probably
> won't work because the code doesn't handle the case of the last
> device going away from a target. This is yet another pre-existing
> bug, since if a timeout happens: ejectif() is called to remove a device,
> resend() will BUG in ifrotate() if all devices are gone.

I'm holding off on the RCU patch until these known refcount bugs are
fixed
