From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 04/10] AOE: use rcu to find network device
Date: Tue, 10 Nov 2009 15:06:17 -0800
Message-ID: <20091110150617.0e6920f0@nehalam>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.409162953@vyatta.com>
	<8ffe0a1df67d13a45a413f40d00dd80a@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ecashin@coraid.com, harvey.harrison@gmail.com,
	bzolnier@gmail.com, netdev@vger.kernel.org
To: Ed Cashin <ecashin@coraid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37926 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758634AbZKJXGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 18:06:34 -0500
In-Reply-To: <8ffe0a1df67d13a45a413f40d00dd80a@coraid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2009 15:01:49 -0500
Ed Cashin <ecashin@coraid.com> wrote:

> On Tue Nov 10 13:07:37 EST 2009, shemminger@vyatta.com wrote:
> > This gets rid of another use of read_lock(&dev_base_lock) by using
> > RCU. Also, it only increments the reference count of the device actually
> > used rather than holding and releasing every device
> > 
> > Compile tested only.
> 
> This function runs once a minute when the aoe driver is loaded,
> if you'd like to test it a bit more.
> 
> It looks like there's no dev_put corresponding to the dev_hold
> after the changes.
> 

Hmm, looks like AOE actually is not ref counting the network device.
So my patch is incorrect. 

As it stands (before my patch), it is UNSAFE. It can decide to queue
packets to a device that is removed out from underneath it causing
reference to freed memory.

Moving the rcu_read_lock up to aoecmd_cfg() would solve that but the
whole driver appears to be unsafe about device refcounting and handling
device removal properly.  

It needs to:

1. Get a device ref count when it remembers a device: (ie addif)
2. Install a notifier that looks for device removal events
3. In notifier, remove interface, including flushing all pending
   skb's for that device.

This obviously is beyond the scope of the RCU stuff.
