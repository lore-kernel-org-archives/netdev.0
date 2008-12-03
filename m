From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
	driver v2
Date: Wed, 03 Dec 2008 18:03:49 -0500
Message-ID: <1228345429.25647.36.camel@localhost.localdomain>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <1227783281.3809.78.camel@johannes.berg>
	 <200812021807.25873.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37438 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753862AbYLCXEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 18:04:48 -0500
In-Reply-To: <200812021807.25873.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-02 at 18:07 -0800, Inaky Perez-Gonzalez wrote:
> On Thursday 27 November 2008, Johannes Berg wrote:
> > along, more functionality was moved to the host (yes, you say this
> > won't happen with wimax, but I think it will, eventually, if wimax
> > gets to be popular enough. never say never), and wext got more
> 
> Agree, never say never; but these are the reasons why I highly doubt
> it'll ever happen:
> 
>  - WiMAX spectrum is heavily regulated

Well, to be fair 3.5GHz is "lightly regulated" here in the US, you just
have to register your base station with the FCC and as long as nobody
else has done so in your area, you win.  The Intel parts don't support
3.5 GHz, but I'm sure somebody elses parts will in the future.

TowerStream has already deployed 3.5GHz fixed WiMAX gear here in Boston,
though they are doing fixed access/T1-replacement for businesses, not a
large consumer-focused mobile wimax network like XOHM/Clear.

Dan

>  - Operators won't allow it. They want tightly safe, certified and
>    tested firmwares/devices that adhere to the standard so they can
>    make sure devices don't mess up a single hertz as that means lost
>    money, especially with a radio that can beam over miles.
> 
>  - Certification (required) of stacks make it almost
>    impossible to maintain a soft implementation.
> 
> > messy. Wext even was defining actual operations, as undefined as
> > they often were, you're not even doing that.
> 
> Why would I define them when I don't even know how they are going to
> look like? It is not as simple as it looks.
> 
> The basics that aren't covered in current's kernel API are scan,
> connect, disconnect. Disconnect is simple, but scan & connect? very
> much impossible to tell what common ground is going to be until more
> devices show up.
> 
> For scanning, some devices require to be told exactly where to scan in
> (as in which combination of band, fft width and coloring of the
> band). Some others don't. Then of course, the scan results might be
> operators? Network Service Providers? Network Access Providers?  base
> station IDs? how do you stitch'em together? You need information to
> map from one to the other, and that is device specific depending on at
> which level they work. How to stich that information together depends
> on the network too (OMA-DM and provisining information help to compose
> this). If it is done at the device/firmware level or at the host level
> is device specific.
> 
> Connect has exactly the same levels of issues as scan: what do I
> connect to? A base station? a NAP or an NSP?
> 
> So back to the original question: I have no information to define such
> an interface at low level, so I am not defining it. Simple :/
> 
> > I don't think you can say it's like cfg80211, cfg80211 in fact does a
> > lot more than the wimax "stack", it can validate parameters for
> > example, and provides actual operations (key operations, peer
> > operations, scanning [soon], ...) rather than just a transport to
> > the driver. As I've said on the relevant patch, I'd love to see the
> > wimax stack take more of that direction.
> 
> If it has to happen, it will happen eventually. If it is a stack or
> not as of now and just a simple control interface, not that I really
> mind. It's just a name.
> 
> > I don't see that as much of a problem. Many of the commands you have
> > defined for the i2400m driver are very generic, for example:
> 
> As I said above, it is not so simple. They are not as generic as they
> look. 
> 
> > This is the biggest issue I see here. I don't see how the stack
> > helps anyone implement a driver for a new device. Sure, they won't
> > have to come up with a new transport, write less lines of generic
> > netlink code, but ultimately that's not the hard part, the hard part
> > is getting the relevant operations right etc.
> 
> I agree -- and that's the whole reason why the "stack" is
> there--because even if it doesn't look so hard, it's just a
> pain. 
> 
> This way someone comes in with a need for a driver and then we can
> start deciding how to cut the scan & connect interfaces. Maybe it
> makes no sense to do it at the kernel level and it has to be done at
> user space, as the i2400m does it; then the kernel API stays the
> same...until another driver comes in...etc. Don't fix it if it ain't
> broke. 
> 
> > This really means you're putting the actual "driver", the piece that
> > does the hardware abstraction, into userspace. And in a binary daemon
> > even, afaict. This was quickly shot down with ipw3945/4965, not sure why
> > nobody has cared here so far. Maybe because you're actually planning to
> > open source that part.
> 
> Nope. I am putting the part that knows how to scan and connect in user 
> space because it does not belong in kernel space. It is big and complex, 
> needs permanent storage, requires complex crypto code and can really
> use a OMA-DM client to communicate with the network.
> 
> Not a binary, btw. Currently the supplicant is a binary, but that will
> change. The OMA-DM client daemon is also a binary as of now and we
> are still thinking how to fix that situation, as there are no open
> source equivalents. Luckily, it is kind of optional.
> 
> > Couldn't the stack provide more functionality here? Somewhere else
> > you speak of using ethernet vs. rawip, couldn't the stack do that
> > translation, possibly even allowing both rawip and ethernet to
> > coexist, or be switchable at runtime if you have a working dhcp
> > client?
> 
> The stack is a control plane, not a data plane. Each driver implements
> data frame passing the way that is most optimal to the device it
> implements support for.
> 
> There is not good reason (as of now) that justifies the extra overhead
> that would be introduced by the "stack" doing it. 
> 
> The only reason I would see that happening would be a mac80211 like
> case, where the stack is doing packet handling in a hypothetical
> soft-mac implementation. As I said above, I highly doubt that
> scenario.
> 
> Thanks,
> 

