From: Ido Yariv <ido@wizery.com>
Subject: Re: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Wed, 27 May 2015 10:40:29 -0400
Message-ID: <20150527144029.GA558@WorkStation.home>
References: <1432663992.4060.286.camel@edumazet-glaptop2.roam.corp.google.com>
 <1432671437-19140-1-git-send-email-ido@wizery.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB40A1A@AcuExch.aculab.com>
 <1432734077.4060.382.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ido Yariv <idox.yariv@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432734077.4060.382.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Wed, May 27, 2015 at 06:41:17AM -0700, Eric Dumazet wrote:
> On Wed, 2015-05-27 at 11:36 +0000, David Laight wrote:
> > From: Of Ido Yariv
> > > Sent: 26 May 2015 21:17
> > > The Tail Loss Probe RFC specifies that the PTO value should be set to
> > > max(2 * SRTT, 10ms), where SRTT is the smoothed round-trip time.
> > > 
> > > The PTO value is converted to jiffies, so the timer may expire
> > > prematurely.
> > > 
> > > This is especially problematic on systems in which HZ <= 100, so work
> > > around this by setting the timeout to at least 2 jiffies on such
> > > systems.
> > > 
> > > The 10ms figure was originally selected based on tests performed with
> > > the current implementation and HZ = 1000. Thus, leave the behavior on
> > > systems with HZ > 100 unchanged.
> > > 
> > > Signed-off-by: Ido Yariv <idox.yariv@intel.com>
> > > ---
> > >  net/ipv4/tcp_output.c | 3 +++
> > >  1 file changed, 3 insertions(+)
> > > 
> > > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > > index 534e5fd..5321df8 100644
> > > --- a/net/ipv4/tcp_output.c
> > > +++ b/net/ipv4/tcp_output.c
> > > @@ -2208,6 +2208,9 @@ bool tcp_schedule_loss_probe(struct sock *sk)
> > >  		timeout = max_t(u32, timeout,
> > >  				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
> > >  	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
> > > +#if HZ <= 100
> > > +	timeout = max_t(u32, timeout, 2);
> > > +#endif
> > 
> > Why not:
> > 	timeout = max_t(u32, timeout, max_t(u32, 2, msecs_to_jiffies(10)));
> > I think the RH max_t() is a compile time constant.
> > 
> > You need 2 jiffies to guarantee a non-zero timeout.
> > Even if HZ=199 with a 'rounding down' msecs_to_jiffies() you get 1 jiffy
> > and a possible immediate timeout.
> > 
> 
> Have you followed previous discussions ?
> 
> I guess we can have a helper macro, but for the moment only one spot was
> found.
> 
> Its kind of depressing having to deal with HZ=100 issues, with modern
> NO_HZ configurations.
> 
> TCP rtts have now usec resolution, so HZ=100 is pushing TCP to very
> imprecise behavior.

HZ=100 is used on some embedded platforms, so it's still something we
have to deal with unfortunately..

Since the '2' here is a lower bound, and msecs_to_jiffies(10) will
return values greater than 2 for HZ>100 anyway, always ensuring the
2 jiffies lower bound shouldn't impact the behavior when HZ=1000.

However, as far as I can tell, comparing msecs_to_jiffies(10) to 2, or
comparing the whole timeout to 2 doesn't make much difference, since
msecs_to_jiffies isn't inlined.

In other words, keeping the #if shouldn't make much difference in behavior,
but will save the small comparison.

Cheers,
Ido.
