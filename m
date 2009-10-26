From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Mon, 26 Oct 2009 06:28:34 +0100
Message-ID: <4AE53382.8020308@gmail.com>
References: <200910252158.53921.opurdila@ixiacom.com> <4AE4C1FA.7000002@gmail.com> <200910252355.32640.opurdila@ixiacom.com> <20091025224153.GB20987@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34497 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754682AbZJZF2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 01:28:44 -0400
In-Reply-To: <20091025224153.GB20987@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen Paul Pfeifer a =E9crit :
> * Octavian Purdila | 2009-10-25 23:55:32 [+0200]:
>=20
>> My results shows that new17 is better or very close to jhash2. And I=
 think its=20
>> lighter then jhash too.
>=20
> If new17 is very close to jhash/jhash2 then the cycles comes into pla=
y.
> Anyway, there is already a very potent hash interface in form of jhas=
h{,2}.
>=20
> +1 for jhash2
>=20

In fact, new10 should be the 'perfect' hash for the "eth%d"
netdev use, not jhash (way more expensive in cpu cycles BTW)

Most linux machines in the world have less than 10 interfaces, jhash
would be really overkill.


Thanks


[PATCH net-next-2.6] netdev: better dev_name_hash

Octavian Purdila pointed out that the current dev_name_hash is=20
not very good at spreading entries when a large number of interfaces
of the same type (e.g. ethXXXXX) are used.

Here is hash distribution of 16000 "dummy%d" devices :

full_name_hash[] =3D {
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 6, 0, 0, 0, 0, 56,
0, 0, 0, 374, 0, 0, 562, 0, 0, 0, 5, 0, 0, 0, 0, 57,
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 6, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 5, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 6, 0, 0, 0, 0, 57,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 5, 0, 0, 0, 0, 56,
0, 0, 0, 376, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 5, 1, 0, 0, 0, 57,
0, 0, 0, 374, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 56,
0, 0, 0, 376, 0, 0, 562, 0, 0, 0, 6, 0, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 5, 0, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 5, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 57,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 56,
};

Instead of using full_name_hash(), netdev should use a hash suited
to its typical uses, which are a common substring followed by a base 10=
 number.

new hash distribution :

string_hash10[] =3D {
62, 63, 61, 60, 61, 63, 61, 62, 64, 62, 61, 62, 62, 60, 60, 61,
61, 59, 60, 63, 61, 60, 62, 63, 62, 60, 60, 60, 59, 60, 61, 59,
58, 61, 61, 60, 60, 61, 61, 58, 58, 59, 58, 57, 58, 59, 58, 59,
60, 60, 59, 61, 63, 61, 60, 60, 62, 61, 60, 61, 61, 60, 61, 62,
61, 62, 63, 63, 62, 62, 64, 64, 61, 62, 63, 62, 62, 63, 64, 64,
64, 64, 64, 62, 64, 65, 62, 62, 63, 63, 62, 62, 63, 64, 62, 62,
64, 62, 63, 65, 64, 63, 63, 64, 64, 63, 63, 67, 65, 64, 66, 66,
66, 66, 66, 65, 64, 63, 65, 63, 63, 66, 66, 64, 64, 65, 65, 64,
63, 66, 64, 64, 65, 65, 63, 64, 65, 63, 62, 61, 64, 61, 61, 63,
65, 64, 63, 64, 62, 62, 62, 64, 61, 61, 63, 63, 63, 63, 65, 64,
62, 61, 63, 61, 61, 62, 61, 61, 62, 63, 62, 62, 63, 66, 62, 61,
62, 62, 62, 61, 62, 61, 61, 61, 64, 62, 63, 65, 63, 63, 63, 64,
62, 60, 60, 63, 61, 61, 63, 62, 63, 65, 65, 63, 62, 63, 65, 62,
62, 64, 63, 63, 65, 66, 65, 64, 64, 65, 63, 64, 66, 63, 63, 65,
66, 64, 63, 64, 66, 64, 63, 65, 63, 64, 66, 66, 64, 63, 64, 64,
62, 62, 64, 61, 60, 62, 63, 62, 61, 62, 63, 61, 62, 63, 60, 59,
};=20


Based on a previous patch from Octavian Purdila

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fa88dcd..e192068 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -196,9 +196,22 @@ EXPORT_SYMBOL(dev_base_lock);
 #define NETDEV_HASHBITS	8
 #define NETDEV_HASHENTRIES (1 << NETDEV_HASHBITS)
=20
+/*
+ * Because of "eth%d" patterns, following hash is giving good distribu=
tion
+ */
+static inline unsigned int string_hash10(const char *name, unsigned in=
t len)
+{
+	unsigned int i, hash =3D 0;
+
+	for (i =3D 0; i < len; i++)
+		hash =3D hash * 10 + name[i];
+
+	return hash;
+}
+
 static inline struct hlist_head *dev_name_hash(struct net *net, const =
char *name)
 {
-	unsigned hash =3D full_name_hash(name, strnlen(name, IFNAMSIZ));
+	unsigned hash =3D string_hash10(name, strnlen(name, IFNAMSIZ));
 	return &net->dev_name_head[hash & ((1 << NETDEV_HASHBITS) - 1)];
 }
=20
