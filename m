From: Michael Arndt <flexray4linux@scriptkiller.de>
Subject: [PATCH] FlexRay: Allocate numbers for FlexRay communication
Date: Thu, 30 Apr 2009 18:38:26 +0200
Message-ID: <20090430163825.GX13310@m58s01.vlinux.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scriptkiller.de ([83.151.21.67]:33325 "EHLO m58s01.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763014AbZD3Qqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2009 12:46:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a protocol family, Ethernet protocol ID,
ARP protocol identifier and a line discipline for FlexRay
communication using Linux.

I do not know why ETH_P_CAN has been chosen to be 0x000C
instead of 0x000A, so I have just inserted it after ETH_P_LOCALTALK,
is that OK or somehow reserved?

Further code including the FlexRay core, raw sockets and
examples will soon be posted on a yet-to-be-created project site.


Signed-off-by: Michael Arndt <flexray4linux@scriptkiller.de>
---
 include/linux/if_arp.h   |    1 +
 include/linux/if_ether.h |    1 +
 include/linux/socket.h   |    4 +++-
 include/linux/tty.h      |    3 ++-
 net/core/sock.c          |    3 +++
 5 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index 5ff8980..294cea5 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -53,6 +53,7 @@
 #define ARPHRD_X25	271		/* CCITT X.25			*/
 #define ARPHRD_HWX25	272		/* Boards with X.25 in firmware	*/
 #define ARPHRD_CAN	280		/* Controller Area Network      */
+#define ARPHRD_FLEXRAY	281		/* FlexRay */
 #define ARPHRD_PPP	512
 #define ARPHRD_CISCO	513		/* Cisco HDLC	 		*/
 #define ARPHRD_HDLC	ARPHRD_CISCO
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index cfe4fe1..f1c08af 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -95,6 +95,7 @@
 #define ETH_P_PPP_MP    0x0008          /* Dummy type for PPP MP frames */
 #define ETH_P_LOCALTALK 0x0009		/* Localtalk pseudo type 	*/
+#define ETH_P_FLEXRAY	0x000A		/* FlexRay			*/
 #define ETH_P_CAN	0x000C		/* Controller Area Network      */
 #define ETH_P_PPPTALK	0x0010		/* Dummy type for Atalk over PPP*/
 #define ETH_P_TR_802_2	0x0011		/* 802.2 frames 		*/
 #define ETH_P_MOBITEX	0x0015		/* Mobitex (kaz@cafe.net)	*/
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 421afb4..edc7daa 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -194,7 +194,8 @@ struct ucred {
 #define AF_RXRPC	33	/* RxRPC sockets 		*/
 #define AF_ISDN		34	/* mISDN sockets 		*/
 #define AF_PHONET	35	/* Phonet sockets		*/
-#define AF_MAX		36	/* For now.. */
+#define AF_FLEXRAY	36	/* FlexRay sockets		*/
+#define AF_MAX		37	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -233,6 +234,7 @@ struct ucred {
 #define PF_RXRPC	AF_RXRPC
 #define PF_ISDN		AF_ISDN
 #define PF_PHONET	AF_PHONET
+#define PF_FLEXRAY	AF_FLEXRAY
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/include/linux/tty.h b/include/linux/tty.h
index fc39db9..25da47c 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -23,7 +23,7 @@
  */
 #define NR_UNIX98_PTY_DEFAULT	4096      /* Default maximum for Unix98 ptys */
 #define NR_UNIX98_PTY_MAX	(1 << MINORBITS) /* Absolute limit */
-#define NR_LDISCS		19
+#define NR_LDISCS		20
 
 /* line disciplines */
 #define N_TTY		0
@@ -46,6 +46,7 @@
 #define N_GIGASET_M101	16	/* Siemens Gigaset M101 serial DECT adapter */
 #define N_SLCAN		17	/* Serial / USB serial CAN Adaptors */
 #define N_PPS		18	/* Pulse per Second */
+#define N_SLFLEXRAY	19	/* Serial / USB serial FlexRay adapters */
 
 /*
  * This character is the same as _POSIX_VDISABLE: it cannot be used as
diff --git a/net/core/sock.c b/net/core/sock.c
index 7dbf3ff..8da4bc6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -155,6 +155,7 @@ static const char *af_family_key_strings[AF_MAX+1] = {
   "sk_lock-27"       , "sk_lock-28"          , "sk_lock-AF_CAN"      ,
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
+  "sk_lock-AF_FLEXRAY",
   "sk_lock-AF_MAX"
 };
 static const char *af_family_slock_key_strings[AF_MAX+1] = {
@@ -170,6 +171,7 @@ static const char *af_family_slock_key_strings[AF_MAX+1] = {
   "slock-27"       , "slock-28"          , "slock-AF_CAN"      ,
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
+  "slock-AF_FLEXRAY",
   "slock-AF_MAX"
 };
 static const char *af_family_clock_key_strings[AF_MAX+1] = {
@@ -185,6 +187,7 @@ static const char *af_family_clock_key_strings[AF_MAX+1] = {
   "clock-27"       , "clock-28"          , "clock-AF_CAN"      ,
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
+  "clock-AF_FLEXRAY",
   "clock-AF_MAX"
 };
 
