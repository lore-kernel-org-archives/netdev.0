From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH v3 2/4] ppp_mppe: check coherency counter for out-of-order sequencing
Date: Wed, 22 May 2013 13:32:51 +0200
Message-ID: <1369222373-7701-2-git-send-email-jorge@dti2.net>
References: <1369222373-7701-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1369222373-7701-1-git-send-email-jorge@dti2.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

While testing a L2TP tunnel without sequencing with MPPE encryption in
stateless mode I noticed that after a packet was reordered the encapsulated
traffic session was stuck but testing against a Cisco gear did work.

>From RFC3078 "MPPE expects packets to be delivered in sequence".

The thing it's that the ppp_mppe module treats the reorder as if the
coherency counter did wrap and rekeys all the "missing" packets.

The link layer protocol should deliver the packets in order but at least
with this patch in place the decryption process survives some packet reorder.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
Changes from v2:
- Addressed Eric Dumazet review.
- Checkpatch clean.

 drivers/net/ppp/ppp_mppe.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 9a1849a..f2e3d17 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -55,6 +55,7 @@
 #include <linux/ppp_defs.h>
 #include <linux/ppp-comp.h>
 #include <linux/scatterlist.h>
+#include <linux/net.h>
 #include <asm/unaligned.h>
 
 #include "ppp_mppe.h"
@@ -125,7 +126,10 @@ struct ppp_mppe_state {
 
 #define MPPE_BITS(p) ((p)[4] & 0xf0)
 #define MPPE_CCOUNT(p) ((((p)[4] & 0x0f) << 8) + (p)[5])
-#define MPPE_CCOUNT_SPACE 0x1000	/* The size of the ccount space */
+#define MPPE_CCOUNT_BITS 12	/* MPPE coherency count bits */
+/* The size of the ccount space */
+#define MPPE_CCOUNT_SPACE (1 << MPPE_CCOUNT_BITS)
+#define MPPE_CCOUNT_SHIFT ((sizeof(int) * 8) - MPPE_CCOUNT_BITS)
 
 #define MPPE_OVHD	2	/* MPPE overhead/packet */
 #define SANITY_MAX	1600	/* Max bogon factor we will tolerate */
@@ -468,6 +472,12 @@ static void mppe_decomp_reset(void *arg)
 	return;
 }
 
+/* Compares two coherency counter values. */
+static int mppe_cmp_ccount(unsigned int a, unsigned int b)
+{
+	return (int)((a << MPPE_CCOUNT_SHIFT) - (b << MPPE_CCOUNT_SHIFT));
+}
+
 /*
  * Decompress (decrypt) an MPPE packet.
  */
@@ -547,6 +557,13 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	 */
 
 	if (!state->stateful) {
+		if (mppe_cmp_ccount(ccount, state->ccount) < 0) {
+			net_warn_ratelimited("%s[%d]: Dropping out-of-order packet with ccount %u, expecting %u!\n",
+					     __func__, state->unit, ccount,
+					     state->ccount);
+			return DECOMP_DROPERROR;
+		}
+
 		/* RFC 3078, sec 8.1.  Rekey for every packet. */
 		while (state->ccount != ccount) {
 			mppe_rekey(state, 0);
-- 
1.7.10.4


