From: =?UTF-8?B?0JDQvdGC0L7QvSDQlC4=?= <littlesmilingcloud@gmail.com>
Subject: [PATCH] iputils: firewall mark option in tracepath/tracepath6
Date: Tue, 10 Aug 2010 13:17:43 +0400
Message-ID: <AANLkTimM6W97bYBgE3Z-KUDWFzq2qMtE=SJW4ixMzsiv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:36243 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422Ab0HJJRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 05:17:44 -0400
Received: by qwh6 with SMTP id 6so8010504qwh.19
        for <netdev@vger.kernel.org>; Tue, 10 Aug 2010 02:17:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/tracepath.c b/tracepath.c
index 81c22e9..6675f14 100644
--- a/tracepath.c
+++ b/tracepath.c
@@ -42,6 +42,7 @@ __u16 base_port;

 const int overhead = 28;
 int mtu = 65535;
+int mark = 0;
 int hops_to = -1;
 int hops_from = -1;
 int no_resolve = 0;
@@ -285,7 +286,7 @@ static void usage(void) __attribute((noreturn));

 static void usage(void)
 {
-	fprintf(stderr, "Usage: tracepath [-n] [-b] [-l <len>]
<destination>[/<port>]\n");
+	fprintf(stderr, "Usage: tracepath [-n] [-b] [-l <len>] [-m <mark>]
<destination>[/<port>]\n");
 	exit(-1);
 }

@@ -299,7 +300,7 @@ main(int argc, char **argv)
 	char *p;
 	int ch;

-	while ((ch = getopt(argc, argv, "nbh?l:")) != EOF) {
+	while ((ch = getopt(argc, argv, "nbh?l:m:")) != EOF) {
 		switch(ch) {
 		case 'n':
 			no_resolve = 1;
@@ -313,6 +314,9 @@ main(int argc, char **argv)
 				exit(1);
 			}
 			break;
+		case 'm':
+		  	mark = atoi(optarg);
+		  	break;
 		default:
 			usage();
 		}
@@ -345,6 +349,12 @@ main(int argc, char **argv)
 	}
 	memcpy(&target.sin_addr, he->h_addr, 4);

+	if (mark) {
+		if (setsockopt(fd, SOL_SOCKET, SO_MARK, &mark, sizeof(mark)) == -1) {
+			fprintf(stderr, "Warning: Failed to set mark %d\n", mark);
+		}
+	}
+
 	on = IP_PMTUDISC_PROBE;
 	if (setsockopt(fd, SOL_IP, IP_MTU_DISCOVER, &on, sizeof(on)) &&
 	    (on = IP_PMTUDISC_DO,
diff --git a/tracepath6.c b/tracepath6.c
index 5cc7424..5d08c62 100644
--- a/tracepath6.c
+++ b/tracepath6.c
@@ -52,6 +52,7 @@ socklen_t targetlen;
 __u16 base_port;

 int overhead = 48;
+int mark = 0;
 int mtu = 128000;
 int hops_to = -1;
 int hops_from = -1;
@@ -359,7 +360,7 @@ static void usage(void) __attribute((noreturn));

 static void usage(void)
 {
-	fprintf(stderr, "Usage: tracepath6 [-n] [-b] [-l <len>]
<destination>[/<port>]\n");
+	fprintf(stderr, "Usage: tracepath6 [-n] [-b] [-l <len>] [-m <mark>]
<destination>[/<port>]\n");
 	exit(-1);
 }

@@ -375,7 +376,7 @@ int main(int argc, char **argv)
 	int gai;
 	char pbuf[NI_MAXSERV];

-	while ((ch = getopt(argc, argv, "nbh?l:")) != EOF) {
+	while ((ch = getopt(argc, argv, "nbh?l:m:")) != EOF) {
 		switch(ch) {
 		case 'n':
 			no_resolve = 1;
@@ -389,6 +390,9 @@ int main(int argc, char **argv)
 				exit(1);
 			}
 			break;
+		case 'm':
+			mark = atoi(optarg);
+			break;
 		default:
 			usage();
 		}
@@ -439,6 +443,12 @@ int main(int argc, char **argv)
 	}
 	freeaddrinfo(ai0);

+	if (mark) {
+		if (setsockopt(fd, SOL_SOCKET, SO_MARK, &mark, sizeof(mark)) == -1) {
+			fprintf(stderr, "Warning: Failed to set mark %d\n", mark);
+		}
+	}
+
 	switch (family) {
 	case AF_INET6:
 		mtu = 128000;
