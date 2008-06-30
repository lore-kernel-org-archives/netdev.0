From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [Fwd: Bug#488430: iproute: lnstat causes segmentation fault]
Date: Mon, 30 Jun 2008 20:20:41 +0200
Message-ID: <1214850041.16171.53.camel@amd64.fatal.se>
References: <1214733409.16171.43.camel@amd64.fatal.se>
	 <20080630103625.7e718a93@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew France <andrew@avito.co.uk>,
	488430@bugs.debian.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:33809 "EHLO
	amd64.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761566AbYF3SSp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 14:18:45 -0400
In-Reply-To: <20080630103625.7e718a93@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On m=C3=A5n, 2008-06-30 at 10:36 -0700, Stephen Hemminger wrote:
> The problem is that MAX_FIELDS is 64, but lnstat is finding 71 fields=
=2E
> This causes a array out of range problem.
>=20
> Just bump MAX_FIELDS to 128

Oh, stupid me to not catch that when I was thinking it used un-allocate=
d
memory and all...
Here's a patch that prevents the overflow and throws a warning instead.


diff --git a/misc/lnstat.c b/misc/lnstat.c
index b56598a..5a0c349 100644
--- a/misc/lnstat.c
+++ b/misc/lnstat.c
@@ -121,6 +121,10 @@ static int map_field_params(struct lnstat_file *ln=
stat_files,
 				if (!fps->params[j].print.width)
 					fps->params[j].print.width =3D
 							FIELD_WIDTH_DEFAULT;
+				if (j >=3D MAX_FIELDS) {
+					fprintf(stderr, "WARN: MAX_FIELDS (%d) reached, truncating input =
data.\n", MAX_FIELDS);
+					break;
+				}
 				j++;
 			}
 		}
@@ -269,8 +273,10 @@ int main(int argc, char **argv)
 				for (tok =3D strtok(tmp, ",");
 				     tok;
 				     tok =3D strtok(NULL, ",")) {
-					if (fp.num >=3D MAX_FIELDS)
+					if (fp.num >=3D MAX_FIELDS) {
+						fprintf(stderr, "WARN: MAX_FIELDS (%d) reached, truncating given=
 keys.\n", MAX_FIELDS);
 						break;
+					}
 					fp.params[fp.num++].name =3D tok;
 				}
 				break;

--=20
Regards,
Andreas Henriksson
