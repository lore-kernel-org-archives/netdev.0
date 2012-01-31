From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Tue, 31 Jan 2012 03:16:09 +0100
Message-ID: <CAL4WiipdO5+1Fi_ig5hB25d2LJvc+cjzyAbo8mxx3e4EiRx9YA@mail.gmail.com>
References: <1327975638-16530-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, xiaoclu@gmail.com
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52510 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282Ab2AaCQJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 21:16:09 -0500
Received: by iacb35 with SMTP id b35so203588iac.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 18:16:09 -0800 (PST)
In-Reply-To: <1327975638-16530-1-git-send-email-shawn.lu@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 31 janvier 2012 03:07, Shawn Lu <shawn.lu@ericsson.com> a =E9crit :
> TCP RST mechanism is broken in TCP md5(RFC2385). When
> connection is gone, md5 key is lost, sending RST without
> md5 hash is deem to ignored by peer. This can be a problem
> since RST help protocal like bgp fast recove from peer crash.
>
> In most case, users of tcp md5, such as bgp and ldp, have listeners
> on both sides. md5 keys for peers are saved in listening socket.
> When passive side connection is gone, we can still get md5 key
> from listening socket. When active side of connection is gone,
> we can try to find listening socket through source port, and
> then md5 key.
> we are not loosing sercuriy here: packet is valified checked with
> md5 hash. No RST is generated if md5 hash doesn't match or no md5
> key can be found.
>
> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
> ---
> =A0net/ipv4/tcp_ipv4.c | =A0 31 ++++++++++++++++++++++++++++++-
> =A0net/ipv6/tcp_ipv6.c | =A0 34 ++++++++++++++++++++++++++++++++--
> =A02 files changed, 62 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 337ba4c..b2358b4 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -601,6 +601,9 @@ static void tcp_v4_send_reset(struct sock *sk, st=
ruct sk_buff *skb)
> =A0 =A0 =A0 =A0struct ip_reply_arg arg;
> =A0#ifdef CONFIG_TCP_MD5SIG
> =A0 =A0 =A0 =A0struct tcp_md5sig_key *key;
> + =A0 =A0 =A0 =A0__u8 *hash_location =3D NULL;
> + =A0 =A0 =A0 unsigned char newhash[16];
> + =A0 =A0 =A0 int genhash;
> =A0#endif
> =A0 =A0 =A0 =A0struct net *net;
>
> @@ -631,7 +634,33 @@ static void tcp_v4_send_reset(struct sock *sk, s=
truct sk_buff *skb)
> =A0 =A0 =A0 =A0arg.iov[0].iov_len =A0=3D sizeof(rep.th);
>
> =A0#ifdef CONFIG_TCP_MD5SIG
> - =A0 =A0 =A0 key =3D sk ? tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->sadd=
r) : NULL;
> + =A0 =A0 =A0 hash_location =3D tcp_parse_md5sig_option(th);
> + =A0 =A0 =A0 if (!sk && hash_location) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* active side is lost. Try to find l=
istening socket through
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* source port, and then find md5 key=
 through listening socket.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we are not loose security here:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Incoming packet is checked with md=
5 hash with finding key,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* no RST generated if md5 hash doesn=
't match.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk =3D __inet_lookup_listener(dev_net(s=
kb_dst(skb)->dev),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 &tcp_hashinfo, ip_hdr(skb)->daddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 ntohs(th->source), inet_iif(skb));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* don't send rst if it can't find key =
*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sk)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;

Now you have a socket in sk, you also are responsible to release the
refcount taken in __inet_lookup_listener()

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
whash, 16) !=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;

same leak

> +
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 key =3D sk ? tcp_v4_md5_do_lookup(sk, i=
p_hdr(skb)->saddr) : NULL;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0if (key) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rep.opt[0] =3D htonl((TCPOPT_NOP << 24=
) |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (=
TCPOPT_NOP << 16) |
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 3edd05a..1da99fd 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1074,6 +1074,12 @@ static void tcp_v6_send_reset(struct sock *sk,=
 struct sk_buff *skb)
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
 struct sk_buff *skb)
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
istening socket through
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* source port, and then find md5 key=
 through listening socket.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we are not loose security here:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Incoming packet is checked with md=
5 hash with finding key,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* no RST generated if md5 hash doesn=
't match.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk =3D inet6_lookup_listener(dev_net(sk=
b_dst(skb)->dev),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0&tcp_hashinfo, &ipv6h->daddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0ntohs(th->source), inet6_iif(skb));
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
whash, 16) !=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;

same leak

> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 key =3D sk ? tcp_v6_md5_do_lookup(sk, &=
ipv6h->saddr) : NULL;
> + =A0 =A0 =A0 }
> =A0#endif
>
> =A0 =A0 =A0 =A0if (th->ack)
> --
> 1.7.0.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
