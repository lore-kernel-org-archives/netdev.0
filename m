From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 01 Aug 2003 18:26:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2AE91D.5090705@pobox.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>	<20030801154021.GA7696@gtf.org>	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>	<20030801162536.GA18574@gtf.org> <20030801132037.3f3542ae.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030801132037.3f3542ae.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> The whole _POINT_ of these ops are to avoid duplicated code.
> If someone is absolutely adament about supporting kernels
> without ops support they should not support it at all.
> 
> The point is to avoid code duplication, but what you suggest can only
> be used to keep the duplicated code around "just in case".  This makes
> exactly no sense at all, it severs only to defeat the whole purpose
> of the change in the first place.
> 
> I totally am against making an ifdef test available for this, it can
> only result in illogical things being done by driver maintainers.


Strangely enough, creating a SET_ETHTOOL_OPS() macro (or 
netif_ethtool_ops or pick your name) reduces ifdefs.

I feel that I've helped shepherd the net driver and PCI APIs to maintain 
something fairly interesting:  a driver API that [for the most part...] 
allows one to write a driver completely without compatibility ifdefs, 
and ancient-kernel junk.  When married with a compat glue lib outside 
the tree, the same ifdef-free driver works on older kernels.

It's an explicit goal to avoid changing the driver API in such a way 
that there is a remotely sane path to supporting older kernels.  One of 
the few things that is not easily work-around-able is new additions to 
existing structures (which wouldn't exist in older kernels).  That's 
what SET_ETHTOOL_OPS would wrap, while also providing a trigger for 
generic compat glue.

This trigger is what _reduces_ code duplication.  Given such a trigger, 
a generic library can implement compat code on older kernels.  The 
drivers remain ifdef-free and compat-junk-free.  This is method used by 
the kcompat toolkit (http://sf.net/projects/gkernel/).

This (IMO) feature continually saves me real time, again and again, when 
merging a new net driver into the kernel.  It saves me time debugging a 
driver in both 2.4 and 2.6.  The time savings is in the minimization (is 
that a word?) of changes across kernel versions, and this particular 
ethtool_ops change will be a thorn in particular.  This ethtool_ops 
change _is_ trivially made backward-compatible, with a simple macro. 
Look at the future, where vendors are submitting 2.6-ready net drivers, 
because we made it easier for them to support their existing platform.

Over and above the time savings, vendors _will_ start submitting drivers 
that actually look like Linux drivers.  This has already started 
happening :)  Just today I received a Via-rhine gbit driver (GPL'd) at 
Red Hat, which I am preparing to merge into the kernel.  After removing 
the awful Hungarian notation and silly procfs apis, the driver's 
actually pretty close to a mergeable driver.  It uses the kcompat stuff, 
and as such isn't full of ifdefs and typical vendor cpp maze.

So, for the benefits of saving me real wall-clock hours, and pushing the 
vendors to create ready-for-the-kernel drivers more often, the cost is a 
simple one-line wrapper macro that in-kernel drivers would rarely use.

In the long run, I'm trying to use and abuse Intel as an example for 
other vendors to follow (using netdev@, splitting up patches, etc.), and 
push the driver maintenance load onto the vendors (where they're 
willing, etc., like Intel).  If vendors are willing to respond to 
feedback and follow standard linux-kernel email development, I'm more 
than happy for them to become a learned funnel of patches to netdev for 
review :)  This kcompat strategy -- back-compat without ifdefs -- goes a 
long way towards that, and SET_ETHTOOL_OPS is a big piece of that puzzle 
right now.

	Jeff
