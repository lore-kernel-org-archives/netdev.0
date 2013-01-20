From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix incorrect LOCKDROPPEDICMPS counter
Date: Sat, 19 Jan 2013 18:10:37 -0800
Message-ID: <1358647837.3464.1050.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:49959 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054Ab3ATCKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 21:10:40 -0500
Received: by mail-pa0-f54.google.com with SMTP id bi5so2793372pad.41
        for <netdev@vger.kernel.org>; Sat, 19 Jan 2013 18:10:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

commit 563d34d057 (tcp: dont drop MTU reduction indications)
added an error leading to incorrect accounting of
LINUX_MIB_LOCKDROPPEDICMPS

If socket is owned by the user, we want to increment
this SNMP counter, unless the message is a
(ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED) one.

Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_ipv4.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 54139fa..70b09ef 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -369,11 +369,10 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 inf=
o)
 	 * We do take care of PMTU discovery (RFC1191) special case :
 	 * we can receive locally generated ICMP messages while socket is hel=
d.
 	 */
-	if (sock_owned_by_user(sk) &&
-	    type !=3D ICMP_DEST_UNREACH &&
-	    code !=3D ICMP_FRAG_NEEDED)
-		NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
-
+	if (sock_owned_by_user(sk)) {
+		if (!(type =3D=3D ICMP_DEST_UNREACH && code =3D=3D ICMP_FRAG_NEEDED)=
)
+			NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
+	}
 	if (sk->sk_state =3D=3D TCP_CLOSE)
 		goto out;
=20
