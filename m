From: Benjamin Poirier <bpoirier@suse.com>
Subject: Re: commit 16ecba59 breaks 82574L under heavy load.
Date: Wed, 19 Jul 2017 17:07:47 -0700
Message-ID: <20170720000747.4jiadqubv7hg5esz@f1.synalogic.ca>
References: <20170718142109.GO18556@csclub.uwaterloo.ca>
 <20170718231435.64us7vu67wtp6pwe@f1.synalogic.ca>
 <20170719141953.GQ18556@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170719141953.GQ18556@csclub.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017/07/19 10:19, Lennart Sorensen wrote:
> On Tue, Jul 18, 2017 at 04:14:35PM -0700, Benjamin Poirier wrote:
> > Thanks for the detailed analysis.
> > 
> > Refering to the original discussion around this patch series, it seemed like
> > the IMS bit for a condition had to be set for the Other interrupt to be raised
> > for that condition.
> > 
> > https://lkml.org/lkml/2015/11/4/683
> > 
> > In this case however, E1000_ICR_RXT0 is not set in IMS so Other shouldn't be
> > raised for Receiver Overrun. Apparently something is going on...
> > 
> > I can reproduce the spurious Other interrupts with a simple mdelay()
> > With the debugging patch at the end of the mail I see stuff like this
> > while blasting with udp frames:
> >           <idle>-0     [086] d.h1 15338.742675: e1000_msix_other: got Other interrupt, count 15127
> >            <...>-54504 [086] d.h. 15338.742724: e1000_msix_other: got Other interrupt, count 1
> >            <...>-54504 [086] d.h. 15338.742774: e1000_msix_other: got Other interrupt, count 1
> >            <...>-54504 [086] d.h. 15338.742824: e1000_msix_other: got Other interrupt, count 1
> >           <idle>-0     [086] d.h1 15340.745123: e1000_msix_other: got Other interrupt, count 27584
> >            <...>-54504 [086] d.h. 15340.745172: e1000_msix_other: got Other interrupt, count 1
> >            <...>-54504 [086] d.h. 15340.745222: e1000_msix_other: got Other interrupt, count 1
> >            <...>-54504 [086] d.h. 15340.745272: e1000_msix_other: got Other interrupt, count 1
> > 
> > > hence sets the flag that (unfortunately) means both link is down and link
> > > state should be checked.  Since this now happens 3000 times per second,
> > > the chances of it happening while the watchdog_task is checking the link
> > > state becomes pretty high, and it if does happen to coincice, then the
> > > watchdog_task will reset the adapter, which causes a real loss of link.
> > 
> > Through which path does watchdog_task reset the adapter? I didn't
> > reproduce that.
> 
> The other interrupt happens and sets get_link_status to true.  At some
> point the watchdog_task runs on some core and calls e1000e_has_link,
> which then calls check_for_link to find out the current link status.
> While e1000e_check_for_copper_link is checking the link state and
> after updating get_link_status to false to indicate link is up, another
> interrupt occurs and another core handles it and changes get_link_status
> to true again.  So by the time e1000e_has_link goes to determine the
> return value, get_link_state has changed back again so now it returns
> link down, and as a result the watchdog_task calls reset, because we
> have packets in the transmit queue (we were busy forwarding over 100000
> packets per second when it happened).

Ah I see. Thanks again.

In your previous mail,
On 2017/07/18 10:21, Lennart Sorensen wrote:
[...]
> I tried checking what the bits in the ICR actually were under these
> conditions, and it would appear that the only bit set is 24 (the Other
> Causes interrupt bit).  So I don't know what the real cause is although

Are you sure about this? In my testing, while triggering the overrun
with the msleep, I read ICR when entering e1000_msix_other() and RXO is
consistently set.

I'm working on a patch that uses that fact to handle the situation and
limit the interrupt.
