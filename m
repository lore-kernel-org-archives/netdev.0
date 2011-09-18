From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT] Networking
Date: Sun, 18 Sep 2011 21:50:40 +0200
Message-ID: <1316375440.31335.19.camel@edumazet-laptop>
References: <20110918.022125.1554085675403900813.davem@davemloft.net>
	 <CA+55aFxc1tMCXKBV33PVD5BybTLBpfJAEcObvoQwbwqbKOsp7g@mail.gmail.com>
	 <20110918192333.GA1641@x4.trippels.de>
	 <1316375164.31335.18.camel@edumazet-laptop>
	 <20110918194818.GB1641@x4.trippels.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110918194818.GB1641@x4.trippels.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 18 septembre 2011 =C3=A0 21:48 +0200, Markus Trippelsdorf a
=C3=A9crit :
> On 2011.09.18 at 21:46 +0200, Eric Dumazet wrote:
> > Le dimanche 18 septembre 2011 =C3=A0 21:23 +0200, Markus Trippelsdo=
rf a
> > =C3=A9crit :
> > > On 2011.09.18 at 11:06 -0700, Linus Torvalds wrote:
> > > > 2011/9/17 David Miller <davem@davemloft.net>:
> > > > >
> > > > > dpward (2):
> > > > >      net: Make flow cache namespace-aware
> > > > >      net: Handle different key sizes between address families=
 in flow cache
> > > > >
> > > > > nhorman (1):
> > > > >      net: don't clear IFF_XMIT_DST_RELEASE in ether_setup
> > > > >
> > > > > rajan.aggarwal85@gmail.com (1):
> > > > >      net/can/af_can.c: Change del_timer to del_timer_sync
> > > >=20
> > > > Guys, if somebody has such a broken email setup that they don't=
 even
> > > > show their own name, don't take patches from them.
> > > >=20
> > > > If you cannot even set up email sanely, there is zero reason to
> > > > believe that the patch should be good. And if the patch is triv=
ial and
> > > > you want to take it despite the source of the patch being crap,=
 please
> > > > spend the five seconds to fix it up.
> > > >=20
> > > > Proper names are part of the commit message. Don't make it look=
 like
> > > > crap. I get ugly flashbacks to SVN or CVS when I see stuff like=
 this.
> > > > Don't do it.
> > >=20
> > > Plus commit 946cedccbd73874 breaks the build:
> > >=20
> > >   LD      init/built-in.o
> > >   LD      .tmp_vmlinux1
> > > net/built-in.o:sysctl_net.c:function tcp_v4_conn_request: error: =
undefined reference to 'cookie_v4_init_sequence'
> > > make: *** [.tmp_vmlinux1] Error 1
> > >=20
> > > commit 946cedccbd7387488d2cee5da92cdfeb28d2e670
> > > Author: Eric Dumazet <eric.dumazet@gmail.com>
> > > Date:   Tue Aug 30 03:21:44 2011 +0000
> > >=20
> > >     tcp: Change possible SYN flooding messages
> > >=20
> > >     "Possible SYN flooding on port xxxx " messages can fill logs =
on servers.
> > >=20
> > >     Change logic to log the message only once per listener, and a=
dd two new
> > >     SNMP counters to track :
> > >=20
> > >     TCPReqQFullDoCookies : number of times a SYNCOOKIE was replie=
d to client
> > >=20
> > >     TCPReqQFullDrop : number of times a SYN request was dropped b=
ecause
> > >     syncookies were not enabled.
> > >=20
> > >     Based on a prior patch from Tom Herbert, and suggestions from=
 David.
> > >=20
> > >=20
> >=20
> > Oh well, trying to remove those ugly #ifdef was not so easy.
> > I'll cook a patch, thanks for the report
>=20
> The following works for me:
>=20
>=20
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index c34f015..ef9dd55 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1264,7 +1264,9 @@ int tcp_v4_conn_request(struct sock *sk, struct=
 sk_buff *skb)
>  	 * evidently real one.
>  	 */
>  	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
> +#ifdef CONFIG_SYN_COOKIES
>  		want_cookie =3D tcp_syn_flood_action(sk, skb, "TCP");
> +#endif
>  		if (!want_cookie)
>  			goto drop;
>  	}
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 3c9fa61..7ffc3b1 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1174,7 +1174,9 @@ static int tcp_v6_conn_request(struct sock *sk,=
 struct sk_buff *skb)
>  		goto drop;
> =20
>  	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
> +#ifdef CONFIG_SYN_COOKIES
>  		want_cookie =3D tcp_syn_flood_action(sk, skb, "TCPv6");
> +#endif
>  		if (!want_cookie)
>  			goto drop;
>  	}
>=20

Dont do that, we _really_ want to call tcp_syn_flood_action()
