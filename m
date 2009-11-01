From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN exchange
 with SYNACK data
Date: Sun, 01 Nov 2009 20:19:15 +0100
Message-ID: <4AEDDF33.9030205@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52846 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbZKATTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2009 14:19:17 -0500
In-Reply-To: <4AE6E7C0.2050408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> This is a significantly revised implementation of an earlier (year-ol=
d)
> patch that no longer applies cleanly, with permission of the original
> author (Adam Langley).  That patch was previously reviewed:
>=20
>    http://thread.gmane.org/gmane.linux.network/102586
>=20
> The principle difference is using a TCP option to carry the cookie no=
nce,
> instead of a user configured offset in the data.  This is more flexib=
le and
> less subject to user configuration error.  Such a cookie option has b=
een
> suggested for many years, and is also useful without SYN data, allowi=
ng
> several related concepts to use the same extension option.
>=20
>    "Re: SYN floods (was: does history repeat itself?)", September 9, =
1996.
>    http://www.merit.net/mail.archives/nanog/1996-09/msg00235.html
>=20
>    "Re: what a new TCP header might look like", May 12, 1998.
>    ftp://ftp.isi.edu/end2end/end2end-interest-1998.mail
>=20
> Data structures are carefully composed to require minimal additions.
> For example, the struct tcp_options_received cookie_plus variable fit=
s
> between existing 16-bit and 8-bit variables, requiring no additional
> space (taking alignment into consideration).  There are no additions =
to
> tcp_request_sock, and only 1 pointer and 1 flag byte in tcp_sock.
>=20
> Allocations have been rearranged to avoid requiring GFP_ATOMIC, with
> only one unavoidable exception in tcp_create_openreq_child(), where t=
he
> tcp_sock itself is created GFP_ATOMIC.
>=20
> These functions will also be used in subsequent patches that implemen=
t
> additional features.
>=20
> Requires:
>   TCPCT part 1a: add request_values parameter for sending SYNACK
>   TCPCT part 1b: sysctl_tcp_cookie_size, socket option
> TCP_COOKIE_TRANSACTIONS, functions
>=20
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  include/linux/tcp.h      |   34 ++++++-
>  include/net/tcp.h        |   67 +++++++++++++-
>  net/ipv4/syncookies.c    |    5 +-
>  net/ipv4/tcp.c           |  128 +++++++++++++++++++++++++-
>  net/ipv4/tcp_input.c     |   84 +++++++++++++++--
>  net/ipv4/tcp_ipv4.c      |   62 +++++++++++--
>  net/ipv4/tcp_minisocks.c |   43 +++++++--
>  net/ipv4/tcp_output.c    |  227
> +++++++++++++++++++++++++++++++++++++++++++---
>  net/ipv6/syncookies.c    |    5 +-
>  net/ipv6/tcp_ipv6.c      |   47 +++++++++-
>  10 files changed, 639 insertions(+), 63 deletions(-)
>=20

This part is really hard to review, and might be splitted ?

cleanups could be done in a cleanup patch only

Examples:

-	tmp_opt.mss_clamp =3D 536;
-	tmp_opt.user_mss  =3D tcp_sk(sk)->rx_opt.user_mss;
+	tmp_opt.mss_clamp =3D TCP_MIN_RCVMSS;
+	tmp_opt.user_mss  =3D tp->rx_opt.user_mss;


-	tp->mss_cache =3D 536;
+	tp->mss_cache =3D TCP_MIN_RCVMSS;


Also your tests are reversed, if you look at the existing coding style.

Example :

+	/* TCP Cookie Transactions */
+	if (0 < sysctl_tcp_cookie_size) {
+		/* Default, cookies without s_data. */
+		tp->cookie_values =3D
+			kzalloc(sizeof(*tp->cookie_values),
+				sk->sk_allocation);
+		if (NULL !=3D tp->cookie_values)
+			kref_init(&tp->cookie_values->kref);
+	}

should be ->

+	/* TCP Cookie Transactions */
+	if (sysctl_tcp_cookie_size > 0) {
+		/* Default, cookies without s_data. */
+		tp->cookie_values =3D
+			kzalloc(sizeof(*tp->cookie_values),
+				sk->sk_allocation);
+		if (tp->cookie_values !=3D NULL)
+			kref_init(&tp->cookie_values->kref);
+	}
