From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 2/3] ip vrf: Improve cgroup2 error messages
Date: Thu,  5 Jan 2017 16:22:22 -0800
Message-ID: <1483662143-15242-3-git-send-email-dsa@cumulusnetworks.com>
References: <1483662143-15242-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33675 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030894AbdAFA3p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 19:29:45 -0500
Received: by mail-pf0-f180.google.com with SMTP id d2so90070440pfd.0
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 16:29:40 -0800 (PST)
In-Reply-To: <1483662143-15242-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if a non-root user attempts to run ip vrf exec a non-helpful
error is returned:

$ ip vrf exec mgmt bash
Failed to mount cgroup2. Are CGROUPS enabled in your kernel?

Only show the CGROUPS kernel hint for the ENODEV error and for the
rest show the strerror for the errno. So now:

$ ip/ip vrf exec mgmt bash
Failed to mount cgroup2: Operation not permitted

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 lib/fs.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/lib/fs.c b/lib/fs.c
index 644bb486ae8e..12a4657a0bc9 100644
--- a/lib/fs.c
+++ b/lib/fs.c
@@ -80,13 +80,21 @@ char *find_cgroup2_mount(void)
 
 	if (mount("none", mnt, CGROUP2_FS_NAME, 0, NULL)) {
 		/* EBUSY means already mounted */
-		if (errno != EBUSY) {
+		if (errno == EBUSY)
+			goto out;
+
+		if (errno == ENODEV) {
 			fprintf(stderr,
 				"Failed to mount cgroup2. Are CGROUPS enabled in your kernel?\n");
-			free(mnt);
-			return NULL;
+		} else {
+			fprintf(stderr,
+				"Failed to mount cgroup2: %s\n",
+				strerror(errno));
 		}
+		free(mnt);
+		return NULL;
 	}
+out:
 	return mnt;
 }
 
-- 
2.1.4
