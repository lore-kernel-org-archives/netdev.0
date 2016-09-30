From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] netfilter: xt_hashlimit: uses div_u64 for division
Date: Fri, 30 Sep 2016 19:39:54 +0200
Message-ID: <201609301939.55089.arnd@arndb.de>
References: <20160930160559.4102745-1-arnd@arndb.de> <20160930160559.4102745-3-arnd@arndb.de> <1475253522.28155.195.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Joshua Hunt <johunt@akamai.com>,
        Vishwanath Pai <vpai@akamai.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1475253522.28155.195.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 30 September 2016, Eric Dumazet wrote:
> On Fri, 2016-09-30 at 18:05 +0200, Arnd Bergmann wrote:
> >  net/netfilter/xt_hashlimit.c | 17 ++++++++++-------
> >  1 file changed, 10 insertions(+), 7 deletions(-)
> > 
> > diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
> > index 44a095ecc7b7..3d5525df6eb3 100644
> > --- a/net/netfilter/xt_hashlimit.c
> > +++ b/net/netfilter/xt_hashlimit.c
> > @@ -464,20 +464,23 @@ static u32 xt_hashlimit_len_to_chunks(u32 len)
> >  static u64 user2credits(u64 user, int revision)
> >  {
> >  	if (revision == 1) {
> > +		u32 user32 = user; /* use 32-bit division */
> > +
> 
> This looks dangerous to me. Have you really tried all possible cases ?

Yes, I'm pretty certain about that: The 11d5f15723c9 patch that introduced this
kept the existing implementation for the revision==1 case, except for changing
the types.

> Caller (even if using revision == 1) does
> user2credits(cfg->avg * cfg->burst, revision);
> 
> Since this is not a fast path, I would prefer to keep the 64bit divide.
>
> Vishwanath version looks safer.

Ok, fair enough. I couldn't tell how much of a fast path this
was, and it's more a general issue that I see with other developers
blindly using div_u64() whenever getting this link error.

Since I already had the patch by the time I saw the other one
(which is also at v3 and got comments), I just sent it out along
with the other two patches I had for netfilter.

I also ended up introducing a typo in a last-minute change, so I'll let
Vishwanath and you work out the best implementation and withdraw my
version.

	Arnd
