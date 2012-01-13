From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 11:57:26 +0100
Message-ID: <1326452246.2272.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120111000040.GA3801@p183.telecom.by>
	 <20120111003611.GA12257@gondor.apana.org.au>
	 <20120112235514.GA5065@p183.telecom.by>
	 <20120113070813.GA20068@gondor.apana.org.au>
	 <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 janvier 2012 =C3=A0 11:41 +0100, Eric Dumazet a =C3=A9cr=
it :

> And a plain kmalloc() is enough, since we fully initialize the array =
a
> bit later.
>=20
> 	for (i =3D 0; i < 16; i++)
> 		LOAD_OP(i, W, input);
> 	for (i =3D 16; i < 80; i++) {
> 		BLEND_OP(i, W);
> 	}


Here is an official patch ;)

[PATCH v3] crypto: sha512 - Fix msg_schedule race

The percpu msg_schedule setup was unsafe as a user in a process
context can be interrupted by a softirq user which would then
scribble over the exact same work area.

Bug reported by Alexey Dobriyan, and diagnosed by Steffen Klassert.

Bug added in commit f9e2bca6c22 (crypto: sha512 - Move message schedule
W[80] to static percpu area)
   =20
Try a dynamic memory allocation, and fallback using a single static
area, guarded by a spinlock.

This removes use of percpu memory.

Reported-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Herbert Xu <herbert@gondor.apana.org.au>
CC: Adrian-Ken Rueegsegger <ken@codelabs.ch>
CC: Steffen Klassert <steffen.klassert@secunet.com>
---
 crypto/sha512_generic.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/crypto/sha512_generic.c b/crypto/sha512_generic.c
index 9ed9f60..b52ef9b 100644
--- a/crypto/sha512_generic.c
+++ b/crypto/sha512_generic.c
@@ -18,10 +18,8 @@
 #include <linux/crypto.h>
 #include <linux/types.h>
 #include <crypto/sha.h>
-#include <linux/percpu.h>
 #include <asm/byteorder.h>
=20
-static DEFINE_PER_CPU(u64[80], msg_schedule);
=20
 static inline u64 Ch(u64 x, u64 y, u64 z)
 {
@@ -87,10 +85,15 @@ static void
 sha512_transform(u64 *state, const u8 *input)
 {
 	u64 a, b, c, d, e, f, g, h, t1, t2;
-
+	static u64 msg_schedule[80];
+	static DEFINE_SPINLOCK(msg_schedule_lock);
 	int i;
-	u64 *W =3D get_cpu_var(msg_schedule);
+	u64 *W =3D kmalloc(sizeof(msg_schedule), GFP_ATOMIC | __GFP_NOWARN);
=20
+	if (!W) {
+		spin_lock_bh(&msg_schedule_lock);
+		W =3D msg_schedule;
+	}
 	/* load the input */
         for (i =3D 0; i < 16; i++)
                 LOAD_OP(i, W, input);
@@ -128,8 +131,11 @@ sha512_transform(u64 *state, const u8 *input)
=20
 	/* erase our data */
 	a =3D b =3D c =3D d =3D e =3D f =3D g =3D h =3D t1 =3D t2 =3D 0;
-	memset(W, 0, sizeof(__get_cpu_var(msg_schedule)));
-	put_cpu_var(msg_schedule);
+	memset(W, 0, sizeof(msg_schedule));
+	if (W =3D=3D msg_schedule)
+		spin_unlock_bh(&msg_schedule_lock);
+	else
+		kfree(W);
 }
=20
 static int
