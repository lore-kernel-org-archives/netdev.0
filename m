From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/5] ipvrf: Fix error path of vrf_switch()
Date: Thu, 17 Aug 2017 19:09:27 +0200
Message-ID: <20170817170931.24435-2-phil@nwl.cc>
References: <20170817170931.24435-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52195 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753490AbdHQRM0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:12:26 -0400
In-Reply-To: <20170817170931.24435-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apart from trying to close(-1), this also leaked memory.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipvrf.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index 0094cf8557cd7..e6fad32abd956 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -372,12 +372,12 @@ static int vrf_switch(const char *name)
 
 	/* -1 on length to add '/' to the end */
 	if (ipvrf_get_netns(netns, sizeof(netns) - 1) < 0)
-		return -1;
+		goto out;
 
 	if (vrf_path(vpath, sizeof(vpath)) < 0) {
 		fprintf(stderr, "Failed to get base cgroup path: %s\n",
 			strerror(errno));
-		return -1;
+		goto out;
 	}
 
 	/* if path already ends in netns then don't add it again */
@@ -428,13 +428,14 @@ static int vrf_switch(const char *name)
 	snprintf(pid, sizeof(pid), "%d", getpid());
 	if (write(fd, pid, strlen(pid)) < 0) {
 		fprintf(stderr, "Failed to join cgroup\n");
-		goto out;
+		goto out2;
 	}
 
 	rc = 0;
+out2:
+	close(fd);
 out:
 	free(mnt);
-	close(fd);
 
 	return rc;
 }
-- 
2.13.1
