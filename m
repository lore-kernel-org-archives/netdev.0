From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: Sereral errors on udpv6_connect()
Date: Wed, 04 Jun 2003 09:39:44 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030604.093944.84705841.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ville Nuorvala <vnuorval@tcs.hut.fi>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

The CONFIG_IPV6_SUBTREE contains multiple fixes and changes.
I'm trying to split them.

This patch fixes multiple errors in udpv6_connect().
 - pointer within an automatic storage class variable fl was illegally cached
   using ip6_dst_store().
 - uninitialized saddr was copied to fl.fl6_src.
 - don't cache if ipv6_saddr_get() failed.
Patch is based on CONFIG_IPV6_SUBTREE patch from Ville Nuorvala 
<vnuorval@tcs.hut.fi>.

Index: linux25-LINUS/net/ipv6/udp.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/udp.c,v
retrieving revision 1.1.1.18
diff -u -r1.1.1.18 udp.c
--- linux25-LINUS/net/ipv6/udp.c	26 May 2003 08:04:11 -0000	1.1.1.18
+++ linux25-LINUS/net/ipv6/udp.c	4 Jun 2003 00:29:32 -0000
@@ -254,7 +254,6 @@
 	struct inet_opt      	*inet = inet_sk(sk);
 	struct ipv6_pinfo      	*np = inet6_sk(sk);
 	struct in6_addr		*daddr;
-	struct in6_addr		saddr;
 	struct dst_entry	*dst;
 	struct flowi		fl;
 	struct ip6_flowlabel	*flowlabel = NULL;
@@ -355,7 +354,7 @@
 
 	fl.proto = IPPROTO_UDP;
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-	ipv6_addr_copy(&fl.fl6_src, &saddr);
+	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 	fl.oif = sk->bound_dev_if;
 	fl.fl_ip_dport = inet->dport;
 	fl.fl_ip_sport = inet->sport;
@@ -381,20 +380,23 @@
 		return err;
 	}
 
-	ip6_dst_store(sk, dst, &fl.fl6_dst);
-
 	/* get the source address used in the appropriate device */
 
-	err = ipv6_get_saddr(dst, daddr, &saddr);
+	err = ipv6_get_saddr(dst, daddr, &fl.fl6_src);
 
 	if (err == 0) {
 		if (ipv6_addr_any(&np->saddr))
-			ipv6_addr_copy(&np->saddr, &saddr);
+			ipv6_addr_copy(&np->saddr, &fl.fl6_src);
 
 		if (ipv6_addr_any(&np->rcv_saddr)) {
-			ipv6_addr_copy(&np->rcv_saddr, &saddr);
+			ipv6_addr_copy(&np->rcv_saddr, &fl.fl6_src);
 			inet->rcv_saddr = LOOPBACK4_IPV6;
 		}
+
+		ip6_dst_store(sk, dst,
+			      !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) ?
+			      &np->daddr : NULL);
+
 		sk->state = TCP_ESTABLISHED;
 	}
 	fl6_sock_release(flowlabel);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
