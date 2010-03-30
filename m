From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: [PATCH] net: Fix oops from tcp_collapse() when using splice()
Date: Tue, 30 Mar 2010 15:45:13 -0500
Message-ID: <1269981913-18073-1-git-send-email-steve@digidescorp.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, monstr@monstr.eu,
	Karl Hiramoto <karl@hiramoto.org>,
	"Steven J. Magnani" <steve@digidescorp.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tcp_read_sock() can have a eat skbs without immediately advancing copied_seq.
This can cause a panic in tcp_collapse() if it is called as a result
of the recv_actor dropping the socket lock.

A userspace program that splices data from a socket to either another
socket or to a file can trigger this bug.

Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
---
diff -uprN a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	2010-03-30 15:25:55.000000000 -0500
+++ b/net/ipv4/tcp.c	2010-03-30 15:27:49.000000000 -0500
@@ -1335,6 +1335,7 @@ int tcp_read_sock(struct sock *sk, read_
 		sk_eat_skb(sk, skb, 0);
 		if (!desc->count)
 			break;
+		tp->copied_seq = seq;
 	}
 	tp->copied_seq = seq;
 
