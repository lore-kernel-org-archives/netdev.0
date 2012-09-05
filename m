From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] usbnet: drop unneeded check for NULL
Date: Wed, 5 Sep 2012 23:14:35 +0100
Message-ID: <1346883275.5325.28.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120904.123740.1915830868205918256.davem@davemloft.net>
	 <20120905044712.GA2284@netboy.at.omicron.at>
	 <2037108.ZemStJh9zr@linux-lqwf.site>
	 <20120905.125016.2259674613767082102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <oneukum@suse.de>, <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39105 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755066Ab2IEWOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 18:14:39 -0400
In-Reply-To: <20120905.125016.2259674613767082102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 12:50 -0400, David Miller wrote:
> From: Oliver Neukum <oneukum@suse.de>
> Date: Wed, 05 Sep 2012 08:24:25 +0200
> 
> > On Wednesday 05 September 2012 06:47:12 Richard Cochran wrote:
> >> and so I think the problem that the test addresses is still present,
> >> or am I missing something?
> > 
> > No,
> > 
> > you are right. Thank you.
> > 
> > Dave, for now, please don't apply this patch. In the long run, this crap
> > in cdc-ncm needs to go. I am starting rewriting this driver right now.
> 
> I already applied it several days ago, someone send me a revert with a
> verbose commit message explaining the situation.

cdc-ncm is aggregating skbs into jumbo USB packets and then, because the
netdev is not signalled when the qdisc stops transmitting, flushing them
after one scheduler tick.  Flushing is done by calling
usbnet_start_xmit() with a null skb pointer and then substituting a real
skb in the tx_fixup callback.

Perhaps the skb_tx_timestamp() call should be moved below the
'if (info->tx_fixup)' block, at which point skb is definitely non-null.
It doesn't look like cdc-ncm will provide useful timestamps either way.

cdc-ncm's aggregation could be improved by either (1) implementing some
type of GSO with appropriate gso_max_size and gso_max_segs limits (2)
adding an explicit transmit flushing operation, similar to that
Alexander Duyck proposed.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
