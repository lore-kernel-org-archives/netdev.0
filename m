From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: [RFC 1/2] udp: add non-linear uniform port allocation scheme option
 /proc/sys/net/ipv4/udp_port_randomization
Date: Wed, 16 Dec 2009 21:24:31 +0200
Message-ID: <4B2933EF.9060606@ixiacom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020306080202080200090109"
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:26202 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S935558AbZLPTYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 14:24:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020306080202080200090109
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit


When we allocate ports with a (really) high frequency, randomization
does more harm as some values tend to repeat with a higher frequency
than they would if allocated uniformly, while others are selected more
rarely.

This patch does not allocate ports linearly as older kernels used to do,
but it allocates the port with an uniform frequency.

For example: assuming UDP_HTABLE_SIZE=8, hint=3, low=0, high=32
This leads to:
> first=3, last=3+8=11, rand=(1 | 1) * UDP_HTABLE_SIZE=8

The port selection code is similar to:
> for first in [3..11):
>     snum = first
>     do if (!good(snum)) snum+=8 while(snum!=first)

Will give the following sequence for snum (skipping `modulo 32` for brevity)
   3,  3+8,  3+8+8,  3+8+8+8,
   4,  4+8,  4+8+8,  4+8+8+8,
  ...
   9,  9+8,  9+8+8,  9+8+8+8,
  10, 10+8, 10+8+8, 10+8+8+8,

This will generate all numbers in the [low..high) interval with the
same frequency. This leads to better performance when most ports are
already allocated.

Randomization is still enabled by default for normal setups that will
most likely not encounter such situations.

Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
---
  include/net/udp.h          |    1 +
  net/ipv4/sysctl_net_ipv4.c |    7 +++++++
  net/ipv4/udp.c             |   18 +++++++++++++++---
  3 files changed, 23 insertions(+), 3 deletions(-)



--------------020306080202080200090109
Content-Type: text/x-patch;
 name="0001-udp-add-non-linear-uniform-port-allocation-scheme-op.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-udp-add-non-linear-uniform-port-allocation-scheme-op.pa";
 filename*1="tch"

diff --git a/include/net/udp.h b/include/net/udp.h
index 5348d80..925535e 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -111,6 +111,7 @@ extern atomic_t udp_memory_allocated;
 extern int sysctl_udp_mem[3];
 extern int sysctl_udp_rmem_min;
 extern int sysctl_udp_wmem_min;
+extern int sysctl_udp_port_randomization;
 
 struct sk_buff;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 7e3712c..ef811c3 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -599,6 +599,13 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero
 	},
+	{
+		.procname	= "udp_port_randomization",
+		.data		= &sysctl_udp_port_randomization,
+		.maxlen		= sizeof(sysctl_udp_port_randomization),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1f95348..f437d9d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -182,6 +182,9 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 	return res;
 }
 
+int sysctl_udp_port_randomization = 1;
+EXPORT_SYMBOL(sysctl_udp_port_randomization);
+
 /**
  *  udp_lib_get_port  -  UDP/-Lite port lookup for IPv4 and IPv6
  *
@@ -202,6 +205,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 	struct net *net = sock_net(sk);
 
 	if (!snum) {
+		static int hint;
 		int low, high, remaining;
 		unsigned rand;
 		unsigned short first, last;
@@ -210,8 +214,13 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		inet_get_local_port_range(&low, &high);
 		remaining = (high - low) + 1;
 
-		rand = net_random();
-		first = (((u64)rand * remaining) >> 32) + low;
+		if (likely(sysctl_udp_port_randomization)) {
+			rand = net_random();
+			first = (((u64)rand * remaining) >> 32) + low;
+		} else {
+			rand = 1;
+			first = hint;
+		}
 		/*
 		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
 		 */
@@ -233,8 +242,11 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 			 */
 			do {
 				if (low <= snum && snum <= high &&
-				    !test_bit(snum >> udptable->log, bitmap))
+				    !test_bit(snum >> udptable->log, bitmap)) {
+					if (unlikely(!sysctl_udp_port_randomization))
+						hint = snum;
 					goto found;
+				}
 				snum += rand;
 			} while (snum != first);
 			spin_unlock_bh(&hslot->lock);


--------------020306080202080200090109--
