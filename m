From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] random32: improvements to prandom_bytes
Date: Sat, 23 Aug 2014 17:03:28 +0200
Message-ID: <1408806208-11072-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akinobu.mita@gmail.com, LW@KARO-electronics.de,
	netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21337 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867AbaHWPDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2014 11:03:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses a couple of minor items, mostly addesssing
prandom_bytes(): 1) prandom_bytes{,_state}() should use size_t
for length arguments, 2) We can use put_unaligned() when filling
the array instead of open coding it [ perhaps some archs will
further benefit from their own arch specific implementation when
GCC cannot make up for it ], 3) Fix a typo, 4) Better use unsigned
int as type for getting the arch seed, 5) Make use of
prandom_u32_max() for timer slack.

Regarding the change to put_unaligned(), callers of prandom_bytes()
which internally invoke prandom_bytes_state(), don't bother as
they expect the array to be filled randomly and don't have any
control of the internal state what-so-ever (that's also why we
have periodic reseeding there, etc), so they really don't care.

Now for the direct callers of prandom_bytes_state(), which
are solely located in test cases for MTD devices, that is,
drivers/mtd/tests/{oobtest.c,pagetest.c,subpagetest.c}:

These tests basically fill a test write-vector through
prandom_bytes_state() with an a-priori defined seed each time
and write that to a MTD device. Later on, they set up a read-vector
and read back that blocks from the device. So in the verification
phase, the write-vector is being re-setup [ so same seed and
prandom_bytes_state() called ], and then memcmp()'ed against the
read-vector to check if the data is the same.

Akinobu, Lothar and I also tested this patch and it runs through
the 3 relevant MTD test cases w/o any errors on the nandsim device
(simulator for MTD devs) for x86_64, ppc64, ARM (i.MX28, i.MX53
and i.MX6):

  # modprobe nandsim first_id_byte=3D0x20 second_id_byte=3D0xac \
                     third_id_byte=3D0x00 fourth_id_byte=3D0x15
  # modprobe mtd_oobtest dev=3D0
  # modprobe mtd_pagetest dev=3D0
  # modprobe mtd_subpagetest dev=3D0

We also don't have any users depending directly on a particular
result of the PRNG (except the PRNG self-test itself), and that's
just fine as it e.g. allowed us easily to do things like upgrading
from taus88 to taus113.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Tested-by: Akinobu Mita <akinobu.mita@gmail.com>
Tested-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 v1->v2:
  - resending as per: http://patchwork.ozlabs.org/patch/375418/
  - rebased, retested

 include/linux/random.h |  4 ++--
 lib/random32.c         | 39 ++++++++++++++++++---------------------
 2 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/include/linux/random.h b/include/linux/random.h
index 57fbbff..b05856e 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -26,7 +26,7 @@ unsigned int get_random_int(void);
 unsigned long randomize_range(unsigned long start, unsigned long end, =
unsigned long len);
=20
 u32 prandom_u32(void);
-void prandom_bytes(void *buf, int nbytes);
+void prandom_bytes(void *buf, size_t nbytes);
 void prandom_seed(u32 seed);
 void prandom_reseed_late(void);
=20
@@ -35,7 +35,7 @@ struct rnd_state {
 };
=20
 u32 prandom_u32_state(struct rnd_state *state);
-void prandom_bytes_state(struct rnd_state *state, void *buf, int nbyte=
s);
+void prandom_bytes_state(struct rnd_state *state, void *buf, size_t nb=
ytes);
=20
 /**
  * prandom_u32_max - returns a pseudo-random number in interval [0, ep=
_ro)
diff --git a/lib/random32.c b/lib/random32.c
index c9b6bf3..0bee183 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -37,6 +37,7 @@
 #include <linux/jiffies.h>
 #include <linux/random.h>
 #include <linux/sched.h>
+#include <asm/unaligned.h>
=20
 #ifdef CONFIG_RANDOM32_SELFTEST
 static void __init prandom_state_selftest(void);
@@ -96,27 +97,23 @@ EXPORT_SYMBOL(prandom_u32);
  *	This is used for pseudo-randomness with no outside seeding.
  *	For more random results, use prandom_bytes().
  */
-void prandom_bytes_state(struct rnd_state *state, void *buf, int bytes=
)
+void prandom_bytes_state(struct rnd_state *state, void *buf, size_t by=
tes)
 {
-	unsigned char *p =3D buf;
-	int i;
-
-	for (i =3D 0; i < round_down(bytes, sizeof(u32)); i +=3D sizeof(u32))=
 {
-		u32 random =3D prandom_u32_state(state);
-		int j;
+	u8 *ptr =3D buf;
=20
-		for (j =3D 0; j < sizeof(u32); j++) {
-			p[i + j] =3D random;
-			random >>=3D BITS_PER_BYTE;
-		}
+	while (bytes >=3D sizeof(u32)) {
+		put_unaligned(prandom_u32_state(state), (u32 *) ptr);
+		ptr +=3D sizeof(u32);
+		bytes -=3D sizeof(u32);
 	}
-	if (i < bytes) {
-		u32 random =3D prandom_u32_state(state);
=20
-		for (; i < bytes; i++) {
-			p[i] =3D random;
-			random >>=3D BITS_PER_BYTE;
-		}
+	if (bytes > 0) {
+		u32 rem =3D prandom_u32_state(state);
+		do {
+			*ptr++ =3D (u8) rem;
+			bytes--;
+			rem >>=3D BITS_PER_BYTE;
+		} while (bytes > 0);
 	}
 }
 EXPORT_SYMBOL(prandom_bytes_state);
@@ -126,7 +123,7 @@ EXPORT_SYMBOL(prandom_bytes_state);
  *	@buf: where to copy the pseudo-random bytes to
  *	@bytes: the requested number of bytes
  */
-void prandom_bytes(void *buf, int bytes)
+void prandom_bytes(void *buf, size_t bytes)
 {
 	struct rnd_state *state =3D &get_cpu_var(net_rand_state);
=20
@@ -137,7 +134,7 @@ EXPORT_SYMBOL(prandom_bytes);
=20
 static void prandom_warmup(struct rnd_state *state)
 {
-	/* Calling RNG ten times to satify recurrence condition */
+	/* Calling RNG ten times to satisfy recurrence condition */
 	prandom_u32_state(state);
 	prandom_u32_state(state);
 	prandom_u32_state(state);
@@ -152,7 +149,7 @@ static void prandom_warmup(struct rnd_state *state)
=20
 static u32 __extract_hwseed(void)
 {
-	u32 val =3D 0;
+	unsigned int val =3D 0;
=20
 	(void)(arch_get_random_seed_int(&val) ||
 	       arch_get_random_int(&val));
@@ -228,7 +225,7 @@ static void __prandom_timer(unsigned long dontcare)
 	prandom_seed(entropy);
=20
 	/* reseed every ~60 seconds, in [40 .. 80) interval with slack */
-	expires =3D 40 + (prandom_u32() % 40);
+	expires =3D 40 + prandom_u32_max(40);
 	seed_timer.expires =3D jiffies + msecs_to_jiffies(expires * MSEC_PER_=
SEC);
=20
 	add_timer(&seed_timer);
--=20
1.7.11.7
