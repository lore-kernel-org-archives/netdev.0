From: Ido Yariv <ido@wizery.com>
Subject: Re: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Wed, 27 May 2015 12:54:03 -0400
Message-ID: <20150527165403.GC558@WorkStation.home>
References: <1432663992.4060.286.camel@edumazet-glaptop2.roam.corp.google.com>
 <1432671437-19140-1-git-send-email-ido@wizery.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB40A1A@AcuExch.aculab.com>
 <1432734077.4060.382.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527144029.GA558@WorkStation.home>
 <1432738585.4060.392.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527152337.GB558@WorkStation.home>
 <1432743816.4060.404.camel@edumazet-glaptop2.roam.corp.google.com>
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
In-Reply-To: <1432743816.4060.404.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Wed, May 27, 2015 at 09:23:36AM -0700, Eric Dumazet wrote:
> On Wed, 2015-05-27 at 11:23 -0400, Ido Yariv wrote:
> 
> > Signed-off-by: Ido Yariv <idox.yariv@intel.com>
> > ---
> >  include/net/tcp.h     | 9 +++++++++
> >  net/ipv4/tcp_output.c | 2 +-
> >  2 files changed, 10 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/net/tcp.h b/include/net/tcp.h
> > index 2bb2bad..86090b6 100644
> > --- a/include/net/tcp.h
> > +++ b/include/net/tcp.h
> > @@ -1751,4 +1751,13 @@ static inline void skb_set_tcp_pure_ack(struct sk_buff *skb)
> >  	skb->truesize = 2;
> >  }
> >  
> > +/* Convert msecs to jiffies, ensuring that the return value is always at least
> > + * 2. This can be used when setting tick-based timers to guarantee that they
> > + * won't expire right away.
> > + */
> > +static inline unsigned long tcp_safe_msecs_to_jiffies(const unsigned int m)
> > +{
> > +	return max_t(u32, 2, msecs_to_jiffies(m));
> > +}
> 
> Note that you can do slightly better if m is a constant at compile
> time ;)
> 
> if (__builtin_constant_p(m) && m * 1000 >= 2 * HZ)
> 	return msecs_to_jiffies(m);
> return max_t(u32, 2, msecs_to_jiffies(m));
> 
> Or something like that ?

That's a nice optimization ;)

However, I think that with Nicholas Mc Guire's recent changes to
msecs_to_jiffies (http://marc.info/?l=linux-kernel&m=143195210010666),
we should get this for free, no?

Cheers,
Ido.
