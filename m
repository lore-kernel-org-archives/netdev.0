From: Willy Tarreau <w@1wt.eu>
Subject: Re: tcp_tw_recycle broken?
Date: Sat, 15 Nov 2008 08:45:40 +0100
Message-ID: <20081115074540.GA22374@1wt.eu>
References: <f9be06770811142037v794cf4f8w7a82ab45c0f3820c@mail.gmail.com> <20081115055748.GY24654@1wt.eu> <f9be06770811142325j79ca0831j7d5820716199811@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Karl Pickett <karl.pickett@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1215 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753196AbYKOHpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2008 02:45:44 -0500
Content-Disposition: inline
In-Reply-To: <f9be06770811142325j79ca0831j7d5820716199811@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 15, 2008 at 02:25:52AM -0500, Karl Pickett wrote:
> On Sat, Nov 15, 2008 at 12:57 AM, Willy Tarreau <w@1wt.eu> wrote:
> 
> > On Fri, Nov 14, 2008 at 11:37:06PM -0500, Karl Pickett wrote:
> > > Hey.  Developing a http proxy on fedora 9 (2.6.25) and running into a
> > > strange issue.
> > >
> > > Having the proxy set up and tear down 6000 tcp connections a second to
> > > the same test server ip and port,
> > > it quickly blows up (5 seconds) due to all 30000 ephemeral ports going
> > > to TIME_WAIT.
> > > setting tw_recycle=1 fixed the problem, and there are never more than
> > > a couple hundred ports in TIME_WAIT.
> > >
> > > BUT...
> > >
> > > Changing the load test to alternate between two test server ips, it
> > > blows up.  Connect: can't assign requested address. (note I am not
> > > binding before hand, I tried
> > > and binding first to port 0 made no difference - it just blows up then
> > > during the bind).
> > >
> > > And there are ~28K ports in TIME_WAIT.  For example:
> > >
> > > proxy_ip:30000 load_test_1:8080 TIME_WAIT
> > > proxy_ip:30000 load_test_2:8080 TIME_WAIT
> > > ...
> > > but most are not duplicates of the same local port.
> > >
> > >
> > > What. The.  Heck.
> > >
> > > So short of rebuilding the kernel with time_wait as 1 second, is there
> > > any other way not to brick my proxy?
> >
> > two things :
> >  - set tcp_tw_reuse to 1 too.
> >  - do a setsockopt(SO_REUSEADDR) before connect()
> >
> > Using this, my proxy has no problem at 35K sess/s on 2.6.25. I'm not sure
> > if disabling either option above still works.
> >
> > Hoping this helps,
> > Willy
> >
> >
> Well, it looks like tw_reuse is what I wanted... not tw_recycle.  Based on a
> python test program over loopback, tw_reuse alone solves the problem...
> so_reuseaddr doesn't do anything.  And apparently the tcp code is too much
> for me...looking at the source I thought tw_reuse only can happen when
> timestamps are enabled.  But even after disabling timestamps tw_reuse still
> works over loopback.
> 
> I'll have to wait until Monday to try it again in the lab.
> 
> May I just confirm.. is tcp_tw_reuse NOT dependent on receiving timestamps?

I never observed any dependency between both, though the code tends to
make me think there is. However, enabling timestamps is often needed when
you're reusing TW sockets, not because of your local system, but because
of possible intermediate systems between the client and the server, such
as firewalls which randomize sequence numbers. Not having tw_reuse prevents
ports from being reused too early. But having tw_reuse alone often makes
the client chose a source port for which a session still exists on a
middle host, with different sequence numbers, which causes trouble.
Enabling timestamps solves the problem when the other end supports PAWS.

So in general, I would add as a rule of thumb that if you need tw_reuse,
you should also enable timestamps "just in case".

Willy

