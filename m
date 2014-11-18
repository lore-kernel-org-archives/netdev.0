From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH v2] ipx: fix locking regression in ipx_sendmsg and ipx_recvmsg
Date: Tue, 18 Nov 2014 23:24:58 +0100
Message-ID: <20141118222458.GA14454@midget.suse.cz>
References: <20141117013448.GA26743@midget.suse.cz>
 <8698539.evYG7fs8jS@wuerfel>
 <20141118221057.GA13473@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbohac@suse.cz, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42211 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754199AbaKRWZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 17:25:00 -0500
Content-Disposition: inline
In-Reply-To: <20141118221057.GA13473@midget.suse.cz>
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
index 91729b8..1e0d796 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1776,20 +1780,21 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 #ifdef CONFIG_IPX_INTERN
 		rc = -ENETDOWN;
 		if (!ipxs->intrfc)
-			goto out; /* Someone zonked the iface */
+			goto out_release; /* Someone zonked the iface */
 		memcpy(uaddr.sipx_node, ipxs->intrfc->if_node, IPX_NODE_LEN);
 #endif	/* CONFIG_IPX_INTERN */
 
 		rc = __ipx_bind(sock, (struct sockaddr *)&uaddr,
 			      sizeof(struct sockaddr_ipx));
 		if (rc)
-			goto out;
+			goto out_release;
 	}
 
 	rc = -ENOTCONN;
 	if (sock_flag(sk, SOCK_ZAPPED))
-		goto out;
+		goto out_release;
 
+	release_sock(sk);
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 				flags & MSG_DONTWAIT, &rc);
 	if (!skb) {
@@ -1807,8 +1812,10 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	rc = skb_copy_datagram_iovec(skb, sizeof(struct ipxhdr), msg->msg_iov,
 				     copied);
-	if (rc)
-		goto out_free;
+	if (rc) {
+		skb_free_datagram(sk, skb);
+		goto out;
+	}
 	if (skb->tstamp.tv64)
 		sk->sk_stamp = skb->tstamp;
 
@@ -1822,11 +1829,11 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_namelen	= sizeof(*sipx);
 	}
 	rc = copied;
+	goto out;
 
-out_free:
-	skb_free_datagram(sk, skb);
-out:
+out_release:
 	release_sock(sk);
+out:
 	return rc;
 }
 
-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
