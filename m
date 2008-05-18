From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
	IRQF_SAMPLE_RANDOM
Date: Sat, 17 May 2008 19:36:08 -0500
Message-ID: <1211070968.18026.113.camel@calx>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>
	 <20080515142154.0595e475@core>
	 <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
	 <20080515215517.GI1936@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Chris Peterson <cpeterso@cpeterso.com>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:36710 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756048AbYERArH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2008 20:47:07 -0400
In-Reply-To: <20080515215517.GI1936@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-05-16 at 00:55 +0300, Adrian Bunk wrote:
> On Thu, May 15, 2008 at 09:07:52AM -0700, Brandeburg, Jesse wrote:
> > Alan Cox wrote:
> > > Chris Peterson <cpeterso@cpeterso.com> wrote:
> > >> I know Jeff Garzik says he's not interested in an anti-entropy
> > >> pogrom for existing net drivers, but here is the patch if anyone
> > >> else is interested..? :)  
> > >> 
> > >> Only 12 net drivers are affected, the last of the
> > >> theoretically-exploitable network entropy. 
> > > 
> > > Looks fine to me. If Jeff doesn't want to touch them then send them
> > > direct to Andrew/Linus.
> > > 
> > > A more interesting alternative might be to mark things like network
> > > drivers with a new flag say IRQF_SAMPLE_DUBIOUS so that users can be
> > > given a switch to enable/disable their use depending upon the
> > > environment. 
> > 
> > we've been hearing rumblings of big customers wanting (maybe requiring)
> > wired network drivers from Intel to  advertise this flag.  Jeff have you
> > heard of such?
> > 
> > I think the argument is that a headless system (no keyboard/mouse, no
> > soundcard, probably no video) with a libata based driver and a network
> > driver without IRQF_SAMPLE_RANDOM has *no* sources of entropy.  In this
> > case the argument is very strong for at least *some* source of entropy
> > from interrupts so that randomness can get some external input.  Just
> > try rebuilding a kernel RPM over an ssh session and you'll see what I
> > mean.
> > 
> > In short, I agree with Alan's IRQF_SAMPLE_DUBIOUS, and know of Linux
> > customers who also want the same.
> 
> We have two random number interfaces:
> - /dev/random
> - /dev/urandom
> 
> If a customer wants to get data from /dev/random although there's not 
> enough entropy that's not a problem we can solve (we can only try to 
> gather more real entropy if possible).
> 
> If he can live with dubious data he can simply use /dev/urandom .
> 
> If a customer wants to use /dev/random and demands to get dubious data 
> there if nothing better is available fulfilling his wish only moves 
> the security bug from his crappy application to the Linux kernel.
> 
> But what we could perhaps do with some kind of IRQF_SAMPLE_DUBIOUS would 
> be to improve the quality of the data in /dev/urandom if there's not 
> enough entropy available?
> 
> I have seen embedded systems with zero entropy, and dubious entropy 
> might there be better than no entropy at all.
> Or am I wrong on the latter?

There are two issues that people need to separate here:

- sampling noise
- estimating entropy in that noise

It certainly makes sense to sample network timing noise. It often does
not make sense to assume that there's any entropy in those timing
samples. For instance:

- our clock resolution may be low enough that an attacker can guess our
samples (ie it's simply HZ, very common in embedded land)
- the bus involved (ISA, peripheral bus, even slow PCI) may have the
same issue
- it may be heavily correlated with some other measurement (ie network
vs disk samples on file servers)

We currently assume that IRQF_SAMPLE_RANDOM means 'this is a completely
trusted unobservable entropy source' which is obviously wrong for
network devices but is right for some other classes of device.

I'd personally prefer to add a new interface, eg
add_network_randomness(), that internalized the wisdom of what to do 
with network samples. Similarly, the various 'input'-like devices that
use SAMPLE_RANDOM should be switched to go through the 'input'
interface.

-- 
Mathematics is the supreme nostalgia of our time.

