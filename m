From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH iproute2 v2 1/2] ss: Fix compiler errors of unused return-values
Date: Mon, 22 Jul 2013 19:24:16 +0200
Message-ID: <1374513857-6096-2-git-send-email-christoph.paasch@uclouvain.be>
References: <1374513857-6096-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:42596 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347Ab3GVRYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 13:24:33 -0400
In-Reply-To: <1374513857-6096-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many errors when compiling with gcc 4.7.3 about unused return-values
upon the calls to fgets and fscanf:

ss.c: In function =E2=80=98user_ent_hash_build=E2=80=99:
ss.c:305:12: error: ignoring return value of =E2=80=98fscanf=E2=80=99, =
declared with attribute warn_unused_result [-Werror=3Dunused-result]
ss.c: In function =E2=80=98get_slabstat=E2=80=99:
ss.c:387:7: error: ignoring return value of =E2=80=98fgets=E2=80=99, de=
clared with attribute warn_unused_result [-Werror=3Dunused-result]
ss.c: In function =E2=80=98init_service_resolver=E2=80=99:
ss.c:511:8: error: ignoring return value of =E2=80=98fgets=E2=80=99, de=
clared with attribute warn_unused_result [-Werror=3Dunused-result]
ss.c: In function =E2=80=98run_ssfilter=E2=80=99:
ss.c:728:11: error: ignoring return value of =E2=80=98fscanf=E2=80=99, =
declared with attribute warn_unused_result [-Werror=3Dunused-result]
ss.c: In function =E2=80=98is_ephemeral=E2=80=99:
ss.c:550:10: error: ignoring return value of =E2=80=98fscanf=E2=80=99, =
declared with attribute warn_unused_result [-Werror=3Dunused-result]
ss.c: In function =E2=80=98netlink_show=E2=80=99:
ss.c:2836:7: error: ignoring return value of =E2=80=98fgets=E2=80=99, d=
eclared with attribute warn_unused_result [-Werror=3Dunused-result]
ss.c: In function =E2=80=98packet_show=E2=80=99:
ss.c:2630:7: error: ignoring return value of =E2=80=98fgets=E2=80=99, d=
eclared with attribute warn_unused_result [-Werror=3Dunused-result]
ss.c: In function =E2=80=98unix_show=E2=80=99:
ss.c:2364:7: error: ignoring return value of =E2=80=98fgets=E2=80=99, d=
eclared with attribute warn_unused_result [-Werror=3Dunused-result]
cc1: all warnings being treated as errors
make[1]: *** [ss.o] Error 1
make[1]: Leaving directory `/home/christoph/workspace/linux/iproute2/mi=
sc'
make: *** [all] Error 2

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---

Notes:
    v2: Add an error-message if fscanf fails, as suggested by Stephen H=
emminger

 misc/ss.c | 33 ++++++++++++++++++++++++---------
 1 file changed, 24 insertions(+), 9 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index c0369f1..be86223 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -302,7 +302,8 @@ static void user_ent_hash_build(void)
=20
 				snprintf(tmp, sizeof(tmp), "%s/%d/stat", root, pid);
 				if ((fp =3D fopen(tmp, "r")) !=3D NULL) {
-					fscanf(fp, "%*d (%[^)])", process);
+					if (fscanf(fp, "%*d (%[^)])", process) =3D=3D EOF)
+						perror("Could not parse process:");
 					fclose(fp);
 				}
 			}
@@ -384,7 +385,10 @@ static int get_slabstat(struct slabstat *s)
=20
 	cnt =3D sizeof(*s)/sizeof(int);
=20
-	fgets(buf, sizeof(buf), fp);
+	if (!fgets(buf, sizeof(buf), fp)) {
+		fclose(fp);
+		return -1;
+	}
 	while(fgets(buf, sizeof(buf), fp) !=3D NULL) {
 		int i;
 		for (i=3D0; i<sizeof(slabstat_ids)/sizeof(slabstat_ids[0]); i++) {
@@ -508,7 +512,10 @@ static void init_service_resolver(void)
 	char buf[128];
 	FILE *fp =3D popen("/usr/sbin/rpcinfo -p 2>/dev/null", "r");
 	if (fp) {
-		fgets(buf, sizeof(buf), fp);
+		if (!fgets(buf, sizeof(buf), fp)) {
+			pclose(fp);
+			return;
+		}
 		while (fgets(buf, sizeof(buf), fp) !=3D NULL) {
 			unsigned int progn, port;
 			char proto[128], prog[128];
@@ -547,8 +554,8 @@ static int is_ephemeral(int port)
 	if (!ip_local_port_min) {
 		FILE *f =3D ephemeral_ports_open();
 		if (f) {
-			fscanf(f, "%d %d",
-			       &ip_local_port_min, &ip_local_port_max);
+			if (fscanf(f, "%d %d", &ip_local_port_min, &ip_local_port_max) =3D=3D=
 EOF)
+				perror("Could not parse port-range:");
 			fclose(f);
 		} else {
 			ip_local_port_min =3D 1024;
@@ -725,7 +732,8 @@ static int run_ssfilter(struct ssfilter *f, struct =
tcpstat *s)
                 if (!low) {
 			FILE *fp =3D ephemeral_ports_open();
 			if (fp) {
-				fscanf(fp, "%d%d", &low, &high);
+				if (fscanf(fp, "%d%d", &low, &high) =3D=3D EOF)
+					perror("Could not parse port-range:");
 				fclose(fp);
 			}
 		}
@@ -2361,7 +2369,10 @@ static int unix_show(struct filter *f)
=20
 	if ((fp =3D net_unix_open()) =3D=3D NULL)
 		return -1;
-	fgets(buf, sizeof(buf)-1, fp);
+	if (!fgets(buf, sizeof(buf)-1, fp)) {
+		fclose(fp);
+		return -1;
+	}
=20
 	if (memcmp(buf, "Peer", 4) =3D=3D 0)
 		newformat =3D 1;
@@ -2627,7 +2638,10 @@ static int packet_show(struct filter *f)
=20
 	if ((fp =3D net_packet_open()) =3D=3D NULL)
 		return -1;
-	fgets(buf, sizeof(buf)-1, fp);
+	if (!fgets(buf, sizeof(buf)-1, fp)) {
+		fclose(fp);
+		return -1;
+	}
=20
 	while (fgets(buf, sizeof(buf)-1, fp)) {
 		sscanf(buf, "%llx %*d %d %x %d %d %u %u %u",
@@ -2833,7 +2847,8 @@ static int netlink_show(struct filter *f)
=20
 	if ((fp =3D net_netlink_open()) =3D=3D NULL)
 		return -1;
-	fgets(buf, sizeof(buf)-1, fp);
+	if (!fgets(buf, sizeof(buf)-1, fp))
+		return -1;
=20
 	while (fgets(buf, sizeof(buf)-1, fp)) {
 		sscanf(buf, "%llx %d %d %x %d %d %llx %d",
--=20
1.8.1.2
