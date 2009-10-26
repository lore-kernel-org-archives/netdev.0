From: "Stephen Hemminger <shemminger@vyatta.com>, Al Viro"
	<viro@zeniv.linux.org.uk>
Subject: [PATCH] dcache: better name hash function
Date: Mon, 26 Oct 2009 15:36:56 -0700
Message-ID: <20091026153656.25be4369@nehalam>
References: <200910252158.53921.opurdila@ixiacom.com>
	<20091025214357.666350d2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754246AbZJZWg7@vger.kernel.org>
In-Reply-To: <20091025214357.666350d2@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some experiments by Octavian with large numbers of network devices identified
that name_hash does not evenly distribute values causing performance
penalties.  The name hashing function is used by dcache et. all
so let's just choose a better one.

Additional standalone tests for 10,000,000 consecutive names
using lots of different algorithms shows fnv as the winner.
It is faster and has almost ideal dispersion. 
string10 is slightly faster, but only works for names like ppp0, ppp1,...

Algorithm             Time       Ratio       Max   StdDev
string10             0.238201       1.00      2444   0.02
fnv32                0.240595       1.00      2576   1.05
fnv64                0.241224       1.00      2556   0.69
SuperFastHash        0.272872       1.00      2871   2.15
string_hash17        0.295160       1.00      2484   0.40
jhash_string         0.300925       1.00      2606   1.00
crc                  1.606741       1.00      2474   0.29
md5_string           2.424771       1.00      2644   0.99
djb2                 0.275424       1.15      3821  19.04
string_hash31        0.264806       1.21      4097  22.78
sdbm                 0.371136       2.87     13016  67.54
elf                  0.371279       3.59      9990  79.50
pjw                  0.401172       3.59      9990  79.50
full_name_hash       0.285851      13.09     35174 171.81
kr_hash              0.245068     124.84    468448 549.89
fletcher             0.267664     124.84    468448 549.89
adler32              0.640668     124.84    468448 549.89
xor                  0.220545     213.82    583189 720.85
lastchar             0.194604     409.57   1000000 998.78

Time is seconds.
Ratio is how many probes required to lookup all values versus
  an ideal hash.
Max is longest chain

Reported-by: Octavian Purdila <opurdila@ixiacom.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/dcache.h	2009-10-26 14:58:45.220347300 -0700
+++ b/include/linux/dcache.h	2009-10-26 15:12:15.004160122 -0700
@@ -45,15 +45,28 @@ struct dentry_stat_t {
 };
 extern struct dentry_stat_t dentry_stat;
 
-/* Name hashing routines. Initial hash value */
-/* Hash courtesy of the R5 hash in reiserfs modulo sign bits */
-#define init_name_hash()		0
+/*
+ * Fowler / Noll / Vo (FNV) Hash
+ * see: http://www.isthe.com/chongo/tech/comp/fnv/
+ */
+#ifdef CONFIG_64BIT
+#define FNV_PRIME  1099511628211ull
+#define FNV1_INIT  14695981039346656037ull
+#else
+#define FNV_PRIME  16777619u
+#define FNV1_INIT  2166136261u
+#endif
+
+#define init_name_hash()	FNV1_INIT
 
-/* partial hash update function. Assume roughly 4 bits per character */
+/* partial hash update function. */
 static inline unsigned long
-partial_name_hash(unsigned long c, unsigned long prevhash)
+partial_name_hash(unsigned char c, unsigned long prevhash)
 {
-	return (prevhash + (c << 4) + (c >> 4)) * 11;
+	prevhash ^= c;
+	prevhash *= FNV_PRIME;
+
+	return prevhash;
 }
 
 /*
