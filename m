From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Wed, 04 May 2011 19:05:42 +0100
Message-ID: <1304532342.2926.46.camel@bwh-desktop>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>
	 <4DC08E7B.7070906@chelsio.com> <1304465684.2873.26.camel@bwh-desktop>
	 <4DC1883F.7050301@chelsio.com> <1304529892.2926.14.camel@bwh-desktop>
	 <4DC18DF8.3090707@chelsio.com>  <4DC18FB2.8060604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dimitris Michailidis <dm@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12968 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754647Ab1EDSFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 14:05:45 -0400
In-Reply-To: <4DC18FB2.8060604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 10:41 -0700, Alexander Duyck wrote:
> On 5/4/2011 10:33 AM, Dimitris Michailidis wrote:
> > On 05/04/2011 10:24 AM, Ben Hutchings wrote:
> >> On Wed, 2011-05-04 at 10:09 -0700, Dimitris Michailidis wrote:
> >>> On 05/03/2011 04:34 PM, Ben Hutchings wrote:
> >>>> On Tue, 2011-05-03 at 16:23 -0700, Dimitris Michailidis wrote:
> >>>>> I think RX_CLS_LOC_UNSPEC should be passed to the driver, where there is
> >>>>> enough knowledge to pick an appropriate slot.  So I'd remove the
> >>>>>
> >>>>>       if (loc == RX_CLS_LOC_UNSPEC)
> >>>>>
> >>>>> block above, let the driver pick a slot, and then pass the selected location
> >>>>> back for ethtool to report.
> >>>> But first we have to specify this in the ethtool API.  So please propose
> >>>> a patch to ethtool.h.
> >>> In the past we discussed that being able to specify the first available slot or
> >>> the last available would be useful, so something like the below?
> >>>
> >>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> >>> index 4194a20..909ef79 100644
> >>> --- a/include/linux/ethtool.h
> >>> +++ b/include/linux/ethtool.h
> >>> @@ -442,7 +442,8 @@ struct ethtool_flow_ext {
> >>>     *	includes the %FLOW_EXT flag.
> >>>     * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
> >>>     *	if packets should be discarded
> >>> - * @location: Index of filter in hardware table
> >>> + * @location: Index of filter in hardware table, or %RX_CLS_FLOW_FIRST_LOC for
> >>> + *	first available index, or %RX_CLS_FLOW_LAST_LOC for last available
> >> [...]
> >>
> >> I think that's reasonable.  We should also explicitly state that
> >> location determines priority, i.e. if a packet matches two filters then
> >> the one with the lower location wins.
> >
> > Easy and true for a TCAM.  For hashing would you use the location to decide how
> > to order filters that fall in the same bucket?
> >
> 
> The problem is none of this is backwards compatible.  The niu driver has 
> supported the network flow classifier rules since 2.6.30.  Adding this 
> would cause all rule setups for niu to fail because these locations 
> would have to exist outside of the current rule locations.

Those rule setups would have to be using some unofficial patched
ethtool.  I don't think that should be a major concern for us.
However...

> This is why I was suggesting that the best approach would be to update 
> the kernel to add a separate ioctl for letting the driver setup the 
> location.
>
> We can just attempt to make that call and when we get the 
> EOPNOTSUPP errno we know the device driver doesn't support it and can 
> then let the rule manager take over.

How about having ETHTOOL_GRXCLSRLCNT set a flag in the 'data' field to
indicate that the driver can assign locations?  (We would have to
specify that for compatibility with older kernels the application must
initialise this filed to 0.)

rmgr_init() would then check for this flag.

I hope someone is actually going to test this on niu, as it sounds like
that will be the only driver using a TCAM... David?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

