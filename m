From: Karen Shaeffer <shaeffer@neuralscape.com>
Subject: Re: [PATCH] forcedeth: msi interrupts
Date: Sat, 7 Jun 2008 11:31:06 -0700
Message-ID: <20080607183106.GA14526@synapse.neuralscape.com>
References: <20080606141054.432ec910.akpm@linux-foundation.org> <F72FA20C31DD4F4C997B91C5B3690A090B146100@hqemmail07.nvidia.com> <20080606214016.GA3345@synapse.neuralscape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, jgarzik@pobox.com,
	manfred@colorfullife.com, netdev@vger.kernel.org
To: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from synapse.neuralscape.com ([198.144.200.82]:40245 "EHLO
	neuralscape.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762063AbYFGSba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2008 14:31:30 -0400
Content-Disposition: inline
In-Reply-To: <20080606214016.GA3345@synapse.neuralscape.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 06, 2008 at 02:40:16PM -0700, Karen Shaeffer wrote:
> On Fri, Jun 06, 2008 at 02:19:31PM -0700, Ayaz Abdulla wrote:
> > Yes, that would be great!
> 
> Hi Ayaz,
> How far back should it be back ported? Do you know?


Hello,
Let me explain and maybe get some advice. I have recently
done work with the Sun Netra X4200 M2 Server that uses
the Nvidia CK48 chipset and the forcedeth driver. You can
see an architecture overview here:
http://www.sun.com/servers/netra/x4200/wp.pdf

The Nvidia NIC that is integrated into the Nvidia 2200 chip,
has a failure mode for the following linux kernels
2.6.21.x
2.6.23.x
2.6.24.x
RHEL 2.6.18*

The NIC will hang under specific conditions for all these
kernels. First, you must run the NIC in 100 Mb mode with autoneg
enabled, then it will always link in a mismatch with the switch.
The switch will link at 100 Mb full duplex, while the Nvidia NIC
will link at 100 Mb half duplex. This was shown with both Cisco
managed switches and HP managed switches, and I suspect it will
happen with any switch. (You can force the NIC to 100 Mb full,
but autoneg will always result in the link mismatch.)

Once this link mismatch is in effect, then, if you run it long
enough, the NIC will eventually hang and become completely
disabled. (I know you shouldn't run a NIC in link mismatch, but end
users in the field sometimes don't realize it has happened.) It could
take days or weeks under reasonably heavy load, but it will always
hang in the end. Continually rebooting the server will result in the
hang in a matter of hours, where the link negotiation results in the
hang. No packets are ever transmitted in these cases. Because it
is reproducable in a matter of hours, this is the preferred way to
reproduce the failure mode.

The ethtool online test will pass. The ethtool offline test
will fail. The driver does TX register dumps into the logs and
reports TX busy errors. I provided all this information to Ayaz
in real time, but never got any response or comment from him.

Even a soft reboot will not clear this failure. This initially
lead me to conclude this is a hardware failure, but it isn't
100% certain to be the case. This is because the NIC is known
to hang at boot time during the link negotiation, where no
packets are ever transmitted. I didn't have time to fully
understand this failure mode, but it could be that a soft
reboot does clear the failure. And then at boot time link
negotiation, it fails immediately, giving the appearance
of a HW failure sustained across a soft reboot. I did not
investigate enough to conclude with certainty it is a HW
failure.

I did determine that a double hard reboot, where the second
reboot is executed while the Netra is in the BIOS POST will
always clear the NIC failure. This lead me to conclude with
reasonable certainty this is a hardware failure that can
occur at 100 Mb mode with a link mismatch. But I am not
certain as stated above. Nvidia never did provide a resolution
to this problem, despite the fact they were provided substantial
information characterizing the failures and clear instructions
on how to reproduce it within a few hours.

I've always known there may be a driver workaround for this
failure. And if there is a driver workaround it would likely
be related to interrupts. So, that was my motivation to ask
the original question here. In the future, I will likely
just dump all the data into bugzilla, as it seems like
the preferred response to such a set of circumtances.

Thanks,
Karen

> > -----Original Message-----
> > From: Andrew Morton [mailto:akpm@linux-foundation.org] 
> > Sent: Friday, June 06, 2008 2:11 PM
> > To: Ayaz Abdulla
> > Cc: jgarzik@pobox.com; manfred@colorfullife.com; netdev@vger.kernel.org
> > Subject: Re: [PATCH] forcedeth: msi interrupts
> > 
> > 
> > On Fri, 06 Jun 2008 14:04:05 -0400
> > Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> > 
> > > 
> > > 
> > > Andrew Morton wrote:
> > > > On Fri, 06 Jun 2008 13:15:32 -0400
> > > > Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> > > > 
> > > > 
> > > >>Andrew Morton wrote:
> > > >>
> > > >>>On Tue, 03 Jun 2008 16:51:46 -0400
> > > >>>Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> > > >>>
> > > >>> > This patch adds a workaround for lost MSI interrupts. There is a
> > race
> > > >>> > condition in the HW in which future interrupts could be missed.
> > The
> > > >>> > workaround is to toggle the MSI irq mask.
> > > >>> >
> > > >>>
> > > >>>Do you think this is a 2.6.26 thing?
> > > >>
> > > >>It is by HW design, not related to the kernel.
> > > > 
> > > > 
> > > > Sorry, what I meant was: do you believe that this patch should be in
> > > > 2.6.26?
> > > Yes, it should be treated as a critical fix.
> > 
> > So should it also be backported into 2.6.25.x?
> > 
> > Bear in mind that $major_distros are apparently basing product on
> > 2.6.25.
-- 
 Karen Shaeffer
 Neuralscape, Palo Alto, Ca. 94306
 shaeffer@neuralscape.com  http://www.neuralscape.com
