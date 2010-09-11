From: Willy Tarreau <w@1wt.eu>
Subject: tcp collapse+splice bug still present in -stable
Date: Sat, 11 Sep 2010 07:42:55 +0200
Message-ID: <20100911054255.GB29288@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@kernel.org
To: David Miller <davem@davemloft.net>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:44321 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801Ab0IKFn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Sep 2010 01:43:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Greg,

one of our customers was encountering frequent kernel panics up to
2.6.32.21 that were always related to splicing and tcp_collapse().
I found the precise BUG_ON() line but I've not forgotten it, something
about ->seq not being OK.

I found the following fix in 2.6.35 which looked to be related to the
same issue, and we could verify that it definitely solves it. Could we
please have it in other stable versions ?

Thanks in advance,
Willy

--
>From baff42ab1494528907bf4d5870359e31711746ae Mon Sep 17 00:00:00 2001
From: Steven J. Magnani <steve@digidescorp.com>
Date: Tue, 30 Mar 2010 13:56:01 -0700
Subject: [PATCH] net: Fix oops from tcp_collapse() when using splice()

tcp_read_sock() can have a eat skbs without immediately advancing copied_seq.
This can cause a panic in tcp_collapse() if it is called as a result
of the recv_actor dropping the socket lock.

A userspace program that splices data from a socket to either another
socket or to a file can trigger this bug.

Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6afb6d8..2c75f89 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1368,6 +1368,7 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 		sk_eat_skb(sk, skb, 0);
 		if (!desc->count)
 			break;
+		tp->copied_seq = seq;
 	}
 	tp->copied_seq = seq;
 

