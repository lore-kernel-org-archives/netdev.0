From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 5/6] lib/namespace: don't leak fd in error case
Date: Thu,  6 Aug 2015 14:24:35 +0200
Message-ID: <1438863876-1935-5-git-send-email-phil@nwl.cc>
References: <1438863876-1935-1-git-send-email-phil@nwl.cc>
 <1438863876-1935-2-git-send-email-phil@nwl.cc>
 <1438863876-1935-3-git-send-email-phil@nwl.cc>
 <1438863876-1935-4-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38165 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755418AbbHFMYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2015 08:24:38 -0400
In-Reply-To: <1438863876-1935-4-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/namespace.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/lib/namespace.c b/lib/namespace.c
index a61feb6..8197165 100644
--- a/lib/namespace.c
+++ b/lib/namespace.c
@@ -58,32 +58,35 @@ int netns_switch(char *name)
 	if (setns(netns, CLONE_NEWNET) < 0) {
 		fprintf(stderr, "setting the network namespace \"%s\" failed: %s\n",
 			name, strerror(errno));
-		return -1;
+		goto fail_close;
 	}
 
 	if (unshare(CLONE_NEWNS) < 0) {
 		fprintf(stderr, "unshare failed: %s\n", strerror(errno));
-		return -1;
+		goto fail_close;
 	}
 	/* Don't let any mounts propagate back to the parent */
 	if (mount("", "/", "none", MS_SLAVE | MS_REC, NULL)) {
 		fprintf(stderr, "\"mount --make-rslave /\" failed: %s\n",
 			strerror(errno));
-		return -1;
+		goto fail_close;
 	}
 	/* Mount a version of /sys that describes the network namespace */
 	if (umount2("/sys", MNT_DETACH) < 0) {
 		fprintf(stderr, "umount of /sys failed: %s\n", strerror(errno));
-		return -1;
+		goto fail_close;
 	}
 	if (mount(name, "/sys", "sysfs", 0, NULL) < 0) {
 		fprintf(stderr, "mount of /sys failed: %s\n",strerror(errno));
-		return -1;
+		goto fail_close;
 	}
 
 	/* Setup bind mounts for config files in /etc */
 	bind_etc(name);
 	return 0;
+fail_close:
+	close(netns);
+	return -1;
 }
 
 int netns_get_fd(const char *name)
-- 
2.1.2
