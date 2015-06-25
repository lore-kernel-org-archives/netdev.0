From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 1/2] iproute2: tc/m_pedit.c - remove dead code
Date: Thu, 25 Jun 2015 02:03:02 -0700
Message-ID: <1435222983-14661-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Stephen Hemminger <shemming@brocade.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35013 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945AbbFYJDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 05:03:12 -0400
Received: by iebrt9 with SMTP id rt9so50309541ieb.2
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 02:03:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

The initializers are simply not needed.

These if-blocks are outright dead code, because '0 > unsigned' is alway=
s
false, so only else clause triggers and regardless of which clause trig=
gers
it only updates 'ind' which is later unconditionally written to before
being used anyway.

Otherwise we get errors from clang:

  m_pedit.c:166:8: error: comparison of 0 > unsigned expression is alwa=
ys false [-Werror,-Wtautological-compare]
    if (0 > tkey->off) {
        ~ ^ ~~~~~~~~~
  m_pedit.c:209:8: error: comparison of 0 > unsigned expression is alwa=
ys false [-Werror,-Wtautological-compare]
    if (0 > tkey->off) {
        ~ ^ ~~~~~~~~~
  2 errors generated.

Change-Id: I3c9e9092915088fc56f992e5df736851541a4458
---
 tc/m_pedit.c | 32 ++++++++------------------------
 1 file changed, 8 insertions(+), 24 deletions(-)

diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index dfe9b2ebd6e0..4fdd189d7d9c 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -160,17 +160,9 @@ pack_key32(__u32 retain,struct tc_pedit_sel *sel,s=
truct tc_pedit_key *tkey)
 int
 pack_key16(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *=
tkey)
 {
-	int ind =3D 0, stride =3D 0;
+	int ind, stride;
 	__u32 m[4] =3D {0xFFFF0000,0xFF0000FF,0x0000FFFF};
=20
-	if (0 > tkey->off) {
-		ind =3D tkey->off + 1;
-		if (0 > ind)
-			ind =3D -1*ind;
-	} else {
-		ind =3D tkey->off;
-	}
-
 	if (tkey->val > 0xFFFF || tkey->mask > 0xFFFF) {
 		fprintf(stderr, "pack_key16 bad value\n");
 		return -1;
@@ -178,18 +170,16 @@ pack_key16(__u32 retain,struct tc_pedit_sel *sel,=
struct tc_pedit_key *tkey)
=20
 	ind =3D tkey->off & 3;
=20
-	if (0 > ind || 2 < ind) {
+	if (ind =3D=3D 3) {
 		fprintf(stderr, "pack_key16 bad index value %d\n",ind);
 		return -1;
 	}
=20
 	stride =3D 8 * ind;
 	tkey->val =3D htons(tkey->val);
-	if (stride > 0) {
-		tkey->val <<=3D stride;
-		tkey->mask <<=3D stride;
-		retain <<=3D stride;
-	}
+	tkey->val <<=3D stride;
+	tkey->mask <<=3D stride;
+	retain <<=3D stride;
 	tkey->mask =3D retain|m[ind];
=20
 	tkey->off &=3D ~3;
@@ -203,28 +193,22 @@ pack_key16(__u32 retain,struct tc_pedit_sel *sel,=
struct tc_pedit_key *tkey)
 int
 pack_key8(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *t=
key)
 {
-	int ind =3D 0, stride =3D 0;
+	int ind, stride;
 	__u32 m[4] =3D {0xFFFFFF00,0xFFFF00FF,0xFF00FFFF,0x00FFFFFF};
=20
-	if (0 > tkey->off) {
-		ind =3D tkey->off + 1;
-		if (0 > ind)
-			ind =3D -1*ind;
-	} else {
-		ind =3D tkey->off;
-	}
-
 	if (tkey->val > 0xFF || tkey->mask > 0xFF) {
 		fprintf(stderr, "pack_key8 bad value (val %x mask %x\n", tkey->val, =
tkey->mask);
 		return -1;
 	}
=20
 	ind =3D tkey->off & 3;
+
 	stride =3D 8 * ind;
 	tkey->val <<=3D stride;
 	tkey->mask <<=3D stride;
 	retain <<=3D stride;
 	tkey->mask =3D retain|m[ind];
+
 	tkey->off &=3D ~3;
=20
 	if (pedit_debug)
--=20
2.4.3.573.g4eafbef
