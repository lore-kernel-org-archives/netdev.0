From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Wed, 04 May 2011 00:34:44 +0100
Message-ID: <1304465684.2873.26.camel@bwh-desktop>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>
	 <4DC08E7B.7070906@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:39015 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883Ab1ECXer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 19:34:47 -0400
In-Reply-To: <4DC08E7B.7070906@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-03 at 16:23 -0700, Dimitris Michailidis wrote:
> On 05/03/2011 09:12 AM, Alexander Duyck wrote:
[...]
> > +int rxclass_rule_ins(int fd, struct ifreq *ifr,
> > +		     struct ethtool_rx_flow_spec *fsp)
> > +{
> > +	struct ethtool_rxnfc nfccmd;
> > +	__u32 loc = fsp->location;
> > +	int err;
> > +
> > +	/*
> > +	 * if location is unspecified pull rules from device
> > +	 * and allocate a free rule for our use
> > +	 */
> > +	if (loc == RX_CLS_LOC_UNSPEC) {
> > +		/* init table of available rules */
> > +		err = rmgr_init(fd, ifr);
> > +		if (err < 0)
> > +			return err;
> > +
> > +		/* verify rule location */
> > +		err = rmgr_add(fsp);
> > +		if (err < 0)
> > +			return err;
> > +
> > +		/* cleanup table and free resources */
> > +		rmgr_cleanup();
> > +	}
> 
> This logic where ethtool tries to select a filter slot when a user provides 
> RX_CLS_LOC_UNSPEC does not work in general.  It assumes that all slots are 
> equal and a new filter can go into any available slot. But a device may have 
> restrictions on where a filter may go that ethtool doesn't know.

I agree.  And if filter lookup is largely hash-based (as it is in
Solarflare hardware) the user will also find it very difficult to
specify the right location!

> I mentioned during a previous review that for cxgb4 some filters require a 
> slot number that is a multiple of 4.  There are some other constraints as 
> well depending on the type of filter being added. For such a device ethtool 
> doesn't know enough to handle RX_CLS_LOC_UNSPEC correctly.
>
> I think RX_CLS_LOC_UNSPEC should be passed to the driver, where there is 
> enough knowledge to pick an appropriate slot.  So I'd remove the
> 
>      if (loc == RX_CLS_LOC_UNSPEC)
> 
> block above, let the driver pick a slot, and then pass the selected location 
> back for ethtool to report.

But first we have to specify this in the ethtool API.  So please propose
a patch to ethtool.h.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

