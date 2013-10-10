From: =?UTF-8?B?RnJhbsOnb2lzIENhY2hlcmV1bA==?= <f.cachereul@alphalink.fr>
Subject: Re: BUG in net/l2tp/l2tp_core.c
Date: Thu, 10 Oct 2013 09:37:18 +0200
Message-ID: <5256592E.3080600@alphalink.fr>
References: <52552BDF.8070800@alphalink.fr> <1381316730.4971.16.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:49307 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751737Ab3JJHhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 03:37:23 -0400
In-Reply-To: <1381316730.4971.16.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2013 01:05 PM, Eric Dumazet wrote:
> On Wed, 2013-10-09 at 12:11 +0200, Fran=C3=A7ois Cachereul wrote:
>> Hi,
>>
>> I got the following BUG when using l2tp modules with smp kernel.
>> I noticed that l2tp_xmit_skb uses bh_lock_sock/bh_unlok_sock which
>> doesn't seem to be correct because it does a lot of stuff and probab=
ly
>> sleep before releasing the lock. I try replacing
>> bh_lock_sock/bh_unlock_sock with lock_sock/release_sock and the BUG
>> doesn't happened anymore. Is it correct ?
>>
>> Regards
>> Fran=C3=A7ois
>>
>=20
> At first glance, you might read commit
> 6af88da14ee284aaad6e4326da09a89191ab6165
> ("l2tp: Fix locking in l2tp_core.c")
>=20
> l2tp_eth_dev_xmit() is called from BH context, so you cannot use
> lock_sock()
>=20
> Try the following patch instead :
>=20
> diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
> index f0a7ada..ffda81e 100644
> --- a/net/l2tp/l2tp_ppp.c
> +++ b/net/l2tp/l2tp_ppp.c
> @@ -353,7 +353,9 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, s=
truct socket *sock, struct msgh
>  		goto error_put_sess_tun;
>  	}
> =20
> +	local_bh_disable();
>  	l2tp_xmit_skb(session, skb, session->hdr_len);
> +	local_bh_enable();
> =20
>  	sock_put(ps->tunnel_sock);
>  	sock_put(sk);
> @@ -422,7 +424,9 @@ static int pppol2tp_xmit(struct ppp_channel *chan=
, struct sk_buff *skb)
>  	skb->data[0] =3D ppph[0];
>  	skb->data[1] =3D ppph[1];
> =20
> +	local_bh_disable();
>  	l2tp_xmit_skb(session, skb, session->hdr_len);
> +	local_bh_enable();
> =20
>  	sock_put(sk_tun);
>  	sock_put(sk);
>=20
>=20

That works. Thanks

=46ran=C3=A7ois
