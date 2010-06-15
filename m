From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCH] net: IP_NODEFRAG option for IPv4 socket
Date: Tue, 15 Jun 2010 11:18:39 +0200
Message-ID: <20100615091715.GB8840@jolsa.Belkin>
References: <4C0FA24A.7060907@trash.net>
 <20100610065631.GA1915@jolsa.lab.eng.brq.redhat.com>
 <4C10ACDC.6010108@trash.net>
 <20100610095312.GC1915@jolsa.lab.eng.brq.redhat.com>
 <4C10B8C8.2050201@trash.net>
 <20100611081604.GA1739@jolsa.Belkin>
 <alpine.LSU.2.01.1006111152230.30433@obet.zrqbmnf.qr>
 <20100611131038.GB1739@jolsa.Belkin>
 <20100615065335.GA8840@jolsa.Belkin>
 <1276586029.2541.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1276586029.2541.12.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 15, 2010 at 09:13:49AM +0200, Eric Dumazet wrote:
> Le mardi 15 juin 2010 =E0 08:53 +0200, Jiri Olsa a =E9crit :
> > hi,
> >=20
> > I prepared the patch implementing IP_NODEFRAG option for IPv4 socke=
t.
> > The reason is, there's no other way to send out the packet with use=
r
> > customized header of the reassembly part.
> >=20
>=20
> Obviously, you need to update documentation and man pages as well.
>=20
> MAN-PAGES: MANUAL PAGES FOR LINUX -- Sections 2, 3, 4, 5, and 7
> M:	Michael Kerrisk <mtk.manpages@gmail.com>
> W:	http://www.kernel.org/doc/man-pages
> L:	linux-man@vger.kernel.org
> S:	Maintained
hi,

I updated the man page, and will send it in the new post.

As for the in tree documentation, do you mean any specific doc?
I haven't found any part related to the setsockopt options..=20

>=20
>=20
> > wbr,
> > jirka
> >=20
> >=20
> > Signed-off-by: Jiri Olsa <jolsa@redhat.com>
> > ---
> > diff --git a/include/linux/in.h b/include/linux/in.h
> > index 583c76f..41d88a4 100644
> > --- a/include/linux/in.h
> > +++ b/include/linux/in.h
> > @@ -85,6 +85,7 @@ struct in_addr {
> >  #define IP_RECVORIGDSTADDR   IP_ORIGDSTADDR
> > =20
> >  #define IP_MINTTL       21
> > +#define IP_NODEFRAG     22
> > =20
> >  /* IP_MTU_DISCOVER values */
> >  #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
> > diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
> > index 1653de5..1989cfd 100644
> > --- a/include/net/inet_sock.h
> > +++ b/include/net/inet_sock.h
> > @@ -137,7 +137,8 @@ struct inet_sock {
> >  				hdrincl:1,
> >  				mc_loop:1,
> >  				transparent:1,
> > -				mc_all:1;
> > +				mc_all:1,
> > +				nodefrag:1;
> >  	int			mc_index;
> >  	__be32			mc_addr;
> >  	struct ip_mc_socklist	*mc_list;
> > diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> > index 551ce56..84d2c8e 100644
> > --- a/net/ipv4/af_inet.c
> > +++ b/net/ipv4/af_inet.c
> > @@ -355,6 +355,8 @@ lookup_protocol:
> >  	inet =3D inet_sk(sk);
> >  	inet->is_icsk =3D (INET_PROTOSW_ICSK & answer_flags) !=3D 0;
> > =20
> > +	inet->nodefrag =3D 0;
> > +
>=20
> Hmm... what about cloning ?

I think as this is the property of the socket (not skb),
it has no affect for cloning


thanks,
jirka

>=20
> >  	if (SOCK_RAW =3D=3D sock->type) {
> >  		inet->inet_num =3D protocol;
> >  		if (IPPROTO_RAW =3D=3D protocol)
> > diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> > index ce23178..d8196e1 100644
> > --- a/net/ipv4/ip_sockglue.c
> > +++ b/net/ipv4/ip_sockglue.c
> > @@ -449,7 +449,7 @@ static int do_ip_setsockopt(struct sock *sk, in=
t level,
> >  			     (1<<IP_MTU_DISCOVER) | (1<<IP_RECVERR) |
> >  			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
> >  			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT) |
> > -			     (1<<IP_MINTTL))) ||
> > +			     (1<<IP_MINTTL) | (1<<IP_NODEFRAG))) ||
> >  	    optname =3D=3D IP_MULTICAST_TTL ||
> >  	    optname =3D=3D IP_MULTICAST_ALL ||
> >  	    optname =3D=3D IP_MULTICAST_LOOP ||
> > @@ -572,6 +572,13 @@ static int do_ip_setsockopt(struct sock *sk, i=
nt level,
> >  		}
> >  		inet->hdrincl =3D val ? 1 : 0;
> >  		break;
> > +	case IP_NODEFRAG:
> > +		if (sk->sk_type !=3D SOCK_RAW) {
> > +			err =3D -ENOPROTOOPT;
> > +			break;
> > +		}
> > +		inet->nodefrag =3D val ? 1 : 0;
> > +		break;
> >  	case IP_MTU_DISCOVER:
> >  		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_PROBE)
> >  			goto e_inval;
> > diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilt=
er/nf_defrag_ipv4.c
> > index cb763ae..eab8de3 100644
> > --- a/net/ipv4/netfilter/nf_defrag_ipv4.c
> > +++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
> > @@ -66,6 +66,11 @@ static unsigned int ipv4_conntrack_defrag(unsign=
ed int hooknum,
> >  					  const struct net_device *out,
> >  					  int (*okfn)(struct sk_buff *))
> >  {
> > +	struct inet_sock *inet =3D inet_sk(skb->sk);
> > +
> > +	if (inet && inet->nodefrag)
> > +		return NF_ACCEPT;
> > +
> >  #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MO=
DULE)
> >  #if !defined(CONFIG_NF_NAT) && !defined(CONFIG_NF_NAT_MODULE)
> >  	/* Previously seen (loopback)?  Ignore.  Do this before
> > --
> > To unsubscribe from this list: send the line "unsubscribe netfilter=
-devel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
