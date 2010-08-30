From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: fix 64K kernel heap content leak via ioctl
Date: Mon, 30 Aug 2010 11:59:01 +0200
Message-ID: <1283162341.3691.45.camel@jlt3.sipsolutions.net>
References: <20100827210240.GC4703@outflux.net>
	 <20100827212254.GB32275@bougret.hpl.hp.com>
	 <1283158058.3691.10.camel@jlt3.sipsolutions.net>
	 <1283158704.3691.11.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <kees.cook@canonical.com>, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>, Tejun Heo <tj@kernel.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:35484 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755115Ab0H3J7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 05:59:18 -0400
In-Reply-To: <1283158704.3691.11.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-30 at 10:58 +0200, Johannes Berg wrote:

> > > @@ -800,9 +800,12 @@ static int ioctl_standard_iw_point(struc
> > >                         goto out;
> > >                 }
> > >  
> > > -               if (copy_to_user(iwp->pointer, extra,
> > > -                                iwp->length *
> > > -                                descr->token_size)) {
> > > +               /* Verify how much we should return. Some driver
> > > +                * may abuse iwp->length... */
> > > +               if((iwp->length * descr->token_size) < extra_size)
> > > +                       extra_size = iwp->length * descr->token_size;
> > > +
> > > +               if (copy_to_user(iwp->pointer, extra, extra_size)) {
> > >                         err = -EFAULT;
> > >                         goto out;

Ok I finally fully understood the issue.

This will fix the problem, but the comment is completely bogus, which I
guess means you didn't actually understand the problem.

> > I believe the below patch is a much better fix as it allows the -E2BIG
> > code path to be invoked which is more informative to users than
> > truncated information (which, in your code, may even be truncated in the
> > middle of a token!!)

My patch also didn't fix the problem, I didn't understand the problem
correctly and was continuously wondering how drivers would ever fill the
buffer with more than max_tokens (which would be a more serious bug,
since they'd overwrite a slab object after "extra").

What really fixes the problem is the patch below though. Had to realise
that the path where the driver didn't do ANYTHING AT ALL was the
problem....

johannes

Subject: wireless extensions: fix kernel heap content leak

From: Johannes Berg <johannes.berg@intel.com>

Wireless extensions have an unfortunate, undocumented
requirement which requires drivers to always fill
iwp->length when returning a successful status. When
a driver doesn't do this, it leads to a kernel heap
content leak when userspace offers a larger buffer
than would have been necessary.

Arguably, this is a driver bug, as it should, if it
returns 0, fill iwp->length, even if it separately
indicated that the buffer contents was not valid.

However, we can also remove this requirement and
avoid this class of driver bugs by setting the iwp
length to max_tokens, which then reflects how big
the buffer is that the driver may fill, regardless
of how big the userspace buffer is.

To illustrate the point, this patch also fixes a
corresponding cfg80211 bug (since this requirement
isn't documented nor was ever pointed out by anyone
during code review, I don't trust all drivers nor
all cfg80211 handlers to implement it correctly).

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/wireless/wext-compat.c |    3 +++
 net/wireless/wext-core.c   |   16 ++++++++++++++++
 2 files changed, 19 insertions(+)

--- wireless-testing.orig/net/wireless/wext-core.c	2010-08-30 11:29:26.000000000 +0200
+++ wireless-testing/net/wireless/wext-core.c	2010-08-30 11:57:41.000000000 +0200
@@ -782,6 +782,22 @@ static int ioctl_standard_iw_point(struc
 		}
 	}
 
+	if (IW_IS_GET(cmd) && !(descr->flags & IW_DESCR_FLAG_NOMAX)) {
+		/*
+		 * If this is a GET, but not NOMAX, it means that the extra
+		 * data is not bounded by userspace, but by max_tokens. Thus
+		 * set the length to max_tokens. This matches the extra data
+		 * allocation.
+		 * The driver should fill it with the number of tokens it
+		 * provided, and it may check iwp->length rather than having
+		 * knowledge of max_tokens. If the driver doesn't change the
+		 * iwp->length, this ioctl just copies back max_token tokens
+		 * filled with zeroes. Hopefully the driver isn't claiming
+		 * them to be valid data.
+		 */
+		iwp->length = descr->max_tokens;
+	}
+
 	err = handler(dev, info, (union iwreq_data *) iwp, extra);
 
 	iwp->length += essid_compat;
--- wireless-testing.orig/net/wireless/wext-compat.c	2010-08-30 11:49:22.000000000 +0200
+++ wireless-testing/net/wireless/wext-compat.c	2010-08-30 11:49:29.000000000 +0200
@@ -1420,6 +1420,9 @@ int cfg80211_wext_giwessid(struct net_de
 {
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
 
+	data->flags = 0;
+	data->length = 0;
+
 	switch (wdev->iftype) {
 	case NL80211_IFTYPE_ADHOC:
 		return cfg80211_ibss_wext_giwessid(dev, info, data, ssid);


