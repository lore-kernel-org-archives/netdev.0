From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Tue, 31 Jan 2012 10:05:12 +0100
Message-ID: <1328000712.2422.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327975638-16530-1-git-send-email-shawn.lu@ericsson.com>
	 <CAL4WiipdO5+1Fi_ig5hB25d2LJvc+cjzyAbo8mxx3e4EiRx9YA@mail.gmail.com>
	 <62162DF05402B341B3DB59932A1FA992B5B5B929BD@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53134 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289Ab2AaJFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 04:05:16 -0500
Received: by bkcjm19 with SMTP id jm19so298093bkc.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 01:05:15 -0800 (PST)
In-Reply-To: <62162DF05402B341B3DB59932A1FA992B5B5B929BD@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 31 janvier 2012 =C3=A0 03:39 -0500, Shawn Lu a =C3=A9crit :
> Resubmit after fixing the sk refcount leak problem pointed out by Eri=
c.
>=20
>=20
> TCP RST mechanism is broken in TCP md5(RFC2385).When
> connection is gone, md5 key is lost, sending RST without
> md5 hash is deem to ignored by peer. This can be a problem
> since RST help protocal like bgp fast recove from peer crash.
>=20
> In most case, users of tcp md5, such as bgp and ldp, have
> listeners on both sides. md5 keys for peers are saved in
> listening socket. When passive side connection is gone,
> we can still get md5 key from listening socket. When active
> side of connection is gone, we can try to find listening socket
> through source port, and then md5 key.
> we are not loosing sercuriy here: packet is valified checked with
> md5 hash. No RST is generated if md5 hash doesn't match or no md5
> key can be found.
>=20
> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
> ---
>  net/ipv4/tcp_ipv4.c |   38 +++++++++++++++++++++++++++++++++++++-
>  net/ipv6/tcp_ipv6.c |   41 +++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 76 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c index 337ba4c.=
=2E6ed1c4a 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -601,6 +601,10 @@ static void tcp_v4_send_reset(struct sock *sk, s=
truct sk_buff *skb)
>  	struct ip_reply_arg arg;
>  #ifdef CONFIG_TCP_MD5SIG
>  	struct tcp_md5sig_key *key;
> +	 __u8 *hash_location =3D NULL;
> +	unsigned char newhash[16];
> +	int genhash;
> +	struct sock *sk1 =3D NULL;
>  #endif
>  	struct net *net;
> =20
> @@ -631,7 +635,33 @@ static void tcp_v4_send_reset(struct sock *sk, s=
truct sk_buff *skb)
>  	arg.iov[0].iov_len  =3D sizeof(rep.th);
> =20
>  #ifdef CONFIG_TCP_MD5SIG
> -	key =3D sk ? tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->saddr) : NULL;
> +	hash_location =3D tcp_parse_md5sig_option(th);
> +	if (!sk && hash_location) {
> +		/*
> +		 * active side is lost. Try to find listening socket through
> +		 * source port, and then find md5 key through listening socket.
> +		 * we are not loose security here:
> +		 * Incoming packet is checked with md5 hash with finding key,
> +		 * no RST generated if md5 hash doesn't match.
> +		 */
> +		sk1 =3D __inet_lookup_listener(dev_net(skb_dst(skb)->dev),
> +					    &tcp_hashinfo, ip_hdr(skb)->daddr,
> +					    ntohs(th->source), inet_iif(skb));
> +		/* don't send rst if it can't find key */
> +		if (!sk1)
> +			return;
> +		key =3D tcp_v4_md5_do_lookup(sk1, ip_hdr(skb)->saddr);

Hmm... The second problem is that its not safe to call
tcp_v4_md5_do_lookup() on an unlocked socket.

And locking a listener is way too expensive, since a listener socket is
already a contention point.

An attacker could send forged tcp md5 packets to slow down a server.

A proper patch needs RCU conversion first.

> +		if (!key)
> +			goto release_sk1;
> +		genhash =3D tcp_v4_md5_hash_skb(newhash, key,
> +					      NULL, NULL, skb);
> +		if (genhash || memcmp(hash_location, newhash, 16) !=3D 0)
> +			goto release_sk1;
> +
> +	} else {
> +		key =3D sk ? tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->saddr) : NULL;
> +	}
> +
>  	if (key) {
>  		rep.opt[0] =3D htonl((TCPOPT_NOP << 24) |
>  				   (TCPOPT_NOP << 16) |
> @@ -659,6 +689,12 @@ static void tcp_v4_send_reset(struct sock *sk, s=
truct sk_buff *skb)
> =20
>  	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
>  	TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
> +
> +#ifdef CONFIG_TCP_MD5SIG
> +release_sk1:
> +	if (sk1)
> +		sock_put(sk1);
> +#endif
>  }
