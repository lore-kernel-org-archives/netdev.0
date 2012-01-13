From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 11:35:42 +0100
Message-ID: <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120111000040.GA3801@p183.telecom.by>
	 <20120111003611.GA12257@gondor.apana.org.au>
	 <20120112235514.GA5065@p183.telecom.by>
	 <20120113070813.GA20068@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20120113070813.GA20068@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 janvier 2012 =C3=A0 18:08 +1100, Herbert Xu a =C3=A9crit=
 :
> On Fri, Jan 13, 2012 at 02:55:14AM +0300, Alexey Dobriyan wrote:
> >
> > Herbert, I couldn't come up with a single scenario. :-(
> > But the bug is easy to reproduce.
>=20
> OK, does this patch work for you?
>=20
> commit 31f4e55c09c1170f8b813c14b1299b70f50db414
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Fri Jan 13 18:06:50 2012 +1100
>=20
>     crypto: sha512 - Fix msg_schedule race
>    =20
>     The percpu msg_schedule setup was unsafe as a user in a process
>     context can be interrupted by a softirq user which would then
>     scribble over the exact same work area.  This was discovered by
>     Steffen Klassert.
>    =20
>     This patch based on ideas from Eric Dumazet fixes this by using
>     two independent work areas.
>    =20
>     Reported-by: Alexey Dobriyan <adobriyan@gmail.com>
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>=20

I wonder ...

With 4096 cpus, do we really want to reserve 5242880 bytes of memory fo=
r
this function ?

What about following patch instead ?

(Trying a dynamic memory allocation, and fallback on a single
pre-allocated bloc of memory, shared by all cpus, protected by a
spinlock)

diff --git a/crypto/sha512_generic.c b/crypto/sha512_generic.c
index 9ed9f60..5c80a76 100644
--- a/crypto/sha512_generic.c
+++ b/crypto/sha512_generic.c
@@ -21,7 +21,6 @@
 #include <linux/percpu.h>
 #include <asm/byteorder.h>
=20
-static DEFINE_PER_CPU(u64[80], msg_schedule);
=20
 static inline u64 Ch(u64 x, u64 y, u64 z)
 {
@@ -87,10 +86,16 @@ static void
 sha512_transform(u64 *state, const u8 *input)
 {
 	u64 a, b, c, d, e, f, g, h, t1, t2;
-
+	static u64 msg_schedule[80];
+	static DEFINE_SPINLOCK(msg_schedule_lock);
 	int i;
-	u64 *W =3D get_cpu_var(msg_schedule);
+	u64 *W =3D kzalloc(sizeof(msg_schedule), GFP_ATOMIC | __GFP_NOWARN);
=20
+=09
+	if (!W) {
+		spin_lock_bh(&msg_schedule_lock);
+		W =3D msg_schedule;
+	}
 	/* load the input */
         for (i =3D 0; i < 16; i++)
                 LOAD_OP(i, W, input);
@@ -128,8 +133,11 @@ sha512_transform(u64 *state, const u8 *input)
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
