From: Federico Vaga <federico.vaga@gmail.com>
Subject: [RFC] assign some address families for local use
Date: Thu, 16 May 2013 17:49:46 +0200
Message-ID: <1483365.AWhs4mCphi@harkonnen>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart3729943.S8xGMTGp2U"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alessandro Rubini <rubini@gnudd.com>
To: "David S. Miller" <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Howells <dhowells@redhat.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <edumazet@google.com>,
	Li Zefan <lizefan@huawei.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--nextPart3729943.S8xGMTGp2U
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hello,

We are working on new protocols and we think that is useful to have some 
address protocol families index assigned for local use. So we will not have 
conflict every time a new protocol is included within the Linux kernel.
Doubt: index 27 and 28 are not assigned to any address family, can be 
explicitly assigned for local use?

We also thought to increase AF_MAX to 64 to avoid to modify it every time.
Doubt: array like af_family_key_strings (net/core/sock.c) will have some NULL 
pointer. I see that a string is specified also for index 27 and 28 even if 
there is not a protocol assigned for these. Is a NULL string a problem for 
these vectors? Typically is used in this way:

    af_family_clock_key_strings[newsk->sk_family]

So, if I set sk_family with an unassigned index I will have a NULL pointer and 
a DEBUG_LOCK_WARN_ON() from lockdep_init_map() (kernel/lockdep.c)


I attached to this email the patch that do these stuff.

-- 
Federico Vaga
--nextPart3729943.S8xGMTGp2U
Content-Disposition: attachment; filename="0001-include-linux-socket.h-assign-address-families-for-l.patch"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-patch; charset="UTF-8"; name="0001-include-linux-socket.h-assign-address-families-for-l.patch"

>From 8ce4f2576aa8e95ea22921c31bdffd049460951d Mon Sep 17 00:00:00 2001
From: Federico Vaga <federico.vaga@gmail.com>
Date: Wed, 15 May 2013 12:32:03 +0200
Subject: [PATCH] include/linux/socket.h: assign address families for local use

The patch assigns 4 address families for local use only. This is
useful because it allows to maintain an address family outside kernel
source without conflict. It is also useful during development until a
number is officially assigned.

This is the same kind of policy applied for major number
(Documentation/devices.text)

This patch also increases the number of maximum address (protocol)
families to 64. In this way for a while nobody need to increase this
value. The cost, in terms of memory, is tiny. I made an (very)
approximate calculation about the cost of an unused address family by
following NPROTO, AF_MAX and PF_MAX usage. If I did not big errors it
should be about 70Byte on 32bit systems and 130Byte on 64bit systems for
each new address family.

I also compiled a kernel on a x86_64 machine:
Without patch
   text	   data	    bss	    dec	    hex		filename
10935491 1398904 1175552 13509947  ce253b	vmlinux

With patch
   text	   data	    bss	    dec	    hex		filename
10935427 1399544 1175552 13510523  ce277b	vmlinux

Signed-off-by: Federico Vaga <federico.vaga@gmail.com>
---
 include/linux/socket.h | 12 +++++++++++-
 net/core/sock.c        | 12 +++++++++---
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 428c37a..4775d69 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -179,7 +179,12 @@ struct ucred {
 #define AF_ALG		38	/* Algorithm sockets		*/
 #define AF_NFC		39	/* NFC sockets			*/
 #define AF_VSOCK	40	/* vSockets			*/
-#define AF_MAX		41	/* For now.. */
+#define AF_LOCAL1	41	/* Local use sockets		*/
+#define AF_LOCAL2	42	/* Local use sockets		*/
+#define AF_LOCAL3	43	/* Local use sockets		*/
+#define AF_LOCAL4	44	/* Local use sockets		*/
+/* new address families here */
+#define AF_MAX		64
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -223,6 +228,11 @@ struct ucred {
 #define PF_ALG		AF_ALG
 #define PF_NFC		AF_NFC
 #define PF_VSOCK	AF_VSOCK
+#define PF_LOCAL1	AF_LOCAL1
+#define PF_LOCAL2	AF_LOCAL2
+#define PF_LOCAL3	AF_LOCAL3
+#define PF_LOCAL4	AF_LOCAL4
+/* new protocol families here */
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/net/core/sock.c b/net/core/sock.c
index 6ba327d..9bf66ab 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -210,7 +210,9 @@ static const char *const af_family_key_strings[AF_MAX+1] = {
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
   "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
-  "sk_lock-AF_NFC"   , "sk_lock-AF_MAX"
+  "sk_lock-AF_NFC"   , "sk_lock-AF_LOCAL1"   , "sk_lock-AF_LOCAL2"   ,
+  "sk_lock-AF_LOCAL3", "sk_lock-AF_LOCAL4"   ,
+  [AF_MAX] = "sk_lock-AF_MAX"
 };
 static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@ -226,7 +228,9 @@ static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
   "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
-  "slock-AF_NFC"   , "slock-AF_MAX"
+  "slock-AF_NFC"   , "slock-AF_LOCAL1"   , "slock-AF_LOCAL2"   ,
+  "slock-AF_LOCAL3", "slock-AF_LOCAL4"   ,
+  [AF_MAX] = "slock-AF_MAX"
 };
 static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
@@ -242,7 +246,9 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
   "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
-  "clock-AF_NFC"   , "clock-AF_MAX"
+  "clock-AF_NFC"   , "clock-AF_LOCAL1"   , "clock-AF_LOCAL2"   ,
+  "clock-AF_LOCAL3", "clock-AF_LOCAL4"   ,
+  [AF_MAX] = "clock-AF_MAX"
 };
 
 /*
-- 
1.8.1.4


--nextPart3729943.S8xGMTGp2U--
