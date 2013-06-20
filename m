From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 3/8] i40e: driver ethtool core
Date: Thu, 20 Jun 2013 20:59:12 +0100
Message-ID: <1371758352.1946.16.camel@bwh-desktop.uk.level5networks.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1371182122-26629-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1371666430.1956.102.camel@bwh-desktop.uk.level5networks.com>
	 <FC41C24E35F18A40888AACA1A36F3E4168533EAD@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40741 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161110Ab3FTT7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 15:59:16 -0400
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E4168533EAD@FMSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-20 at 19:47 +0000, Nelson, Shannon wrote:
> > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> > Sent: Wednesday, June 19, 2013 11:27 AM
> > 
> > On Thu, 2013-06-13 at 20:55 -0700, Jeff Kirsher wrote:
> > > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
[...]
> > > +static struct i40e_stats i40e_gstrings_stats[] = {
> > > +	I40E_PF_STAT("rx_bytes", stats.eth.rx_bytes),
> > > +	I40E_PF_STAT("tx_bytes", stats.eth.tx_bytes),
> > > +	I40E_PF_STAT("rx_errors", stats.eth.rx_errors),
> > > +	I40E_PF_STAT("tx_errors", stats.eth.tx_errors),
> > 
> > Duplicates.
> 
> Well, not really are they duplicates - the NETDEV_STAT numbers are
> specifically for each netdev that is attached to this device.  Because
> the XL710 supports VMDq, SR-IOV, and some other device multiplexing
> schemes, each netdev's NETDEV_STAT struct is the subset of the traffic
> going through its portion of the device.
>
> The PF_STAT struct holds the stats for what actually goes through the
> physical port.  This is not necessarily a summation of the various
> NETDEV_STAT structs, because some connections may be talking to each
> other and not out the physical port.
> 
> When ethtool -S is called on the PF's netdev, we see both the netdev
> and the ports stats printed.  When called on non-PF connection we only
> see the netdev stats, none of the port stats.

Good point.  And this is something I've been meaning to bring up for
discussion on netdev myself - we should have some naming convention to
distinguish per-port and per-function/per-netdev statistics.

> > [...]
> > > +#define I40E_QUEUE_STATS_LEN \
> > > +  ((((struct i40e_netdev_priv *)netdev_priv(netdev))->vsi-
> > >num_queue_pairs + \
> > > +    ((struct i40e_netdev_priv *)netdev_priv(netdev))->vsi-
> > >num_queue_pairs) * 2)
> > 
> > netdev should be a macro parameter.  Actually this could just as well be
> > a function.
> 
> Sure.
> Can you tell we inherited a lot from our previous drivers?

Just a little. :-)

[...]
> > > +static int i40e_set_phys_id(struct net_device *netdev,
> > > +			    enum ethtool_phys_id_state state)
> > > +{
> > > +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> > > +	struct i40e_pf *pf = np->vsi->back;
> > > +	struct i40e_hw *hw = &pf->hw;
> > > +	int blink_freq = 2;
> > > +	static u32 led_status;
> > 
> > Ugh, no.
> > 
> > Since ETHTOOL_PHYSID drops the RTNL between calls to set_phys_id, it's
> > possible to invoke it on multiple devices at the same time...
> 
> Yep, that should become PF netdev specific.
[...]

My point was that you have a static variable here, whose use is not
serialised.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
