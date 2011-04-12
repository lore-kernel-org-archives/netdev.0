From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 09:20:39 -0700
Message-ID: <20110412092039.69f420f6@nehalam>
References: <4D9E62D9.5010400@scotdoyle.com>
	<20110408121700.0aad53fe@nehalam>
	<4D9FE5BE.6060600@scotdoyle.com>
	<20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	<4DA39330.2030102@scotdoyle.com>
	<20110411183105.46e86684@nehalam>
	<4DA3CB4B.9090506@scotdoyle.com>
	<1302581384.3603.14.camel@edumazet-laptop>
	<1302582172.3603.18.camel@edumazet-laptop>
	<4DA3E074.5090603@scotdoyle.com>
	<1302587490.3603.22.camel@edumazet-laptop>
	<4DA3F909.5020609@scotdoyle.com>
	<1302608951.3233.33.camel@edumazet-laptop>
	<1302613353.30934.22.camel@polaris.local>
	<1302614145.3233.47.camel@edumazet-laptop>
	<1302617968.30934.34.camel@polaris.local>
	<1302619749.3233.56.camel@edumazet-laptop>
	<1302621233.30934.44.camel@polaris.local>
	<1302624851.3233.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan =?UTF-8?B?TMO8YmJl?= <jluebbe@debian.org>,
	Scot Doyle <lkml@scotdoyle.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org, Bandan Das <bandan.das@stratus.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37685 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757651Ab1DLQUm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 12:20:42 -0400
In-Reply-To: <1302624851.3233.63.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Apr 2011 18:14:11 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 12 avril 2011 =C3=A0 17:13 +0200, Jan L=C3=BCbbe a =C3=A9cri=
t :
> > On Tue, 2011-04-12 at 16:49 +0200, Eric Dumazet wrote:=20
> > > Of course, this might be a complete shot in the dark, but a
> > > stackprotector fault in icmp_send() really sounds like a problem =
in
> > > ip_options_echo() [ or bad input data given to this function ]
> >=20
> > It was my understanding that all IP options given to ip_options_ech=
o are
> > either from local sources or have gone through ip_options_compile, =
which
> > seems to verify that the sum of the individual option lengths do no=
t
> > exceed the ip header. So there wouldn't need to be additional check=
s in
> > ip_options_echo.
> >=20
> > If this is not the case, we need size checks in ip_options_echo bef=
ore
> > copying over each option.
> >=20
> > > Other related changes (but as old as v2.6.22) :
> > >=20
> > > commit 11a03f78fbf15a866ba
> > > ([NetLabel]: core network changes)
> >=20
> > When investigating the problem I had with timestamps, i found that =
most
> > of the lines in ip_options_echo and _compile have not been changed =
since
> > before 2.2 (some even before 2.0). The newer changes have all been
> > updates for changed API elsewhere in the stack.
> >=20
>=20
> commit 462fb2af9788a82 might be the problem.
> (bridge : Sanitize skb before it enters the IP stack)
>=20
> We are supposed to provide a zeroed ip_options to ip_options_compile(=
)
>=20
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 008ff6c..f3bc322 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -249,11 +249,9 @@ static int br_parse_ip_options(struct sk_buff *s=
kb)
>  		goto drop;
>  	}
> =20
> -	/* Zero out the CB buffer if no options present */
> -	if (iph->ihl =3D=3D 5) {
> -		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +	if (iph->ihl =3D=3D 5)
>  		return 0;
> -	}
> =20
>  	opt->optlen =3D iph->ihl*4 - sizeof(struct iphdr);
>  	if (ip_options_compile(dev_net(dev), opt, skb))

I think the confusion is that IPCB(skb) is not the IP header but
scratch space used during IP header processing. Before the sanitize
patch the CB was cleared.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
