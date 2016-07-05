From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] ipnetns: Make netns mount points private
Date: Tue,  5 Jul 2016 16:42:53 +0200
Message-ID: <1467729773-16751-3-git-send-email-phil@nwl.cc>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46995 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932976AbcGEOnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 10:43:13 -0400
In-Reply-To: <1467729773-16751-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On systems with a shared /proc mount point, the netns mounts inherit
that propagation group and therefore cause unnecessary overhead upon
netns deletion.

In order to achieve this, the MS_REC flag when making NETNS_RUN_DIR
shared has to be removed as well or otherwise it will make existing
netns mount points shared again.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipnetns.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 1cefe73c68bfc..acaedd5894e6c 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -636,7 +636,7 @@ static int netns_add(int argc, char **argv)
 	 * file in all namespaces allowing the network namespace to be freed
 	 * sooner.
 	 */
-	while (mount("", NETNS_RUN_DIR, "none", MS_SHARED | MS_REC, NULL)) {
+	while (mount("", NETNS_RUN_DIR, "none", MS_SHARED, NULL)) {
 		/* Fail unless we need to make the mount point */
 		if (errno != EINVAL || made_netns_run_dir_mount) {
 			fprintf(stderr, "mount --make-shared %s failed: %s\n",
@@ -678,6 +678,11 @@ static int netns_add(int argc, char **argv)
 			netns_path, strerror(errno));
 		goto out_delete;
 	}
+	if (mount("", netns_path, "none", MS_PRIVATE, NULL)) {
+		fprintf(stderr, "mount --make-private %s failed: %s\n",
+			netns_path, strerror(errno));
+		return -1;
+	}
 	return 0;
 out_delete:
 	netns_delete(argc, argv);
-- 
2.8.2
