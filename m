From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [ 2375.793397] WARNING: CPU: 0 PID: 1149 at
 net/netlink/genetlink.c:1037 genl_unbind+0xc0/0xd0()
Date: Thu, 15 Jan 2015 09:37:51 +0100
Message-ID: <1421311071.1962.2.camel@sipsolutions.net>
References: <20150114161334.28acf5fc@tlielax.poochiereds.net>
	 <1421275700.1950.34.camel@sipsolutions.net>
	 <1421277946.1950.38.camel@sipsolutions.net>
	 <20150114212039.68c9a5a6@synchrony.poochiereds.net>
	 (sfid-20150115_032043_532670_586AA242)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Layton <jeff.layton@primarydata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35005 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433AbbAOIh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 03:37:59 -0500
In-Reply-To: <20150114212039.68c9a5a6@synchrony.poochiereds.net> (sfid-20150115_032043_532670_586AA242)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-14 at 21:20 -0500, Jeff Layton wrote:

> > Ok - after long deliberation I found a way to trigger it. It requires
> > that you leave a multicast group (likely by destroying a socket) at the
> > same time as the kernel unregisters the generic netlink group. I have no
> > idea what generic netlink group you might be using here, but I could
> > reproduce it with a strategically placed delay in the netlink code and
> > the nl80211 genl group by opening a socket, closing the socket, and
> > removing the cfg80211 module (to unregister the nl80211 genl group)
> > while the socket was still being closed.
> > 
> > I'll think about a fix tomorrow - it doesn't seem trivial due to
> > possible locking concerns.

> FWIW, it popped around a dozen times or so?

Yeah it would pop up for every multicast group that any socket you owned
while closing the program (which of course closes the sockets) would
have opened on that genl family.

The thing that confuses me is how you managed to unregister a genl
family at literally the same time, but I cannot find - from code review
- a way to trigger it without that. If the family goes away cleanly
before then the groups of all open sockets are cleared so it can't
happen, and if the family is still alive when the socket is closed then
of course it also can't happen.

> Unfortunately, I didn't save the logs from the run. I'll try to
> reproduce it again tomorrow (and save the logs this time), but I don't
> see it every time.

If you do manage to do that it would be great to confirm that it is
indeed the scenario I found (and reproduced).

Thanks,
johannes
