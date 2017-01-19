From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] net: ethtool: avoid allocation failure for dump_regs
Date: Thu, 19 Jan 2017 10:56:21 -0500
Message-ID: <20170119155620.GD6245@tuxdriver.com>
References: <1484746445-97920-1-git-send-email-darcari@redhat.com>
 <20170118.114505.1855687422610394730.davem@davemloft.net>
 <e88b01a6-dae8-a97e-9a8b-8aab030ad099@redhat.com>
 <20170119141508.GA6245@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>
To: David Arcari <darcari@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49021 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753137AbdASQBq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 11:01:46 -0500
Content-Disposition: inline
In-Reply-To: <20170119141508.GA6245@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I forgot to Cc Johannes and Kalle...

On Thu, Jan 19, 2017 at 09:15:09AM -0500, John W. Linville wrote:
> On Thu, Jan 19, 2017 at 07:35:22AM -0500, David Arcari wrote:
> > On 01/18/2017 11:45 AM, David Miller wrote:
> > > From: David Arcari <darcari@redhat.com>
> > > Date: Wed, 18 Jan 2017 08:34:05 -0500
> > >
> > >> If the user executes 'ethtool -d' for an interface and the associated
> > >> get_regs_len() function returns 0, the user will see a call trace from
> > >> the vmalloc() call in ethtool_get_regs().  This patch modifies
> > >> ethtool_get_regs() to avoid the call to vmalloc when the size is zero.
> > >>
> > >> Signed-off-by: David Arcari <darcari@redhat.com>
> > > I think when the driver indicates this, it is equivalent to saying that
> > > the operation isn't supported.
> > >
> > > Also, this guards us against ->get_regs() methods that don't handle
> > > zero length requests properly.  I see many which are going to do
> > > really terrible things in that situation.
> > >
> > > Therefore, if get_regs_len() returns zero, treat it the safe as if the
> > > ethtool operations were NULL.
> > >
> > > Thanks.
> > 
> > That was actually the fix that I was originally considering, but it
> > turns out
> > there is a problem with it.
> > 
> > I found that the vmalloc error was occurring because
> > ieee80211_get_regs_len() in
> > net/mac80211/ethtool.c was returning zero.  The ieee80211_get_regs in
> > the same
> > file returns the hw version. It turns out that this information is used
> > by the
> > at76c50x-usb driver in the user space ethtool to report which HW variant
> > is in
> > use.  Returning an error when regs_len() returns zero would break this
> > functionality.
> > 
> > -Dave
> 
> I'm responsible for this mess. The original idea was for various
> mac80211-based drivers to override the ethtool operation and provide
> their own dump operation, but the mac80211 crowd never embraced
> the idea.
> 
> In the meantime, I added the default implementation which just
> passed-up wdev->wiphy->hw_version as the version info for a 0-length
> register dump. I then implemented a driver-specific regiser dump
> handler for userland ethtool that would interpret the hardware version
> information for the at76c50x-usb driver.
> 
> So the net of it is, if we treat a return of 0 from get_regs_len()
> as "not supported", we break this one driver-specific feature for
> userland ethtool. Realistically, there are probably very few users
> to care. But I can't guarantee that the number is zero.
> 
> Possible solutions:
> 
> 	-- break userland ethtool for at76c50x-usb
> 	-- avoid 0-len allocation attempt (David Arcari's patch)
> 	-- make allocator accept a 0 length value w/o oops'ing
> 	-- change mac8011 code to return non-zero from get_regs_len()
> 
> Thoughts? The last option holds a certain attraction, but I'm not
> sure how to make it useful...?
> 
> John
> 
> -- 
> John W. Linville		Someday the world will need a hero, and you
> linville@tuxdriver.com			might be all we have.  Be ready.
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
