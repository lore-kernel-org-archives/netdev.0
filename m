From: Dave Boutcher <daveboutcher@gmail.com>
Subject: IGMP Join dropping multicast packets
Date: Sat, 14 Mar 2009 15:16:51 -0500
Message-ID: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:41644 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757872AbZCNUQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 16:16:54 -0400
Received: by yw-out-2324.google.com with SMTP id 5so582209ywh.1
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2009 13:16:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm running into an interesting problem with joining multiple
multicast feeds.  If you join multiple multicast feeds using
setsockopt(...,IP_ADD_MEMBERSHIP...) it causes packets on UNRELATED
multicast feeds to get dropped.  We have a multicast feed on a rock
solid network, and we were very surprised to see dropped packets.  The
cause was a different process/program being run by a different user
joining a bunch of mulitcast feeds.

I can recreate this with a fairly simple testcase (attached below.)
The problem doesn't happen with unicast UDP data, and it doesn't
happen with loopback, so you need at least two systems to run this
(and what subscriber to netdev doesn't have at least two systems.)  To
recreate, run "receiver" on one system, "sender", on another, and then
"joiner" on the receiving system.  You should see a message pop out
saying that packets have been dropped.  I've recreated this on a few
different kernel versions (the latest being 2.6.28) and a few
different sets off hardware.  I HAVEN"T recreated it if the system
doing the IP_ADD_MEMBERSHIP specifies a specific interface rather than
INADDR_ANY.  I'm not sure if that is core to the issue or not.  You
may also need to bump the value in
/proc/sys/net/ipv4/igmp_max_memberships (though that hasn't seemed
necessary for me.)

I poked around in igmp.c, but its mojo exceeds my threshold.  If
anyone has any ideas or questions I'd be happy to hear them.

diff -uNr null/joiner.c multicast/joiner.c
--- null/joiner.c	1969-12-31 18:00:00.000000000 -0600
+++ multicast/joiner.c	2009-03-14 15:04:10.000000000 -0500
@@ -0,0 +1,44 @@
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdbool.h>
+#include <string.h>
+#include <unistd.h>
+
+#define NUMSOCK 55
+
+int main(int argc, char **argv)
+{
+	struct ip_mreq mreq;
+	int i;
+	int sd;
+	char ipaddr[64];
+
+	for (i=0; i<NUMSOCK; i++) {
+		sd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
+		
+		if (sd < 0) {
+			perror("socket");
+			exit(0);
+		}
+		
+		sprintf(ipaddr,"239.192.2.%d",i+1);
+		
+		mreq.imr_multiaddr.s_addr = inet_addr(ipaddr);
+		mreq.imr_interface.s_addr = htonl(INADDR_ANY);
+		
+		if (setsockopt(sd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq))) {
+			perror("IP_ADD_MEMBERSHIP");
+			exit(0);
+		}
+	}
+
+	printf("Sleeping for 10 seconds\n");
+	sleep(10);
+
+	exit(0);
+}
+
diff -uNr null/Makefile multicast/Makefile
--- null/Makefile	1969-12-31 18:00:00.000000000 -0600
+++ multicast/Makefile	2009-03-14 15:13:09.000000000 -0500
@@ -0,0 +1,9 @@
+CFLAGS = -Wall -g
+
+all: sender receiver joiner
+
+receiver:
+
+sender:
+
+joiner:
diff -uNr null/mctest.h multicast/mctest.h
--- null/mctest.h	1969-12-31 18:00:00.000000000 -0600
+++ multicast/mctest.h	2009-03-14 14:47:13.000000000 -0500
@@ -0,0 +1,10 @@
+#ifndef __MCTEST_H__
+#define __MCTEST_H__
+
+struct mcdata {
+	int32_t seq1;
+	char data[60];
+	int32_t seq2;
+};
+
+#endif
Binary files null/receiver and multicast/receiver differ
diff -uNr null/receiver.c multicast/receiver.c
--- null/receiver.c	1969-12-31 18:00:00.000000000 -0600
+++ multicast/receiver.c	2009-03-14 14:48:25.000000000 -0500
@@ -0,0 +1,71 @@
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdbool.h>
+#include <string.h>
+#include <unistd.h>
+
+#include "mctest.h"
+
+int main(int argc, char **argv)
+{
+	int sd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
+	int on = 1;
+	struct sockaddr_in addr;
+	uint32_t seq = 1;
+	int bytes;
+	struct ip_mreq mreq;
+
+	struct mcdata data;
+
+	if (sd < 0) {
+		perror("socket");
+		exit(0);
+	}
+
+	mreq.imr_multiaddr.s_addr = inet_addr("239.192.1.1");
+	mreq.imr_interface.s_addr = htonl(INADDR_ANY);
+
+	if (setsockopt(sd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq))) {
+		perror("IP_ADD_MEMBERSHIP");
+		exit(0);
+	}
+
+	if (setsockopt(sd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(int))) {
+		perror("SO_REUSEADDR");
+		exit(0);
+	}
+
+	bzero(&addr, sizeof(addr));
+	addr.sin_family = AF_INET;
+	addr.sin_port = ntohs(60604);
+	addr.sin_addr.s_addr = inet_addr("239.192.1.1");
+
+	if (bind(sd, (struct sockaddr*)&addr, sizeof(addr))) {
+		perror("bind");
+		exit(0);
+	}
+
+	while(1) {
+		bytes = recv(sd, &data, sizeof(data), 0);
+		if (bytes != sizeof(data)) {
+			printf("recv got %d, expected %lu\n",
+			       bytes, sizeof(data));
+			exit(0);
+		}
+
+		if ((ntohl(data.seq1) != seq) ||
+		    (ntohl(data.seq2) != seq)) {
+			printf("Mismatched seq! Expected %u, got %u/%u\n",
+			       seq, ntohl(data.seq1), ntohl(data.seq2));
+		}
+
+		seq = ntohl(data.seq1)+1;
+		if (seq % 10000 == 0)
+			printf("got seq %u\n",seq);
+	}
+}
+
diff -uNr null/sender.c multicast/sender.c
--- null/sender.c	1969-12-31 18:00:00.000000000 -0600
+++ multicast/sender.c	2009-03-14 14:47:13.000000000 -0500
@@ -0,0 +1,55 @@
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdbool.h>
+#include <string.h>
+#include <unistd.h>
+
+#include "mctest.h"
+
+int main(int argc, char **argv)
+{
+	int sd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
+	int on = 1;
+	struct sockaddr_in addr;
+	uint32_t seq = 1;
+	int bytes;
+
+	struct mcdata data;
+
+	if (sd < 0) {
+		perror("socket");
+		exit(0);
+	}
+
+	if (setsockopt(sd, IPPROTO_IP, IP_MULTICAST_LOOP, &on, sizeof(int))) {
+		perror("IO_MULTICAST_LOOP");
+		exit(0);
+	}
+
+	bzero(&addr, sizeof(addr));
+	addr.sin_family = AF_INET;
+	addr.sin_port = ntohs(60604);
+	addr.sin_addr.s_addr = inet_addr("239.192.1.1");
+
+	memset(data.data, 0xdb, sizeof(data.data));
+
+	while (1) {
+		data.seq1 = data.seq2 = htonl(seq);
+
+		bytes = sendto(sd, &data, sizeof(data), 0,
+			       (struct sockaddr *)&addr, sizeof(addr));
+		if (bytes != sizeof(data)) {
+			perror("send");
+			exit(0);
+		}
+
+		seq++;
+		usleep(1000);
+	}
+
+	return 0;
+}

-- 
Dave B
