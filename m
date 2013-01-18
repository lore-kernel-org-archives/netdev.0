From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH iproute2-3.8 2/6] iproute2: Normalize return codes in "ip netns"
Date: Thu, 17 Jan 2013 16:46:09 -0800
Message-ID: <87sj5z48tq.fsf_-_@xmission.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	<87622v5ngt.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:55143 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033Ab3ARAq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 19:46:29 -0500
In-Reply-To: <87622v5ngt.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Thu, 17 Jan 2013 16:44:34 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ben Hutchings pointed out that the return value of do_netns is passed
to exit and the current convention of returning -1 for failure is
inconsitent with that reality.

Return EXIT_FAILURE instead of -1 and EXIT_SUCCESS instead of 0.  To make
it clear that the return codes are expected to be passed to exit.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 ip/ipnetns.c |   56 ++++++++++++++++++++++++++------------------------------
 1 files changed, 26 insertions(+), 30 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index f2c42ba..ae55090 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -40,17 +40,14 @@ static int setns(int fd, int nstype)
 }
 #endif /* HAVE_SETNS */
 
-
-static void usage(void) __attribute__((noreturn));
-
-static void usage(void)
+static int usage(void)
 {
 	fprintf(stderr, "Usage: ip netns list\n");
 	fprintf(stderr, "       ip netns add NAME\n");
 	fprintf(stderr, "       ip netns delete NAME\n");
 	fprintf(stderr, "       ip netns exec NAME cmd ...\n");
 	fprintf(stderr, "       ip netns monitor\n");
-	exit(-1);
+	return EXIT_FAILURE;
 }
 
 int get_netns_fd(const char *name)
@@ -75,7 +72,7 @@ static int netns_list(int argc, char **argv)
 
 	dir = opendir(NETNS_RUN_DIR);
 	if (!dir)
-		return 0;
+		return EXIT_SUCCESS;
 
 	while ((entry = readdir(dir)) != NULL) {
 		if (strcmp(entry->d_name, ".") == 0)
@@ -85,7 +82,7 @@ static int netns_list(int argc, char **argv)
 		printf("%s\n", entry->d_name);
 	}
 	closedir(dir);
-	return 0;
+	return EXIT_SUCCESS;
 }
 
 static void bind_etc(const char *name)
@@ -127,11 +124,11 @@ static int netns_exec(int argc, char **argv)
 
 	if (argc < 1) {
 		fprintf(stderr, "No netns name specified\n");
-		return -1;
+		return EXIT_FAILURE;
 	}
 	if (argc < 2) {
 		fprintf(stderr, "No cmd specified\n");
-		return -1;
+		return EXIT_FAILURE;
 	}
 	name = argv[0];
 	cmd = argv[1];
@@ -140,32 +137,32 @@ static int netns_exec(int argc, char **argv)
 	if (netns < 0) {
 		fprintf(stderr, "Cannot open network namespace: %s\n",
 			strerror(errno));
-		return -1;
+		return EXIT_FAILURE;
 	}
 	if (setns(netns, CLONE_NEWNET) < 0) {
 		fprintf(stderr, "seting the network namespace failed: %s\n",
 			strerror(errno));
-		return -1;
+		return EXIT_FAILURE;
 	}
 
 	if (unshare(CLONE_NEWNS) < 0) {
 		fprintf(stderr, "unshare failed: %s\n", strerror(errno));
-		return -1;
+		return EXIT_FAILURE;
 	}
 	/* Don't let any mounts propogate back to the parent */
 	if (mount("", "/", "none", MS_SLAVE | MS_REC, NULL)) {
 		fprintf(stderr, "mount --make-rslave / failed: %s\n",
 			strerror(errno));
-		return -1;
+		return EXIT_FAILURE;
 	}
 	/* Mount a version of /sys that describes the network namespace */
 	if (umount2("/sys", MNT_DETACH) < 0) {
 		fprintf(stderr, "umount of /sys failed: %s\n", strerror(errno));
-		return -1;
+		return EXIT_FAILURE;
 	}
 	if (mount(name, "/sys", "sysfs", 0, NULL) < 0) {
 		fprintf(stderr, "mount of /sys failed: %s\n",strerror(errno));
-		return -1;
+		return EXIT_FAILURE;
 	}
 
 	/* Setup bind mounts for config files in /etc */
@@ -174,7 +171,7 @@ static int netns_exec(int argc, char **argv)
 	if (execvp(cmd, argv + 1)  < 0)
 		fprintf(stderr, "exec of %s failed: %s\n",
 			cmd, strerror(errno));
-	exit(-1);
+	return EXIT_FAILURE;
 }
 
 static int netns_delete(int argc, char **argv)
@@ -184,7 +181,7 @@ static int netns_delete(int argc, char **argv)
 
 	if (argc < 1) {
 		fprintf(stderr, "No netns name specified\n");
-		return -1;
+		return EXIT_FAILURE;
 	}
 
 	name = argv[0];
@@ -193,9 +190,9 @@ static int netns_delete(int argc, char **argv)
 	if (unlink(netns_path) < 0) {
 		fprintf(stderr, "Cannot remove %s: %s\n",
 			netns_path, strerror(errno));
-		return -1;
+		return EXIT_FAILURE;
 	}
-	return 0;
+	return EXIT_SUCCESS;
 }
 
 static int netns_add(int argc, char **argv)
@@ -214,7 +211,7 @@ static int netns_add(int argc, char **argv)
 
 	if (argc < 1) {
 		fprintf(stderr, "No netns name specified\n");
-		return -1;
+		return EXIT_FAILURE;
 	}
 	name = argv[0];
 
@@ -228,7 +225,7 @@ static int netns_add(int argc, char **argv)
 	if (fd < 0) {
 		fprintf(stderr, "Could not create %s: %s\n",
 			netns_path, strerror(errno));
-		return -1;
+		return EXIT_FAILURE;
 	}
 	close(fd);
 	if (unshare(CLONE_NEWNET) < 0) {
@@ -243,11 +240,10 @@ static int netns_add(int argc, char **argv)
 			netns_path, strerror(errno));
 		goto out_delete;
 	}
-	return 0;
+	return EXIT_SUCCESS;
 out_delete:
 	netns_delete(argc, argv);
-	exit(-1);
-	return -1;
+	return EXIT_FAILURE;
 }
 
 
@@ -260,19 +256,19 @@ static int netns_monitor(int argc, char **argv)
 	if (fd < 0) {
 		fprintf(stderr, "inotify_init failed: %s\n",
 			strerror(errno));
-		return -1;
+		return EXIT_FAILURE;
 	}
 	if (inotify_add_watch(fd, NETNS_RUN_DIR, IN_CREATE | IN_DELETE) < 0) {
 		fprintf(stderr, "inotify_add_watch failed: %s\n",
 			strerror(errno));
-		return -1;
+		return EXIT_FAILURE;
 	}
 	for(;;) {
 		ssize_t len = read(fd, buf, sizeof(buf));
 		if (len < 0) {
 			fprintf(stderr, "read failed: %s\n",
 				strerror(errno));
-			return -1;
+			return EXIT_FAILURE;
 		}
 		for (event = (struct inotify_event *)buf;
 		     (char *)event < &buf[len];
@@ -283,7 +279,7 @@ static int netns_monitor(int argc, char **argv)
 				printf("delete %s\n", event->name);
 		}
 	}
-	return 0;
+	return EXIT_SUCCESS;
 }
 
 int do_netns(int argc, char **argv)
@@ -296,7 +292,7 @@ int do_netns(int argc, char **argv)
 		return netns_list(argc-1, argv+1);
 
 	if (matches(*argv, "help") == 0)
-		usage();
+		return usage();
 
 	if (matches(*argv, "add") == 0)
 		return netns_add(argc-1, argv+1);
@@ -311,5 +307,5 @@ int do_netns(int argc, char **argv)
 		return netns_monitor(argc-1, argv+1);
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip netns help\".\n", *argv);
-	exit(-1);
+	return EXIT_FAILURE;
 }
-- 
1.7.5.4
