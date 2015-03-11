From: Tobias Stoeckmann <tobias@stoeckmann.org>
Subject: [PATCH] Avoid signal race in arpd initialization.
Date: Wed, 11 Mar 2015 21:58:45 +0100
Message-ID: <20150311205845.GA23722@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:58784 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbbCKU6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:58:46 -0400
Received: from localhost ([79.227.12.190]) by mrelayeu.kundenserver.de
 (mreue001) with ESMTPSA (Nemesis) id 0MROX9-1Z0LhT1iiV-00UYNN for
 <netdev@vger.kernel.org>; Wed, 11 Mar 2015 21:58:44 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signal handlers in arpd use siglongjmp() to return into main function
during polls. The environment for the jumps is set after the signal
handlers are installed. This leaves a small time frame in which an
uninitialized environment could be used for a siglongjmp() call, leading
to undefined behavior.

While at it, define flag variables as sig_atomic_t instead of int.
---
 misc/arpd.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/misc/arpd.c b/misc/arpd.c
index 7919eb8..cfd1e39 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -64,9 +64,9 @@ struct rtnl_handle rth;
 struct pollfd pset[2];
 int udp_sock = -1;
 
-volatile int do_exit;
-volatile int do_sync;
-volatile int do_stats;
+volatile sig_atomic_t do_exit;
+volatile sig_atomic_t do_sync;
+volatile sig_atomic_t do_stats;
 
 struct {
 	unsigned long arp_new;
@@ -793,10 +793,6 @@ int main(int argc, char **argv)
 	}
 
 	openlog("arpd", LOG_PID | LOG_CONS, LOG_DAEMON);
-	catch_signal(SIGINT, sig_exit);
-	catch_signal(SIGTERM, sig_exit);
-	catch_signal(SIGHUP, sig_sync);
-	catch_signal(SIGUSR1, sig_stats);
 
 #define EVENTS (POLLIN|POLLPRI|POLLERR|POLLHUP)
 	pset[0].events = EVENTS;
@@ -804,7 +800,12 @@ int main(int argc, char **argv)
 	pset[1].events = EVENTS;
 	pset[1].revents = 0;
 
-	sigsetjmp(env, 1);
+	if (sigsetjmp(env, 1) == 0) {
+		catch_signal(SIGINT, sig_exit);
+		catch_signal(SIGTERM, sig_exit);
+		catch_signal(SIGHUP, sig_sync);
+		catch_signal(SIGUSR1, sig_stats);
+	}
 
 	for (;;) {
 		in_poll = 1;
-- 
2.3.2
