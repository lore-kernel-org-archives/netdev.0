From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [patch] IPV6: Refcount leaks in udpv6_connect()
Date: Sat, 14 Jun 2003 00:07:25 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306132149290.4922-100000@rhea.tcs.hut.fi>
References: <20030604.093944.84705841.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030604.093944.84705841.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

A dst refcount leak had unfortunately crept into my original
CONFIG_IPV6_SUBTREES patch and your derived udpv6_connect() patch
(changeset 1.1215.68.12).

While fixing this, I also found and fixed some other apparent leaks.

This patch fixes several bugs in udpv6_connect():
- dst refcount leak if ipv6_get_saddr() fails
- several flowlabel refcount leaks

The diff is done against ChangeSet 1.1307.

Thanks,
Ville

diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/net/ipv6/udp.c merge-2.5/net/ipv6/udp.c
--- linux-2.5/net/ipv6/udp.c	Fri Jun 13 16:08:00 2003
+++ merge-2.5/net/ipv6/udp.c	Fri Jun 13 16:05:33 2003
@@ -299,9 +299,10 @@
 	if (addr_type == IPV6_ADDR_MAPPED) {
 		struct sockaddr_in sin;

-		if (__ipv6_only_sock(sk))
-			return -ENETUNREACH;
-
+		if (__ipv6_only_sock(sk)) {
+			err = -ENETUNREACH;
+			goto out;
+		}
 		sin.sin_family = AF_INET;
 		sin.sin_addr.s_addr = daddr->s6_addr32[3];
 		sin.sin_port = usin->sin6_port;
@@ -309,8 +310,8 @@
 		err = udp_connect(sk, (struct sockaddr*) &sin, sizeof(sin));

 ipv4_connected:
-		if (err < 0)
-			return err;
+		if (err)
+			goto out;

 		ipv6_addr_set(&np->daddr, 0, 0, htonl(0x0000ffff), inet->daddr);

@@ -323,7 +324,7 @@
 			ipv6_addr_set(&np->rcv_saddr, 0, 0, htonl(0x0000ffff),
 				      inet->rcv_saddr);
 		}
-		return 0;
+		goto out;
 	}

 	if (addr_type&IPV6_ADDR_LINKLOCAL) {
@@ -331,8 +332,8 @@
 		    usin->sin6_scope_id) {
 			if (sk->sk_bound_dev_if &&
 			    sk->sk_bound_dev_if != usin->sin6_scope_id) {
-				fl6_sock_release(flowlabel);
-				return -EINVAL;
+				err = -EINVAL;
+				goto out;
 			}
 			sk->sk_bound_dev_if = usin->sin6_scope_id;
 			if (!sk->sk_bound_dev_if &&
@@ -341,8 +342,10 @@
 		}

 		/* Connect to link-local address requires an interface */
-		if (!sk->sk_bound_dev_if)
-			return -EINVAL;
+		if (!sk->sk_bound_dev_if) {
+			err = -EINVAL;
+			goto out;
+		}
 	}

 	ipv6_addr_copy(&np->daddr, daddr);
@@ -379,31 +382,33 @@

 	if ((err = dst->error) != 0) {
 		dst_release(dst);
-		fl6_sock_release(flowlabel);
-		return err;
+		goto out;
 	}

 	/* get the source address used in the appropriate device */

 	err = ipv6_get_saddr(dst, daddr, &fl.fl6_src);

-	if (err == 0) {
-		if (ipv6_addr_any(&np->saddr))
-			ipv6_addr_copy(&np->saddr, &fl.fl6_src);
-
-		if (ipv6_addr_any(&np->rcv_saddr)) {
-			ipv6_addr_copy(&np->rcv_saddr, &fl.fl6_src);
-			inet->rcv_saddr = LOOPBACK4_IPV6;
-		}
+	if (err) {
+		dst_release(dst);
+		goto out;
+	}

-		ip6_dst_store(sk, dst,
-			      !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) ?
-			      &np->daddr : NULL);
+	if (ipv6_addr_any(&np->saddr))
+		ipv6_addr_copy(&np->saddr, &fl.fl6_src);

-		sk->sk_state = TCP_ESTABLISHED;
+	if (ipv6_addr_any(&np->rcv_saddr)) {
+		ipv6_addr_copy(&np->rcv_saddr, &fl.fl6_src);
+		inet->rcv_saddr = LOOPBACK4_IPV6;
 	}
-	fl6_sock_release(flowlabel);

+	ip6_dst_store(sk, dst,
+		      !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) ?
+		      &np->daddr : NULL);
+
+	sk->sk_state = TCP_ESTABLISHED;
+out:
+	fl6_sock_release(flowlabel);
 	return err;
 }

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
