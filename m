From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Mon, 30 Jan 2012 21:37:12 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5B9294A@EUSAACMS0702.eamcs.ericsson.se>
References: <1327975638-16530-1-git-send-email-shawn.lu@ericsson.com>
 <CAL4WiipdO5+1Fi_ig5hB25d2LJvc+cjzyAbo8mxx3e4EiRx9YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr3.ericy.com ([198.24.6.13]:36121 "EHLO imr3.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003Ab2AaChQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 21:37:16 -0500
In-Reply-To: <CAL4WiipdO5+1Fi_ig5hB25d2LJvc+cjzyAbo8mxx3e4EiRx9YA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes. Eric is right.  I will have to fix refcount problem.
Will send out another patch later on. =20

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
Sent: Monday, January 30, 2012 6:16 PM
To: Shawn Lu
Cc: davem@davemloft.net; netdev@vger.kernel.org; xiaoclu@gmail.com
Subject: Re: [PATCH] tcp: md5: fix md5 RST when both sides have listene=
r

Le 31 janvier 2012 03:07, Shawn Lu <shawn.lu@ericsson.com> a =E9crit :
> TCP RST mechanism is broken in TCP md5(RFC2385). When connection is=20
> gone, md5 key is lost, sending RST without
> md5 hash is deem to ignored by peer. This can be a problem since RST=20
> help protocal like bgp fast recove from peer crash.
>
> In most case, users of tcp md5, such as bgp and ldp, have listeners o=
n=20
> both sides. md5 keys for peers are saved in listening socket.
> When passive side connection is gone, we can still get md5 key from=20
> listening socket. When active side of connection is gone, we can try=20
> to find listening socket through source port, and then md5 key.
> we are not loosing sercuriy here: packet is valified checked with
> md5 hash. No RST is generated if md5 hash doesn't match or no md5 key=
=20
> can be found.
>
> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
> ---
> =A0net/ipv4/tcp_ipv4.c | =A0 31 ++++++++++++++++++++++++++++++-
> =A0net/ipv6/tcp_ipv6.c | =A0 34 ++++++++++++++++++++++++++++++++--
> =A02 files changed, 62 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c index=20
> 337ba4c..b2358b4 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -601,6 +601,9 @@ static void tcp_v4_send_reset(struct sock *sk,=20
> struct sk_buff *skb)
> =A0 =A0 =A0 =A0struct ip_reply_arg arg;
> =A0#ifdef CONFIG_TCP_MD5SIG
> =A0 =A0 =A0 =A0struct tcp_md5sig_key *key;
> + =A0 =A0 =A0 =A0__u8 *hash_location =3D NULL;
> + =A0 =A0 =A0 unsigned char newhash[16];
> + =A0 =A0 =A0 int genhash;
> =A0#endif
> =A0 =A0 =A0 =A0struct net *net;
>
> @@ -631,7 +634,33 @@ static void tcp_v4_send_reset(struct sock *sk,=20
> struct sk_buff *skb)
> =A0 =A0 =A0 =A0arg.iov[0].iov_len =A0=3D sizeof(rep.th);
>
> =A0#ifdef CONFIG_TCP_MD5SIG
> - =A0 =A0 =A0 key =3D sk ? tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->sadd=
r) :=20
> NULL;
> + =A0 =A0 =A0 hash_location =3D tcp_parse_md5sig_option(th);
> + =A0 =A0 =A0 if (!sk && hash_location) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* active side is lost. Try to find l=
istening socket=20
> + through
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* source port, and then find md5 key=
 through listening socket.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we are not loose security here:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Incoming packet is checked with md=
5 hash with=20
> + finding key,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* no RST generated if md5 hash doesn=
't match.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk =3D=20
> + __inet_lookup_listener(dev_net(skb_dst(skb)->dev),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 &tcp_hashinfo,=20
> + ip_hdr(skb)->daddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 ntohs(th->source),=20
> + inet_iif(skb));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* don't send rst if it can't find key =
*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sk)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;

Now you have a socket in sk, you also are responsible to release the re=
fcount taken in __inet_lookup_listener()

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 key =3D tcp_v4_md5_do_lookup(sk, ip_hdr=
(skb)->saddr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!key)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;

leak refcount

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 genhash =3D tcp_v4_md5_hash_skb(newhash=
, key,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 NULL, NULL, skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (genhash || memcmp(hash_location, ne=
whash, 16) !=3D=20
> + 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;

same leak

> +
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 key =3D sk ? tcp_v4_md5_do_lookup(sk,=20
> + ip_hdr(skb)->saddr) : NULL;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0if (key) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rep.opt[0] =3D htonl((TCPOPT_NOP << 24=
) |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (=
TCPOPT_NOP << 16) | diff --git=20
> a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c index 3edd05a..1da99fd=20
> 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1074,6 +1074,12 @@ static void tcp_v6_send_reset(struct sock *sk,=
=20
> struct sk_buff *skb)
> =A0 =A0 =A0 =A0const struct tcphdr *th =3D tcp_hdr(skb);
> =A0 =A0 =A0 =A0u32 seq =3D 0, ack_seq =3D 0;
> =A0 =A0 =A0 =A0struct tcp_md5sig_key *key =3D NULL;
> +#ifdef CONFIG_TCP_MD5SIG
> + =A0 =A0 =A0 __u8 *hash_location =3D NULL;
> + =A0 =A0 =A0 struct ipv6hdr *ipv6h =3D ipv6_hdr(skb);
> + =A0 =A0 =A0 unsigned char newhash[16];
> + =A0 =A0 =A0 int genhash;
> +#endif
>
> =A0 =A0 =A0 =A0if (th->rst)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> @@ -1082,8 +1088,32 @@ static void tcp_v6_send_reset(struct sock *sk,=
=20
> struct sk_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0#ifdef CONFIG_TCP_MD5SIG
> - =A0 =A0 =A0 if (sk)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 key =3D tcp_v6_md5_do_lookup(sk, &ipv6_=
hdr(skb)->saddr);
> + =A0 =A0 =A0 hash_location =3D tcp_parse_md5sig_option(th);
> + =A0 =A0 =A0 if (!sk && hash_location) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* active side is lost. Try to find l=
istening socket=20
> + through
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* source port, and then find md5 key=
 through listening socket.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we are not loose security here:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Incoming packet is checked with md=
5 hash with=20
> + finding key,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* no RST generated if md5 hash doesn=
't match.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk =3D inet6_lookup_listener(dev_net(sk=
b_dst(skb)->dev),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0&tcp_hashinfo,=20
> + &ipv6h->daddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0ntohs(th->source),=20
> + inet6_iif(skb));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sk)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 key =3D tcp_v6_md5_do_lookup(sk, &ipv6h=
->saddr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!key)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;

same leak

> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 genhash =3D tcp_v6_md5_hash_skb(newhash=
, key,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 NULL, NULL, skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (genhash || memcmp(hash_location, ne=
whash, 16) !=3D=20
> + 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;

same leak

> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 key =3D sk ? tcp_v6_md5_do_lookup(sk, &=
ipv6h->saddr) :=20
> + NULL;
> + =A0 =A0 =A0 }
> =A0#endif
>
> =A0 =A0 =A0 =A0if (th->ack)
> --
> 1.7.0.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in=20
> the body of a message to majordomo@vger.kernel.org More majordomo inf=
o=20
> at =A0http://vger.kernel.org/majordomo-info.html
