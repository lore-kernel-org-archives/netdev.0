From: behanw@converseincode.com
Subject: [PATCH] bluetooth: LLVMLinux: Remove VLAIS from bluetooth/amp.c
Date: Fri,  5 Sep 2014 16:03:34 -0700
Message-ID: <1409958214-5651-1-git-send-email-behanw@converseincode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@linux-foundation.org,
	Behan Webster <behanw@converseincode.com>,
	Mark Charlebois <charlebm@gmail.com>,
	=?UTF-8?q?Jan-Simon=20M=C3=B6ller?= <dl9pf@gmx.de>
To: davem@davemloft.net, gustavo@padovan.org, johan.hedberg@gmail.com,
	marcel@holtmann.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Behan Webster <behanw@converseincode.com>

Replaced the use of a Variable Length Array In Struct (VLAIS) with a C9=
9
compliant equivalent. This patch allocates the appropriate amount of me=
mory
using an char array.

The new code can be compiled with both gcc and clang.

struct shash_desc contains a flexible array member member ctx declared =
with
CRYPTO_MINALIGN_ATTR, so sizeof(struct shash_desc) aligns the beginning
of the array declared after struct shash_desc with long long.

No trailing padding is required because it is not a struct type that ca=
n
be used in an array.

The CRYPTO_MINALIGN_ATTR is required so that desc is aligned with long =
long
as would be the case for a struct containing a member with
CRYPTO_MINALIGN_ATTR.

Signed-off-by: Behan Webster <behanw@converseincode.com>
Signed-off-by: Mark Charlebois <charlebm@gmail.com>
Signed-off-by: Jan-Simon M=C3=B6ller <dl9pf@gmx.de>
---
 net/bluetooth/amp.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/bluetooth/amp.c b/net/bluetooth/amp.c
index 016cdb6..2640d78 100644
--- a/net/bluetooth/amp.c
+++ b/net/bluetooth/amp.c
@@ -149,15 +149,14 @@ static int hmac_sha256(u8 *key, u8 ksize, char *p=
laintext, u8 psize, u8 *output)
 	if (ret) {
 		BT_DBG("crypto_ahash_setkey failed: err %d", ret);
 	} else {
-		struct {
-			struct shash_desc shash;
-			char ctx[crypto_shash_descsize(tfm)];
-		} desc;
+		char desc[sizeof(struct shash_desc) +
+			crypto_shash_descsize(tfm)] CRYPTO_MINALIGN_ATTR;
+		struct shash_desc *shash =3D (struct shash_desc *)desc;
=20
-		desc.shash.tfm =3D tfm;
-		desc.shash.flags =3D CRYPTO_TFM_REQ_MAY_SLEEP;
+		shash->tfm =3D tfm;
+		shash->flags =3D CRYPTO_TFM_REQ_MAY_SLEEP;
=20
-		ret =3D crypto_shash_digest(&desc.shash, plaintext, psize,
+		ret =3D crypto_shash_digest(shash, plaintext, psize,
 					  output);
 	}
=20
--=20
1.9.1
