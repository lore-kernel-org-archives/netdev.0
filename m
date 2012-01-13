From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 18:08:13 +1100
Message-ID: <20120113070813.GA20068@gondor.apana.org.au>
References: <20120111000040.GA3801@p183.telecom.by> <20120111003611.GA12257@gondor.apana.org.au> <20120112235514.GA5065@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120112235514.GA5065@p183.telecom.by>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 13, 2012 at 02:55:14AM +0300, Alexey Dobriyan wrote:
>
> Herbert, I couldn't come up with a single scenario. :-(
> But the bug is easy to reproduce.

OK, does this patch work for you?

commit 31f4e55c09c1170f8b813c14b1299b70f50db414
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Jan 13 18:06:50 2012 +1100

    crypto: sha512 - Fix msg_schedule race
    
    The percpu msg_schedule setup was unsafe as a user in a process
    context can be interrupted by a softirq user which would then
    scribble over the exact same work area.  This was discovered by
    Steffen Klassert.
    
    This patch based on ideas from Eric Dumazet fixes this by using
    two independent work areas.
    
    Reported-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/crypto/sha512_generic.c b/crypto/sha512_generic.c
index 9ed9f60..a49c457 100644
--- a/crypto/sha512_generic.c
+++ b/crypto/sha512_generic.c
@@ -11,6 +11,7 @@
  *
  */
 #include <crypto/internal/hash.h>
+#include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mm.h>
@@ -21,7 +22,9 @@
 #include <linux/percpu.h>
 #include <asm/byteorder.h>
 
-static DEFINE_PER_CPU(u64[80], msg_schedule);
+#define SHA512_SCHEDULE_SIZE 80
+
+static DEFINE_PER_CPU(u64[SHA512_SCHEDULE_SIZE * 2], msg_schedule);
 
 static inline u64 Ch(u64 x, u64 y, u64 z)
 {
@@ -89,7 +92,8 @@ sha512_transform(u64 *state, const u8 *input)
 	u64 a, b, c, d, e, f, g, h, t1, t2;
 
 	int i;
-	u64 *W = get_cpu_var(msg_schedule);
+	u64 *W = get_cpu_var(msg_schedule) +
+		 SHA512_SCHEDULE_SIZE * !!in_interrupt();
 
 	/* load the input */
         for (i = 0; i < 16; i++)
@@ -128,7 +132,7 @@ sha512_transform(u64 *state, const u8 *input)
 
 	/* erase our data */
 	a = b = c = d = e = f = g = h = t1 = t2 = 0;
-	memset(W, 0, sizeof(__get_cpu_var(msg_schedule)));
+	memset(W, 0, SHA512_SCHEDULE_SIZE * sizeof(*W));
 	put_cpu_var(msg_schedule);
 }
 
Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
