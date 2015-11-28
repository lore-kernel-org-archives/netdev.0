From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/5] ss: review is_ephemeral()
Date: Sat, 28 Nov 2015 01:00:03 +0100
Message-ID: <1448668805-28074-4-git-send-email-phil@nwl.cc>
References: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:60338 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbbK1AAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Nov 2015 19:00:44 -0500
In-Reply-To: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to keep static port boundaries global, they are not used
directly. Keeping them local also allows to safely reduce their names to
the minimum. Assign hardcoded fallback values also if fscanf() fails.
Get rid of unnecessary braces around return parameter.

Instead of more or less duplicating is_ephemeral() in run_ssfilter(),
simply call the function instead.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 32 ++++++++++----------------------
 1 file changed, 10 insertions(+), 22 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 4988d34e18c78..7928573285e4e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -904,8 +904,6 @@ static void init_service_resolver(void)
 	pclose(fp);
 }
 
-static int ip_local_port_min, ip_local_port_max;
-
 /* Even do not try default linux ephemeral port ranges:
  * default /etc/services contains so much of useless crap
  * wouldbe "allocated" to this area that resolution
@@ -914,19 +912,18 @@ static int ip_local_port_min, ip_local_port_max;
  */
 static int is_ephemeral(int port)
 {
-	if (!ip_local_port_min) {
+	static int min = 0, max = 0;
+
+	if (!min) {
 		FILE *f = ephemeral_ports_open();
-		if (f) {
-			fscanf(f, "%d %d",
-			       &ip_local_port_min, &ip_local_port_max);
-			fclose(f);
-		} else {
-			ip_local_port_min = 1024;
-			ip_local_port_max = 4999;
+		if (!f || fscanf(f, "%d %d", &min, &max) < 2) {
+			min = 1024;
+			max = 4999;
 		}
+		if (f)
+			fclose(f);
 	}
-
-	return (port >= ip_local_port_min && port<= ip_local_port_max);
+	return port >= min && port <= max;
 }
 
 
@@ -1081,8 +1078,6 @@ static int run_ssfilter(struct ssfilter *f, struct sockstat *s)
 	switch (f->type) {
 		case SSF_S_AUTO:
 	{
-                static int low, high=65535;
-
 		if (s->local.family == AF_UNIX) {
 			char *p;
 			memcpy(&p, s->local.data, sizeof(p));
@@ -1094,14 +1089,7 @@ static int run_ssfilter(struct ssfilter *f, struct sockstat *s)
 		if (s->local.family == AF_NETLINK)
 			return s->lport < 0;
 
-                if (!low) {
-			FILE *fp = ephemeral_ports_open();
-			if (fp) {
-				fscanf(fp, "%d%d", &low, &high);
-				fclose(fp);
-			}
-		}
-		return s->lport >= low && s->lport <= high;
+		return is_ephemeral(s->lport);
 	}
 		case SSF_DCOND:
 	{
-- 
2.5.0
