From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH RFC] wext: Add event stream wrappers that return E2BIG
 when values don't fit
Date: Thu, 29 Jan 2015 22:22:09 +0100
Message-ID: <1422566529.6322.26.camel@sipsolutions.net>
References: <1422565452-19825-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	james.minor@ni.com, joseph.hershberger@ni.com, ben.shelton@ni.com,
	jaeden.amero@ni.com, joshc@ni.com, rich.tollerton@ni.com,
	brad.mouring@ni.com
To: Xander Huff <xander.huff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422565452-19825-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-01-29 at 15:04 -0600, Xander Huff wrote:
> From: James Minor <james.minor@ni.com>
> 
> These issues show up when using the WEXT <-> NL80211 conversion layer and
> scanning with that.

Err, this is incorrect - there's no such conversion.

What you mean is "with the wext (compatibility) code in cfg80211".

> When the scan results come back, some of the IEs
> (information elements) are missing, those that specifically advertise the
> network security type. This happens due to the IEs getting chopped off in
> if the buffer that's passed in isn't large enough to get the full IE. The
> fix is to instead return E2BIG. Without this fix, the advertised security
> type is misinterpreted, since it appears to be a WPA or WEP network.
> 
> Testing with this fix resulted in a network which previously showed up as a
> PSK network now correctly showing up as EAP.
> 
> Side effects: A user space app which before did not get E2BIG and instead
> got a clipped off buffer might now get E2BIG instead, if the passed buffer
> is not large enough.

Arguably, apps will always have had to expect that, since we do that
also when it gets full. In fact, I'm not sure why we don't currently do
this, but I guess it depends on where in the data stream we ran out of
space.

Either way, I *strongly* recommend against using this in the first
place. There's an upper bound of 64k (I think) on the amount of memory
that can be used, and people have been known to run into this limit - at
which point you get absolutely no scan results back whatsoever. It's far
safer to use nl80211's scan dump, and if you're looking at this code in
particular then clearly you have it available.

Regarding the patch itself, it seems to add a bit much code. Is there
really no better way to express this? Perhaps by checking that the
stream actually moved forward - which will *always* happen for any of
these functions if they actually did anything? Even maybe if the new
_check inlines were to do that it'd still make the code smaller.

johannes
