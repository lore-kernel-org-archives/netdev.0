From: Phil Sutter <phil@nwl.cc>
Subject: Re: RFC: ss: improve horizontal output scaling
Date: Thu, 24 Sep 2015 14:36:15 +0200
Message-ID: <20150924123615.GB26600@orbit.nwl.cc>
References: <20150924111650.GY24212@orbit.nwl.cc>
 <1443097547.29850.159.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:42924 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754340AbbIXMgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 08:36:17 -0400
Content-Disposition: inline
In-Reply-To: <1443097547.29850.159.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 05:25:47AM -0700, Eric Dumazet wrote:
> On Thu, 2015-09-24 at 13:16 +0200, Phil Sutter wrote:
> > Hi,
> > 
> > Currently, ss scales it's output to the available horizontal screen
> > space available, so that the regular columns (Netid, State, Recv-Q,
> > Send-Q, Local Address:Port and Peer Address:Port) use the maximum space
> > available and extended information (e.g. users) get wrapped into a new
> > line.
> > 
> > While this approach is sufficient for smaller terminals to improve
> > readability, it's kind of awkward in full-screen terminals which provide
> > enough space to display everything on the same line.
> > 
> > On the other hand, the current approach makes sense in that the output
> > width is hard to predict: Unix domain sockets have a filesystem path as
> > local address, which might be really long (e.g. 68 characters for a
> > libvirt socket on my box). The '-p' flag prints process names, so
> > extended information might become very long as well. The actual width of
> > each line's fields is not known before it has been printed. Since input
> > potentially comes from netlink, there is no random access which could be
> > used to scroll quickly through the input and find each column's longest
> > field.
> > 
> > There are a number of possible ways to improve this:
> > 
> > 1. Introduce scalemax parameter:
> >    This parameter specifies the maximum terminal width to scale to.
> >    Implementation is trivial, and works well for me as my terminals are
> >    either 95, 126 or 193 characters wide. Setting scalemax to 128 leaves
> >    line wrapping in place in all but full-screen mode. Though other's
> >    mileage may vary, and fiddling with this number is inconvenient as
> >    well.
> 
> The big ss mistake was to not insert a new line before 'extended' info
> (this gives uid: ino: and sk: fields)
> 
> "ss -te | more" only gives one line per socket today
> 
> But "ss -ti" gives 2 lines per socket
> 
> Not sure we can change this. Maybe make it conditional to
>  if (isatty(STDOUT_FILENO)) 
> 
> (If stdout is a terminal, then cap the screen_width to 100 but insert a
> new line before extended)
> 
> I very often use "ss -tei|more" to get rid of these extra long lines, so
> I would vote to cap screen_width to 100 anyway.

This is because TIOCGWINSZ returns 80 if the output is a pipe. This
means that with '| more', output is simply scaled to 80 columns instead
of what your actual terminal width is.

Inserting a newline instead of leaving the wrapping to the terminal
would mean to enforce two lined output in any case. Then your '| more'
trick (which is nice, btw) would not work anymore.

In general I think the wrapping is a good thing to do, as this way you
can maximise a terminal afterwards and get cleaner output. Of course,
repeating the command in the maximised terminal will make it messy
again. :)

Thanks, Phil
