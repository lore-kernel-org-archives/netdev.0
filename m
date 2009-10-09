From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: behaviour question for igb on nehalem box
Date: Fri, 9 Oct 2009 13:22:30 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0910091250440.5328@jbrandeb-desk1.amr.corp.intel.com>
References: <4ACF8466.5030309@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-list <e1000-devel@lists.sourceforge.net>,
	Linux Network Development list <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4ACF8466.5030309@nortel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 9 Oct 2009, Chris Friesen wrote:
> I've got some general questions around the expected behaviour of the
> 82576 igb net device.  (On a dual quad-core Nehalem box, if it matters.)
> 
> As a caveat, the box is running Centos 5.3 with their 2.6.18 kernel.
> It's using the 1.3.16-k2 igb driver though, which looks to be the one
> from mainline linux.
> 
> The igb driver is being loaded with no parameters specified.  At driver
> init time, it's selecting 1 tx queue and 4 rx queues per device.
> 
> My first question is whether the number of queues makes sense.  I

It does for this kernel, because 2.6.18 doesn't support multiple tx 
queues.  The hardware supports RSS over receive queues, and the driver 
doesn't mention the multiple receive queues from the OS.

> couldn't figure out how this would happen since the rules for selecting
> the number of queues seems to be the same for rx and tx.  Also, it's not
> clear to me why it's limiting itself to 4 rx queues when I have 8
> physical cores (and 16 virtual ones with hyperthreading enabled).

for gigabit more queues is not necessarily better, and MQ arguably isn't 
necessary at all for gigabit.  However, it can help for some workloads 
when spreading out RX traffic.  the hardware you have only supports 8 
queues (rx and tx) and the driver is configured to only set up 4 max.

> My second question is around how the rx queues are mapped to interrupts.
>  According to /proc/interrupts there appears to be a 1:1 mapping between
> queues and interrupts.  However, I've set up at test with a given amount
> of traffic coming in to the device (from 4 different IP addresses and 4
> ports).  Under this scenario, "ethtool -S" shows the number of packets
> increasing for only rx queue 0, but I see the interrupt count going up
> for two interrupts.

one transmit interrupt and one receive interrupt?  RSS will spread the 
receive work out in a flow based way, based on ip/xDP header.  Your test 
as described should be using more than one flow (and therefore more than 
one rx queue) unless you got caught out by the default arp_filter 
behavior (check arp -an).
 
> My final question is around smp affinity for the rx and tx queue
> interrupts.  Do I need to affine the interrupt for each rx queue to a
> single core to guarantee proper packet ordering, or can they be handled
> on arbitrary cores?  Should the tx queue be affined to a particular core
> or left to be handled by all cores?

on RHEL5.3 you can use irqbalance, you shouldn't need to hand affine 
anything.  Packets won't be received out of order unless you have the rx 
interrupts going to more that one cpu per queue. (smp_affinity mask has 
more than one bit set)  RSS is doing flow steering.

going to a 2.6.27 or newer kernel will get you full tx multiqueue support.

Hope this helps,
  Jesse

------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
