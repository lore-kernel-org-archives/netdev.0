From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH v4] ipx: fix locking regression in ipx_sendmsg and ipx_recvmsg
Date: Wed, 19 Nov 2014 23:05:49 +0100
Message-ID: <20141119220549.GA26133@midget.suse.cz>
References: <1609909.1jJeqOzgZ8@wuerfel>
 <20141119103413.GA19092@midget.suse.cz>
 <20141119103814.GB19092@midget.suse.cz>
 <20141119.154400.1045032776950540216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbohac@suse.cz, arnd@arndb.de, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42199 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756504AbaKSWFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 17:05:52 -0500
Content-Disposition: inline
In-Reply-To: <20141119.154400.1045032776950540216.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes an old regression introduced by commit
b0d0d915 (ipx: remove the BKL).

When a recvmsg syscall blocks waiting for new data, no data can be sent on the
same socket with sendmsg because ipx_recvmsg() sleeps with the socket locked.

This breaks mars-nwe (NetWare emulator):
- the ncpserv process reads the request using recvmsg
- ncpserv forks and spawns nwconn
- ncpserv calls a (blocking) recvmsg and waits for new requests
- nwconn deadlocks in sendmsg on the same socket 

Commit b0d0d915 has simply replaced BKL locking with
lock_sock/release_sock. Unlike now, BKL got unlocked while
sleeping, so a blocking recvmsg did not block a concurrent
sendmsg.

Only keep the socket locked while actually working with the socket data and
release it prior to calling skb_recv_datagram(). 


Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index a0c7536..d0725d9 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1764,6 +1764,7 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct ipxhdr *ipx = NULL;
 	struct sk_buff *skb;
 	int copied, rc;
+	bool locked = true;
 
 	lock_sock(sk);
 	/* put the autobinding in */
@@ -1790,6 +1791,8 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (sock_flag(sk, SOCK_ZAPPED))
 		goto out;
 
+	release_sock(sk);
+	locked = false;
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 				flags & MSG_DONTWAIT, &rc);
 	if (!skb) {
@@ -1825,7 +1828,8 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 out_free:
 	skb_free_datagram(sk, skb);
 out:
-	release_sock(sk);
+	if (locked)
+		release_sock(sk);
 	return rc;
 }
 
-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
