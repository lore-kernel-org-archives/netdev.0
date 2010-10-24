From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 5/9] tproxy: allow non-local binds of IPv6 sockets if
 IP_TRANSPARENT is enabled
Date: Sun, 24 Oct 2010 14:03:18 +0900
Message-ID: <1287896598.9883.5.camel@takos>
References: <20101020112118.6260.31618.stgit@este.odu>
	 <20101020112118.6260.93956.stgit@este.odu>
	 <4CBEE45D.2080201@linux-ipv6.org>  <1287583653.29676.9.camel@bzorp.lan>
	 <1287696252.2707.24.camel@takos>  <1287845294.13882.4.camel@bzorp.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@balabit.hu>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287845294.13882.4.camel@bzorp.lan>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2010-10-23, Balazs Scheidler wrote:
> On Fri, 2010-10-22 at 06:24 +0900, YOSHIFUJI Hideaki wrote:
> > Hello.
> > 
> > 2010-10-20, Balazs Scheidler wrote:
> > > On Wed, 2010-10-20 at 21:45 +0900, YOSHIFUJI Hideaki wrote:
> > > > (2010/10/20 20:21), KOVACS Krisztian wrote:
> > > > > From: Balazs Scheidler<bazsi@balabit.hu>
> > > > > 
> > > > > Signed-off-by: Balazs Scheidler<bazsi@balabit.hu>
> > > > > Signed-off-by: KOVACS Krisztian<hidden@balabit.hu>
> > > > > ---
> > > > >   net/ipv6/af_inet6.c |    2 +-
> > > > >   1 files changed, 1 insertions(+), 1 deletions(-)
> > > > > 
> > > > > diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> > > > > index 6022098..9480572 100644
> > > > > --- a/net/ipv6/af_inet6.c
> > > > > +++ b/net/ipv6/af_inet6.c
> > > > > @@ -343,7 +343,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
> > > > >   			 */
> > > > >   			v4addr = LOOPBACK4_IPV6;
> > > > >   			if (!(addr_type&  IPV6_ADDR_MULTICAST))	{
> > > > > -				if (!ipv6_chk_addr(net,&addr->sin6_addr,
> > > > > +				if (!inet->transparent&&  !ipv6_chk_addr(net,&addr->sin6_addr,
> > > > >   						   dev, 0)) {
> > > > >   					err = -EADDRNOTAVAIL;
> > > > >   					goto out_unlock;
> > > > > 
> > > > > 
> > > > 
> > > > As I wrote before in other thread, this does not seem sufficient --
> > > > well, it is sufficient to allow non-local bind, but before we're
> > > > allowing this, we need add checks of source address in sending side.
> > > 
> > > Can you please elaborate or point us to the other thread? Is it some
> > > kind of address-type check that we miss?
> > 
> > Please see my comment at:
> > <http://kerneltrap.org/mailarchive/linux-netdev/2010/7/5/6280572>
> > 
> > This will result in allowing non-privileged users easily sending from
> > non-local / unauthorized address, which is not good, and which should
> > not be allowed from security aspects.
> 
> IP_TRANSPARENT requires root (more precisely CAP_NET_ADMIN privielges)
> for IPV6.
> 
> However as I see right now this check was missed from the IPv6
> implementation.
> 
> Is that enough as a safeguard? e.g. something like this:
> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 0553867..f683d2c 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -343,6 +343,10 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
>                 break;
>  
>         case IPV6_TRANSPARENT:
> +                if (!capable(CAP_NET_ADMIN)) {
> +                        retv = -EPERM;
> +                        break;
> +                }
>                 if (optlen < sizeof(int))
>                         goto e_inval;
>                 /* we don't have a separate transparent bit for IPV6 we use the one in the IPv4 socket */
> 
> 
> 

I think it is the thing we must to have.  Thanks.

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji

