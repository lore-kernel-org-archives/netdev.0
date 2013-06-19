From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: nl80211 NULL pointer dereference
Date: Wed, 19 Jun 2013 09:54:48 +0200
Message-ID: <1371628488.8349.3.camel@jlt4.sipsolutions.net>
References: <CA+55aFxOde8n0M2=77-TQ2Ea9iz8s-e8zGFwjj6RVyMFXBgxEA@mail.gmail.com>
	 <20130618.190632.33329016434510583.davem@davemloft.net>
	 <CA+55aFz=eG5-zh1toHxrx=4Qm4DvwyiBCU3u-6tc0-utfZ6xiA@mail.gmail.com>
	 (sfid-20130619_042459_700600_08CD35A3)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	John Linville <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:42234 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933966Ab3FSHy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 03:54:59 -0400
In-Reply-To: <CA+55aFz=eG5-zh1toHxrx=4Qm4DvwyiBCU3u-6tc0-utfZ6xiA@mail.gmail.com> (sfid-20130619_042459_700600_08CD35A3)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-18 at 16:24 -1000, Linus Torvalds wrote:

> So it would seem that it's that
> 
>     info->attrs[NL80211_ATTR_REG_RULES]
> 
> thing that is NULL.
> 
> And yes, the code checks that for being non-NULL in at the top of the
> function, but maybe there is a race with something else setting it to
> NULL? There is a kzalloc(GFP_KERNEL) in between, so it doesn't even
> have to be a very small race...

Yes. I looked at it, and reproduced it (after making the window larger
by putting some sleeps in there and WARN_ON()). It's really just a
stupid mistake I made: in nl80211_dump_wiphy() I parse attributes into
the global nl80211_fam.attrbuf, without making sure that it has proper
locking. Normally we do something like that only on the first iteration
of a dump which is OK because it's locked, but here I did it always,
which is clearly a bug.

I'll have a patch in a minute.

johannes
