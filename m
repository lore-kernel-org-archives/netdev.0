From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ifstat, nstat: fix daemon mode
Date: Wed,  2 Mar 2016 16:56:27 +0100
Message-ID: <1456934187-4843-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53102 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756069AbcCBP4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 10:56:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the relevant code (and it's bugs) is identical in both files, fix
them in one go. This patch fixes multiple issues:

* Using 'int' for the 'tdiff' variable does not suffice on 64bit
  systems, the assigned initial time difference makes it wrap and
  contain a negative value afterwards. Instead use the more appropriate
  'time_t' type.

* As far as I understood the code, poll() is supposed to time out just
  at the right time to trigger update_db() in the configured interval.
  Therefore it's timeout must be set to the desired interval *minus* the
  time that has already passed since then.

* With the last change to the algorithm in place, it does not make sense
  to call update_db() before returning data to the connected client.
  Actually, it never does otherwise we could skip the periodic updates
  in the first place.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ifstat.c | 9 +++------
 misc/nstat.c  | 9 +++------
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index ac5c29c89184a..694d9839d2bd0 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -589,7 +589,7 @@ static void server_loop(int fd)
 
 	for (;;) {
 		int status;
-		int tdiff;
+		time_t tdiff;
 		struct timeval now;
 
 		gettimeofday(&now, NULL);
@@ -600,7 +600,7 @@ static void server_loop(int fd)
 			tdiff = 0;
 		}
 
-		if (poll(&p, 1, tdiff + scan_interval) > 0
+		if (poll(&p, 1, scan_interval - tdiff) > 0
 		    && (p.revents&POLLIN)) {
 			int clnt = accept(fd, NULL, NULL);
 			if (clnt >= 0) {
@@ -613,11 +613,8 @@ static void server_loop(int fd)
 					close(clnt);
 				} else {
 					FILE *fp = fdopen(clnt, "w");
-					if (fp) {
-						if (tdiff > 0)
-							update_db(tdiff);
+					if (fp)
 						dump_raw_db(fp, 0);
-					}
 					exit(0);
 				}
 			}
diff --git a/misc/nstat.c b/misc/nstat.c
index 99705286d279c..22b27eba7c8f6 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -433,7 +433,7 @@ static void server_loop(int fd)
 
 	for (;;) {
 		int status;
-		int tdiff;
+		time_t tdiff;
 		struct timeval now;
 		gettimeofday(&now, NULL);
 		tdiff = T_DIFF(now, snaptime);
@@ -442,7 +442,7 @@ static void server_loop(int fd)
 			snaptime = now;
 			tdiff = 0;
 		}
-		if (poll(&p, 1, tdiff + scan_interval) > 0
+		if (poll(&p, 1, scan_interval - tdiff) > 0
 		    && (p.revents&POLLIN)) {
 			int clnt = accept(fd, NULL, NULL);
 			if (clnt >= 0) {
@@ -455,11 +455,8 @@ static void server_loop(int fd)
 					close(clnt);
 				} else {
 					FILE *fp = fdopen(clnt, "w");
-					if (fp) {
-						if (tdiff > 0)
-							update_db(tdiff);
+					if (fp)
 						dump_kern_db(fp, 0);
-					}
 					exit(0);
 				}
 			}
-- 
2.7.2
