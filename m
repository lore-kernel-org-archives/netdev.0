From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH net v2 3/9] net/mac89x0: Fix and modernize log messages
Date: Fri, 6 Oct 2017 22:06:47 +1100 (AEDT)
Message-ID: <alpine.LNX.2.00.1710062009140.3@nippy.intranet>
References: <cover.1507211120.git.fthain@telegraphics.com.au> <e9fb341944d187cabf1ccef78cfdc9de64e3f158.1507211120.git.fthain@telegraphics.com.au> <20171005.210842.1348457661309929796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005.210842.1348457661309929796.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Oct 2017, David Miller wrote:

> From: Finn Thain <fthain@telegraphics.com.au>
> Date: Thu, 5 Oct 2017 21:11:05 -0400 (EDT)
> 
> > Fix misplaced newlines in conditional log messages.
> 
> Please don't do this, the way the author formatted the strings was 
> intentional, they intended to print out:
> 
> 	NAME: cs89%c0%s rev %c found at %#8lx IRQ %d ADDR %pM
> 
> But now you are splitting it into multiple lines.

Right.

> Also, you're printing the IRQ information after register_netdev() which 
> is bad.  As soon as register_netdev() is called, the driver's
> ->open() routine can be invoked, and during which time some
> log messages could be emitted during that operation.
> 
> And that would cut the probe messages up.
> 

Yes and no. The thing is, "IRQ %d" isn't really a "probe message" and 
doesn't need to be logged at all: the IRQ is entirely fixed. Actually the 
same is true for the macmace driver. There is value in this information 
but it can be found in /proc/interrupts so I'd happily drop the "IRQ %d" 
portion from these log messages.

> I know how you got to this state, you saw a reference to dev->name 
> before it had a real value.  You just removed the "eth%d" string 
> entirely.  And since you removed the dev->name reference, you had no 
> reason to move log messages after register_netdev() at all.
> 

Not quite. I used the "MAC %pM, IRQ %d" style for consistency with other 
NIC drivers. Though consistency in itself may be insufficient 
justification. More importantly, I wanted the MAC address logged together 
with the actual interface name. That's how I arrived at this code.

> Anyways, you can also see the intention of the author here becuase they 
> have _explicit_ leading newlines in the error path messages that come 
> after the inital probe printk.
> 

Of course. I do understand the existing code. And the code actually 
reflects the intentions of the author of the ISA driver. Having the IRQ 
logged could be really valuable to the typical ISA card user but this 
platform is not ISA.

> The real way to fix the early dev->name reference is to replace it with 
> a dev_info() call and have it use the struct device name rather than the 
> netdev device one.
> 

This driver only runs on machines with one expansion slot (called a "Comm 
Slot"). So I figured that either pr_info() or printk(KERN_INFO ...) would 
do just fine here (always has done). I did consider dev_info() but I don't 
see the benefit. I'm probably missing something, so would you elaborate 
please?

BTW I've also used pr_info() elsewhere in this series in platform drivers. 
It's not yet clear to me whether the mac89x0 driver should ultimately bind 
to a platform device or a nubus device: comm slot cards are a bit of 
each.

> Again, I think you really shouldn't be making these small weird changes 
> to these old drivers.
> 

These are weird changes befitting a weird platform.

I understand your reluctance to touch legacy drivers, but my intention is 
not change for the sake of change. There is bitrot here. Sometimes that's 
due to the rest of the kernel having changed and sometimes it's due to 
actual damage of the kind you seem to fear. I'm trying to address both.

-- 
