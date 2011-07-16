From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] iproute2: Fail "ip netns add" on existing network namespaces.
Date: Fri, 15 Jul 2011 17:29:41 -0700
Message-ID: <m1hb6nkqyx.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56751 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578Ab1GPA3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 20:29:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use O_EXCL so that we only create and mount a new network namespace
if there is no chance an existing network namespace is present.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---

 ip/ipnetns.c |   17 +++++------------
 1 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index dff3497..e41a598 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -41,16 +41,6 @@ static int setns(int fd, int nstype)
 #endif /* HAVE_SETNS */
 
 
-static int touch(const char *path, mode_t mode)
-{
-	int fd;
-	fd = open(path, O_RDONLY|O_CREAT, mode);
-	if (fd < 0)
-		return -1;
-	close(fd);
-	return 0;
-}
-
 static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
@@ -214,6 +204,7 @@ static int netns_add(int argc, char **argv)
 	 */
 	char netns_path[MAXPATHLEN];
 	const char *name;
+	int fd;
 
 	if (argc < 1) {
 		fprintf(stderr, "No netns name specified\n");
@@ -227,11 +218,13 @@ static int netns_add(int argc, char **argv)
 	mkdir(NETNS_RUN_DIR, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
 
 	/* Create the filesystem state */
-	if (touch(netns_path, 0) < 0) {
+	fd = open(netns_path, O_RDONLY|O_CREAT|O_EXCL, 0);
+	if (fd < 0) {
 		fprintf(stderr, "Could not create %s: %s\n",
 			netns_path, strerror(errno));
-		goto out_delete;
+		return -1;
 	}
+	close(fd);
 	if (unshare(CLONE_NEWNET) < 0) {
 		fprintf(stderr, "Failed to create a new network namespace: %s\n",
 			strerror(errno));
-- 
1.7.5.1.217.g4e3aa

