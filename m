From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Fri, 09 Jul 2010 19:13:00 +0200
Message-ID: <1278695580.2696.55.camel@edumazet-laptop>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
	 <AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>
	 <1278626921.2435.73.camel@edumazet-laptop>
	 <AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Felipe W Damasio <felipewd@gmail.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 09 juillet 2010 =C3=A0 12:03 -0300, Felipe W Damasio a =C3=A9=
crit :
> Hi,
>=20
> 2010/7/8 Eric Dumazet <eric.dumazet@gmail.com>:
> > Please try to reproduce a new report.
> >
> > It looks like a memory corruption, and it would be good to see if a
> > common pattern is occurring.
>=20
> I'm trying..the thing is the freeze occured on the machine that sits
> on a 200Mbps ISP in bridge-mode. Since the machine frooze, and the
> whole ISP went down for a few minutes, I'm not allowed to run any
> tests on it.
>=20
> I've setup the same scenario on a lab, but since last night been
> unable to reproduce the bug. Maybe there's a clue on the this crash
> below that can help me write some program to trigger the problem?
>=20

Reviewing tproxy stuff I spotted a problem in nf_tproxy_assign_sock()
but I could not see how it could explain your crash.

We can read uninitialized memory and trigger a fault in
nf_tproxy_assign_sock(), not later in tcp_recvmsg()...

David, Patrick, what do you think ?

Thanks

[PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets

transparent field of a socket is either inet_twsk(sk)->tw_transparent
for timewait sockets, or inet_sk(sk)->transparent for other sockets
(TCP/UDP).

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_c=
ore.c
index 5490fc3..daab8c4 100644
--- a/net/netfilter/nf_tproxy_core.c
+++ b/net/netfilter/nf_tproxy_core.c
@@ -70,7 +70,11 @@ nf_tproxy_destructor(struct sk_buff *skb)
 int
 nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk)
 {
-	if (inet_sk(sk)->transparent) {
+	bool transparent =3D (sk->sk_state =3D=3D TCP_TIME_WAIT) ?
+				inet_twsk(sk)->tw_transparent :
+				inet_sk(sk)->transparent;
+
+	if (transparent) {
 		skb_orphan(skb);
 		skb->sk =3D sk;
 		skb->destructor =3D nf_tproxy_destructor;
