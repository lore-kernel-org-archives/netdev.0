From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v6 5/5] syncookies: use SipHash in place of SHA1
Date: Fri, 16 Dec 2016 04:03:28 +0100
Message-ID: <20161216030328.11602-6-Jason@zx2c4.com>
References: <20161215203003.31989-1-Jason@zx2c4.com>
 <20161216030328.11602-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	linux-crypto@vger.kernel.org,
	David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	George Spelvin <linux@sciencehorizons.net>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	ak@linux.intel.com,
	davem@davemloft.net,
	luto@amacapital.net
Return-path: <kernel-hardening-return-5624-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161216030328.11602-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

SHA1 is slower and less secure than SipHash, and so replacing syncookie
generation with SipHash makes natural sense. Some BSDs have been doing
this for several years in fact.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 net/ipv4/syncookies.c | 20 ++++----------------
 net/ipv6/syncookies.c | 37 ++++++++++++++++---------------------
 2 files changed, 20 insertions(+), 37 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 3e88467d70ee..03bb068f8888 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -13,13 +13,13 @@
 #include <linux/tcp.h>
 #include <linux/slab.h>
 #include <linux/random.h>
-#include <linux/cryptohash.h>
+#include <linux/siphash.h>
 #include <linux/kernel.h>
 #include <linux/export.h>
 #include <net/tcp.h>
 #include <net/route.h>
 
-static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
+static siphash_key_t syncookie_secret[2] __read_mostly;
 
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
@@ -48,24 +48,12 @@ static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
 #define TSBITS	6
 #define TSMASK	(((__u32)1 << TSBITS) - 1)
 
-static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS], ipv4_cookie_scratch);
-
 static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
 {
-	__u32 *tmp;
-
 	net_get_random_once(syncookie_secret, sizeof(syncookie_secret));
-
-	tmp  = this_cpu_ptr(ipv4_cookie_scratch);
-	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
-	tmp[0] = (__force u32)saddr;
-	tmp[1] = (__force u32)daddr;
-	tmp[2] = ((__force u32)sport << 16) + (__force u32)dport;
-	tmp[3] = count;
-	sha_transform(tmp + 16, (__u8 *)tmp, tmp + 16 + 5);
-
-	return tmp[17];
+	return siphash_4u32(saddr, daddr, (u32)sport << 16 | dport, count,
+			    syncookie_secret[c]);
 }
 
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index a4d49760bf43..04d19e89a3e0 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -16,7 +16,7 @@
 
 #include <linux/tcp.h>
 #include <linux/random.h>
-#include <linux/cryptohash.h>
+#include <linux/siphash.h>
 #include <linux/kernel.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
@@ -24,7 +24,7 @@
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
-static u32 syncookie6_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
+static siphash_key_t syncookie6_secret[2] __read_mostly;
 
 /* RFC 2460, Section 8.3:
  * [ipv6 tcp] MSS must be computed as the maximum packet size minus 60 [..]
@@ -41,30 +41,25 @@ static __u16 const msstab[] = {
 	9000 - 60,
 };
 
-static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS], ipv6_cookie_scratch);
-
 static u32 cookie_hash(const struct in6_addr *saddr, const struct in6_addr *daddr,
 		       __be16 sport, __be16 dport, u32 count, int c)
 {
-	__u32 *tmp;
+	const struct {
+		struct in6_addr saddr;
+		struct in6_addr daddr;
+		u32 count;
+		u16 sport;
+		u16 dport;
+	} __aligned(SIPHASH_ALIGNMENT) combined = {
+		.saddr = *saddr,
+		.daddr = *daddr,
+		.count = count,
+		.sport = sport,
+		.dport = dport
+	};
 
 	net_get_random_once(syncookie6_secret, sizeof(syncookie6_secret));
-
-	tmp  = this_cpu_ptr(ipv6_cookie_scratch);
-
-	/*
-	 * we have 320 bits of information to hash, copy in the remaining
-	 * 192 bits required for sha_transform, from the syncookie6_secret
-	 * and overwrite the digest with the secret
-	 */
-	memcpy(tmp + 10, syncookie6_secret[c], 44);
-	memcpy(tmp, saddr, 16);
-	memcpy(tmp + 4, daddr, 16);
-	tmp[8] = ((__force u32)sport << 16) + (__force u32)dport;
-	tmp[9] = count;
-	sha_transform(tmp + 16, (__u8 *)tmp, tmp + 16 + 5);
-
-	return tmp[17];
+	return siphash(&combined, sizeof(combined), syncookie6_secret[c]);
 }
 
 static __u32 secure_tcp_syn_cookie(const struct in6_addr *saddr,
-- 
2.11.0
