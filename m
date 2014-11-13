From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: skb_fclone_busy() needs to detect orphaned skb
Date: Thu, 13 Nov 2014 13:20:22 -0800
Message-ID: <1415913622.17262.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414690354.9028.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141113191502.GC7095@hercules>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: Luis Henriques <luis.henriques@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:37261 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934041AbaKMVUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 16:20:24 -0500
Received: by mail-pa0-f51.google.com with SMTP id kq14so16153132pab.38
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 13:20:23 -0800 (PST)
In-Reply-To: <20141113191502.GC7095@hercules>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-13 at 19:15 +0000, Luis Henriques wrote:
> Hi Eric,
>=20
> On Thu, Oct 30, 2014 at 10:32:34AM -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >=20
> > Some drivers are unable to perform TX completions in a bound time.
> > They instead call skb_orphan()
> >=20
> > Problem is skb_fclone_busy() has to detect this case, otherwise
> > we block TCP retransmits and can freeze unlucky tcp sessions on
> > mostly idle hosts.
> >=20
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Fixes: 1f3279ae0c13 ("tcp: avoid retransmits of TCP packets hanging=
 in host queues")
> > ---
> >  This is a stable candidate.
> >  This problem is known to hurt users of linux-3.16 kernels used by =
guests kernels.
> >  David, I can provide backports if you want.
> >  Thanks !
> >=20
>=20
> We got a bug report[0] where a backport for 3.16 was provided.  Since
> I couldn't find the original backport post, I'm not sure who's the
> actual author.  Could you please confirm if this backport is correct?
> (I'm copying the patch below).
>=20
> [0] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1390604
>=20
> Cheers,
> --
> Lu=C3=ADs
>=20
>=20

Sure ! I provided this patch indeed, I am 'The Google engineer'
mentioned in this bug report ;)

Signed-off-by: Eric Dumazet <edumazet@google.com>


Thanks !

> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 4e4932b5079b..a8794367cd20 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2082,7 +2082,8 @@ static bool skb_still_in_host_queue(const struc=
t sock *sk,
>  	const struct sk_buff *fclone =3D skb + 1;
> =20
>  	if (unlikely(skb->fclone =3D=3D SKB_FCLONE_ORIG &&
> -		     fclone->fclone =3D=3D SKB_FCLONE_CLONE)) {
> +		     fclone->fclone =3D=3D SKB_FCLONE_CLONE &&
> +		     fclone->sk =3D=3D sk)) {
>  		NET_INC_STATS_BH(sock_net(sk),
>  				 LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES);
>  		return true;
