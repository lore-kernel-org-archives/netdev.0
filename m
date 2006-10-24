From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Tue, 24 Oct 2006 11:10:21 +0200
Message-ID: <1161681021.2840.23.camel@ux156>
References: <1161335976.21402.11.camel@devlinux-hong>
	 <20061023144028.629dc5d8@griffin.suse.cz> <1161607680.6617.36.camel@ux156>
	 <20061023145646.32bbd59f@griffin.suse.cz>
	 <1161678053.7083.7.camel@devlinux-hong>  <1161678908.2840.12.camel@ux156>
	 <1161679134.7258.6.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38023 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030251AbWJXJJZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 05:09:25 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1161679134.7258.6.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-24 at 16:38 +0800, Hong Liu wrote:

> The first time when we set the TKIP key, we can set the phase1 key if
> the driver requires.

Right.

> The problem is when IV16 wraps, who will generate the new phase1 key?

Ok, I was confused for a moment, but yes, when the 16-bit part of the IV
wraps then the upper part changes and hence you need to regenerate the
phase1 key. 

> If the stack need to do this, then we will need to call set_key in the
> packet TX path which I think may not be appropriate.

Well, I checked again and found that bcm34xx requires the IV (48) to be
maintained by software, iow with each packet you tell the hardware what
the IV16 should be. Hence you know when it has wrapped and thus (before
submitting the DMA for the packet) you can regenerate the phase1 key in
software and upload it to the hardware key memory.

This is getting quite complicated. How about having the stack maintain
the IV *only*, and adding helper functions for
 * generating the phase 1 key
 * generating the phase 2 key based on the phase 1 key
that the drivers can use as required?

ipw3945 would call both key generation functions as required, and
bcm43xx would just call the phase 1 function when a key is uploaded and
when the iv16 wraps, not using the phase 2 function at all.

johannes
