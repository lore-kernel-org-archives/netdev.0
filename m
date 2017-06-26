From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] separate SIOCGIFCONF from the rest of dev_ioctl()
Date: Mon, 26 Jun 2017 23:06:40 +0100
Message-ID: <20170626220640.GC10672@ZenIV.linux.org.uk>
References: <20170626174033.GA10672@ZenIV.linux.org.uk>
 <1498508714.24675.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49196 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751381AbdFZWGo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 18:06:44 -0400
Content-Disposition: inline
In-Reply-To: <1498508714.24675.5.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 26, 2017 at 10:25:14PM +0200, Johannes Berg wrote:
> On Mon, 2017-06-26 at 18:40 +0100, Al Viro wrote:
> 
> > 	Only two of dev_ioctl() callers may pass SIOCGIFCONF to it.
> > Separating that codepath from the rest of dev_ioctl() allows both
> > to simplify dev_ioctl() itself (all other cases work with struct
> > ifreq *)
> > *and* seriously simplify the compat side of that beast: all it takes
> > is passing to inet_gifconf() an extra argument - the size of
> > individual
> > records (sizeof(struct ifreq) or sizeof(struct compat_ifreq)).  With
> > dev_ifconf() called directly from sock_do_ioctl()/compat_dev_ifconf()
> > that's easy to arrange.
> 
> No objection from me; however, I just introduced another special case
> (in a bugfix for a >20yo bug ...) here:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/?id=68dd02d19c811ca8ea60220a9d73e13b4bdad73a
> 
> It would perhaps make sense to also pull that out into the caller,
> which could also get rid of the stupid way the #ifdef is placed in
> sock_ioctl(). For compat, it's already pulled out anyway, even a level
> up than where you're calling it for SIOCGIFCONF - might make sense to
> put the wext stuff into compat_sock_ioctl_trans() too.

BTW, speaking of odd ioctls - e.g. SIOCGIFMETRIC does
	* for AF_AX25, AF_X25, AF_IRDA, AF_NETROM, AF_ROSE: fail with -EINVAL
	* everything else - store 0 in ifr->ifr_metric and succeed.
Is there anything special about that set of families or is it just a cut'n'paste
accident?  SIOCGIFNETMASK:
	* AF_AX25, AF_X25, AF_IRDA, AF_NETROM, AF_ROSE, AF_IPX, AF_QIPCRTR: -EINVAL
	* AF_INET: return ipv4 netmask associated with the interface in question.
	* AF_PACKET: if CONFIG_INET => as AF_INET, otherwise -ENOIOCTLCMD
	* everything else: -ENOTTY, as far as I can tell
Again, what makes ax25 different from e.g. decnet?  netmask makes no sense for
either, and AFAICS in exact same way.  And the set of -EINVAL ones is similar,
but not identical to SIOCGIFMETRIC case...

And then there's SIOCGSTAMP and friends; AFAICS, they are identical for everything
that implements them, modulo differences in locking.  The set of those who have
those also looks fairly random...
