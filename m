From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 01 Aug 2003 19:01:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2AF141.2010308@pobox.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>	<20030801154021.GA7696@gtf.org>	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>	<20030801162536.GA18574@gtf.org>	<20030801132037.3f3542ae.davem@redhat.com>	<3F2AE91D.5090705@pobox.com> <20030801153255.204baf66.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030801153255.204baf66.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 01 Aug 2003 18:26:37 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>Strangely enough, creating a SET_ETHTOOL_OPS() macro (or 
>>netif_ethtool_ops or pick your name) reduces ifdefs.
> 
> 
> And then we'll have all of these functions present in
> the driver, unused, and we'll get tons of warning from
> gcc.
> 
> The duplication of code is still there, and this is the
> main point.

Not correct:  there is nothing unused, there are no warnings, in either 
the in-kernel case or the older-kernel case.  Look at kcompat.  That is 
code that is working, and producing the 2.4/2.6-ready vendor drivers I 
spoke of.

I'm apparently not communicating the design that exists in kcompat, if 
you think this.  The design is:

	code for 2.6, and it magically works in 2.4

It's a back-compat system that is so good you don't even know it's 
there.  It's completely invisible to the mainline kernel -- as it should 
be -- presuming that one pays attention to subtle API change effects.

Do you see yet how there is no code duplication, no ifdefs, no warnings 
about unused functions?  That is the key point of the whole design, and 
key to the thread of discussion here.


> You can't get rid of the duplicated code without accepting that you
> will have seperate 2.6.x and 2.4.x strains of your driver.
> 
> If you aren't willing to accept seperate strains of your driver, you
> simply don't use netdev_ops.

Look at kcompat.  That is real, working code that demonstrates the approach.


>>the few things that is not easily work-around-able is new additions to 
>>existing structures (which wouldn't exist in older kernels).  That's 
>>what SET_ETHTOOL_OPS would wrap, while also providing a trigger for 
>>generic compat glue.
> 
> 
> What gets rid of the static functions that do the work when
> SET_ETHTOOL_OPS() is a nop?

SET_ETHTOOL_OPS is never a no-op.

The back-compat form of SET_ETHTOOL_OPS registers the ethtool_ops 
pointer in storage for later use.

A DO_ETHTOOL_OPS macro in the driver's ->do_ioctl -- intentionally not 
included in the kernel -- does the rest, calling kcompat's backported 
net/core/ethtool.c, which in turn calls the ethtool_ops hooks in the 
driver.  Making the kcompat'd net driver ready for 2.6 would then 
involve simply deleting one line.

That's why there is no code duplication or unused driver code.

	Jeff
