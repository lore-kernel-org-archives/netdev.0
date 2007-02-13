From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.20-git8 fails compile -- net/built-in.o __ipv6_addr_type
Date: Tue, 13 Feb 2007 11:55:10 +0900 (JST)
Message-ID: <20070213.115510.21486123.yoshfuji@linux-ipv6.org>
References: <20070213.111345.78160400.yoshfuji@linux-ipv6.org>
	<200702130236.l1D2a0u7014457@clem.clem-digital.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: clem@clem.clem-digital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54525 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030614AbXBMCzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 21:55:08 -0500
In-Reply-To: <200702130236.l1D2a0u7014457@clem.clem-digital.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200702130236.l1D2a0u7014457@clem.clem-digital.net> (at Mon, 12 Feb 2007 21:35:59 -0500 (EST)), Pete Clements <clem@clem.clem-digital.net> says:

> Quoting YOSHIFUJIHideaki/=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
>   > In article <20070212181216.c55ca788.akpm@linux-foundation.org> (at Mon, 12 Feb 2007 18:12:16 -0800), Andrew Morton <akpm@linux-foundation.org> says:
>   > 
>   > > > On Mon, 12 Feb 2007 20:10:13 -0500 (EST) Pete Clements <clem@clem.clem-digital.net> wrote:
>   > > > 2.6.20-git8 fails compile:
>   > > > 
>   > > >   CHK     include/linux/compile.h
>   > > >   UPD     include/linux/compile.h
>   > > >   CC      init/version.o
>   > > >   LD      init/built-in.o
>   > > >   LD      .tmp_vmlinux1
>   > > > net/built-in.o: In function `svc_udp_recvfrom':
>   > > > svcsock.c:(.text+0x61be4): undefined reference to `__ipv6_addr_type'
>   > > > make: *** [.tmp_vmlinux1] Error 1
>   > > > 
>   > > 
>   > > Please send the .config.
>   > 
>   > and, the gcc version...
>   > 
>   > --yoshfuji
>   > -
> 
> git 7 compiled just fine.

Ah, this is because of new ipv6 support in sunrpc code.
Enable it if it is statically compiled.

Alternatively, we could 
- export __ipv6_addr_type in new net/ipv6/addrconf_core.c
or
- introduce tiny inline for chcking if the address is link-local.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 63ae947..27dcb31 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -107,12 +107,12 @@ static inline void svc_reclassify_socket
 		sock_lock_init_class_and_name(sk, "slock-AF_INET-NFSD",
 		    &svc_slock_key[0], "sk_lock-AF_INET-NFSD", &svc_key[0]);
 		break;
-
+#ifdef CONFIG_IPV6
 	case AF_INET6:
 		sock_lock_init_class_and_name(sk, "slock-AF_INET6-NFSD",
 		    &svc_slock_key[1], "sk_lock-AF_INET6-NFSD", &svc_key[1]);
 		break;
-
+#endif
 	default:
 		BUG();
 	}
@@ -131,7 +131,7 @@ static char *__svc_print_addr(struct soc
 			NIPQUAD(((struct sockaddr_in *) addr)->sin_addr),
 			htons(((struct sockaddr_in *) addr)->sin_port));
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(CONFIG_IPV6)
 	case AF_INET6:
 		snprintf(buf, len, "%x:%x:%x:%x:%x:%x:%x:%x, port=%u",
 			NIP6(((struct sockaddr_in6 *) addr)->sin6_addr),
@@ -449,7 +449,7 @@ svc_wake_up(struct svc_serv *serv)
 
 union svc_pktinfo_u {
 	struct in_pktinfo pkti;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(CONFIG_IPV6)
 	struct in6_pktinfo pkti6;
 #endif
 };
@@ -467,7 +467,7 @@ static void svc_set_cmsg_data(struct svc
 			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
 		}
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(CONFIG_IPV6)
 	case AF_INET6: {
 			struct in6_pktinfo *pki = CMSG_DATA(cmh);
 
@@ -737,7 +737,7 @@ static void svc_udp_get_sender_address(s
 			rqstp->rq_daddr.addr.s_addr = skb->nh.iph->daddr;
 		}
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(CONFIG_IPV6)
 	case AF_INET6: {
 		/* this is derived from net/ipv6/udp.c:udpv6_recvmesg */
 			struct sockaddr_in6 *sin6 = svc_addr_in6(rqstp);
@@ -977,7 +977,7 @@ static inline int svc_port_is_privileged
 	case AF_INET:
 		return ntohs(((struct sockaddr_in *)sin)->sin_port)
 			< PROT_SOCK;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(CONFIG_IPV6)
 	case AF_INET6:
 		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
 			< PROT_SOCK;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 49cabff..877b52b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1187,11 +1187,12 @@ static inline void xs_reclassify_socket(
 			&xs_slock_key[0], "sk_lock-AF_INET-NFS", &xs_key[0]);
 		break;
 
+#ifdef CONFIG_IPV6
 	case AF_INET6:
 		sock_lock_init_class_and_name(sk, "slock-AF_INET6-NFS",
 			&xs_slock_key[1], "sk_lock-AF_INET6-NFS", &xs_key[1]);
 		break;
-
+#endif
 	default:
 		BUG();
 	}


-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
