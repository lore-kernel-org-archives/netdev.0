From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH net] phonet: properly unshare skbs in
 =?UTF-8?Q?phonet=5Frcv=28=29?=
Date: Wed, 13 Jan 2016 14:26:33 +0200
Message-ID: <ba49c1524db476eab37647078cfeddcc@roundcube.remlab.net>
References: <568EA671.7000502@gmail.com> <56929985.3020502@gmail.com>
 <1452457610.16445.13.camel@edumazet-glaptop2.roam.corp.google.com>
 <5694188F.80907@gmail.com>
 <CAO7SqHA9dNUDG+pYJoQvipE_ErM4Bgo0_o9er_OLxZLDgNVJ8Q@mail.gmail.com>
 <56944DFA.4050002@gmail.com>
 <1452560786.1223.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAO7SqHC+fTCyNd8ukSH4tJ1qPvAYzMGSfhrzXmMn0NLve6NTQA@mail.gmail.com>
 <1452565288.1223.10.camel@edumazet-glaptop2.roam.corp.google.com>
 <1452565515.1223.11.camel@edumazet-glaptop2.roam.corp.google.com>
 <5694A840.8030900@gmail.com>
 <1452608377.1223.13.camel@edumazet-glaptop2.roam.corp.google.com>
 <1452617880.1223.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns207790.ip-94-23-215.eu ([94.23.215.26]:53227 "EHLO
	ns207790.ip-94-23-215.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607AbcAMMds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 07:33:48 -0500
In-Reply-To: <1452617880.1223.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 2016-01-12 18:58, Eric Dumazet a =C3=A9crit=C2=A0:
> From: Eric Dumazet <edumazet@google.com>
>
> Ivaylo Dimitrov reported a regression caused by commit 7866a621043f
> ("dev: add per net_device packet type chains").
>
> skb->dev becomes NULL and we crash in __netif_receive_skb_core().
>
> Before above commit, different kind of bugs or corruptions could=20
> happen
> without major crash.

Hmm... was that always a problem then, or did it get introduced=20
earlier? I thought it was impossible for skb to be shared on PF-recv=20
callback way back.

> But the root cause is that phonet_rcv() can queue skb without=20
> checking
> if skb is shared or not.
>
> Many thanks to Ivaylo Dimitrov for his help, diagnosis and tests.
>
> Reported-by: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
> Tested-by: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Remi Denis-Courmont <courmisch@gmail.com>
> ---
>  net/phonet/af_phonet.c |    4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index 10d42f3220ab..f925753668a7 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -377,6 +377,10 @@ static int phonet_rcv(struct sk_buff *skb,
> struct net_device *dev,
>  	struct sockaddr_pn sa;
>  	u16 len;
>
> +	skb =3D skb_share_check(skb, GFP_ATOMIC);
> +	if (!skb)
> +		return NET_RX_DROP;
> +
>  	/* check we have at least a full Phonet header */
>  	if (!pskb_pull(skb, sizeof(struct phonethdr)))
>  		goto out;

Ack, thanks.

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
