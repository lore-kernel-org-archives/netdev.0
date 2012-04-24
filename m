From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Tue, 24 Apr 2012 12:49:50 -0700
Message-ID: <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
References: <1335289058.5205.165.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tore Anderson <tore@fud.no>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:32797 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757112Ab2DXTtv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 15:49:51 -0400
Received: by iadi9 with SMTP id i9so1401671iad.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 12:49:50 -0700 (PDT)
In-Reply-To: <1335289058.5205.165.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Why do we refuse to set ipv6 mtu's below 1280?
how is what we do any better?

On Tue, Apr 24, 2012 at 10:37 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Quoting Tore Anderson from :
> https://bugzilla.kernel.org/show_bug.cgi?id=3D42572
>
> When RTAX_FEATURE_ALLFRAG is set on a route, the effective TCP segmen=
t
> size does not take into account the size of the IPv6 Fragmentation
> header that needs to be included in outbound packets, causing every
> transmitted TCP segment to be fragmented across two IPv6 packets, the
> latter of which will only contain 8 bytes of actual payload.
>
> RTAX_FEATURE_ALLFRAG is typically set on a route in response to
> receving a ICMPv6 Packet Too Big message indicating a Path MTU of les=
s
> than 1280 bytes. 1280 bytes is the minimum IPv6 MTU, however ICMPv6
> PTBs with MTU < 1280 are still valid, in particular when an IPv6
> packet is sent to an IPv4 destination through a stateless translator.
> Any ICMPv4 Need To Fragment packets originated from the IPv4 part of
> the path will be translated to ICMPv6 PTB which may then indicate an
> MTU of less than 1280.
>
> The Linux kernel refuses to reduce the effective MTU to anything belo=
w
> 1280 bytes, instead it sets it to exactly 1280 bytes, and
> RTAX_FEATURE_ALLFRAG is also set. However, the TCP segment size appea=
rs
> to be set to 1240 bytes (1280 Path MTU - 40 bytes of IPv6 header),
> instead of 1232 (additionally taking into account the 8 bytes require=
d
> by the IPv6 Fragmentation extension header).
>
> This in turn results in rather inefficient transmission, as every
> transmitted TCP segment now is split in two fragments containing
> 1232+8 bytes of payload.
>
> After this patch, all the outgoing packets that includes a
> Fragmentation header all are "atomic" or "non-fragmented" fragments,
> i.e., they both have Offset=3D0 and More Fragments=3D0.
>
> With help from David S. Miller
>
> Reported-by: Tore Anderson <tore@fud.no>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Tested-by: Tore Anderson <tore@fud.no>
> ---
> =C2=A0include/net/inet_connection_sock.h | =C2=A0 =C2=A01 +
> =C2=A0include/net/tcp.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A04 ++--
> =C2=A0net/ipv4/tcp_output.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0| =C2=A0 19 +++++++++++++++++--
> =C2=A0net/ipv6/tcp_ipv6.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0| =C2=A0 =C2=A01 +
> =C2=A04 files changed, 21 insertions(+), 4 deletions(-)
>
> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_co=
nnection_sock.h
> index 46c9e2c..7d83f90 100644
> --- a/include/net/inet_connection_sock.h
> +++ b/include/net/inet_connection_sock.h
> @@ -45,6 +45,7 @@ struct inet_connection_sock_af_ops {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct d=
st_entry *dst);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct inet_peer *(*get_peer)(struct sock =
*sk, bool *release_it);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 =C2=A0 =C2=A0 =C2=A0 =C2=A0 net_header=
_len;
> + =C2=A0 =C2=A0 =C2=A0 u16 =C2=A0 =C2=A0 =C2=A0 =C2=A0 net_frag_heade=
r_len;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sockaddr_l=
en;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int =C2=A0 =C2=A0 =C2=A0 =C2=A0 (*setsocko=
pt)(struct sock *sk, int level, int optname,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0char __user *optval, u=
nsigned int optlen);
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index fc880e9..0fb84de 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -544,8 +544,8 @@ extern int tcp_read_sock(struct sock *sk, read_de=
scriptor_t *desc,
>
> =C2=A0extern void tcp_initialize_rcv_mss(struct sock *sk);
>
> -extern int tcp_mtu_to_mss(const struct sock *sk, int pmtu);
> -extern int tcp_mss_to_mtu(const struct sock *sk, int mss);
> +extern int tcp_mtu_to_mss(struct sock *sk, int pmtu);
> +extern int tcp_mss_to_mtu(struct sock *sk, int mss);
> =C2=A0extern void tcp_mtup_init(struct sock *sk);
> =C2=A0extern void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt);
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 7b7cf38..834e89f 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1150,7 +1150,7 @@ int tcp_trim_head(struct sock *sk, struct sk_bu=
ff *skb, u32 len)
> =C2=A0}
>
> =C2=A0/* Calculate MSS. Not accounting for SACKs here. =C2=A0*/
> -int tcp_mtu_to_mss(const struct sock *sk, int pmtu)
> +int tcp_mtu_to_mss(struct sock *sk, int pmtu)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct tcp_sock *tp =3D tcp_sk(sk);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct inet_connection_sock *icsk =3D=
 inet_csk(sk);
> @@ -1161,6 +1161,14 @@ int tcp_mtu_to_mss(const struct sock *sk, int =
pmtu)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mss_now =3D pmtu - icsk->icsk_af_ops->net_=
header_len - sizeof(struct tcphdr);
>
> + =C2=A0 =C2=A0 =C2=A0 /* IPv6 adds a frag_hdr in case RTAX_FEATURE_A=
LLFRAG is set */
> + =C2=A0 =C2=A0 =C2=A0 if (icsk->icsk_af_ops->net_frag_header_len) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct dst_e=
ntry *dst =3D __sk_dst_get(sk);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (dst && dst_all=
frag(dst))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 mss_now -=3D icsk->icsk_af_ops->net_frag_header_len;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Clamp it (mss_clamp does not include tc=
p options) */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mss_now > tp->rx_opt.mss_clamp)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mss_now =3D tp=
->rx_opt.mss_clamp;
> @@ -1179,7 +1187,7 @@ int tcp_mtu_to_mss(const struct sock *sk, int p=
mtu)
> =C2=A0}
>
> =C2=A0/* Inverse of above */
> -int tcp_mss_to_mtu(const struct sock *sk, int mss)
> +int tcp_mss_to_mtu(struct sock *sk, int mss)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct tcp_sock *tp =3D tcp_sk(sk);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct inet_connection_sock *icsk =3D=
 inet_csk(sk);
> @@ -1190,6 +1198,13 @@ int tcp_mss_to_mtu(const struct sock *sk, int =
mss)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0icsk->icsk_ext_hdr_le=
n +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0icsk->icsk_af_ops->ne=
t_header_len;
>
> + =C2=A0 =C2=A0 =C2=A0 /* IPv6 adds a frag_hdr in case RTAX_FEATURE_A=
LLFRAG is set */
> + =C2=A0 =C2=A0 =C2=A0 if (icsk->icsk_af_ops->net_frag_header_len) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct dst_e=
ntry *dst =3D __sk_dst_get(sk);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (dst && dst_all=
frag(dst))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 mtu +=3D icsk->icsk_af_ops->net_frag_header_len;
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return mtu;
> =C2=A0}
>
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index cdbf292..57b2109 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1778,6 +1778,7 @@ static const struct inet_connection_sock_af_ops=
 ipv6_specific =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.syn_recv_sock =C2=A0 =C2=A0 =3D tcp_v6_sy=
n_recv_sock,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.get_peer =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
=3D tcp_v6_get_peer,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.net_header_len =C2=A0 =C2=A0=3D sizeof(st=
ruct ipv6hdr),
> + =C2=A0 =C2=A0 =C2=A0 .net_frag_header_len =3D sizeof(struct frag_hd=
r),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.setsockopt =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D=
 ipv6_setsockopt,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.getsockopt =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D=
 ipv6_getsockopt,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.addr2sockaddr =C2=A0 =C2=A0 =3D inet6_csk=
_addr2sockaddr,
>
>



--=20
Maciej A. =C5=BBenczykowski
Kernel Networking Developer @ Google
1600 Amphitheatre Parkway, Mountain View, CA 94043
tel: +1 (650) 253-0062
