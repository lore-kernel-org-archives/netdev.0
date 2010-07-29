From: Dmitry Popov <dp@highloadlab.com>
Subject: [PATCH] tcp: cookie transactions setsockopt memory leak
Date: Thu, 29 Jul 2010 15:59:36 +0400
Message-ID: <AANLkTinHWJviHmhVcFQkobsgxa4-AaFUpHmd1wybiB+u@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Steven J. Magnani" <steve@digidescorp.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	William Allen Simpson <william.allen.simpson@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Dmitry Popov <dp@highloadlab.com>

There is a bug in do_tcp_setsockopt(net/ipv4/tcp.c),
TCP_COOKIE_TRANSACTIONS case.
In some cases (when tp->cookie_values =3D=3D NULL) new tcp_cookie_value=
s
structure can be allocated (at cvp), but not bound to
tp->cookie_values. So a memory leak occurs.

Signed-off-by: Dmitry Popov <dp@highloadlab.com>
---
tp->cookie_values can be NULL if socket was initialized with
sysctl_tcp_cookie_size =3D=3D 0 (tcp_v4_init_sock, net/ipv4/tcp_ipv4.c)
Buggy releases: 2.6.33+ (since commit e56fb50f2b7958b931c8a2fc0966061b3=
f3c8f3a)

=A0net/ipv4/tcp.c | =A0 =A07 +++++--
=A01 files changed, 5 insertions(+), 2 deletions(-)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 83d0213..9c490a1 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2179,6 +2179,8 @@ static int do_tcp_setsockopt(struct sock *sk, int=
 level,
 				      GFP_KERNEL);
 			if (cvp =3D=3D NULL)
 				return -ENOMEM;
+
+			kref_init(&cvp->kref);
 		}
 		lock_sock(sk);
 		tp->rx_opt.cookie_in_always =3D
@@ -2193,12 +2195,11 @@ static int do_tcp_setsockopt(struct sock *sk, i=
nt level,
 				 */
 				kref_put(&tp->cookie_values->kref,
 					 tcp_cookie_values_release);
-				kref_init(&cvp->kref);
-				tp->cookie_values =3D cvp;
 			} else {
 				cvp =3D tp->cookie_values;
 			}
 		}
+
 		if (cvp !=3D NULL) {
 			cvp->cookie_desired =3D ctd.tcpct_cookie_desired;

@@ -2212,6 +2213,8 @@ static int do_tcp_setsockopt(struct sock *sk, int=
 level,
 				cvp->s_data_desired =3D ctd.tcpct_s_data_desired;
 				cvp->s_data_constant =3D 0; /* false */
 			}
+
+			tp->cookie_values =3D cvp;
 		}
 		release_sock(sk);
 		return err;
