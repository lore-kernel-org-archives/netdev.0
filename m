From: Greg Banks <gnb@sgi.com>
Subject: Re: NAPI, e100, and system performance problem
Date: Sat, 23 Apr 2005 09:28:31 +1000
Message-ID: <20050422232831.GB6462@sgi.com>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408> <Pine.LNX.4.61.0504180943290.15052@linux.site> <1113855967.7436.39.camel@localhost.localdomain> <20050419055535.GA12211@sgi.com> <m1hdhzyrdz.fsf@muc.de> <1114173195.7679.30.camel@localhost.localdomain> <20050422172108.GA10598@muc.de> <1114193902.7978.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, Greg Banks <gnb@sgi.com>,
        Arthur Kepner <akepner@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114193902.7978.39.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 22, 2005 at 02:18:22PM -0400, jamal wrote:
> On Fri, 2005-22-04 at 19:21 +0200, Andi Kleen wrote:
> > On Fri, Apr 22, 2005 at 08:33:15AM -0400, jamal wrote:
> [..]
> > > They should not run slower - but they may consume more CPU.
> > 
> > They actually run slower.
> > 

IIRC I saw a similar but very small effect on Altix hardware about 18
months ago, but I'm unable to get at my old logbooks right now.  I
do remember the effect was very small compared to the CPU usage effect
and I didn't bother investigating or mentioning it.

> Why do they run slower? There could be 1000 other variables involved?
> What is it that makes you so sure it is NAPI?

At the time I was running 2 kernels identical except that one had
NAPI disabled in tg3.c.

> There is only one complaint I have ever heard about NAPI and it is about
> low rates: It consumes more CPU at very low rates. Very low rates
> depends on how fast your CPU can process at any given time. Refer to my
> earlier email. Are you saying low rates are a common load?
> 
> The choices are: a) at high rates you die or b) at _very low_ rates
> you consume more CPU (3-6% more depending on your system). 

This is a false dichotomy.  The mechanism could instead dynamically
adjust to the actual network load.  For example dev->weight could
be dynamically adjusted according to a 1-second average packet
arrival rate on that device.  As a further example the driver could
use that value as a guide to control interrupt coalescing parameters.

In SGI's fileserving group we commonly see two very different traffic
patterns, both of which must work efficiently without manual tuning.

1.  high-bandwidth, CPU-sensitive: NFS and CIFS data and metadata
    traffic.

2.  low bandwidth, latency-sensitive: metadata traffic on SGI's
    proprietary clustered filesystem.

The solution on Irix was a dynamic feedback mechanism in the driver
to control the interrupt coalescing parameters, so the driver
adjusts to the predominant traffic.

I think this is a generic problem that other people face too, possibly
without being aware of it.  Given that NAPI seeks to be a generic
solution to device interrupt control, and given that it spreads
responsibility between the driver and the device layer, I think
there is room to improve NAPI to cater for various workloads without
implementing enormously complicated control mechanisms in each driver.

> Logic says lets choose a). You could overcome b) by turning on
> mitigation at the expense of latency. We could "fix" at a cost of 
> making the whole state machine complex - which would be defeating  
> the " optimize for the common".

Sure, NAPI is simple.  Current experience on Altix is that
NAPI is the solution that is clear, simple, and wrong.

> >> Note, this would entirely solve what Andi and the SGI people are 
> >> talking about.
> > 
> > Perhaps, but Linux has to perform well on old hardware too.
> > New silicon is not a solution.

Agreed.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
