From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: RE: [PATCH] netfilter: fix stringop-overflow warning with UBSAN
Date: Wed, 4 Oct 2017 20:01:13 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1710041956250.9636@blackhole.kfki.hu>
References: <20170731100913.465530-1-arnd@arndb.de> <063D6719AE5E284EB5DD2968C1650D6DD0047F28@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: 'Arnd Bergmann' <arnd@arndb.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Aaron Conole <aconole@bytheb.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "coreteam@netfilter.org" <coreteam@netfilter.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0047F28@AcuExch.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

[Sorry, at holiday I just cursory watched the mailing lists.]

On Tue, 1 Aug 2017, David Laight wrote:

> From: Arnd Bergmann
> > Sent: 31 July 2017 11:09
> > Using gcc-7 with UBSAN enabled, we get this false-positive warning:
> > 
> > net/netfilter/ipset/ip_set_core.c: In function 'ip_set_sockfn_get':
> > net/netfilter/ipset/ip_set_core.c:1998:3: error: 'strncpy' writing 32 bytes into a region of size 2
> > overflows the destination [-Werror=stringop-overflow=]
> >    strncpy(req_get->set.name, set ? set->name : "",
> >    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> >     sizeof(req_get->set.name));
> >     ~~~~~~~~~~~~~~~~~~~~~~~~~~
> > 
> > This seems completely bogus, and I could not find a nice workaround.
> > To work around it in a less elegant way, I change the ?: operator
> > into an if()/else() construct.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > ---
> >  net/netfilter/ipset/ip_set_core.c | 8 ++++++--
> >  1 file changed, 6 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
> > index e495b5e484b1..d7ebb021003b 100644
> > --- a/net/netfilter/ipset/ip_set_core.c
> > +++ b/net/netfilter/ipset/ip_set_core.c
> > @@ -1995,8 +1995,12 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
> >  		}
> >  		nfnl_lock(NFNL_SUBSYS_IPSET);
> >  		set = ip_set(inst, req_get->set.index);
> > -		strncpy(req_get->set.name, ,
> > -			IPSET_MAXNAMELEN);
> > +		if (set)
> > +			strncpy(req_get->set.name, set->name,
> > +				sizeof(req_get->set.name));
> > +		else
> > +			memset(req_get->set.name, '\0',
> > +			       sizeof(req_get->set.name));
> 
> If you use strncpy() here, the compiler might optimise the code
> back to 'how it was before'.
> 
> Or, maybe an explicit temporary: 'const char *name = set ? set->name : "";

I think the best to go with the explicit temporary variable. The if-else 
construct is too much for such a case.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
