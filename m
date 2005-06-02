From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: RFC: NAPI packet weighting patch
Date: Thu, 2 Jun 2005 14:19:55 -0700
Message-ID: <468F3FDA28AA87429AD807992E22D07E0450BFD0@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        <shemminger@osdl.org>, <netdev@oss.sgi.com>,
        <Robert.Olsson@data.slu.se>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <hadi@cyberus.ca>, "Jon Mason" <jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The DRR algorithm assumes a perfect world, where hardware resources are
infinite, packets arrive continuously (or separated by very long
delays), there are no bus latencies, and CPU speed is infinite.

The real world is much messier: hardware starves for resources if it's
not serviced quickly enough, packets arrive at inconvenient intervals
(especially at 10 and 100 Mbps speeds), and buses and CPUs are slow.

Thus, the driver should have the intelligence built into it to make an
"intelligent" choice on what the weight should be for that
driver/hardware.  The calculation in the driver should take into account
all the factors that the driver has access to.  These include link
speed, bus type and speed, processor speed and some amount of actual
device FIFO size and latency smarts.  The driver would use all of the
factors to come up with a weight to prevent it from dropping frames and
not to starve out other devices in the system or hinder performance.  It
seems to us that the driver is the one that know best and should try to
come up with a reasonable value for weight based on its own knowledge of
the hardware.

This has been showing up in our NAPI test data which Mitch is currently
scrubbing for release.  It shows that there is a need for either better
default static weight numbers or for them to be calculated based on some
system dynamic variables.  We would like to see the latter tried but the
only problem is that each driver would have to make its own
calculations, and it may not have access to all of the system-wide data
it would need to make a proper calculation.

Even with a more intelligent driver, we still would like to see some
mechanism for the weight to be changed at runtime, such as with
Stephen's sysfs patch.  This would allow a sysadmin (or user-space app)
to tune the system based on statistical data that isn't available to the
individual driver.

Cheers,
John


> -----Original Message-----
> From: jamal [mailto:hadi@cyberus.ca] 
> Sent: Thursday, June 02, 2005 5:27 AM
> To: Jon Mason
> Cc: David S. Miller; Williams, Mitch A; shemminger@osdl.org; 
> netdev@oss.sgi.com; Robert.Olsson@data.slu.se; Ronciak, John; 
> Venkatesan, Ganesh; Brandeburg, Jesse
> Subject: Re: RFC: NAPI packet weighting patch
> 
> 
> On Tue, 2005-31-05 at 18:28 -0500, Jon Mason wrote:
> > On Tuesday 31 May 2005 05:14 pm, David S. Miller wrote:
> > > From: Jon Mason <jdmason@us.ibm.com>
> > > Date: Tue, 31 May 2005 17:07:54 -0500
> > >
> > > > Of course some performace analysis would have to be 
> done to determine the
> > > > optimal numbers for each speed/duplexity setting per driver.
> > >
> > > per cpu speed, per memory bus speed, per I/O bus speed, 
> and add in other
> > > complications such as NUMA
> > >
> > > My point is that whatever experimental number you come up 
> with will be
> > > good for that driver on your systems, not necessarily for others.
> > >
> > > Even within a system, whatever number you select will be the wrong
> > > thing to use if one starts a continuous I/O stream to the SATA
> > > controller in the next PCI slot, for example.
> > >
> > > We keep getting bitten by this, as the Altix perf data 
> continually shows,
> > > and we need to absolutely stop thinking this way.
> > >
> > > The way to go is to make selections based upon observed events and
> > > mesaurements.
> > 
> > I'm not arguing against a /proc entry to tune dev->weight 
> for those sysadmins 
> > advanced enough to do that.  I am arguing that we can make 
> the driver smarter 
> > (at little/no cost)  for "out of the box" users.
> > 
> 
> What is the point of making the driver "smarter"? 
> Recall, the algorithm used to schedule the netdevices is based on an
> extension of Weighted Round Robin from Varghese et al known 
> as DRR (ask
> gooogle for details).
> The idea is to provide fairness amongst many drivers. As an 
> example, if
> you have a gige driver it shouldnt be taking all the resources at the
> expense of starving the fastether driver.
> If the admin wants one driver to be more "important" than the other,
> s/he will make sure it has a higher weight.
> 
> cheers,
> jamal
> 
> 
