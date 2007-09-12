From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 4/6] [IPROUTE2]: Overhead calculation is now done in the
	kernel
Date: Wed, 12 Sep 2007 12:14:39 +0200
Message-ID: <1189592079.26927.25.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:39728 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964916AbXILKPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:15:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 07a74a2613440fc1a68d0faa7235ed7027532d78
Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Tue Sep 11 16:59:58 2007 +0200

    [IPROUTE2]: Overhead calculation is now done in the kernel.
    
    The only current user is HTB. HTB overhead argument is now passed on
    to the kernel (in the struct tc_ratespec). Also correct the data
    types.
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

diff --git a/tc/q_htb.c b/tc/q_htb.c
index 53e3f78..310d36d 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -107,8 +107,9 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	__u32 rtab[256],ctab[256];
 	unsigned buffer=0,cbuffer=0;
 	int cell_log=-1,ccell_log = -1;
-	unsigned mtu, mpu;
-	unsigned char mpu8 = 0, overhead = 0;
+	unsigned mtu;
+	unsigned short mpu = 0;
+	unsigned short overhead = 0;
 	struct rtattr *tail;
 
 	memset(&opt, 0, sizeof(opt)); mtu = 1600; /* eth packet len */
@@ -127,12 +128,12 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 			}
 		} else if (matches(*argv, "mpu") == 0) {
 			NEXT_ARG();
-			if (get_u8(&mpu8, *argv, 10)) {
+			if (get_u16(&mpu, *argv, 10)) {
 				explain1("mpu"); return -1;
 			}
 		} else if (matches(*argv, "overhead") == 0) {
 			NEXT_ARG();
-			if (get_u8(&overhead, *argv, 10)) {
+			if (get_u16(&overhead, *argv, 10)) {
 				explain1("overhead"); return -1;
 			}
 		} else if (matches(*argv, "quantum") == 0) {
@@ -206,9 +207,11 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	if (!buffer) buffer = opt.rate.rate / get_hz() + mtu;
 	if (!cbuffer) cbuffer = opt.ceil.rate / get_hz() + mtu;
 
-/* encode overhead and mpu, 8 bits each, into lower 16 bits */
-	mpu = (unsigned)mpu8 | (unsigned)overhead << 8;
-	opt.ceil.mpu = mpu; opt.rate.mpu = mpu;
+	opt.ceil.overhead = overhead;
+	opt.rate.overhead = overhead;
+
+	opt.ceil.mpu = mpu;
+	opt.rate.mpu = mpu;
 
 	if ((cell_log = tc_calc_rtable(opt.rate.rate, rtab, cell_log, mtu, mpu)) < 0) {
 		fprintf(stderr, "htb: failed to calculate rate table.\n");
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 58155fb..1ab0ba0 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -73,8 +73,6 @@ int tc_calc_rtable(unsigned bps, __u32 *rtab, int cell_log, unsigned mtu,
 		   unsigned mpu)
 {
 	int i;
-	unsigned overhead = (mpu >> 8) & 0xFF;
-	mpu = mpu & 0xFF;
 
 	if (mtu == 0)
 		mtu = 2047;
@@ -86,8 +84,6 @@ int tc_calc_rtable(unsigned bps, __u32 *rtab, int cell_log, unsigned mtu,
 	}
 	for (i=0; i<256; i++) {
 		unsigned sz = (i<<cell_log);
-		if (overhead)
-			sz += overhead;
 		if (sz < mpu)
 			sz = mpu;
 		rtab[i] = tc_calc_xmittime(bps, sz);

