From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix possible NULL dereference in
 tcp_vX_send_reset()
Date: Tue, 25 Nov 2014 07:40:04 -0800
Message-ID: <1416930004.29427.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	=?UTF-8?Q?Ja=C5=A1a?= Bartelj <jasa.bartelj@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:49117 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbaKYPkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 10:40:07 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so5216328igb.1
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 07:40:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

After commit ca777eff51f7 ("tcp: remove dst refcount false sharing for
prequeue mode") we have to relax check against skb dst in
tcp_v[46]_send_reset() if prequeue dropped the dst.

If a socket is provided, a full lookup was done to find this socket,
so the dst test can be skipped.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=3D88191
Reported-by: Ja=C5=A1a Bartelj <jasa.bartelj@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Daniel Borkmann <dborkman@redhat.com>
=46ixes: ca777eff51f7 ("tcp: remove dst refcount false sharing for preq=
ueue mode")
---
 net/ipv4/tcp_ipv4.c |    5 ++++-
 net/ipv6/tcp_ipv6.c |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9c7d7621466b..147be2024290 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -598,7 +598,10 @@ static void tcp_v4_send_reset(struct sock *sk, str=
uct sk_buff *skb)
 	if (th->rst)
 		return;
=20
-	if (skb_rtable(skb)->rt_type !=3D RTN_LOCAL)
+	/* If sk not NULL, it means we did a successful lookup and incoming
+	 * route had to be correct. prequeue might have dropped our dst.
+	 */
+	if (!sk && skb_rtable(skb)->rt_type !=3D RTN_LOCAL)
 		return;
=20
 	/* Swap the send and the receive. */
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ace29b60813c..dc495ae2ead0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -903,7 +903,10 @@ static void tcp_v6_send_reset(struct sock *sk, str=
uct sk_buff *skb)
 	if (th->rst)
 		return;
=20
-	if (!ipv6_unicast_destination(skb))
+	/* If sk not NULL, it means we did a successful lookup and incoming
+	 * route had to be correct. prequeue might have dropped our dst.
+	 */
+	if (!sk && !ipv6_unicast_destination(skb))
 		return;
=20
 #ifdef CONFIG_TCP_MD5SIG
