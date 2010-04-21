From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 13:27:33 +0200
Message-ID: <1271849253.7895.1929.camel@edumazet-laptop>
References: <4BCE33B9.8050101@candelatech.com>
	 <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
	 <4BCE392F.60104@candelatech.com>
	 <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
	 <4BCE3D8D.3030500@candelatech.com>
	 <1271808314.7895.614.camel@edumazet-laptop>
	 <20100421003022.GA3107@ioremap.net>
	 <1271828799.7895.1287.camel@edumazet-laptop>
	 <20100421082559.GA32475@ioremap.net>
	 <1271840535.7895.1612.camel@edumazet-laptop>
	 <20100421095812.GA14778@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:57125 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143Ab0DUL1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 07:27:42 -0400
Received: by bwz25 with SMTP id 25so7982222bwz.28
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 04:27:40 -0700 (PDT)
In-Reply-To: <20100421095812.GA14778@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the patch I use now and my test application is now able to open
and connect 1000000 sockets (ulimit -n 1000000)

Trick is bind_conflict() must refuse a socket to bind to a port on a non
null IP if another socket already uses same port on same IP.

Plus the previous patch sent (check a conflict before exiting the search
loop)

What do you think ?

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index e0a3e35..78cbc39 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -70,13 +70,17 @@ int inet_csk_bind_conflict(const struct sock *sk,
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
+			const __be32 sk2_rcv_saddr = inet_rcv_saddr(sk2);
+
 			if (!reuse || !sk2->sk_reuse ||
 			    sk2->sk_state == TCP_LISTEN) {
-				const __be32 sk2_rcv_saddr = inet_rcv_saddr(sk2);
 				if (!sk2_rcv_saddr || !sk_rcv_saddr ||
 				    sk2_rcv_saddr == sk_rcv_saddr)
 					break;
-			}
+			} else if (reuse && sk2->sk_reuse &&
+				   sk2_rcv_saddr &&
+				   sk2_rcv_saddr == sk_rcv_saddr)
+				break;
 		}
 	}
 	return node != NULL;
@@ -120,9 +124,11 @@ again:
 						smallest_size = tb->num_owners;
 						smallest_rover = rover;
 						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {
-							spin_unlock(&head->lock);
-							snum = smallest_rover;
-							goto have_snum;
+							if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
+								spin_unlock(&head->lock);
+								snum = smallest_rover;
+								goto have_snum;
+							}
 						}
 					}
 					goto next;


