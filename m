From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] ppp: ensure file->private_data can't be overridden
Date: Mon, 14 Mar 2016 18:59:40 +0100
Message-ID: <20160314175940.GB1462@alphalink.fr>
References: <3f04de903b6be9e1c30427830c0a1568478e0c6c.1457462784.git.g.nault@alphalink.fr>
 <20160311.144216.676727973447663610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, paulus@samba.org, alan@linux.intel.com,
	arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60110 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354AbcCNR7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 13:59:44 -0400
Content-Disposition: inline
In-Reply-To: <20160311.144216.676727973447663610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 02:42:16PM -0500, David Miller wrote:
> From: Guillaume Nault <g.nault@alphalink.fr>
> Date: Tue, 8 Mar 2016 20:14:30 +0100
> 
> > Lock ppp_mutex and check that file->private_data is NULL before
> > executing any action in ppp_unattached_ioctl().
> > The test done by ppp_ioctl() can't be relied upon, because
> > file->private_data may have been updated meanwhile. In which case
> > ppp_unattached_ioctl() will override file->private_data and mess up
> > reference counters or loose pointer to previously allocated PPP unit.
> > 
> > In case the test fails, -ENOTTY is returned, just like if ppp_ioctl()
> > had rejected the ioctl in the first place.
> > 
> > Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> 
> If this thing can disappear on us, then we need to make the entirety
> of ppp_ioctl() run with the mutex held to fix this properly.
> 
> Otherwise ->private_data could go NULL on us meanwhile as well.
> 
> We should hold the mutex, to stabilize the value of ->private_data.

Actually, only ppp_release() can reset ->private_data to NULL. Beyond
closing the file's last reference, the only way to trigger it is
to run the PPPIOCDETACH ioctl. But even then, ppp_release() isn't
called if the file has more than one reference.
So ->private_data should never go NULL from under another user.

As for setting ->private_data to non-NULL value, this is exclusively
handled by ppp_unattached_ioctl(). Since the ppp_mutex is held at the
beginning of the function, calls are serialised, but one may still
overwrite ->private_data and leak the memory previously pointed to.
By testing ->private_data with ppp_mutex held, this patch fixes this
issue, and ->private_data is now guaranteed to remain constant after
it's been set.

Testing ->private_data without lock in ppp_ioctl() before calling
ppp_unattached_ioctl() is fine, because either ->private_data is
not NULL and thus is stable, or it is and ppp_unattached_ioctl()
takes care of not overriding ->private_data, should its value get
modified before taking the mutex.


I considered moving ppp_mutex up to cover the entirety of ppp_ioctl()
too, but finally choosed to handle everything in ppp_unattached_ioctl()
because that's where the problem really stands.
ppp_ioctl() takes the mutex for historical reasons (semi-automatic BKL
removal) and there are several places where holding ppp_mutex seems
unnecessary (e.g. for PPPIOCDETACH). So I felt the right direction was
to move ppp_mutex further down rather than moving it up to cover the
entirety of ppp_ioctl().

In particular, with regard to adding rtnetlink handlers for PPP (which
is the objective that lead to those PPP fixes), holding ppp_mutex for
too long is a problem. An rtnetlink handler would run under protection
of the rtnl mutex, and would need to grab ppp_mutex too (unless we
don't associate the PPP unit fd to the net device in the .newlink
callback).
But currently the PPPIOCNEWUNIT ioctl holds ppp_mutex before taking the
rtnl mutex (in ppp_create_interface()). In this context moving
ppp_mutex up to ppp_ioctl() makes things more difficult because what's
required is, on the contrary, moving it further down so that it gets
held after the rtnl mutex.
However I'd agree that such consideration shouldn't come into play for
fixes on net. It weighted a bit in my decision to not push ppp_mutex
up though.
