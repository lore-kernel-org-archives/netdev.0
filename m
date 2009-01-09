From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] ethtool: Support arbitrary speeds
Date: Fri, 09 Jan 2009 13:16:14 +0000
Message-ID: <1231506974.3006.18.camel@achroite>
References: <200901080203.SAA19103@tardy.cup.hp.com>
	 <1231384446.2677.32.camel@hashbaz.i.decadent.org.uk>
	 <49656F01.3090603@pobox.com>  <49664FFD.1010608@hp.com>
	 <1231442701.3893.4.camel@achroite>  <496658EB.1080206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:39232 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753003AbZAINQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 08:16:25 -0500
In-Reply-To: <496658EB.1080206@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The speed and speed_hi fields of struct ethtool_cmd together represent
a value in units of Mbit/s.  The valid speed settings are hardware-
dependent and should be checked by the driver.  Remove our validation
and allow arbitrary positive values.  Continue to report 0 and -1 as
"Unknown!" since some drivers will report these invalid values when
the link is down.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
On Thu, 2009-01-08 at 11:50 -0800, Rick Jones wrote:
> >=20
> > I think 0, (u32)(-1) and (u16)(-1) may have to be special-cased as
> > unknown, but everything else can be treated as a number of Mbit/s. =
 I
> > don't know what a driver should do about an interface that really r=
uns
> > at 65.535 Gbit/s though...
>=20
> Something along these lines then? (assuming my mailer doesn't fubar t=
his
> :( - I normally send matches via mailx)

That's kind of incomplete.  Here's my attempt.

In a quick test I found that the tg3 driver *doesn't* validate the spee=
d
setting if autonegotiation is off, and will accept and report back e.g.
99.  But this patch doesn't create a new problem as you could already
set it to the unsupported speeds of 2500 and 10000.

Ben.
=EF=BB=BF
 ethtool.8 |    4 ++--
 ethtool.c |   42 ++++++++++--------------------------------
 2 files changed, 12 insertions(+), 34 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index 1beb387..1504a23 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -183,7 +183,7 @@ ethtool \- Display or change ethernet card settings
=20
 .B ethtool \-s
 .I ethX
-.B4 speed 10 100 1000 2500 10000
+.BI speed \ N
 .B2 duplex half full
 .B4 port tp aui bnc mii fibre
 .B2 autoneg on off
@@ -343,7 +343,7 @@ All following options only apply if
 .B \-s
 was specified.
 .TP
-.A4 speed 10 100 1000 2500 10000
+.BI speed \ N
 Set speed in Mb/s.
 .B ethtool
 with just the device name as an argument will show you the supported d=
evice speeds.
diff --git a/ethtool.c b/ethtool.c
index a7c02d0..bcc865e 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -107,7 +107,7 @@ static struct option {
     char *opthelp;
 } args[] =3D {
     { "-s", "--change", MODE_SSET, "Change generic options",
-		"		[ speed 10|100|1000|2500|10000 ]\n"
+		"		[ speed %%d ]\n"
 		"		[ duplex half|full ]\n"
 		"		[ port tp|aui|bnc|mii|fibre ]\n"
 		"		[ autoneg on|off ]\n"
@@ -608,17 +608,8 @@ static void parse_cmdline(int argc, char **argp)
 				i +=3D 1;
 				if (i >=3D argc)
 					show_usage(1);
-				if (!strcmp(argp[i], "10"))
-					speed_wanted =3D SPEED_10;
-				else if (!strcmp(argp[i], "100"))
-					speed_wanted =3D SPEED_100;
-				else if (!strcmp(argp[i], "1000"))
-					speed_wanted =3D SPEED_1000;
-				else if (!strcmp(argp[i], "2500"))
-					speed_wanted =3D SPEED_2500;
-				else if (!strcmp(argp[i], "10000"))
-					speed_wanted =3D SPEED_10000;
-				else
+				speed_wanted =3D strtol(argp[i], NULL, 10);
+				if (speed_wanted <=3D 0)
 					show_usage(1);
 				break;
 			} else if (!strcmp(argp[i], "duplex")) {
@@ -893,30 +884,17 @@ static void dump_advertised(struct ethtool_cmd *e=
p)
=20
 static int dump_ecmd(struct ethtool_cmd *ep)
 {
+	u32 speed;
+
 	dump_supported(ep);
 	dump_advertised(ep);
=20
 	fprintf(stdout, "	Speed: ");
-	switch (ethtool_cmd_speed(ep)) {
-	case SPEED_10:
-		fprintf(stdout, "10Mb/s\n");
-		break;
-	case SPEED_100:
-		fprintf(stdout, "100Mb/s\n");
-		break;
-	case SPEED_1000:
-		fprintf(stdout, "1000Mb/s\n");
-		break;
-	case SPEED_2500:
-		fprintf(stdout, "2500Mb/s\n");
-		break;
-	case SPEED_10000:
-		fprintf(stdout, "10000Mb/s\n");
-		break;
-	default:
-		fprintf(stdout, "Unknown! (%i)\n", ethtool_cmd_speed(ep));
-		break;
-	};
+	speed =3D ethtool_cmd_speed(ep);
+	if (speed =3D=3D 0 || speed =3D=3D (u16)(-1) || speed =3D=3D (u32)(-1=
))
+		fprintf(stdout, "Unknown!\n");
+	else
+		fprintf(stdout, "%uMb/s\n", speed);
=20
 	fprintf(stdout, "	Duplex: ");
 	switch (ep->duplex) {

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

