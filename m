From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] tcp: improve REUSEADDR/NOREUSEADDR cohabitation
Date: Wed, 20 May 2015 10:59:02 -0700
Message-ID: <1432144742-17786-3-git-send-email-edumazet@google.com>
References: <1432144742-17786-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Flavio Leitner <fbl@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f74.google.com ([209.85.218.74]:33029 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023AbbETR7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 13:59:17 -0400
Received: by oiav63 with SMTP id v63so1016308oia.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 10:59:16 -0700 (PDT)
In-Reply-To: <1432144742-17786-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_csk_get_port() randomization effort tends to spread
sockets on all the available range (ip_local_port_range)

This is unfortunate because SO_REUSEADDR sockets have
less requirements than non SO_REUSEADDR ones.

If an application uses SO_REUSEADDR hint, it is to try to
allow source ports being shared.

So instead of picking a random port number in ip_local_port_range,
lets try first in first half of the range.

This gives more chances to use upper half of the range for the
sockets with strong requirements (not using SO_REUSEADDR)

Note this patch does not add a new sysctl, and only changes
the way we try to pick port number.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>
Cc: Flavio Leitner <fbl@redhat.com>
---
 net/ipv4/inet_connection_sock.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index b95fb263a13f..60021d0d9326 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -99,6 +99,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	struct net *net = sock_net(sk);
 	int smallest_size = -1, smallest_rover;
 	kuid_t uid = sock_i_uid(sk);
+	int attempt_half = (sk->sk_reuse == SK_CAN_REUSE) ? 1 : 0;
 
 	local_bh_disable();
 	if (!snum) {
@@ -106,6 +107,14 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 
 again:
 		inet_get_local_port_range(net, &low, &high);
+		if (attempt_half) {
+			int half = low + ((high - low) >> 1);
+
+			if (attempt_half == 1)
+				high = half;
+			else
+				low = half;
+		}
 		remaining = (high - low) + 1;
 		smallest_rover = rover = prandom_u32() % remaining + low;
 
@@ -154,6 +163,11 @@ again:
 				snum = smallest_rover;
 				goto have_snum;
 			}
+			if (attempt_half == 1) {
+				/* OK we now try the upper half of the range */
+				attempt_half = 2;
+				goto again;
+			}
 			goto fail;
 		}
 		/* OK, here is the one we will use.  HEAD is
-- 
2.2.0.rc0.207.ga3a616c
