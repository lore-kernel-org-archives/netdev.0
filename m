From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT] Networking
Date: Sun, 18 Sep 2011 22:35:30 +0200
Message-ID: <1316378130.31335.32.camel@edumazet-laptop>
References: <20110918.022125.1554085675403900813.davem@davemloft.net>
	 <CA+55aFxc1tMCXKBV33PVD5BybTLBpfJAEcObvoQwbwqbKOsp7g@mail.gmail.com>
	 <20110918192333.GA1641@x4.trippels.de>
	 <1316375164.31335.18.camel@edumazet-laptop>
	 <20110918194818.GB1641@x4.trippels.de>
	 <CA+55aFwmwYXzC_4q+XuEAx3ta6U-jf=NvMcAc-J+4DBxLm8Efg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:48197 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756536Ab1IRUfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 16:35:36 -0400
In-Reply-To: <CA+55aFwmwYXzC_4q+XuEAx3ta6U-jf=NvMcAc-J+4DBxLm8Efg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 septembre 2011 =C3=A0 12:55 -0700, Linus Torvalds a =C3=A9=
crit :
> On Sun, Sep 18, 2011 at 12:48 PM, Markus Trippelsdorf
> <markus@trippelsdorf.de> wrote:
> >
> > The following works for me:
>=20
> No it doesn't. It may *compile* for you, but it doesn't work for you.
> It avoids all the other stuff that tcp_syn_flood_action() also does
> (notably the printout).
>=20
> The real fix looks to be either:
>=20
>  - make an empty (inline/macro) cookie_v4_init_sequence() for the
> non-syncookie config case
>=20

Yes, this one seems the less ugly.

=46rankly, we should remove CONFIG_SYN_COOKIE option...

Sorry for the mess, dont blame David on this, since netdev guys
probably always use CONFIG_SYN_COOKIE.

Thanks

[PATCH] tcp: fix build error if !CONFIG_SYN_COOKIE

commit 946cedccbd7387 (tcp: Change possible SYN flooding messages)
added a build error if CONFIG_SYN_COOKIE=3Dn

Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/tcp.h |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e9b48b0..f860d64 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -431,17 +431,34 @@ extern int tcp_disconnect(struct sock *sk, int fl=
ags);
 extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *s=
kb,=20
 				    struct ip_options *opt);
+#ifdef CONFIG_SYN_COOKIE
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *=
skb,=20
 				     __u16 *mss);
+#else
+static inline __u32 cookie_v4_init_sequence(struct sock *sk,
+					    struct sk_buff *skb,
+					    __u16 *mss)
+{
+	return 0;
+}
+#endif
=20
 extern __u32 cookie_init_timestamp(struct request_sock *req);
 extern bool cookie_check_timestamp(struct tcp_options_received *opt, b=
ool *);
=20
 /* From net/ipv6/syncookies.c */
 extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *s=
kb);
+#ifdef CONFIG_SYN_COOKIE
 extern __u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *=
skb,
 				     __u16 *mss);
-
+#else
+static inline __u32 cookie_v6_init_sequence(struct sock *sk,
+					    struct sk_buff *skb,
+					    __u16 *mss)
+{
+	return 0;
+}
+#endif
 /* tcp_output.c */
=20
 extern void __tcp_push_pending_frames(struct sock *sk, unsigned int cu=
r_mss,
