From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PATCH: uninitialized memory access in tcp_parse_options
Date: Sat, 26 Jun 2010 07:58:04 +0200
Message-ID: <1277531884.2481.22.camel@edumazet-laptop>
References: <1277127249.9469.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:41827 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798Ab0FZF6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 01:58:10 -0400
Received: by wwi17 with SMTP id 17so1511978wwi.19
        for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 22:58:09 -0700 (PDT)
In-Reply-To: <1277127249.9469.53.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 juin 2010 =C3=A0 15:34 +0200, Mathieu Lacage a =C3=A9crit :
> valgrind reports the following error:
>=20
> =3D=3D15996=3D=3D Conditional jump or move depends on uninitialised v=
alue(s)
> =3D=3D15996=3D=3D    at 0x6E63E4C: tcp_parse_options (tcp_input.c:377=
6)
> =3D=3D15996=3D=3D    by 0x6E856A3: tcp_check_req (tcp_minisocks.c:532=
)
> =3D=3D15996=3D=3D    by 0x6E7F0C6: tcp_v4_hnd_req (tcp_ipv4.c:1492)
> =3D=3D15996=3D=3D    by 0x6E7F55A: tcp_v4_do_rcv (tcp_ipv4.c:1571)
> =3D=3D15996=3D=3D    by 0x6E808C5: tcp_v4_rcv (tcp_ipv4.c:1690)
> =3D=3D15996=3D=3D    by 0x6E2DA7B: ip_local_deliver_finish (ip_input.=
c:231)
> =3D=3D15996=3D=3D    by 0x6E2DE0C: ip_local_deliver (netfilter.h:206)
> =3D=3D15996=3D=3D    by 0x6E2E940: ip_rcv_finish (dst.h:255)
> =3D=3D15996=3D=3D    by 0x6E2F17C: ip_rcv (netfilter.h:206)
> =3D=3D15996=3D=3D    by 0x6D53D0E: __netif_receive_skb (dev.c:2873)
> =3D=3D15996=3D=3D    by 0x6D5521F: process_backlog (dev.c:3305)
> =3D=3D15996=3D=3D    by 0x6D55A20: net_rx_action (dev.c:3435)
>=20
> The attached patch (generated against net-next-2.6) fixes that error =
by
> making sure that user_mss is correctly initialized at the start of
> tcp_parse_options, just like saw_tstamp is initialized at the start o=
f
> this function. To try to be coherent, this patch also removes the
> redundant initialization of saw_tstamp from the caller, tcp_check_req=
=2E
>=20
> hope this helps,
> Mathieu


Mathieu, this valgrind splat is a false positive, and your fix is not
necessary or at the right place.

In tcp_check_req(), we call tcp_parse_options() only to get the
saw_tstamp indication. So only initialize this field to 0 before callin=
g
tcp_parse_options()

If you want to avoid valgrind false positive at this point, without
introducing bug for other tcp_parse_options() callers, a better fix
would be following patch.

Thanks

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 794c2e1..4e758ac 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -520,14 +520,13 @@ struct sock *tcp_check_req(struct sock *sk, struc=
t sk_buff *skb,
 			   struct request_sock *req,
 			   struct request_sock **prev)
 {
-	struct tcp_options_received tmp_opt;
+	struct tcp_options_received tmp_opt =3D {0};
 	u8 *hash_location;
 	struct sock *child;
 	const struct tcphdr *th =3D tcp_hdr(skb);
 	__be32 flg =3D tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLA=
G_ACK);
 	int paws_reject =3D 0;
=20
-	tmp_opt.saw_tstamp =3D 0;
 	if (th->doff > (sizeof(struct tcphdr)>>2)) {
 		tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
=20


