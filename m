From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/3] IPv6: breakage of sendmsg to IPv4-mapped address via
 UDPv6 socket
Date: Sun, 26 Oct 2003 18:54:12 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031026.185412.22276663.yoshfuji@linux-ipv6.org>
References: <20030807223421.70497d61.davem@redhat.com>
	<20030808.170839.90822982.yoshfuji@linux-ipv6.org>
	<20031026.185023.108406592.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, miyazawa@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20031026.185023.108406592.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

> I'm about to send 3 patches to fix them.
>
> [1/3] IPv6: Odd IPv6 header in UDPv6 packets when sending MSG_MORE flag
> [2/3] NET: store cork'ing flow information in common storage in inet_opt
> [3/3] IPv6: breakage of sendmsg to IPv4-mapped address via UDPv6 socket

[3/3] IPv6: breakage of sendmsg to IPv4-mapped address via UDPv6 socket

D: Fixing breakage of sendmsg to IPv4-mapped address via UDPv6 socket;
D: check destination address before checking cork flag to process
D: appropriately.

--- linux-2.5-net/net/ipv4/udp.c	Sun Oct 26 16:23:36 2003
+++ linux-2.5-udp6_append_data/net/ipv4/udp.c	Sun Oct 26 16:23:55 2003
@@ -522,8 +522,13 @@
 	 	 * The socket lock must be held while it's corked.
 		 */
 		lock_sock(sk);
-		if (likely(up->pending))
+		if (likely(up->pending)) {
+			if (unlikely(up->pending != AF_INET)) {
+				release_sock(sk);
+				return -EINVAL;
+			}
  			goto do_append_data;
+		}
 		release_sock(sk);
 	}
 	ulen += sizeof(struct udphdr);
@@ -642,7 +647,7 @@
 	inet->cork.fl.fl_ip_dport = dport;
 	inet->cork.fl.fl4_src = saddr;
 	inet->cork.fl.fl_ip_sport = inet->sport;
-	up->pending = 1;
+	up->pending = AF_INET;
 
 do_append_data:
 	up->len += ulen;
--- linux-2.5-net/net/ipv6/udp.c	Sun Oct 26 16:23:36 2003
+++ linux-2.5-udp6_append_data/net/ipv6/udp.c	Sun Oct 26 16:23:55 2003
@@ -787,11 +787,56 @@
 	struct dst_entry *dst;
 	int addr_len = msg->msg_namelen;
 	int ulen = len;
-	int addr_type;
 	int hlimit = -1;
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int err;
-	
+
+	/* destination address check */
+	if (sin6) {
+		if (addr_len < offsetof(struct sockaddr, sa_data))
+			return -EINVAL;
+
+		switch (sin6->sin6_family) {
+		case AF_INET6:
+			if (addr_len < SIN6_LEN_RFC2133)
+				return -EINVAL;
+			daddr = &sin6->sin6_addr;
+			break;
+		case AF_INET:
+			goto do_udp_sendmsg;
+		case AF_UNSPEC:
+			msg->msg_name = sin6 = NULL;
+			msg->msg_namelen = addr_len = 0;
+			daddr = NULL;
+			break;
+		default:
+			return -EINVAL;
+		}
+	} else if (!up->pending) {
+		if (sk->sk_state != TCP_ESTABLISHED)
+			return -EDESTADDRREQ;
+		daddr = &np->daddr;
+	} else 
+		daddr = NULL;
+
+	if (daddr) {
+		if (ipv6_addr_type(daddr) == IPV6_ADDR_MAPPED) {
+			struct sockaddr_in sin;
+			sin.sin_family = AF_INET;
+			sin.sin_port = sin6 ? sin6->sin6_port : inet->dport;
+			sin.sin_addr.s_addr = daddr->s6_addr[3];
+			msg->msg_name = &sin;
+			msg->msg_namelen = sizeof(sin);
+do_udp_sendmsg:
+			if (__ipv6_only_sock(sk))
+				return -ENETUNREACH;
+			return udp_sendmsg(iocb, sk, msg, len);
+		}
+	}
+
+	if (up->pending == AF_INET)
+		return udp_sendmsg(iocb, sk, msg, len);
+
 	/* Rough check on arithmetic overflow,
 	   better check is made in ip6_build_xmit
 	   */
@@ -805,6 +850,10 @@
 		 */
 		lock_sock(sk);
 		if (likely(up->pending)) {
+			if (unlikely(up->pending != AF_INET6)) {
+				release_sock(sk);
+				return -EINVAL;
+			}
 			dst = NULL;
 			goto do_append_data;
 		}
@@ -815,18 +864,6 @@
 	memset(fl, 0, sizeof(*fl));
 
 	if (sin6) {
-		if (sin6->sin6_family == AF_INET) {
-			if (__ipv6_only_sock(sk))
-				return -ENETUNREACH;
-			return udp_sendmsg(iocb, sk, msg, len);
-		}
-
-		if (addr_len < SIN6_LEN_RFC2133)
-			return -EINVAL;
-
-		if (sin6->sin6_family && sin6->sin6_family != AF_INET6)
-			return -EINVAL;
-
 		if (sin6->sin6_port == 0)
 			return -EINVAL;
 
@@ -864,24 +901,6 @@
 		fl->fl6_flowlabel = np->flow_label;
 	}
 
-	addr_type = ipv6_addr_type(daddr);
-
-	if (addr_type == IPV6_ADDR_MAPPED) {
-		struct sockaddr_in sin;
-
-		if (__ipv6_only_sock(sk))
-			return -ENETUNREACH;
-
-		sin.sin_family = AF_INET;
-		sin.sin_addr.s_addr = daddr->s6_addr32[3];
-		sin.sin_port = inet->cork.fl.fl_ip_dport;
-		msg->msg_name = (struct sockaddr *)(&sin);
-		msg->msg_namelen = sizeof(sin);
-		fl6_sock_release(flowlabel);
-
-		return udp_sendmsg(iocb, sk, msg, len);
-	}
-
 	if (!fl->oif)
 		fl->oif = sk->sk_bound_dev_if;
 
@@ -950,7 +969,7 @@
 		goto out;
 	}
 
-	up->pending = 1;
+	up->pending = AF_INET6;
 
 do_append_data:
 	up->len += ulen;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
