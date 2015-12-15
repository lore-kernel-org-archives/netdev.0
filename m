From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as drain mode
Date: Tue, 15 Dec 2015 18:43:46 +0100
Message-ID: <20151215174346.GA3187@1wt.eu>
References: <1443320655.3273.7.camel@edumazet-glaptop2.roam.corp.google.com> <CALx6S34PkfKS47_FxuqwDbqP9P0C5J7YRR5e_-BLjfkPwPRgXw@mail.gmail.com> <1447222769.17135.92.camel@edumazet-glaptop2.roam.corp.google.com> <CALx6S37FOq+JVs8LKh5ezR9JhATrz2=NhmbEYPUxUt8Cyb9xaw@mail.gmail.com> <1447262610.17135.114.camel@edumazet-glaptop2.roam.corp.google.com> <CALx6S37B4mGqYe63JkLmPeQNuOX_WMK2NHaOe7Dtt79Nv9Mo4g@mail.gmail.com> <1447267424.17135.115.camel@edumazet-glaptop2.roam.corp.google.com> <1447290541.22599.11.camel@edumazet-glaptop2.roam.corp.google.com> <20151215161456.GA3182@1wt.eu> <1450199424.8474.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:45466 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932211AbbLORny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 12:43:54 -0500
Content-Disposition: inline
In-Reply-To: <1450199424.8474.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2015 at 09:10:24AM -0800, Eric Dumazet wrote:
> On Tue, 2015-12-15 at 17:14 +0100, Willy Tarreau wrote:
> > Hi Eric,
> > 
> > On Wed, Nov 11, 2015 at 05:09:01PM -0800, Eric Dumazet wrote:
> > > On Wed, 2015-11-11 at 10:43 -0800, Eric Dumazet wrote:
> > > > On Wed, 2015-11-11 at 10:23 -0800, Tom Herbert wrote:
> > > > 
> > > > > How about doing this in shutdown called for a listener?
> > > > 
> > > > Seems a good idea, I will try it, thanks !
> > > > 
> > > 
> > > Arg, I forgot about this shutdown() discussion we had recently
> > > with Oracle guys.
> > > 
> > > It is currently used in linux to unblock potential threads in accept()
> > > system call.
> > > 
> > > This would prevent syn_recv sockets to be finally accepted.
> > 
> > I had a conversation with an haproxy user who's concerned with the
> > connection drops during the reload operation and we stumbled upon
> > this thread. I was considering improving shutdown() as well for this
> > as haproxy already performs a shutdown(RD) during a "pause" operation
> > (ie: workaround for kernels missing SO_REUSEPORT).
> > 
> > And I found that the code clearly doesn't make this possible since
> > shutdown(RD) flushes the queue and stops the listening.
> > 
> > However I found what I consider an elegant solution which works
> > pretty well : by simply adding a test in compute_score(), we can
> > ensure that a previous socket ranks lower than the current ones,
> > and is never considered as long as the new ones are present. Here I
> > achieved this using setsockopt(SO_LINGER). The old process just has
> > to do this with a non-zero value on the socket it wants to put into
> > lingering mode and that's all.
> > 
> > I find this elegant since it keeps the same semantics as for a
> > connected socket in that it avoids killing the queue, and that it
> > doesn't change the behaviour for existing applications. It just
> > turns out that listening sockets are set up without any lingering
> > by default so we don't need to add any new socket options nor
> > anything.
> > 
> > Please let me know what you think about it (patch attached), if
> > it's accepted it's trivial to adapt haproxy to this new behaviour.
> 
> Well, problem is : some applications use LINGER on the listener,
> you can not really hijack this flag.

Ah ? but what does it bring in this case ? I'm not seeing it used
anywhere on a listening socket. The code took care of not breaking
them though (ie they still accept if no other socket shows up with
a higher score). Otherwise we'll have to switch to Tolga's patch,
unless we find another socket option that can safely be combined
and which makes sense (I often find it better not to make userland
depend on new updates of includes when possible).

Cheers,
Willy
