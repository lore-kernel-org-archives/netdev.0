From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 3/4] ip vrf: Fix reset to default VRF
Date: Thu, 15 Dec 2016 12:07:01 -0800
Message-ID: <1481832422-10267-4-git-send-email-dsa@cumulusnetworks.com>
References: <1481832422-10267-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:35754 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752020AbcLOUHL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 15:07:11 -0500
Received: by mail-pg0-f45.google.com with SMTP id p66so23346700pga.2
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 12:07:10 -0800 (PST)
In-Reply-To: <1481832422-10267-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Path in vrf_switch for "default" VRF is supposed to be MNT/vrf not
MNT/default. Also, default_vrf flag is redundant with ifindex. Remove
the flag in favor of ifindex != 0.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipvrf.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index a2669f339691..de2ec5c120cb 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -202,16 +202,15 @@ static int vrf_configure_cgroup(const char *path, int ifindex)
 static int vrf_switch(const char *name)
 {
 	char path[PATH_MAX], *mnt, pid[16];
-	int ifindex = name_is_vrf(name);
-	bool default_vrf = false;
+	int ifindex = 0;
 	int rc = -1, len, fd = -1;
 
-	if (!ifindex) {
-		if (strcmp(name, "default")) {
+	if (strcmp(name, "default")) {
+		ifindex = name_is_vrf(name);
+		if (!ifindex) {
 			fprintf(stderr, "Invalid VRF name\n");
 			return -1;
 		}
-		default_vrf = true;
 	}
 
 	mnt = find_cgroup2_mount();
@@ -221,8 +220,8 @@ static int vrf_switch(const char *name)
 	/* path to cgroup; make sure buffer has room to cat "/cgroup.procs"
 	 * to the end of the path
 	 */
-	len = snprintf(path, sizeof(path) - sizeof(CGRP_PROC_FILE), "%s%s/%s",
-		       mnt, default_vrf ? "" : "/vrf", name);
+	len = snprintf(path, sizeof(path) - sizeof(CGRP_PROC_FILE), "%s/vrf/%s",
+		       mnt, ifindex ? name : "");
 	if (len > sizeof(path) - sizeof(CGRP_PROC_FILE)) {
 		fprintf(stderr, "Invalid path to cgroup2 mount\n");
 		goto out;
@@ -233,7 +232,7 @@ static int vrf_switch(const char *name)
 		goto out;
 	}
 
-	if (!default_vrf && vrf_configure_cgroup(path, ifindex))
+	if (ifindex && vrf_configure_cgroup(path, ifindex))
 		goto out;
 
 	/*
-- 
2.1.4
