From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] rhashtable: don't attempt to grow when at max_size
Date: Thu, 23 Apr 2015 22:49:52 +0200
Message-ID: <1429822192.9525.2.camel@sipsolutions.net>
References: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
	 <20150423204628.GA28217@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36608 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164AbbDWUt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2015 16:49:59 -0400
In-Reply-To: <20150423204628.GA28217@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-23 at 21:46 +0100, Thomas Graf wrote:
> On 04/23/15 at 04:38pm, Johannes Berg wrote:
> > From: Johannes Berg <johannes.berg@intel.com>
> > 
> > The conversion of mac80211's station table to rhashtable had a bug
> > that I found by accident in code review, that hadn't been found as
> > rhashtable apparently managed to have a maximum hash chain length
> > of one (!) in all our testing.
> 
> This is the desired chain length ;-)

Sure. But I had a bug in my handling of collisions, so I explicitly
wanted to test them. After all, they are in some ways expected in a hash
table :)

> > At that point, rhashtable WARNed in rhashtable_insert_rehash() but
> > didn't actually reject the hash table insertion. This caused it to
> > lose insertions - my master list of stations would have 9 entries,
> > but the rhashtable only had 5. This may warrant a deeper look, but
> > that WARN_ON() just shouldn't happen.
> 
> The warning got fixed recently (51bb8e331b) and
> rhashtable_insert_rehash() now only allows a single rehash if at
> max_size already. It will now return -EBUSY.
> 
> Insertions may still fail while the table is above 100% utilization
> so this fix is absolutely needed though.

Yeah just failing would be a bit strange.

> > Fix this by not returning true from rht_grow_above_100() when the
> > rhashtable's max_size has been reached - in this case the user is
> > explicitly configuring it to be at most that big, so even if it's
> > now above 100% it shouldn't attempt to resize.
> 
> Good catch. I wonder whether we want to trigger a periodic rehash
> in an interval in this situation or just leave this up to the user
> to setup a timer himself.

You could just document it that it's probably useful if max_size is set?
I'm just going to be setting max_size for debug purposes, so don't
really care all that much.

johannes
