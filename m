From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: [PATCHv2] bridge: disable snooping if there is no querier
Date: Thu, 25 Jul 2013 21:31:26 +0200
Message-ID: <20130725193126.GC11914@Linus-Debian>
References: <1374757046-12463-1-git-send-email-linus.luessing@web.de>
 <1374760580-12920-1-git-send-email-linus.luessing@web.de>
 <20130725090140.658f33f7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Cong Wang <amwang@redhat.com>,
	Adam Baker <linux@baker-net.org.uk>,
	Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:49770 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756212Ab3GYTbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 15:31:41 -0400
Received: from localhost ([46.246.33.183]) by smtp.web.de (mrweb103) with
 ESMTPSA (Nemesis) id 0MRlED-1UdqwR2SfR-00Sx4E for <netdev@vger.kernel.org>;
 Thu, 25 Jul 2013 21:31:40 +0200
Content-Disposition: inline
In-Reply-To: <20130725090140.658f33f7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 09:01:40AM -0700, Stephen Hemminger wrote:
> On Thu, 25 Jul 2013 15:56:20 +0200
> Linus L=C3=BCssing <linus.luessing@web.de> wrote:
>=20
> > =20
> > +static void br_multicast_update_querier_timer(struct net_bridge *b=
r,
> > +					      unsigned long max_delay)
> > +{
> > +	if (!timer_pending(&br->multicast_querier_timer))
> > +		atomic64_set(&br->multicast_querier_delay_time,
> > +			     jiffies + max_delay);
> > +
> > +	mod_timer(&br->multicast_querier_timer,
> > +		  jiffies + br->multicast_querier_interval);
> > +}
> > +
>=20
> Isn't this test racing with timer expiration.
>=20
> static void br_multicast_update_querier_timer(struct net_bridge *br,
> 					      unsigned long max_delay)
> {
> 	if (!timer_pending(&br->multicast_querier_timer))
> 		atomic64_set(&br->multicast_querier_delay_time,
> 			     jiffies + max_delay);
> What if timer completes here?

If the timer completes here, then for one thing this means that
the query message is very late (we were supposed to have heard
at least two query messages by now, query messages should by
default arrive every 125 seconds, we are at 255 seconds now).

Which in most cases would have the reason of the original querier
having left.

Not resetting the newly introduced
br->multicast_querier_delay_time means that we won't switch back
to flooding for a grace period (which we would have done if the
timer had completed three lines earlier).

So the question is, does refraining from switching back to
flooding for the grace period result in any packet loss in this
scenario?

Yes and no. Our current records from the previous multicast
listener reports are still valid until
br->multicast_membership_interval, so for another 5 seconds.
So in the worst case we can have lost multicast packets for
up to five seconds for some listeners.

However, normal multicast routers would have the same issue for
this five seconds period. So to me it looks like this is
actually a bug in RFC2710, section 7.4 - Multicast Listener
Interval: We and multicast routers wouldn't have that problem if
it were 'plus (one _and a half_ Query Response Interval)' instead.

So maybe we could just increase br->multicast_membership_interval
from 260 to 265 with another patch?


Despite from that I don't see which other issues could arise from
the race you pointed out here.

>=20
> 	mod_timer(&br->multicast_querier_timer,
> 		  jiffies + br->multicast_querier_interval);
> }
>=20
>=20
> And another race if timer goes off?
>=20
> static void br_multicast_update_querier_timer(struct net_bridge *br,
> 					      unsigned long max_delay)
> {
> 	if (!timer_pending(&br->multicast_querier_timer))
> 		atomic64_set(&br->multicast_querier_delay_time,
> 			     jiffies + max_delay);
> Timer fires here...?
>=20
> 	mod_timer(&br->multicast_querier_timer,
> 		  jiffies + br->multicast_querier_interval);
> }

Hm? Sorry, I don't quite see how this race differs from the one
you pointed out before.


Thanks for looking at this patch so far!

Cheers, Linus
