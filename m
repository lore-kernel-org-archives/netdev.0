From: Martin KaFai Lau <kafai@fb.com>
Subject: [net_test_tools] udpflood: Add IPv6 support
Date: Tue, 2 Dec 2014 10:41:46 -0800
Message-ID: <1417545706-31249-1-git-send-email-kafai@fb.com>
References: <1413837765-5446-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54415 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753975AbaLBSlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 13:41:49 -0500
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id sB2Ievk0019431
	for <netdev@vger.kernel.org>; Tue, 2 Dec 2014 10:41:49 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1r1h2ugck6-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 10:41:49 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 dea0922c7a5211e48fad0002c95209d8-23ad8390 for <netdev@vger.kernel.org>;	Tue,
 02 Dec 2014 10:41:47 -0800
In-Reply-To: <1413837765-5446-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch:
1. Add IPv6 support
2. Print timing for every 65536 fib insert operations to observe
   the gc effect (mostly for IPv6 fib).
---
 udpflood.c | 125 +++++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 101 insertions(+), 24 deletions(-)

diff --git a/udpflood.c b/udpflood.c
index 6e658f7..5855012 100644
--- a/udpflood.c
+++ b/udpflood.c
@@ -6,7 +6,9 @@
 #include <string.h>
 #include <errno.h>
 #include <unistd.h>
+#include <stdint.h>
 
+#include <sys/time.h>
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
@@ -15,57 +17,121 @@
 #define _GNU_SOURCE
 #include <getopt.h>
 
+static int debug = 0;
+
+typedef union sa_u {
+	struct sockaddr_in a4;
+	struct sockaddr_in6 a6;
+} sa_u;
+
 static int usage(void)
 {
 	printf("usage: udpflood [ -l count ] [ -m message_size ] [ -c num_ip_addrs ] IP_ADDRESS\n");
 	return -1;
 }
 
-static int send_packets(in_addr_t start_addr, in_addr_t end_addr,
-			int port, int count, int msg_sz)
+static uint32_t get_last32h(const sa_u *sa)
+{
+	if (sa->a4.sin_family == PF_INET)
+		return ntohl(sa->a4.sin_addr.s_addr);
+	else
+		return ntohl(sa->a6.sin6_addr.s6_addr32[3]);
+}
+
+static void set_last32h(sa_u *sa, uint32_t last32h)
+{
+	if (sa->a4.sin_family == PF_INET)
+		sa->a4.sin_addr.s_addr = htonl(last32h);
+	else
+		sa->a6.sin6_addr.s6_addr32[3] = htonl(last32h);
+}
+
+static void print_sa(const sa_u *sa, const char *msg)
+{
+	char buf[sizeof("xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx")];
+
+	if (!debug)
+		return;
+
+	switch (sa->a4.sin_family) {
+	case PF_INET:
+		inet_ntop(PF_INET, &(sa->a4.sin_addr.s_addr), buf,
+			  sizeof(buf));
+		break;
+	case PF_INET6:
+		inet_ntop(PF_INET6, sa->a6.sin6_addr.s6_addr, buf, sizeof(buf));
+		break;
+	}
+
+	printf("%s: %s\n", msg, buf);
+}
+
+static long get_diff_ms(const struct timeval *now,
+			     const struct timeval *start)
+{
+	long start_ms, now_ms;
+	start_ms = start->tv_sec * 1000 + (start->tv_usec / 1000);
+	now_ms = now->tv_sec * 1000 + (now->tv_usec  / 1000);
+	return now_ms - start_ms;
+}
+
+static int send_packets(const sa_u *start_sa, size_t num_addrs, int count,
+			int msg_sz)
 {
 	char *msg = malloc(msg_sz);
-	struct sockaddr_in saddr;
-	in_addr_t addr;
+	sa_u cur_sa;
+	uint32_t start_addr32h, end_addr32h, cur_addr32h;
 	int fd, i, err;
+	struct timeval last, now;
 
 	if (!msg)
 		return -ENOMEM;
 
 	memset(msg, 0, msg_sz);
 
-	addr = start_addr;
-
-	memset(&saddr, 0, sizeof(saddr));
-	saddr.sin_family = AF_INET;
-	saddr.sin_port = port;
-	saddr.sin_addr.s_addr = addr;
+	memcpy(&cur_sa, start_sa, sizeof(cur_sa));
+	cur_addr32h = start_addr32h = get_last32h(&cur_sa);
+	end_addr32h = start_addr32h + num_addrs;
 
-	fd = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
+	fd = socket(cur_sa.a4.sin_family, SOCK_DGRAM, IPPROTO_IP);
 	if (fd < 0) {
 		perror("socket");
 		err = fd;
 		goto out_nofd;
 	}
-	err = connect(fd, (struct sockaddr *) &saddr, sizeof(saddr));
+	err = connect(fd, (struct sockaddr *) &cur_sa, sizeof(cur_sa));
 	if (err < 0) {
 		perror("connect");
-		close(fd);
 		goto out;
 	}
 
+	print_sa(start_sa, "start_addr");
+	gettimeofday(&last, NULL);
 	for (i = 0; i < count; i++) {
-		saddr.sin_addr.s_addr = addr;
-
+		print_sa(&cur_sa, "sendto");
 		err = sendto(fd, msg, msg_sz, 0,
-			     (struct sockaddr *) &saddr, sizeof(saddr));
+			     (struct sockaddr *) &cur_sa, sizeof(cur_sa));
 		if (err < 0) {
 			perror("sendto");
 			goto out;
 		}
 
-		if (++addr >= end_addr)
-			addr = start_addr;
+		if (++cur_addr32h >= end_addr32h)
+			cur_addr32h = start_addr32h;
+		set_last32h(&cur_sa, cur_addr32h);
+
+		/*
+		 * print timing info for every 65536 fib inserts to
+		 * observe the gc effect (mostly for IPv6 fib).
+		 */
+		if (i && (i & 0xFFFF) == 0) {
+		    long diff_ms;
+		    gettimeofday(&now, NULL);
+		    diff_ms = get_diff_ms(&now, &last);
+		    printf("%d %ld.%ld\n", i >> 16,
+			   diff_ms / 1000, diff_ms % 1000);
+		    memcpy(&last, &now, sizeof(last));
+		}
 	}
 
 	err = 0;
@@ -79,14 +145,14 @@ out_nofd:
 int main(int argc, char **argv, char **envp)
 {
 	int port, msg_sz, count, num_addrs, ret;
-	in_addr_t start_addr, end_addr;
+	sa_u start_sa;
 
 	port = 6000;
 	msg_sz = 32;
 	count = 10000000;
 	num_addrs = 1;
 
-	while ((ret = getopt(argc, argv, "l:s:p:c:")) >= 0) {
+	while ((ret = getopt(argc, argv, "dl:s:p:c:")) >= 0) {
 		switch (ret) {
 		case 'l':
 			sscanf(optarg, "%d", &count);
@@ -100,18 +166,29 @@ int main(int argc, char **argv, char **envp)
 		case 'c':
 			sscanf(optarg, "%d", &num_addrs);
 			break;
+		case 'd':
+			debug = 1;
+			break;
 		case '?':
 			return usage();
 		}
 	}
 
+	if (num_addrs < 1 || count < 1)
+		return usage();
+
 	if (!argv[optind])
 		return usage();
 
-	start_addr = inet_addr(argv[optind]);
-	if (start_addr == INADDR_NONE)
+	memset(&start_sa, 0, sizeof(start_sa));
+	start_sa.a4.sin_port = htons(port);
+	if (inet_pton(PF_INET, argv[optind], &start_sa.a4.sin_addr))
+		start_sa.a4.sin_family = PF_INET;
+	else if (inet_pton(PF_INET6, argv[optind],
+			   start_sa.a6.sin6_addr.s6_addr))
+		start_sa.a6.sin6_family = PF_INET6;
+	else
 		return usage();
-	end_addr = start_addr + num_addrs;
 
-	return send_packets(start_addr, end_addr, port, count, msg_sz);
+	return send_packets(&start_sa, num_addrs, count, msg_sz);
 }
-- 
1.8.1
