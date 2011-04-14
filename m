From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip: ip_options_compile() resilient to NULL skb route
Date: Thu, 14 Apr 2011 05:37:43 +0200
Message-ID: <1302752263.3549.41.camel@edumazet-laptop>
References: <4DA522B2.90200@scotdoyle.com> <4DA5BCF7.9020606@scotdoyle.com>
	 <1302708487.3725.0.camel@edumazet-laptop>
	 <20110413.144812.116375845.davem@davemloft.net>
	 <1302748276.3549.20.camel@edumazet-laptop> <20110413195424.1d2393c6@s6510>
	 <1302750214.3549.34.camel@edumazet-laptop>
	 <20110414123058.d4ffe7fb.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, lkml@scotdoyle.com,
	netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38487 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab1DNDhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 23:37:48 -0400
Received: by wwa36 with SMTP id 36so1490735wwa.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 20:37:47 -0700 (PDT)
In-Reply-To: <20110414123058.d4ffe7fb.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 avril 2011 =C3=A0 12:30 +0900, Hiroaki SHIMODA a =C3=A9crit=
 :
> On Thu, 14 Apr 2011 05:03:34 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le mercredi 13 avril 2011 =C3=A0 19:54 -0700, Stephen Hemminger a =C3=
=A9crit :
> >=20
> > > I like this because it lets the bridge be transparent.
> > > The existing options code adds entry in record route, and which
> > > is not desirable.
> >=20
> > OK then, I realize I should have submitted a full patch, here it is=
=2E
> >=20
> > Thanks !
> >=20
> > [PATCH] ip: ip_options_compile() resilient to NULL skb route
> >=20
> > Scot Doyle demonstrated ip_options_compile() could be called with a=
n skb
> > without an attached route, using a setup involving a bridge, netfil=
ter,
> > and forged IP packets.
> >=20
> > Let's make ip_options_compile() a bit more robust, instead of chang=
ing
> > bridge/netfilter code.
>=20
> And ip_options_rcv_srr() in br_parse_ip_options() also=20
> expects an skb with attached route, so below patch is needed ?
>=20
> diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
> index 28a736f..3af1968 100644
> --- a/net/ipv4/ip_options.c
> +++ b/net/ipv4/ip_options.c
> @@ -603,7 +603,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
>  	unsigned long orefdst;
>  	int err;
> =20
> -	if (!opt->srr)
> +	if (!opt->srr || !rt)
>  		return 0;
> =20
>  	if (skb->pkt_type !=3D PACKET_HOST)
>=20
> Thanks.

Indeed good catch, but should we return 0 or -EINVAL so that caller can
drop packet ?

@@ -606,7 +606,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	if (!opt->srr)
 		return 0;
=20
-	if (skb->pkt_type !=3D PACKET_HOST)
+	if (skb->pkt_type !=3D PACKET_HOST || !rt)
                return -EINVAL;
 	if (rt->rt_type =3D=3D RTN_UNICAST) {
 		if (!opt->is_strictroute)


