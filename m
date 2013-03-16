From: William Ahern <william@25thandclement.com>
Subject: Re: connect(2) reassociation regression
Date: Sat, 16 Mar 2013 13:39:55 -0700
Message-ID: <20130316203955.GA23495@wilbur.25thandClement.com>
References: <20130316055632.GA21364@wilbur.25thandClement.com> <1363445467.29475.63.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [68.68.99.238] ([68.68.99.238]:39878 "EHLO
	wilbur.25thandClement.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751325Ab3CPUkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 16:40:43 -0400
Content-Disposition: inline
In-Reply-To: <1363445467.29475.63.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 16, 2013 at 07:51:07AM -0700, Eric Dumazet wrote:
> On Fri, 2013-03-15 at 22:56 -0700, William Ahern wrote:
> > I've stumbled upon what may be a regression in connect(2) behavior.
<snip>
> > At some point in the 3.x cycle (maybe after 3.2.0) something was changed.
> > Whereas previously any reassociation worked, regardless of destination
> > network, now if the _first_ association is to the loopback, any subsequent
> > association to non-loopback fails with EINVAL. However, if the loopback is
> > the second or later association then everything continues to work. In other
> > words, the sequence
> > 
<snip>
> 
> There is an issue as the connect() call sets both local address:port and
> remote address, in the case the local address was not already set by a
> prior bind().
> 
> And once bound to a local address, its not really clear if we are
> allowed to bind to a different one, and fall in the possible traps of
> SO_REUSEADDR and find another socket bound to the same local addr:port.
> 
> So if the second connect() also change the source port, I am pretty sure
> some applications will badly break.
> 
> I would just avoid the problem of handling this mess, and let the
> application close the socket and allocate a new one.

This is for UDP, not TCP. The alternative is sendto/recvfrom. For a
non-blocking, recursive DNS library reopening sockets all of the time is
really messy.

> Changing the kernel behavior on these kind of unspecified stuff might
> break some other applications.

Indeed. The behavior _was_ changed, and my application broke, and
potentially many other applications.

> Clearly the BSD API was bad, as the connect() is a 'super operation',
> not only setting the remote address:port, but also the local
> address:port given the current routing table.

Well, AFAICT Linux implemented this behavior for years. FWIW, Solaris also
implements this behavior. It's been universal until recently.
