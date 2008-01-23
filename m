From: "Michaelian Ennis" <michaelian.ennis@gmail.com>
Subject: arping
Date: Wed, 23 Jan 2008 17:03:36 -0500
Message-ID: <bb9aee10801231403u459edf9brcfb633f87f01cb30@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:43383 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbYAWWDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 17:03:37 -0500
Received: by wa-out-1112.google.com with SMTP id v27so5299493wah.23
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 14:03:36 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Someone filed a bug at bugs.gentoo.org reflecting a possible
enhancement to arping.  In short the patches author felt that select
should be used instead of signals to avoid missing a timeout.

The bug is located at:
http://bugs.gentoo.org/show_bug.cgi?id=144526

The diff follows:

--- arping.c	2006-08-20 19:14:39.000000000 -0500
+++ /var/tmp/portage/iputils-021109-r3/work/iputils/arping.c	2006-08-20
19:17:40.000000000 -0500
@@ -7,9 +7,6 @@
  *		2 of the License, or (at your option) any later version.
  *
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
- *		2006.08.18	erik quanstrom <quanstro@quanstro.net>
- *				use select instead of signals so timeouts will work.
- *				
  */

 #include <stdlib.h>
@@ -18,6 +15,7 @@
 #include <linux/sockios.h>
 #include <sys/file.h>
 #include <sys/time.h>
+#include <sys/signal.h>
 #include <sys/ioctl.h>
 #include <linux/if.h>
 #include <linux/if_arp.h>
@@ -31,12 +29,12 @@
 #include <string.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
-#include <stdarg.h>

 #include "SNAPSHOT.h"

 static void usage(void) __attribute__((noreturn));

+int quit_on_reply=0;
 char *device="eth0";
 int ifindex;
 char *source;
@@ -45,10 +43,7 @@
 int dad, unsolicited, advert;
 int quiet;
 int count=-1;
-int ntosend=-1;
-int ntorecv=-1;
 int timeout;
-struct timeval timeouttv;
 int unicasting;
 int s;
 int broadcast_only;
@@ -64,19 +59,6 @@
 #define MS_TDIFF(tv1,tv2) ( ((tv1).tv_sec-(tv2).tv_sec)*1000 + \
 			   ((tv1).tv_usec-(tv2).tv_usec)/1000 )

-#define pkttrace(...)	/* fprintf(stderr, __VA_ARGS__) */
-
-void
-errexit(int err, const char* fmt, ...)
-{
-	va_list ap;
-
-	va_start(ap, fmt);
-	vfprintf(stderr, fmt, ap);
-	va_end(ap);
-	exit(err);
-}
-	
 void usage(void)
 {
 	fprintf(stderr,
@@ -97,6 +79,16 @@
 	exit(2);
 }

+void set_signal(int signo, void (*handler)(void))
+{
+	struct sigaction sa;
+
+	memset(&sa, 0, sizeof(sa));
+	sa.sa_handler = (void (*)(int))handler;
+	sa.sa_flags = SA_RESTART;
+	sigaction(signo, &sa, NULL);
+}
+
 int send_pack(int s, struct in_addr src, struct in_addr dst,
 	      struct sockaddr_ll *ME, struct sockaddr_ll *HE)
 {
@@ -130,9 +122,7 @@
 	p+=4;

 	gettimeofday(&now, NULL);
-	pkttrace("sendto->\n");
 	err = sendto(s, buf, p-buf, 0, (struct sockaddr*)HE, sizeof(*HE));
-	pkttrace("sendto<-\n");
 	if (err == p-buf) {
 		last = now;
 		sent++;
@@ -145,20 +135,20 @@
 void finish(void)
 {
 	if (!quiet) {
-		fflush(stdout);
-		fprintf(stderr, "Sent %d probes (%d broadcast(s))\n", sent, brd_sent);
-		fprintf(stderr, "Received %d response(s)", received);
+		printf("Sent %d probes (%d broadcast(s))\n", sent, brd_sent);
+		printf("Received %d response(s)", received);
 		if (brd_recv || req_recv) {
-			fprintf(stderr, " (");
+			printf(" (");
 			if (req_recv)
-				fprintf(stderr, "%d request(s)", req_recv);
+				printf("%d request(s)", req_recv);
 			if (brd_recv)
-				fprintf(stderr, "%s%d broadcast(s)",
+				printf("%s%d broadcast(s)",
 				       req_recv ? ", " : "",
 				       brd_recv);
-			fprintf(stderr, ")");
+			printf(")");
 		}
-		fprintf(stderr, "\n");
+		printf("\n");
+		fflush(stdout);
 	}
 	if (dad)
 		exit(!!received);
@@ -167,13 +157,34 @@
 	exit(!received);
 }

+void catcher(void)
+{
+	struct timeval tv;
+
+	gettimeofday(&tv, NULL);
+
+	if (start.tv_sec==0)
+		start = tv;
+
+	if (count-- == 0 || (timeout && MS_TDIFF(tv,start) > timeout*1000 + 500))
+		finish();
+
+	if (last.tv_sec==0 || MS_TDIFF(tv,last) > 500) {
+		send_pack(s, src, dst, &me, &he);
+		if (count == 0 && unsolicited)
+			finish();
+	}
+	alarm(1);
+}
+
 void print_hex(unsigned char *p, int len)
 {
 	int i;
-	for (i=0; i<len-1; i++)
-		printf("%02X:", p[i]);
-	if(len)
+	for (i=0; i<len; i++) {
 		printf("%02X", p[i]);
+		if (i != len-1)
+			printf(":");
+	}
 }

 int recv_pack(unsigned char *buf, int len, struct sockaddr_ll *FROM)
@@ -274,6 +285,8 @@
 		brd_recv++;
 	if (ah->ar_op == htons(ARPOP_REQUEST))
 		req_recv++;
+	if (quit_on_reply)
+		finish();
 	if(!broadcast_only) {
 		memcpy(he.sll_addr, p, me.sll_halen);
 		unicasting=1;
@@ -281,75 +294,26 @@
 	return 1;
 }

-
-unsigned char packet[4096];		// too big for stack on some arch.
-
-void
-pktloop(void)
-{
-	struct sockaddr_ll from;
-	socklen_t alen = sizeof(from);
-	fd_set rset;
-	struct timeval tmo;
-	int cc, i;
-
-	for(;;){
-		if(ntosend-- == 0)
-			break;
-		send_pack(s, src, dst, &me, &he);
-
-  		gettimeofday(&tmo, 0);
-		if(timeout)
-			i = MS_TDIFF(timeouttv, tmo) ;
-		else
-			i = 1000;
-		if(i < 0)
-			break;
-		if(i > 1000)
-			i = 1000;		// maximum select 1s.
-		tmo.tv_sec = i/1000;
-		tmo.tv_usec = (i%1000)*1000;
-
-		FD_ZERO(&rset);
-		FD_SET(s, &rset);
-		pkttrace("select %d ; %d\n", (int)tmo.tv_sec, (int)tmo.tv_usec);
-		i = select(s+1, &rset, 0, 0, &tmo);
-		pkttrace("<- select\n");
-		if(i == -1){
-			perror("arping: select");
-			exit(1);
-		}
-		if(i == 0){
-			gettimeofday(&tmo, 0);
-			i =  MS_TDIFF(timeouttv, tmo);
-			if(timeout && i <= 0)
-				break;
-			continue;
-		}
-		if ((cc = recvfrom(s, packet, sizeof(packet), 0,
-				   (struct sockaddr *)&from, &alen)) < 0) {
-			perror("arping: recvfrom");
-			continue;
-		}
-		if(recv_pack(packet, cc, &from))
-			if(--ntorecv == 0)
-				break;
-	}
-}
-
 int
 main(int argc, char **argv)
 {
-	int ch, onereply;
+	int socket_errno;
+	int ch;
+	uid_t uid = getuid();
+
+	s = socket(PF_PACKET, SOCK_DGRAM, 0);
+	socket_errno = errno;
+
+	setuid(uid);

 	while ((ch = getopt(argc, argv, "h?bfDUAqc:w:s:I:V")) != EOF) {
 		switch(ch) {
 		case 'b':
-			broadcast_only = 1;
+			broadcast_only=1;
 			break;
 		case 'D':
 			dad++;
-			onereply = 1;
+			quit_on_reply=1;
 			break;
 		case 'U':
 			unsolicited++;
@@ -365,15 +329,13 @@
 			count = atoi(optarg);
 			break;
 		case 'w':
-			gettimeofday(&timeouttv, 0);
-			timeouttv.tv_sec += atoi(optarg);
-			timeout = 1;
+			timeout = atoi(optarg);
 			break;
 		case 'I':
  			device = optarg;
  			break;
  		case 'f':
- 			onereply = 1;
+ 			quit_on_reply=1;
 			break;
 		case 's':
 			source = optarg;
@@ -392,26 +354,19 @@

 	if (argc != 1)
 		usage();
-	target = *argv;

-	if(onereply)
-		ntorecv = 1;
-	if(timeout)			// strange ping compatability.
-		ntorecv = count;
-	else
-		ntosend = count;
+	target = *argv;

-	if (device == 0) {
+	if (device == NULL) {
 		fprintf(stderr, "arping: device (option -I) is required\n");
 		usage();
 	}

-	s = socket(PF_PACKET, SOCK_DGRAM, 0);
 	if (s < 0) {
+		errno = socket_errno;
 		perror("arping: socket");
 		exit(2);
 	}
-	setuid(getuid());

 	if (1) {
 		struct ifreq ifr;
@@ -424,13 +379,19 @@
 		ifindex = ifr.ifr_ifindex;

 		if (ioctl(s, SIOCGIFFLAGS, (char*)&ifr)) {
-			perror("arping: ioctl(SIOCGIFFLAGS)");
+			perror("ioctl(SIOCGIFFLAGS)");
 			exit(2);
 		}
-		if (!(ifr.ifr_flags&IFF_UP))
-			errexit(2, "Interface \"%s\" is down\n", device);
-		if (ifr.ifr_flags&(IFF_NOARP|IFF_LOOPBACK))
-			errexit(dad ? 0 : 2, "Interface \"%s\" is not ARPable\n", device);
+		if (!(ifr.ifr_flags&IFF_UP)) {
+			if (!quiet)
+				printf("Interface \"%s\" is down\n", device);
+			exit(2);
+		}
+		if (ifr.ifr_flags&(IFF_NOARP|IFF_LOOPBACK)) {
+			if (!quiet)
+				printf("Interface \"%s\" is not ARPable\n", device);
+			exit(dad?0:2);
+		}
 	}

 	if (inet_aton(target, &dst) != 1) {
@@ -456,7 +417,7 @@
 		int probe_fd = socket(AF_INET, SOCK_DGRAM, 0);

 		if (probe_fd < 0) {
-			perror("arping: socket");
+			perror("socket");
 			exit(2);
 		}
 		if (device) {
@@ -468,7 +429,7 @@
 		if (src.s_addr) {
 			saddr.sin_addr = src;
 			if (bind(probe_fd, (struct sockaddr*)&saddr, sizeof(saddr)) == -1) {
-				perror("arping: bind");
+				perror("bind");
 				exit(2);
 			}
 		} else if (!dad) {
@@ -481,11 +442,11 @@
 			if (setsockopt(probe_fd, SOL_SOCKET, SO_DONTROUTE, (char*)&on,
sizeof(on)) == -1)
 				perror("WARNING: setsockopt(SO_DONTROUTE)");
 			if (connect(probe_fd, (struct sockaddr*)&saddr, sizeof(saddr)) == -1) {
-				perror("arping: connect");
+				perror("connect");
 				exit(2);
 			}
 			if (getsockname(probe_fd, (struct sockaddr*)&saddr, &alen) == -1) {
-				perror("arping: getsockname");
+				perror("getsockname");
 				exit(2);
 			}
 			src = saddr.sin_addr;
@@ -497,34 +458,60 @@
 	me.sll_ifindex = ifindex;
 	me.sll_protocol = htons(ETH_P_ARP);
 	if (bind(s, (struct sockaddr*)&me, sizeof(me)) == -1) {
-		perror("arping: bind");
+		perror("bind");
 		exit(2);
 	}

 	if (1) {
 		socklen_t alen = sizeof(me);
 		if (getsockname(s, (struct sockaddr*)&me, &alen) == -1) {
-			perror("arping: getsockname");
+			perror("getsockname");
 			exit(2);
 		}
 	}
-	if (me.sll_halen == 0)
-		errexit(dad ? 0 : 2, "Interface \"%s\" is not ARPable (no ll
address)\n", device);
+	if (me.sll_halen == 0) {
+		if (!quiet)
+			printf("Interface \"%s\" is not ARPable (no ll address)\n", device);
+		exit(dad?0:2);
+	}

 	he = me;
 	memset(he.sll_addr, -1, he.sll_halen);

 	if (!quiet) {
-		fprintf(stderr, "ARPING %s ", inet_ntoa(dst));
-		fprintf(stderr, "from %s %s\n",  inet_ntoa(src), device ? : "");
+		printf("ARPING %s ", inet_ntoa(dst));
+		printf("from %s %s\n",  inet_ntoa(src), device ? : "");
 	}

-	if (!src.s_addr && !dad)
-		errexit(2, "arping: no source address in not-DAD mode\n");
+	if (!src.s_addr && !dad) {
+		fprintf(stderr, "arping: no source address in not-DAD mode\n");
+		exit(2);
+	}
+
+	set_signal(SIGINT, finish);
+	set_signal(SIGALRM, catcher);
+
+	catcher();

-	pktloop();
-	finish();
-	return 1;		// shut up gcc.
+	while(1) {
+		sigset_t sset, osset;
+		unsigned char packet[4096];
+		struct sockaddr_ll from;
+		socklen_t alen = sizeof(from);
+		int cc;
+
+		if ((cc = recvfrom(s, packet, sizeof(packet), 0,
+				   (struct sockaddr *)&from, &alen)) < 0) {
+			perror("arping: recvfrom");
+			continue;
+		}
+		sigemptyset(&sset);
+		sigaddset(&sset, SIGALRM);
+		sigaddset(&sset, SIGINT);
+		sigprocmask(SIG_BLOCK, &sset, &osset);
+		recv_pack(packet, cc, &from);
+		sigprocmask(SIG_SETMASK, &osset, NULL);
+	}
 }
