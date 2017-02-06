From: Alban Browaeys <alban.browaeys@gmail.com>
Subject: Re: [PATCH] netfilter: xt_hashlimit: Fix integer divide round to
 zero.
Date: Mon, 06 Feb 2017 15:28:07 +0100
Message-ID: <1486391287.2374.1.camel@gmail.com>
References: <20170204224731.3222-1-alban.browaeys@gmail.com>
         <20170206130443.GA10990@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206130443.GA10990@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 06 février 2017 à 14:04 +0100, Pablo Neira Ayuso a écrit :
> On Sat, Feb 04, 2017 at 11:47:31PM +0100, Alban Browaeys wrote:
> > diff --git a/net/netfilter/xt_hashlimit.c
> > b/net/netfilter/xt_hashlimit.c
> > index 10063408141d..df75ad643eef 100644
> > --- a/net/netfilter/xt_hashlimit.c
> > +++ b/net/netfilter/xt_hashlimit.c
> > @@ -463,21 +463,19 @@ static u32 xt_hashlimit_len_to_chunks(u32 len)
> >  /* Precision saver. */
> >  static u64 user2credits(u64 user, int revision)
> >  {
> > > > +	/* Avoid overflow: divide the constant operands first */
> > > >  	if (revision == 1) {
> > > > -		/* If multiplying would overflow... */
> > > > -		if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
> > > > -			/* Divide first. */
> > > > -			return div64_u64(user, XT_HASHLIMIT_SCALE)
> > > > -				* HZ * CREDITS_PER_JIFFY_v1;
> > > > +		return div64_u64(user, div64_u64(XT_HASHLIMIT_SCALE,
> > > > +			HZ * CREDITS_PER_JIFFY_v1));
> >  
> > > > -		return div64_u64(user * HZ * CREDITS_PER_JIFFY_v1,
> > > > +		return user * div64_u64(HZ * CREDITS_PER_JIFFY_v1,
> >  				 XT_HASHLIMIT_SCALE);
> 
> I see two return statements here, the one coming later is
> shadowed, this can't be right.

I fixed revision 2 case then copy the code to revision 1
 and lost the condition in the process.
The code duplication is useless. I will rework it in v2.

Thank you for the review.
