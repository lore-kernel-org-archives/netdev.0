From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-2.6.22] [IPV4]: Fix build without procfs.
Date: Wed, 25 Apr 2007 12:35:49 +1000
Message-ID: <E1HgXMD-0000LK-00@gondolin.me.apana.org.au>
References: <20070425.002048.109830535.yoshfuji@linux-ipv6.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1605 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161828AbXDYCgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 22:36:11 -0400
In-Reply-To: <20070425.002048.109830535.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> 
> diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
> index 4ff6c15..3bd25f5 100644
> --- a/net/ipv4/Makefile
> +++ b/net/ipv4/Makefile
> @@ -10,11 +10,11 @@ obj-y     := route.o inetpeer.o protocol.o \
>             tcp_minisocks.o tcp_cong.o \
>             datagram.o raw.o udp.o udplite.o \
>             arp.o icmp.o devinet.o af_inet.o  igmp.o \
> -            sysctl_net_ipv4.o fib_frontend.o fib_semantics.o
> +            sysctl_net_ipv4.o fib_frontend.o fib_semantics.o \
> +            proc.o
> 
> obj-$(CONFIG_IP_FIB_HASH) += fib_hash.o
> obj-$(CONFIG_IP_FIB_TRIE) += fib_trie.o
> -obj-$(CONFIG_PROC_FS) += proc.o

This makes no sense.  Why should we include all these proc operations
when PROC_FS is turned off? How about this as a fix (on top of the
above patch):

[IPV4]: Move snmp_mib_init out of proc.c

The function snmp_mib_init has nothing to do with proc so this patch
moves it out of proc.c and to the only place that uses it.  Right now
there is only one user so I'ved made it static too.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/ip.h b/include/net/ip.h
index f41ce07..75f226d 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -166,9 +166,6 @@ DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_ADD_STATS_BH(field, adnd)	SNMP_ADD_STATS_BH(net_statistics, field, adnd)
 #define NET_ADD_STATS_USER(field, adnd)	SNMP_ADD_STATS_USER(net_statistics, field, adnd)
 
-extern int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign);
-extern void snmp_mib_free(void *ptr[2]);
-
 extern int sysctl_local_port_range[2];
 extern int sysctl_ip_default_ttl;
 extern int sysctl_ip_nonlocal_bind;
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 3bd25f5..4ff6c15 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -10,11 +10,11 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     tcp_minisocks.o tcp_cong.o \
 	     datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
-	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o \
-	     proc.o
+	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o
 
 obj-$(CONFIG_IP_FIB_HASH) += fib_hash.o
 obj-$(CONFIG_IP_FIB_TRIE) += fib_trie.o
+obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index a33ca7e..6a141d6 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1243,6 +1243,31 @@ static struct net_protocol icmp_protocol = {
 	.handler =	icmp_rcv,
 };
 
+static int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
+{
+	BUG_ON(ptr == NULL);
+	ptr[0] = __alloc_percpu(mibsize);
+	if (!ptr[0])
+		goto err0;
+	ptr[1] = __alloc_percpu(mibsize);
+	if (!ptr[1])
+		goto err1;
+	return 0;
+err1:
+	free_percpu(ptr[0]);
+	ptr[0] = NULL;
+err0:
+	return -ENOMEM;
+}
+
+static void snmp_mib_free(void *ptr[2])
+{
+	BUG_ON(ptr == NULL);
+	free_percpu(ptr[0]);
+	free_percpu(ptr[1]);
+	ptr[0] = ptr[1] = NULL;
+}
+
 static int __init init_ipv4_mibs(void)
 {
 	if (snmp_mib_init((void **)net_statistics,
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index a236154..ae68a69 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -45,7 +45,6 @@
 #include <net/sock.h>
 #include <net/raw.h>
 
-#ifdef CONFIG_PROC_FS
 static int fold_prot_inuse(struct proto *proto)
 {
 	int res = 0;
@@ -391,30 +390,4 @@ out_netstat:
 	rc = -ENOMEM;
 	goto out;
 }
-#endif
-
-int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
-{
-	BUG_ON(ptr == NULL);
-	ptr[0] = __alloc_percpu(mibsize);
-	if (!ptr[0])
-		goto err0;
-	ptr[1] = __alloc_percpu(mibsize);
-	if (!ptr[1])
-		goto err1;
-	return 0;
-err1:
-	free_percpu(ptr[0]);
-	ptr[0] = NULL;
-err0:
-	return -ENOMEM;
-}
-
-void snmp_mib_free(void *ptr[2])
-{
-	BUG_ON(ptr == NULL);
-	free_percpu(ptr[0]);
-	free_percpu(ptr[1]);
-	ptr[0] = ptr[1] = NULL;
-}
 
