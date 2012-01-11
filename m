From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: sha512: make it work, undo percpu message schedule
Date: Wed, 11 Jan 2012 03:00:40 +0300
Message-ID: <20120111000040.GA3801@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit f9e2bca6c22d75a289a349f869701214d63b5060
aka "crypto: sha512 - Move message schedule W[80] to static percpu area"
created global message schedule area.

If sha512_update will ever be entered twice, hilarity ensures.

Probably the easiest way to notice incorrect hashes being calculated is
to run 2 ping floods over AH with hmac(sha512):

	#!/usr/sbin/setkey -f
	flush;
	spdflush;
	add IP1 IP2 ah 25 -A hmac-sha512 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000025;
	add IP2 IP1 ah 52 -A hmac-sha512 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000052;
	spdadd IP1 IP2 any -P out ipsec ah/transport//require;
	spdadd IP2 IP1 any -P in  ipsec ah/transport//require;

XfrmInStateProtoError will start ticking with -EBADMSG being returned
from ah_input(). This never happens with, say, hmac(sha1).

I personally don't understand this changelog entry:

	"The message schedule W (u64[80]) is too big for the stack."

Hash context is dynamically allocated.

W[80] stack usage can be trimmed like in SHA-1, this is for separate patch.

P. S.: If only one ping flood runs, XfrmInStateProtoError will also tick
	but very slowly. I personally can't explain this.

With patch applied (on BOTH sides), XfrmInStateProtoError does not tick
with multiple bidirectional ping flood streams like it doesn't tick
with SHA-1.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 crypto/sha512_generic.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

--- a/crypto/sha512_generic.c
+++ b/crypto/sha512_generic.c
@@ -21,8 +21,6 @@
 #include <linux/percpu.h>
 #include <asm/byteorder.h>
 
-static DEFINE_PER_CPU(u64[80], msg_schedule);
-
 static inline u64 Ch(u64 x, u64 y, u64 z)
 {
         return z ^ (x & (y ^ z));
@@ -89,7 +87,7 @@ sha512_transform(u64 *state, const u8 *input)
 	u64 a, b, c, d, e, f, g, h, t1, t2;
 
 	int i;
-	u64 *W = get_cpu_var(msg_schedule);
+	u64 W[80];
 
 	/* load the input */
         for (i = 0; i < 16; i++)
@@ -128,8 +126,6 @@ sha512_transform(u64 *state, const u8 *input)
 
 	/* erase our data */
 	a = b = c = d = e = f = g = h = t1 = t2 = 0;
-	memset(W, 0, sizeof(__get_cpu_var(msg_schedule)));
-	put_cpu_var(msg_schedule);
 }
 
 static int
