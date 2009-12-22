From: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Subject: Re: Still using IPTOS_TOS() in kernel? Really???
Date: Tue, 22 Dec 2009 13:28:56 +0100
Message-ID: <200912221328.56573.schmto@hrz.tu-chemnitz.de>
References: <4B298118.2000608@redfish-solutions.com> <200912212150.34727.schmto@hrz.tu-chemnitz.de> <4B2FE882.3080207@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_IuLMLyCJc+qewmg"
To: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jack.hrz.tu-chemnitz.de ([134.109.132.46]:38385 "EHLO
	jack.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbZLVM27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 07:28:59 -0500
In-Reply-To: <4B2FE882.3080207@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_IuLMLyCJc+qewmg
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

> I'll poke around and see if I can figure out how that works...
> 
> Looking at include/linux/pkt_sched.h:
> 
> #define TC_PRIO_BESTEFFORT              0
> #define TC_PRIO_FILLER                  1
> #define TC_PRIO_BULK                    2
> #define TC_PRIO_INTERACTIVE_BULK        4
> #define TC_PRIO_INTERACTIVE             6
> #define TC_PRIO_CONTROL                 7
> 
> it seems that these TC priorities are just random, unrelated buckets and
>  their ordinality has no relation to their priority.  Is that correct?
No.
 
1.Type Of Service Field is defined in RFC 791:
Bits 0-2:  Precedence.
Bit    3:  0 = Normal Delay,      1 = Low Delay.
Bit    4:  0 = Normal Throughput, 1 = High Throughput.
Bit    5:  0 = Normal Reliability, 1 = High Reliability.
Bits 6-7:  ECN (RFC 3168). ECN-ECT, ECN-CE

2. include/net/route.h
static inline char rt_tos2priority(u8 tos)
{
	return ip_tos2prio[IPTOS_TOS(tos)>>1];
}

- IPTOS_TOS(tos), masks 0001.1110 
  (from left: Delay, Throughput, Reliability, ECN-ECT)
- IPTOS_TOS(tos)>>1, generates: 0000.1111
  value range: 0 .. 15.
- ip_tos2prio [ IPTOS_TOS(tos)>>1 ], 
  lookup table:

3. net/ipv4/route.c 
const __u8 ip_tos2prio[16] = {
	TC_PRIO_BESTEFFORT,
	ECN_OR_COST(FILLER),
	TC_PRIO_BESTEFFORT,
	ECN_OR_COST(BESTEFFORT),
	TC_PRIO_BULK,
	ECN_OR_COST(BULK),
	TC_PRIO_BULK,
	ECN_OR_COST(BULK),
	TC_PRIO_INTERACTIVE,
	ECN_OR_COST(INTERACTIVE),
	TC_PRIO_INTERACTIVE,
	ECN_OR_COST(INTERACTIVE),
	TC_PRIO_INTERACTIVE_BULK,
	ECN_OR_COST(INTERACTIVE_BULK),
	TC_PRIO_INTERACTIVE_BULK,
	ECN_OR_COST(INTERACTIVE_BULK)
};

with resolved defines it would look like:
const __u8 ip_tos2prio[16] = {0 1 0 0  2 2 2 2  6 6 6 6  4 4 4 4 };

So y = rt_tos2priority(x) maps:
- - - - - - - - - - -
x	y	bin(x)
0	0	0000
1	1	0001	-> ECN - ECT bit set
2	0	0010	-> High Reliability bit set
3	0	0011
4	2	0100	-> High Throughput bit set
5	2	0101
6	2	0110
7	2	0111
8	6	1000	-> Low Delay bit set
9	6	1001
10	6	1010
11	6	1011
12	4	1100
13	4	1101
14	4	1110
15	4	1111

4. 
High Reliability gets priority 0.
High Throughput gets priority 2.
Low Delay gets highest priority 6.

priority:
-> Low Delay (6), High Throughput (2), High Reliability (0) !

5.
> If that's the case, then you *can't* just do:
> static inline char rt_dscp2priority(u8 tos)
> {
> 	return IPTOS_PREC(tos)>>5;
> }
> 
> for instance.  No, that would be too easy.  :-)
No, thats right. You map:

y = rt_dscp2priority(x)
y	x
- - - - - - - -
0	CS0
1	CS1
2	CS2
3	CS3
4	CS4
5	CS5
6	CS6
7	CS7

This IMHO is compliant to RFC 2474. 

6. So we simply need to do:
static inline char rt_tos2priority(u8 tos)
{
#ifdef CONFIG_IP_DIFFSERV_COMPLIANT
	return tos >> 5;
#else
	return ip_tos2prio[IPTOS_TOS(tos)>>1];
#endif
}

7. -> See [PATCH]: ipv4: add DiffServ priority based routing
    
    Enables IPv4 Differentiated Services support for IP priority based
    routing. Notice that the IP TOS field was redefined 1998 to DiffServ
    (RFC 2474). Type Of Service is deprecated since 1998 !
    
    This patch adds a compliant flag to net/ipv4/Kconfig, which allows
    the user to select DiffServ ore TOS priority based routing. Default
    answer is TOS.
    
    Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>


Torsten



--Boundary-00=_IuLMLyCJc+qewmg
Content-Type: text/x-patch;
  charset="UTF-8";
  name="0001-ipv4-add-DiffServ-priority-based-routing.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-ipv4-add-DiffServ-priority-based-routing.patch"

=46rom e7539f1d3620286559d298b81dc5ca1672af4733 Mon Sep 17 00:00:00 2001
=46rom: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
Date: Tue, 22 Dec 2009 12:49:54 +0100
Subject: [PATCH] ipv4: add DiffServ priority based routing

Enables IPv4 Differentiated Services support for IP priority based
routing. Notice that the IP TOS field was redefined 1998 to DiffServ
(RFC 2474). Type Of Service is deprecated since 1998 !

This patch adds a compliant flag to net/ipv4/Kconfig, which allows
the user to select DiffServ ore TOS priority based routing. Default
answer is TOS.

Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
=2D--
 include/net/route.h |    4 ++++
 net/ipv4/Kconfig    |   15 +++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 40f6346..8bf43a5 100644
=2D-- a/include/net/route.h
+++ b/include/net/route.h
@@ -141,7 +141,11 @@ extern const __u8 ip_tos2prio[16];
=20
 static inline char rt_tos2priority(u8 tos)
 {
+#ifdef CONFIG_IP_DIFFSERV_COMPLIANT
+	return tos >> 5;
+#else
 	return ip_tos2prio[IPTOS_TOS(tos)>>1];
+#endif
 }
=20
 static inline int ip_route_connect(struct rtable **rp, __be32 dst,
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index b0d3cef..b2a79e5 100644
=2D-- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -272,6 +272,21 @@ config IP_PIMSM_V2
 	  gated-5). This routing protocol is not used widely, so say N unless
 	  you want to play with it.
=20
+config IP_DIFFSERV_COMPLIANT
+	bool "IP: DiffServ priority routing"
+	default n
+	help
+	  Enables IPv4 Differentiated Services support for IP priority based
+	  routing. If you say YES here, TOS priority based routing is disabled.
+	  Notice that the IP TOS field was redefined 1998 to DiffServ (RFC 2474).=
=20
+	  Type Of Service is deprecated since 1998 ! So in future default answer
+	  should be YES.=20
+
+	    Y: DiffServ
+	    N: Type Of Service
+
+	  If unsure, say N.
+
 config IP_DSCP_STAT
 	bool "IP: DSCP statistic"
 	help
=2D-=20
1.6.3.3


--Boundary-00=_IuLMLyCJc+qewmg--
