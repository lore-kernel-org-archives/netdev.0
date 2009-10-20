From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH TESTING] Add support for configuring route entry features
Date: Tue, 20 Oct 2009 18:22:01 +0200
Message-ID: <1256055721-22065-1-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ori@comsleep.com, ilpo.jarvinen@helsinki.fi,
	Gilad Ben-Yossef <gilad@codefidence.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:54961 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbZJTQV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 12:21:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed to test my previous per route entry TCP options patch.

=46eature display is still numeric, so this is not the final version ye=
t.

To use: add "features nows nots nosack nodsack to a route entry.

Based loosley on original patch by Ilpo J=C3=A4rvinen.

Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>

CC: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

---
 include/linux/rtnetlink.h |   10 ++++++----
 ip/iproute.c              |   45 +++++++++++++++++++++++++++++++++++++=
+++++++-
 2 files changed, 50 insertions(+), 5 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 63d1c69..35964d4 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -376,10 +376,12 @@ enum
=20
 #define RTAX_MAX (__RTAX_MAX - 1)
=20
-#define RTAX_FEATURE_ECN	0x00000001
-#define RTAX_FEATURE_SACK	0x00000002
-#define RTAX_FEATURE_TIMESTAMP	0x00000004
-#define RTAX_FEATURE_ALLFRAG	0x00000008
+#define RTAX_FEATURE_ECN        0x00000001
+#define RTAX_FEATURE_NO_SACK    0x00000002
+#define RTAX_FEATURE_NO_TSTAMP  0x00000004
+#define RTAX_FEATURE_ALLFRAG    0x00000008
+#define RTAX_FEATURE_NO_WSCALE  0x00000010
+#define RTAX_FEATURE_NO_DSACK   0x00000020
=20
 struct rta_session
 {
diff --git a/ip/iproute.c b/ip/iproute.c
index aeea93d..9dcc0e0 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -54,6 +54,22 @@ static const char *mx_names[RTAX_MAX+1] =3D {
 	[RTAX_FEATURES] =3D "features",
 	[RTAX_RTO_MIN]	=3D "rto_min",
 };
+
+struct valname {
+	unsigned int	val;
+	const char	*name;
+};
+
+static const struct valname features[] =3D {
+	{ RTAX_FEATURE_NO_SACK, "nosack" },
+	{ RTAX_FEATURE_NO_TSTAMP, "notimestamps" },
+	{ RTAX_FEATURE_NO_TSTAMP, "nots" },
+	{ RTAX_FEATURE_NO_WSCALE, "nowindowscale" },
+	{ RTAX_FEATURE_NO_WSCALE, "nows" },
+	{ RTAX_FEATURE_NO_DSACK, "nodsack" },
+=09
+};
+
 static void usage(void) __attribute__((noreturn));
=20
 static void usage(void)
@@ -75,7 +91,8 @@ static void usage(void)
 	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ] [reordering =
NUMBER ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcw=
nd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ sr=
c ADDRESS ]\n");
-	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ] \n")=
;
+	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ]\n");=
=20
+	fprintf(stderr, "           [ features DISABLED_FEATURES ]\n");
 	fprintf(stderr, "TYPE :=3D [ unicast | local | broadcast | multicast =
| throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]=
\n");
 	fprintf(stderr, "TABLE_ID :=3D [ local | main | default | all | NUMBE=
R ]\n");
@@ -85,6 +102,8 @@ static void usage(void)
 	fprintf(stderr, "NHFLAGS :=3D [ onlink | pervasive ]\n");
 	fprintf(stderr, "RTPROTO :=3D [ kernel | boot | static | NUMBER ]\n")=
;
 	fprintf(stderr, "TIME :=3D NUMBER[s|ms|us|ns|j]\n");
+	fprintf(stderr, "DISABLED_FEATURES :=3D sack | timestamps | ts | ecn =
| frto |\n");
+	fprintf(stderr, "                     [ DISABLED_FEATURES ]\n");
 	exit(-1);
 }
=20
@@ -877,6 +896,30 @@ int iproute_modify(int cmd, unsigned flags, int ar=
gc, char **argv)
 			if (get_unsigned(&win, *argv, 0))
 				invarg("\"ssthresh\" value is invalid\n", *argv);
 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_SSTHRESH, win);
+		} else if (matches(*argv, "features") =3D=3D 0) {
+			int j;
+			unsigned int f =3D 0;
+			NEXT_ARG();
+			while (1) {
+				for (j =3D 0; j < ARRAY_SIZE(features); j++) {
+					if (strcmp(*argv, features[j].name) =3D=3D 0) {
+						f |=3D features[j].val;
+						if (!NEXT_ARG_OK())
+							goto feat_out;
+						NEXT_ARG();
+						break;
+					}
+				}
+				if (j =3D=3D ARRAY_SIZE(features)) {
+					if (f)
+						PREV_ARG();
+					break;
+				}
+			}
+feat_out:
+			if (!f)
+				invarg("\"features\" list is invalid\n", *argv);
+			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_FEATURES, f);
 		} else if (matches(*argv, "realms") =3D=3D 0) {
 			__u32 realm;
 			NEXT_ARG();
--=20
1.5.6.3

