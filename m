From: Jiri Bohac <jbohac@suse.cz>
Subject: ipx: fix locking regression in ipx_sendmsg and ipx_recvmsg
Date: Mon, 17 Nov 2014 02:34:48 +0100
Message-ID: <20141117013448.GA26743@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45406 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753178AbaKQBev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2014 20:34:51 -0500
Content-Disposition: inline
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

Similarly, a potentially sleeping sendmsg() could block calls to recvmsg().

Only keep the socket locked while actually working with the socket data and
release it prior to calling skb_recv_datagram() / ipxitf_send().


Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 91729b8..1e0d796 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1703,11 +1703,11 @@ static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
 /*	if (sk->sk_zapped)
 		return -EIO; */	/* Socket not bound */
 	if (flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
-		goto out;
+		goto out_release;
 
 	/* Max possible packet size limited by 16 bit pktsize in header */
 	if (len >= 65535 - sizeof(struct ipxhdr))
-		goto out;
+		goto out_release;
 
 	if (usipx) {
 		if (!ipxs->port) {
@@ -1718,24 +1718,24 @@ static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
 #ifdef CONFIG_IPX_INTERN
 			rc = -ENETDOWN;
 			if (!ipxs->intrfc)
-				goto out; /* Someone zonked the iface */
+				goto out_release; /* Someone zonked the iface */
 			memcpy(uaddr.sipx_node, ipxs->intrfc->if_node,
 				IPX_NODE_LEN);
 #endif
 			rc = __ipx_bind(sock, (struct sockaddr *)&uaddr,
 					sizeof(struct sockaddr_ipx));
 			if (rc)
-				goto out;
+				goto out_release;
 		}
 
 		rc = -EINVAL;
 		if (msg->msg_namelen < sizeof(*usipx) ||
 		    usipx->sipx_family != AF_IPX)
-			goto out;
+			goto out_release;
 	} else {
 		rc = -ENOTCONN;
 		if (sk->sk_state != TCP_ESTABLISHED)
-			goto out;
+			goto out_release;
 
 		usipx = &local_sipx;
 		usipx->sipx_family 	= AF_IPX;
@@ -1745,12 +1745,16 @@ static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
 		memcpy(usipx->sipx_node, ipxs->dest_addr.node, IPX_NODE_LEN);
 	}
 
+	/* releases sk */
 	rc = ipxrtr_route_packet(sk, usipx, msg->msg_iov, len,
 				 flags & MSG_DONTWAIT);
 	if (rc >= 0)
 		rc = len;
-out:
+	goto out;
+
+out_release:
 	release_sock(sk);
+out:
 	return rc;
 }
 
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
 
diff --git a/net/ipx/ipx_route.c b/net/ipx/ipx_route.c
index 67e7ad3..2f082af 100644
--- a/net/ipx/ipx_route.c
+++ b/net/ipx/ipx_route.c
@@ -163,6 +163,7 @@ int ipxrtr_route_skb(struct sk_buff *skb)
 
 /*
  * Route an outgoing frame from a socket.
+ * Expects sk to be locked and releases it before returning.
  */
 int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *usipx,
 			struct iovec *iov, size_t len, int noblock)
@@ -184,7 +185,7 @@ int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *usipx,
 		rt = ipxrtr_lookup(usipx->sipx_network);
 		rc = -ENETUNREACH;
 		if (!rt)
-			goto out;
+			goto out_release;
 		intrfc = rt->ir_intrfc;
 	}
 
@@ -242,12 +243,16 @@ int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *usipx,
 	else
 		ipx->ipx_checksum = ipx_cksum(ipx, len + sizeof(struct ipxhdr));
 
+	release_sock(sk);
 	rc = ipxitf_send(intrfc, skb, (rt && rt->ir_routed) ?
 			 rt->ir_router_node : ipx->ipx_dest.node);
+	goto out;
 out_put:
 	ipxitf_put(intrfc);
 	if (rt)
 		ipxrtr_put(rt);
+out_release:
+	release_sock(sk);
 out:
 	return rc;
 }

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
