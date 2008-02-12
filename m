From: Ross Vandegrift <ross@kallisti.us>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 12 Feb 2008 15:38:57 -0500
Message-ID: <20080212203857.GA32506@kallisti.us>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com> <20080205192559.GA10573@kallisti.us> <20080205201106.GB26150@one.firstfloor.org> <20080205212335.GA11287@kallisti.us> <20080206085357.GA1402@one.firstfloor.org> <20080207194446.GA25463@kallisti.us> <20080208120746.GE4745@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Glenn Griffin <ggriffin.kernel@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764479AbYBLUkb@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080208120746.GE4745@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 08, 2008 at 01:07:46PM +0100, Andi Kleen wrote:
> On Thu, Feb 07, 2008 at 02:44:46PM -0500, Ross Vandegrift wrote:
> > On Wed, Feb 06, 2008 at 09:53:57AM +0100, Andi Kleen wrote:
> > My initial test is end-to-end 1000Mbps, but I've got a few different
> > packet rates.
> > 
> > > If the young/old heuristics do not work well enough anymore most
> > > likely we should try readding RED to the syn queue again. That used
> > > to be pretty effective in the early days. I don't quite remember why
> > > Linux didn't end up using it in fact.
> > 
> > I'm running juno-z with 2, 4, & 8 threads of syn flood to port 80.
> > wireshark measures 2 threads at 350pps, 4 threads at 750pps, and 8
> 
> What's the total bandwidth of the attack?

Sorry for the delay in getting back to you on this Andi.

Here's a breakdown for each attack of the pps and bandwidth:

packets/s	Mb/s

380		0.182 
715		0.343
1193		0.572
16460		7.896

The first three tests were done with some fixed delay inbetween syn
floods.  The last is done with all delays as small as possible.


> > threads at 1200pps.  Under no SYN flood, the server handles 750 HTTP
> > requests per second, measured via httping in flood mode.
> 
> Thanks for the tests. Could you please do an additional experiment? 
> Use sch_em or similar to add a jittering longer latency in the connection
> (as would be realistic in a real distributed DOS). Does it make a
> difference? 

Jitter on both ends makes it worse.  Jitter only on the syn flooder
end behaves approximately the same.

If I add jitter to both the flooder and the target with:
	tc qdisc add dev eth0 root netem delay 50ms 100ms distribution normal
I can kill off the host with even a single thread of syn flooding,
even with a backlog queue size of 32768.


> > With a default tcp_max_syn_backlog of 1024, I can trivially prevent
> > any inbound client connections with 2 threads of syn flood.
> > Enabling tcp_syncookies brings the connection handling back up to 725
> > fetches per second.
> 
> Yes the defaults are probably too low. That's something that should
> be fixed.

Yea, with a longer queue, the server is somewhat more resiliant.  But
it's still pretty easy to overwhelm it.  syncookies is a night and day
difference.


> > At these levels the CPU impact of tcp_syncookies is nothing.  I can't
> 
> CPU impact of syncookies was never a concern. The problems are rather
> missing flow control and disabling of valuable TCP features.

Oh definitely - Willy raised the CPU issue in another mail, I was just
including my findings with a bigger CPU.

In general I agree with you for the TCP features, but in the cases where
we're enabling syncookies, it's the difference between bad connectivity and
no connectivity.

-- 
Ross Vandegrift
ross@kallisti.us

"The good Christian should beware of mathematicians, and all those who
make empty prophecies. The danger already exists that the mathematicians
have made a covenant with the devil to darken the spirit and to confine
man in the bonds of Hell."
	--St. Augustine, De Genesi ad Litteram, Book II, xviii, 37
