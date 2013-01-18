From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH iproute2-3.8 4/6] iproute2: Make "ip netns delete" more likely to succeed
Date: Thu, 17 Jan 2013 16:47:18 -0800
Message-ID: <87ip6v48rt.fsf_-_@xmission.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	<87622v5ngt.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:55867 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab3ARArc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 19:47:32 -0500
In-Reply-To: <87622v5ngt.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Thu, 17 Jan 2013 16:44:34 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sometimes "ip netns delete" fails because it can not delete the file a
network namespace was mounted on.  If this only happened when a
network namespace was really in use this would be fine, but today it
is possible to pin all network namespaces by simply having a long
running process started with "ip netns exec".

Every mount is copied when a network namespace is created so it is
impossible to prevent the mounts from getting into other mount
namespaces.  Modify all mounts in the files and subdirectories of
/var/run/netns to be shared mount points so that unmount events can
propogate, making it unlikely that "ip netns delete" will fail because
a directory is mounted in another mount namespace.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 ip/ipnetns.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 4fce379..33765b5 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -208,6 +208,7 @@ static int netns_add(int argc, char **argv)
 	char netns_path[MAXPATHLEN];
 	const char *name;
 	int fd;
+	int made_netns_run_dir_mount = 0;
 
 	if (argc < 1) {
 		fprintf(stderr, "No netns name specified\n");
@@ -220,6 +221,29 @@ static int netns_add(int argc, char **argv)
 	/* Create the base netns directory if it doesn't exist */
 	mkdir(NETNS_RUN_DIR, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
 
+	/* Make it possible for network namespace mounts to propogate between
+	 * mount namespaces.  This makes it likely that a unmounting a network
+	 * namespace file in one namespace will unmount the network namespace
+	 * file in all namespaces allowing the network namespace to be freed
+	 * sooner.
+	 */
+	while (mount("", NETNS_RUN_DIR, "none", MS_SHARED | MS_REC, NULL)) {
+		/* Fail unless we need to make the mount point */
+		if (errno != EINVAL || made_netns_run_dir_mount) {
+			fprintf(stderr, "mount --make-shared %s failed: %s\n",
+				NETNS_RUN_DIR, strerror(errno));
+			return EXIT_FAILURE;
+		}
+
+		/* Upgrade NETNS_RUN_DIR to a mount point */
+		if (mount(NETNS_RUN_DIR, NETNS_RUN_DIR, "none", MS_BIND, NULL)) {
+			fprintf(stderr, "mount --bind %s %s failed: %s\n",
+				NETNS_RUN_DIR, NETNS_RUN_DIR, strerror(errno));
+			return EXIT_FAILURE;
+		}
+		made_netns_run_dir_mount = 1;
+	}
+
 	/* Create the filesystem state */
 	fd = open(netns_path, O_RDONLY|O_CREAT|O_EXCL, 0);
 	if (fd < 0) {
-- 
1.7.5.4
