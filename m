From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Linux router performance (3c59x) (fwd)
Date: Mon, 17 Mar 2003 22:43:38 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0303172239390.30872@ns.istop.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I haven't heard from Jamal or Dave, so perhaps someone from this list has
some wisdom to impart.
Currently the box in question is running a 67% system load with ~40kpps.
Here's the switch port stats that the 2 3c905cx cards are plugged into:

  5 minute input rate 36143000 bits/sec, 8914 packets/sec
  5 minute output rate 54338000 bits/sec, 10722 packets/sec
-
  5 minute input rate 50585000 bits/sec, 12445 packets/sec
  5 minute output rate 34326000 bits/sec, 9596 packets/sec

Ralph Doncaster
principal, IStop.com

---------- Forwarded message ----------
Date: Mon, 17 Mar 2003 11:18:25 -0500 (EST)
From: Ralph Doncaster <ralph@istop.com>
To: jamal <hadi@cyberus.ca>
Cc: "mcr@sandelman.ottawa.on.ca" <mcr@sandelman.ottawa.on.ca>,
     "vortex@scyld.com" <vortex@scyld.com>,
     "davem@redhat.com" <davem@redhat.com>
Subject: Re: Linux router performance (3c59x)

Hi Jamal,

I found a 3c59x NAPI patch (from orr.falooley.org/pub/linux/net/, which
seems to be down right now), and applied that against the stock 2.4.20
kernel.  Unfortunately I don't see a noticable improvement from 2.4.19
without NAPI.  When I send a 10kpps flood of 64-byte frames through the
router, the CPU flatlines (duron 750).  The number of interrupts/sec
doesn't go down and the context switching is reduced so NAPI is having
some affect, but not the intended reduction in CPU load (10kpps flood was
done during the middle of this vmstat log, when you see idle go to 0):

root@tor-router /usr/src# vmstat 2
   procs                      memory    swap          io     system
cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us
sy  id
 0  0  1    932 623600  15636  27916   0   0     2    51 2762  1085  13
41  47
 0  0  1    932 623600  15636  27916   0   0     0     0 18603  1660   0
43  57
 0  0  1    932 623600  15636  27916   0   0     0     0 18495  1593   0
50  50
 0  0  1    932 623584  15652  27916   0   0     0    20 18949  1671   0
49  51
 0  0  1    932 623584  15652  27916   0   0     0     0 18768  1192   0
63  37
 0  0  1    932 623584  15652  27916   0   0     0     0 16084    62   0
100   0
 0  0  1    932 623584  15652  27916   0   0     0     0 16059   132   0
100   0
 0  0  1    932 623576  15660  27916   0   0     0     8 18043    24   0
100   0
 0  0  1    932 623576  15660  27916   0   0     0     0 17795    71   0
100   0
 0  0  1    932 623576  15660  27916   0   0     0     0 14181    70   0
100   0
 0  0  1    932 623576  15660  27916   0   0     0     0 16764   122   0
100   0
 0  0  1    932 623576  15660  27916   0   0     0     0 16802    63   0
100   0
 0  0  1    932 623568  15668  27916   0   0     0     8 17044    23   0
100   0
 0  0  1    932 623568  15668  27916   0   0     0     0 19198  1520   0
48  52
 0  0  1    932 623568  15668  27916   0   0     0     0 18684  1611   0
39  61
 0  0  1    932 623568  15668  27916   0   0     0     0 18256  1518   0
44  56

This is a box doing straight routing (no firewalling), with a full bgp4
routing table (>100k routes).  Kernel advanced router config option as
well as fastroute was chosen.

Is the 3c59x NAPI patch just no good, or is there something else I should
be doing to get decent linux routing throughput with it?

Ralph Doncaster
principal, IStop.com

On Sat, 14 Dec 2002, jamal wrote:

>
>
> On Fri, 13 Dec 2002, Ralph Doncaster wrote:
>
> > Hi Jamal,
> >
> > I'm running 2.4.19 on a linux router in Toronto.  It's got 2 3c905CX
> > cards, and I've disabled rx_copybreak in the driver.  FASTROUTE is not
> > tuned on.  CPU is a Duron-750.  At around 40kpps, the box hits 100% CPU.
> >
>
> And it should probably die if you start hitting around 60kpps i.e no
> packets make it.
>
> > Based on your numbers for 2.2.14, it would seem FASTROUTE would make a big
> > difference.
> > http://robur.slu.se/Linux/net-development/jamal/FF-html/img7.htm
> >
>
> It has its disadvantages:
> It chews a lot of CPU and theres a lot of things you must bypass
> by virtue of DMA-DMA connectivity.
>
> > Comparing the Usenix paper results for 2.4 seem to show that FASTROUTE
> > doesn't make as much difference.  Since your numbers show almost 100kpps
>
> I think if you only have a couple of interfaces on a P2 you should pretty
> much be able to do about 100Kpps on each.
>
> > for regular 2.4 I'm guessing that means the irqmitigation of the stock
> > 3c59x.c sucks, even though it looks like it will process multiple packets
> > per interrupt under load (max_interrupt_work).
>
> irq mitigation is only done by a few NICs. NAPI does a better mitigation
> in s/ware without requiring h/ware support. The mitigation is based on
> feedback from the system; so if the system is slow (pentium vs P3) you
> process less and NEVER die. I believe theres 3c59x.c NAPI driver.
>
> > DaveM was rather terse
> > when I communicated with him recently, but what he clearly said was the
> > e1000 is the best performer under linux due to software IRQ mitigation
> > features in the driver (not the hardware RxIntDelay feature).
> >
>
> He was more than likely refering to NAPI. e1000 is definetly the best; but
> i dont own any; Robert Olson owns a few and he swears by them. I can email
> him for details if you are interested.
>
> > Now that 2.4.20 includes the e1000 driver, it would seem the easiest way
> > to get high-performance routing under Linux would be for me to upgrade
> > from 2.4.19 to 2.4.20 with the FASTROUTE enabled, and swap my 3C905CX
> > cards for a couple of e1000's.
> >
>
> No. Forget FASTROUTE. I dont think anyone is looking at it at all or it
> is ever being updated; we killed it with NAPI perfomance wise, no
> difference and featurewise NAPI is superior.
> Although recently i have been thinking of experimenting withe CISCO like
> adjancecies/CEF (but that is a totaly different thing).
>
> > Looking at the README
> > ftp://robur.slu.se/pub/Linux/net-development/NAPI/README
> > It seems to indicate the 2.4.20 e1000 driver is NAPIfied, so I shouldn't
> > need any NAPI patches.
> >
>
> 2.4.20 already has NAPI built in. When you compile the kernel, you have
> it.
>
> > Lastly, your comments to MCR about NAPI being better than FASTROUTE seem
> > to imply that I don't need FASTROUTE.  However I would expect FASTROUTE to
> > provide additional performance when used with NAPI (since it avoids the
> > codepath for firewalling & NAT).
> >
>
> If you dont have any firewalling policies on theres no difference.
> NAT is a different beast - that thing puts Linux to shame.
> so, no you dont need FASTROUTE.
>
> cheers,
> jamal
>
>
