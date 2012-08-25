From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: soft lockup - CPU#6 stuck for 22s! [httpd2-event:15597]
Date: Sat, 25 Aug 2012 13:47:05 +0200
Message-ID: <1345895225.19483.447.camel@edumazet-glaptop>
References: <5038215E.60403@opensuse.org>
	 <1345885186.19483.109.camel@edumazet-glaptop>
	 <1345886085.19483.141.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Cristian =?ISO-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:64987 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809Ab2HYLrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 07:47:11 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr14so1855739wib.1
        for <netdev@vger.kernel.org>; Sat, 25 Aug 2012 04:47:10 -0700 (PDT)
In-Reply-To: <1345886085.19483.141.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-08-25 at 11:14 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> On Sat, 2012-08-25 at 10:59 +0200, Eric Dumazet wrote:
> > On Fri, 2012-08-24 at 20:50 -0400, Cristian Rodr=C3=ADguez wrote:
> > > Hi, the issue I reported with IPV6 few weeks ago seems to be gone=
, but
> > > now I am getting the following crash..
>=20
> > Oh, I now see the bug, I'll send a patch asap
>=20
> Please try the following fix.
>=20
> Thanks !

Well, this v2 seems cleaner :

[PATCH v2] tcp: tcp_slow_start() should not decrease snd_cwnd

Cristian Rodr=C3=ADguez reported various lockups in TCP stack,
introduced by commit 9dc274151a548 (tcp: fix ABC in tcp_slow_start())

We could exit tcp_slow_start() with a zeroed snd_cwnd,
and next time we enter tcp_slow_start(), we run an infinite loop.

Reported-by: Cristian Rodr=C3=ADguez <crrodriguez@opensuse.org>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_cong.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 1432cdb..e656c72 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -337,7 +337,7 @@ void tcp_slow_start(struct tcp_sock *tp)
 		tp->snd_cwnd_cnt -=3D tp->snd_cwnd;
 		delta++;
 	}
-	tp->snd_cwnd =3D min(tp->snd_cwnd + delta, tp->snd_cwnd_clamp);
+	tp->snd_cwnd =3D clamp(tp->snd_cwnd + delta, tp->snd_cwnd, tp->snd_cw=
nd_clamp);
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
=20
