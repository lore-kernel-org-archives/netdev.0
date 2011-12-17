From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC][PATCH net-next] ethtool: Allow drivers to select RX NFC
 rule locations
Date: Sat, 17 Dec 2011 04:15:01 +0000
Message-ID: <1324095301.2825.304.camel@deadeye>
References: <1324084683.2798.45.camel@bwh-desktop>
	 <4EEC021D.1050804@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54731 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750957Ab1LQEPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 23:15:09 -0500
In-Reply-To: <4EEC021D.1050804@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-16 at 18:44 -0800, Dimitris Michailidis wrote:
> On 12/16/2011 05:18 PM, Ben Hutchings wrote:
> > Define special location values for RX NFC that request the driver to
> > select the actual rule location.  This allows for implementation on
> > devices that use hash-based filter lookup, whereas currently the API is
> > more suited to devices with TCAM lookup or linear search.
> > 
> > In ethtool_set_rxnfc() and the compat wrapper ethtool_ioctl(), copy
> > the structure back to user-space after insertion so that the actual
> > location is returned.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> I like this change.  One concern below.
> 
> > -	return dev->ethtool_ops->set_rxnfc(dev, &info);
> > +	rc = dev->ethtool_ops->set_rxnfc(dev, &info);
> > +	if (rc)
> > +		return rc;
> > +
> > +	if (cmd == ETHTOOL_SRXCLSRLINS &&
> > +	    copy_to_user(useraddr, &info, info_size))
> > +		return -EFAULT;
> 
> Here we return failure but the rule has been added successfully and is in 
> effect.  It may be better to return 0 and let user-space tell this last step 
> failed by the fact that the location field is still special.

If copy_to_user() fails then the user program has a bug (or is probing
for security flaws).  A return value of -EFAULT is morally equivalent to
SIGSEGV.  (I'm not sure why it isn't translated into a signal on return,
but I imagine there are historical reasons.)  I don't see any point in
trying to help userland recover from this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
