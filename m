From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] MIPS checksum fix
Date: Tue, 30 Sep 2008 00:28:56 +0900 (JST)
Message-ID: <20080930.002856.93205794.anemo@mba.ocn.ne.jp>
References: <20080919114743.GA19359@linux-mips.org>
	<20080919120752.GA19877@linux-mips.org>
	<BFB5F5A7-2980-4BCB-A14D-9EB6114B031B@terran.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, macro@linux-mips.org,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: u1@terran.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:55452 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558AbYI2P3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 11:29:01 -0400
In-Reply-To: <BFB5F5A7-2980-4BCB-A14D-9EB6114B031B@terran.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Sep 2008 14:52:24 -0700, Bryan Phillippe <u1@terran.org> wrote:
> 
> I tried this patch (with and without Atsushi's addition, shown below)  
> on a MIPS64 today and the checksums were all bad (i.e. worse than the  
> original problem).
> 
> Note that I had to manually create the diff, because of "malformed  
> patch" errors at line 21 (second hunk).
> 
> If anyone would like to send me an updated unified diff for this  
> issue, I can re-test today within the next day.

I suppose your problem is still not fixed, right?

If so, could you try this patch?  With this patch, checksums is always
compared with a result of "reference" implementation.  If any mismatch
was found, please report the log.

 arch/mips/lib/Makefile            |    1 +
 arch/mips/lib/csum_partial.S      |    4 +-
 arch/mips/lib/csum_partial_test.c |  109 +++++++++++++++++++++++++++++++++++++
 3 files changed, 112 insertions(+), 2 deletions(-)

diff --git a/arch/mips/lib/Makefile b/arch/mips/lib/Makefile
index 8810dfb..cb56e19 100644
--- a/arch/mips/lib/Makefile
+++ b/arch/mips/lib/Makefile
@@ -29,3 +29,4 @@ obj-$(CONFIG_CPU_VR41XX)	+= dump_tlb.o
 
 # libgcc-style stuff needed in the kernel
 obj-y += ashldi3.o ashrdi3.o cmpdi2.o lshrdi3.o ucmpdi2.o
+obj-y += csum_partial_test.o
diff --git a/arch/mips/lib/csum_partial.S b/arch/mips/lib/csum_partial.S
index edac989..22e9767 100644
--- a/arch/mips/lib/csum_partial.S
+++ b/arch/mips/lib/csum_partial.S
@@ -101,7 +101,7 @@
 	.text
 	.set	noreorder
 	.align	5
-LEAF(csum_partial)
+LEAF(asm_csum_partial)
 	move	sum, zero
 	move	t7, zero
 
@@ -296,7 +296,7 @@ LEAF(csum_partial)
 	ADDC32(sum, a2)
 	jr	ra
 	.set	noreorder
-	END(csum_partial)
+	END(asm_csum_partial)
 
 
 /*
diff --git a/arch/mips/lib/csum_partial_test.c b/arch/mips/lib/csum_partial_test.c
new file mode 100644
index 0000000..4a4887e
--- /dev/null
+++ b/arch/mips/lib/csum_partial_test.c
@@ -0,0 +1,109 @@
+#include <net/checksum.h>
+
+static inline __sum16 ref_csum_fold(__wsum csum)
+{
+	u32 sum = (__force u32)csum;
+	sum = (sum & 0xffff) + (sum >> 16);
+	sum = (sum & 0xffff) + (sum >> 16);
+	return (__force __sum16)~sum;
+}
+
+static inline unsigned short from32to16(unsigned int x)
+{
+	/* add up 16-bit and 16-bit for 16+c bit */
+	x = (x & 0xffff) + (x >> 16);
+	/* add up carry.. */
+	x = (x & 0xffff) + (x >> 16);
+	return x;
+}
+
+static unsigned int do_csum(const unsigned char * buff, int len)
+{
+	int odd, count;
+	unsigned int result = 0;
+
+	if (len <= 0)
+		goto out;
+	odd = 1 & (unsigned long) buff;
+	if (odd) {
+#ifdef __BIG_ENDIAN
+		result = *buff;
+#else
+		result = *buff << 8;
+#endif
+		len--;
+		buff++;
+	}
+	count = len >> 1;		/* nr of 16-bit words.. */
+	if (count) {
+		if (2 & (unsigned long) buff) {
+			result += *(unsigned short *) buff;
+			count--;
+			len -= 2;
+			buff += 2;
+		}
+		count >>= 1;		/* nr of 32-bit words.. */
+		if (count) {
+		        unsigned int carry = 0;
+			do {
+				unsigned int w = *(unsigned int *) buff;
+				count--;
+				buff += 4;
+				result += carry;
+				result += w;
+				carry = (w > result);
+			} while (count);
+			result += carry;
+			result = (result & 0xffff) + (result >> 16);
+		}
+		if (len & 2) {
+			result += *(unsigned short *) buff;
+			buff += 2;
+		}
+	}
+	if (len & 1) {
+#ifdef __BIG_ENDIAN
+		result += (*buff << 8);
+#else
+		result += *buff;
+#endif
+	}
+	result = from32to16(result);
+	if (odd)
+		result = ((result >> 8) & 0xff) | ((result & 0xff) << 8);
+out:
+	return result;
+}
+
+static __wsum ref_csum_partial(const void *buff, int len, __wsum sum)
+{
+	unsigned int result = do_csum(buff, len);
+
+	/* add in old sum, and carry.. */
+	result += (__force u32)sum;
+	if ((__force u32)sum > result)
+		result += 1;
+	return (__force __wsum)result;
+}
+
+__wsum asm_csum_partial(const void *buff, int len, __wsum sum);
+
+__wsum csum_partial(const void *buff, int len, __wsum sum)
+{
+	__wsum ref_wsum = ref_csum_partial(buff, len, sum);
+	__sum16 ref_sum = ref_csum_fold(ref_wsum);
+	__wsum cal_wsum = asm_csum_partial(buff, len, sum);
+	__sum16 cal_sum = csum_fold(cal_wsum);
+	if (ref_sum != cal_sum) {
+		int i;
+		printk("csum_partial error."
+		       " %#04x(%#08x) != %#04x(%#08x)\n",
+		       ref_sum, ref_wsum, cal_sum, cal_wsum);
+		printk("len %#04x, sum %#08x\n", len, sum);
+		printk("buf");
+		for (i = 0; i < len; i++)
+			printk(" %#02x", *((const u8 *)buff + i));
+		printk("\n");
+	}
+	return ref_wsum;
+}
