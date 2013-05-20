From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [RFC PATCH 2/2] ppp_mppe: Check coherency counter for out-of-order sequencing
Date: Mon, 20 May 2013 18:34:00 +0200
Message-ID: <1369067640-2793-2-git-send-email-jorge@dti2.net>
References: <1369067640-2793-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1369067640-2793-1-git-send-email-jorge@dti2.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

While testing a L2TP tunnel without sequencing with MPPE encryption in
stateless mode noticed that after a packet was reordered the encapsulated
traffic session was stuck but testing against a Cisco gear did work.

>From RFC3078 "MPPE expects packets to be delivered in sequence".

The thing it's that the ppp_mppe module treats the reorder as if the
coherency counter did wrap and rekeys all the "missing" packets.

The link layer protocol should deliver the packets in order but at least
with this patch in place the decryption process survives some packet reorder.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 drivers/net/ppp/ppp_mppe.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 9a1849a..0a10a6d 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -55,6 +55,7 @@
 #include <linux/ppp_defs.h>
 #include <linux/ppp-comp.h>
 #include <linux/scatterlist.h>
+#include <linux/net.h>
 #include <asm/unaligned.h>
 
 #include "ppp_mppe.h"
@@ -469,6 +470,15 @@ static void mppe_decomp_reset(void *arg)
 }
 
 /*
+ * Compares two coherency counter values.
+ */
+static int
+mppe_cmp_ccount(unsigned int a, unsigned int b)
+{
+	return (int)((a << 20) - (b << 20));
+}
+
+/*
  * Decompress (decrypt) an MPPE packet.
  */
 static int
@@ -547,6 +557,17 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	 */
 
 	if (!state->stateful) {
+		if (mppe_cmp_ccount(ccount, state->ccount) < 0) {
+			if (state->debug >= 7 && net_ratelimit())
+				printk(KERN_DEBUG
+				       "%s[%d:]: Dropping out-of-order packet, "
+				       "ccount %u expecting %u.\n",
+				       __func__, state->unit, ccount,
+				       state->ccount);
+
+			return DECOMP_DROPERROR;
+		}
+
 		/* RFC 3078, sec 8.1.  Rekey for every packet. */
 		while (state->ccount != ccount) {
 			mppe_rekey(state, 0);
-- 
1.7.10.4


