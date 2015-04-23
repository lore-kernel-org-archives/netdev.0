From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rhashtable: don't attempt to grow when at max_size
Date: Thu, 23 Apr 2015 21:46:28 +0100
Message-ID: <20150423204628.GA28217@casper.infradead.org>
References: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40032 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbDWUqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 16:46:32 -0400
Content-Disposition: inline
In-Reply-To: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/15 at 04:38pm, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> The conversion of mac80211's station table to rhashtable had a bug
> that I found by accident in code review, that hadn't been found as
> rhashtable apparently managed to have a maximum hash chain length
> of one (!) in all our testing.

This is the desired chain length ;-)

> In order to test the bug and verify the fix I set my rhashtable's
> max_size very low (4) in order to force getting hash collisions.
> 
> At that point, rhashtable WARNed in rhashtable_insert_rehash() but
> didn't actually reject the hash table insertion. This caused it to
> lose insertions - my master list of stations would have 9 entries,
> but the rhashtable only had 5. This may warrant a deeper look, but
> that WARN_ON() just shouldn't happen.

The warning got fixed recently (51bb8e331b) and
rhashtable_insert_rehash() now only allows a single rehash if at
max_size already. It will now return -EBUSY.

Insertions may still fail while the table is above 100% utilization
so this fix is absolutely needed though.

> Fix this by not returning true from rht_grow_above_100() when the
> rhashtable's max_size has been reached - in this case the user is
> explicitly configuring it to be at most that big, so even if it's
> now above 100% it shouldn't attempt to resize.

Good catch. I wonder whether we want to trigger a periodic rehash
in an interval in this situation or just leave this up to the user
to setup a timer himself.

> This fixes the "lost insertion" issue and consequently allows my
> code to display its error (and verify my fix for it.)
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
