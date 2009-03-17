From: Felix von Leitner <felix-kernel@fefe.de>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 18:51:41 +0100
Message-ID: <20090317175141.GA13270@codeblau.de>
References: <20090316233934.GD32111@codeblau.de> <49BF0A5A.2040501@hp.com> <20090317125845.GB9754@codeblau.de> <49BFA9F0.6070702@hp.com> <20090317141432.GA10575@codeblau.de> <49BFBA58.30501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ioctl.codeblau.de ([80.190.240.67]:45316 "EHLO codeblau.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753422AbZCQRvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 13:51:44 -0400
Content-Disposition: inline
In-Reply-To: <49BFBA58.30501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I am worried about the overhead of storing the IPv6 addresses.
> > I am not storing them in the IPv4 case.

> > But the socket code has been rewritten to use IPv6 addresses only,
> > precisely because IPv4-mapped addresses exist.
> So, what you want to do is provide IPv4 only service on a fully
> configured dual-stacked machine by running an IPv6 enabled application?

Yes.
Actually, I want to provide IPv6 and IPv4 service, but it turns out the
users in some cases want to run the service in IPv4-only mode.

> Why do you not want to provide IPv6 side of the same service?

As I said, in this particular case, you run two processes.
One for IPv6 and one for IPv4.

The reason is that

  a) it's P2P, so you don't want to provide IPv6 addresses of peers to
  IPv4 users anyway, because if they supported IPv6, they'd be
  connecting via IPv6.

  b) IPv4 users outnumber IPv6 users by a wide margin.  For the IPv4
  case it does not make sense to waste 12 bytes per IP address to even
  store the "::ffff:" part.

> You mentioned overhead (and I am guessing that's the answer the above question),
> but is the number of IPv6 clients so high that your service would
> not be able to handle it.

The overhead is the memory overhead needed to store the IP addresses of
the peers.  For some popular files we are talking about a five digit
number of peers, and we don't want to store the full IPv6 address for
those.  We do want to use IPv6 sockets so we don't have to add code to
differentiate and make it work, because the kernel already has that code
in the form of the ipv4-mapped address handling code.  And it works,
except for that one if clause that prevents me from binding to
::ffff:0.0.0.0

As I said, this is not _me_ who wants to bind there.  It's the user who
uses "-i 0.0.0.0" to get a process that runs only in IPv4 mode.  It took
me a while to see the point in that, too.

But again, it's not my place to argue with the customers on how they
want to use the software.  It's my place to provide software that does
what they need.  And if you ask me, the same holds true for you.

> As I've already mentioned, your overhead of tracking IPv6 clients is actually
> lower that tracking all the IPv4 clients using mapped addresses.

You did not understand the problem then.
I hope you understand it now.

> One way of preventing the tracking IPv6 clients is by disallowing IPv6 traffic
> or even not configuring any IPv6 addresses.  That could get what you want
> right now, without waiting for a kernel patch.

We do have IPv6, and we have it enabled, and we run a copy of the
software on the IPv6 address, too.

Now we could bind to the specific address of the PC, but that happens to
inferfere with the load balancing and failover installation we have.  In
the case of one failing node, we configure that IP address on one of the
other hosts and expect that host to handle that traffic.

> In this case, you are making a trade-off of application complexity against
> kernel complexity.  You are making your application much simpler, while demanding
> more complexity from the kernel.

In fact it's the other way around.

I waited for the kernel to support v4 mapped addresses.
Then I wrote the socket layer on top of it.

You already committed on providing the complexity.  Now I just want you
to follow through on the promise. :-)

> >> If you are prepared to deal with it, you might as well deal with real ipv6 addresses
> >> at the same time and mitigate your overhead somewhat.
> > You are currently proving all the snide remarks by the BSD people about
> > the Linux IP stack true, and the "professionalism" snide remarks of the
> > Solaris people.  Great work, man.
> This is really a great way to convince someone to do the work... :/

Hey, I'm just saying.  My middleware runs on Linux, BSD, OSX and
Solaris.  I'm just writing the middleware.  Previously, users of my
middleware switched from BSD to Linux because v4 mapped v6 addresses
were turned off by default in FreeBSD.  My users made a stink about it
and convinced FreeBSD to change the default.  But many of them switched
to Linux.

What do you think happens if my middleware now does not work right on
Linux?  People will switch to Solaris.  Or FreeBSD.

I am willing to put up a fight before abandoning ship.  You apparently
think this is a disservice to you because I'm taking your time with
this, but it's in fact the opposite.  I'm giving Linux an opportunity
here to set things right.

Linux has stood tall as a beacon of "it may take us longer but we like
to do things right".  We did not just do a big kernel lock, we wanted to
do it right.  We did not just take an old Unix filesystem, we wanted to
do it right.  We did not just reimplement mbufs, we wanted to do memory
management right.

And now I hope we do not just let some language lawyer weasel through
some RFC and provide an interpretation of it that would legally allow
the current broken behavior.  I hope we fix it instead.

This may not seem like much to you, but we are talking about the biggest
noncommercial Internet messaging infrastructure here.  If they run
Linux, that is an asset for Linux.  Because it shows that we can scale.
We can provide a proper implementation of the IPv6 APIs.

Please don't be part of the problem.  Be part of the solution.

Felix
