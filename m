From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 34322] New: No ECN marking in IPv6
Date: Sat, 07 May 2011 11:44:46 +0200
Message-ID: <1304761486.2821.945.camel@edumazet-laptop>
References: <bug-34322-10286@https.bugzilla.kernel.org/>
	 <20110505144146.4bc1e744.akpm@linux-foundation.org>
	 <1304694292.3066.29.camel@edumazet-laptop>  <20110506171249.GA29942@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57011 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395Ab1EGJov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 05:44:51 -0400
Received: by wwa36 with SMTP id 36so4258029wwa.1
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 02:44:50 -0700 (PDT)
In-Reply-To: <20110506171249.GA29942@uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Steinar H. Gunderson <sgunderson@bigfoot.com>

Le vendredi 06 mai 2011 =C3=A0 19:12 +0200, Steinar H. Gunderson a =C3=A9=
crit :

> Sure, but is really checking against NULL the right way of checking f=
or IPv6
> sockets? I'd imagined I should have checked address family or somethi=
ng
> instead...
>=20

It should be fine.

I cooked for you the official patch and made sure it worked with a RED
ECN setup, and one ipv6 tcp xmit.

# tc -s -d qdisc show dev eth1
=2E..
qdisc red 11: parent 1:11 limit 120Kb min 8Kb max 80Kb ecn ewma 2 Plog =
21 Scell_log 11
 Sent 114694826 bytes 76446 pkt (dropped 15, overlimits 485 requeues 0)=
=20
 rate 12126Kbit 1011pps backlog 0b 0p requeues 0=20
  marked 470 early 15 pdrop 0 other 0


Thanks again !

[PATCH] ipv6: restore correct ECN handling on TCP xmit

Since commit e9df2e8fd8fbc9 (Use appropriate sock tclass setting for
routing lookup) we lost ability to properly add ECN codemarks to ipv6
TCP frames.

It seems like TCP_ECN_send() calls INET_ECN_xmit(), which only sets the
ECN bit in the IPv4 ToS field (inet_sk(sk)->tos), but after the patch,
what's checked is inet6_sk(sk)->tclass, which is a completely different
field.

Close bug https://bugzilla.kernel.org/show_bug.cgi?id=3D34322

[Eric Dumazet] : added the INET_ECN_dontxmit() fix and replace macros
by inline functions for clarity.

Signed-off-by: Steinar H. Gunderson <sgunderson@bigfoot.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/net/inet_ecn.h |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index 88bdd01..2fa8d13 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -38,9 +38,19 @@ static inline __u8 INET_ECN_encapsulate(__u8 outer, =
__u8 inner)
 	return outer;
 }
=20
-#define	INET_ECN_xmit(sk) do { inet_sk(sk)->tos |=3D INET_ECN_ECT_0; }=
 while (0)
-#define	INET_ECN_dontxmit(sk) \
-	do { inet_sk(sk)->tos &=3D ~INET_ECN_MASK; } while (0)
+static inline void INET_ECN_xmit(struct sock *sk)
+{
+	inet_sk(sk)->tos |=3D INET_ECN_ECT_0;
+	if (inet6_sk(sk) !=3D NULL)
+		inet6_sk(sk)->tclass |=3D INET_ECN_ECT_0;
+}
+
+static inline void INET_ECN_dontxmit(struct sock *sk)
+{
+	inet_sk(sk)->tos &=3D ~INET_ECN_MASK;
+	if (inet6_sk(sk) !=3D NULL)
+		inet6_sk(sk)->tclass &=3D ~INET_ECN_MASK;
+}
=20
 #define IP6_ECN_flow_init(label) do {		\
       (label) &=3D ~htonl(INET_ECN_MASK << 20);	\


