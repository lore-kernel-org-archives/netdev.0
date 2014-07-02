From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] net: arcnet: Remove "#define bool int"
Date: Wed,  2 Jul 2014 14:12:01 +0200
Message-ID: <1404303121-2548-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The header file include/linux/arcdevice.h #defines bool to int, if
bool is not already #defined. However, the files which use that header
file seem to rely on that #define (unconditionally) being in effect:
the prototypes for the functions arcrimi_reset, com20020_reset,
com90io_reset, com90xx_reset (whose addresses are assigned to the
hw.reset member of struct arcnet_local) use int explicitly.

Moreover, that #define is an accident waiting to happen (scenario:
inclusion of arcdevice.h followed by inclusion of some header which
declares function prototypes using bool). Also, #include
<linux/types.h> must appear before #include <linux/arcdevice.h> (the
compiler wouldn't like "typedef _Bool int").

Since none of the files using arcdevice.h declare variables of type
"bool", the patch is actually quite simple, unlike the commit message.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 include/linux/arcdevice.h | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index 7216b0d..df03562 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -22,10 +22,6 @@
 #ifdef __KERNEL__
 #include  <linux/irqreturn.h>
 
-#ifndef bool
-#define bool int
-#endif
-
 /*
  * RECON_THRESHOLD is the maximum number of RECON messages to receive
  * within one minute before printing a "cabling problem" warning. The
@@ -285,9 +281,9 @@ struct arcnet_local {
 	unsigned long first_recon; /* time of "first" RECON message to count */
 	unsigned long last_recon;  /* time of most recent RECON */
 	int num_recons;		/* number of RECONs between first and last. */
-	bool network_down;	/* do we think the network is down? */
+	int network_down;	/* do we think the network is down? */
 
-	bool excnak_pending;    /* We just got an excesive nak interrupt */
+	int excnak_pending;    /* We just got an excesive nak interrupt */
 
 	struct {
 		uint16_t sequence;	/* sequence number (incs with each packet) */
@@ -305,7 +301,7 @@ struct arcnet_local {
 		void (*command) (struct net_device * dev, int cmd);
 		int (*status) (struct net_device * dev);
 		void (*intmask) (struct net_device * dev, int mask);
-		bool (*reset) (struct net_device * dev, bool really_reset);
+		int (*reset) (struct net_device * dev, int really_reset);
 		void (*open) (struct net_device * dev);
 		void (*close) (struct net_device * dev);
 
-- 
1.9.2
