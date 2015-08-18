From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] lib/namespace: fix fd leakage in non-error case
Date: Tue, 18 Aug 2015 18:11:08 +0200
Message-ID: <1439914268-3864-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:41325 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753210AbbHRQLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 12:11:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My previous patch 5950ba9 ("lib/namespace: don't leak fd in error case")
was a step in the wrong direction. Instead of closing the opened file
descriptor in error case only, follow a better approach here and close
the fd as soon as it is not used anymore. This way the inelegant goto
statements can be dropped, and the fd leak in non-error case is fixed as
well.

Fixes: 5950ba9 ("lib/namespace: don't leak fd in error case")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/namespace.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/lib/namespace.c b/lib/namespace.c
index 8197165..30b5138 100644
--- a/lib/namespace.c
+++ b/lib/namespace.c
@@ -58,35 +58,34 @@ int netns_switch(char *name)
 	if (setns(netns, CLONE_NEWNET) < 0) {
 		fprintf(stderr, "setting the network namespace \"%s\" failed: %s\n",
 			name, strerror(errno));
-		goto fail_close;
+		close(netns);
+		return -1;
 	}
+	close(netns);
 
 	if (unshare(CLONE_NEWNS) < 0) {
 		fprintf(stderr, "unshare failed: %s\n", strerror(errno));
-		goto fail_close;
+		return -1;
 	}
 	/* Don't let any mounts propagate back to the parent */
 	if (mount("", "/", "none", MS_SLAVE | MS_REC, NULL)) {
 		fprintf(stderr, "\"mount --make-rslave /\" failed: %s\n",
 			strerror(errno));
-		goto fail_close;
+		return -1;
 	}
 	/* Mount a version of /sys that describes the network namespace */
 	if (umount2("/sys", MNT_DETACH) < 0) {
 		fprintf(stderr, "umount of /sys failed: %s\n", strerror(errno));
-		goto fail_close;
+		return -1;
 	}
 	if (mount(name, "/sys", "sysfs", 0, NULL) < 0) {
 		fprintf(stderr, "mount of /sys failed: %s\n",strerror(errno));
-		goto fail_close;
+		return -1;
 	}
 
 	/* Setup bind mounts for config files in /etc */
 	bind_etc(name);
 	return 0;
-fail_close:
-	close(netns);
-	return -1;
 }
 
 int netns_get_fd(const char *name)
-- 
2.1.2
