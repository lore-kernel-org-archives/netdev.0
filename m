From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] iproute: update dsfield file values
Date: Mon, 15 Sep 2014 13:06:08 +0200
Message-ID: <20140915130608.5d238cb1@redhat.com>
References: <20140914204353.5a0579be@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753931AbaIOLGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 07:06:12 -0400
In-Reply-To: <20140914204353.5a0579be@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Sep 2014 20:43:53 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

> Update the rt_dsfield file to contain values defined in current RFC.
> The days of TOS precedence are gone, even Cisco doesn't refer
> to these in the documents.
> ---
>  etc/iproute2/rt_dsfield | 26 ++++++++++++--------------
>  1 file changed, 12 insertions(+), 14 deletions(-)
> 
> diff --git a/etc/iproute2/rt_dsfield b/etc/iproute2/rt_dsfield
> index 496ef66..c0f3679 100644
> --- a/etc/iproute2/rt_dsfield
> +++ b/etc/iproute2/rt_dsfield
> @@ -1,17 +1,6 @@
> -0x00	default
> -0x10	lowdelay

SSH clients still set ToS bits to 0x10.

And our default pfifo_fast qdisc puts this into the high-prio band.
(TC_PRIO_INTERACTIVE=6 mapped via prio2band[16] to band 0)

rt_tos2priority() lookup bit masks "tos & 0x1E"
(and perform mapping lookup (note shift right(tos)>>1) in ip_tos2prio[16])

Maybe the kernel is handling DSCP wrongly? see below.

> -0x08	throughput
> -0x04	reliability
> -# This value overlap with ECT, do not use it!
> -0x02	mincost
> -# These values seems do not want to die, Cisco likes them by a strange reason.
> -0x20	priority
> -0x40	immediate
> -0x60	flash
> -0x80	flash-override
> -0xa0	critical
> -0xc0	internet
> -0xe0	network
> +# Differentiated field values
> +# These include the DSCP and unused bits
> +0x0	default
>  # Newer RFC2597 values
>  0x28	AF11
>  0x30	AF12

E.g. kernel will map AF12 to TC_PRIO_INTERACTIVE
 ((0x30 & 0x1E)>>1) => 8
 lookup in ip_tos2prio[8] = TC_PRIO_INTERACTIVE

> @@ -25,3 +14,12 @@
>  0x88	AF41
>  0x90	AF42
>  0x98	AF43
> +# Older values RFC2474
> +0x20	CS1
> +0x40	CS2
> +0x60	CS3
> +0x80	CS4
> +0xA0	CS5
> +0xC0	CS6
> +0xE0	CS7
> +0x5C	EF

(bash)$ echo $(((0x5C & 0x1E)>>1))  # = 14

 ip_tos2prio[14] = TC_PRIO_INTERACTIVE_BULK

Is it a bug, that we put DSCP's Expedited Forwarding (EF) into the
best-effort priority band(1) in pfifo_fast???


Below diff that highlight the kernel code doing the mapping:


[PATCH] net: tracking to ToS/DSCP values are mapped to pfifo_fast prio bands

From: Jesper Dangaard Brouer <brouer@redhat.com>

Something seems wrong with the mapping of DSCP mappings to prio bands
in our default pfifo_fast qdisc.

Especially it seems strange, that DSCP's Expedited Forwarding (EF)
get mapped into the best-effort priority band(1) in pfifo_fast.
---

 include/net/route.h            |    2 +-
 include/uapi/linux/ip.h        |    3 ++-
 include/uapi/linux/pkt_sched.h |    1 +
 net/ipv4/route.c               |   35 ++++++++++++++++++-----------------
 net/sched/sch_generic.c        |    7 ++++++-
 5 files changed, 28 insertions(+), 20 deletions(-)


diff --git a/include/net/route.h b/include/net/route.h
index b17cf28..6fc63e2 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -208,7 +208,7 @@ static inline void ip_rt_put(struct rtable *rt)
 #define IPTOS_RT_MASK	(IPTOS_TOS_MASK & ~3)
 
 extern const __u8 ip_tos2prio[16];
-
+// hey diff
 static inline char rt_tos2priority(u8 tos)
 {
 	return ip_tos2prio[IPTOS_TOS(tos)>>1];
diff --git a/include/uapi/linux/ip.h b/include/uapi/linux/ip.h
index 4119594..36849ff 100644
--- a/include/uapi/linux/ip.h
+++ b/include/uapi/linux/ip.h
@@ -18,10 +18,11 @@
 #define _UAPI_LINUX_IP_H
 #include <linux/types.h>
 #include <asm/byteorder.h>
-
+// hey diff here is the IPTOS_TOS_MASK
 #define IPTOS_TOS_MASK		0x1E
 #define IPTOS_TOS(tos)		((tos)&IPTOS_TOS_MASK)
 #define	IPTOS_LOWDELAY		0x10
+// Hmmm, is IPTOS_LOWDELAY exported to userspace?
 #define	IPTOS_THROUGHPUT	0x08
 #define	IPTOS_RELIABILITY	0x04
 #define	IPTOS_MINCOST		0x02
diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index d62316b..d07322b 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -19,6 +19,7 @@
 #define TC_PRIO_BESTEFFORT		0
 #define TC_PRIO_FILLER			1
 #define TC_PRIO_BULK			2
+// hey diff look at priority defines here
 #define TC_PRIO_INTERACTIVE_BULK	4
 #define TC_PRIO_INTERACTIVE		6
 #define TC_PRIO_CONTROL			7
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index eaa4b00..0d547c1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -168,23 +168,24 @@ static struct dst_ops ipv4_dst_ops = {
 
 #define ECN_OR_COST(class)	TC_PRIO_##class
 
-const __u8 ip_tos2prio[16] = {
-	TC_PRIO_BESTEFFORT,
-	ECN_OR_COST(BESTEFFORT),
-	TC_PRIO_BESTEFFORT,
-	ECN_OR_COST(BESTEFFORT),
-	TC_PRIO_BULK,
-	ECN_OR_COST(BULK),
-	TC_PRIO_BULK,
-	ECN_OR_COST(BULK),
-	TC_PRIO_INTERACTIVE,
-	ECN_OR_COST(INTERACTIVE),
-	TC_PRIO_INTERACTIVE,
-	ECN_OR_COST(INTERACTIVE),
-	TC_PRIO_INTERACTIVE_BULK,
-	ECN_OR_COST(INTERACTIVE_BULK),
-	TC_PRIO_INTERACTIVE_BULK,
-	ECN_OR_COST(INTERACTIVE_BULK)
+/* lookup: tos bitmasked 0x1E and shifted right (tos>>1) in rt_tos2priority(tos) */
+const __u8 ip_tos2prio[16] = {        // lower-two bits should have been for ECN (see "-" split)
+	TC_PRIO_BESTEFFORT,           // [0]  000-00 = 0x00  default
+	ECN_OR_COST(BESTEFFORT),      // [1]  000-10 = 0x02  TOS-"mincost" (conflict with ECN bits)
+	TC_PRIO_BESTEFFORT,           // [2]  001-00 = 0x04  TOS-"reliability"
+	ECN_OR_COST(BESTEFFORT),      // [3]  001-10 = 0x06
+	TC_PRIO_BULK,                 // [4]  010-00 = 0x08  TOS-"throughput"  DSCP(AF11+21+31+41)
+	ECN_OR_COST(BULK),            // [5]  010-10 = 0x0A
+	TC_PRIO_BULK,                 // [6]  011-00 = 0x0C
+	ECN_OR_COST(BULK),            // [7]  011-10 = 0X0E
+	TC_PRIO_INTERACTIVE,          // [8]  100-00 = 0x10  TOS-"lowdelay" - DSCP(AF12+22+32+42)
+	ECN_OR_COST(INTERACTIVE),     // [9]  100-10 = 0x12
+	TC_PRIO_INTERACTIVE,          // [10] 101-00 = 0x14
+	ECN_OR_COST(INTERACTIVE),     // [11] 101-10 = 0x16
+	TC_PRIO_INTERACTIVE_BULK,     // [12] 110-00 = 0x18  DSCP(AF13+23+33+43)
+	ECN_OR_COST(INTERACTIVE_BULK),// [13] 110-10 = 0x1A
+	TC_PRIO_INTERACTIVE_BULK,     // [14] 111-00 = 0x1C  DSCP(EF) (0x5C & 0x1E)=0x1C
+	ECN_OR_COST(INTERACTIVE_BULK) // [15] 111-10 = 0x1E
 };
 EXPORT_SYMBOL(ip_tos2prio);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a8bf9f9..c353234 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -408,7 +408,12 @@ static struct Qdisc noqueue_qdisc = {
 	.busylock	=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.busylock),
 };
 
-
+// ToS 0x10 maps to TC_PRIO_INTERACTIVE=6      => band 0
+// DSCP(EF) maps to TC_PRIO_INTERACTIVE_BULK=4 => band 1
+//
+// DSCP(AF11+21+31+41) TC_PRIO_BULK=2             => band 2
+// DSCP(AF12+22+32+42) TC_PRIO_INTERACTIVE=6      => band 0
+// DSCP(AF13+23+33+43) TC_PRIO_INTERACTIVE_BULK=4 => band 1
 static const u8 prio2band[TC_PRIO_MAX + 1] = {
 	1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1
 };


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
