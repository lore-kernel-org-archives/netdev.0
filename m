From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: [PATCH 1/2] netem: trace enhancement: iproute2
Date: Tue, 20 Nov 2007 23:12:36 +0100
Message-ID: <20071120231236.ynpcqyrm8c8c04gw@email.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:53453 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756756AbXKTWTm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 17:19:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Upon starting netem with the trace enhancement (e.g. netem trace) a new 
process (called flowseed) is created which sends the "delay-values" to 
the netem kernel module with the help of the configfs. The values are 
written in chunks of 1000, thus avoiding to many context switches.
When the corresponding qdisc gets deleted the flowseed process 
terminates himself (because he receives a negative return value from 
the write call).

Since we have inserted a subdirectory iproute2/netem/distributions the 
patch became quite huge. For ease of discussion I inline the relevant 
part of the patch in this email and the whole patch can be found on 
http://www.tcn.hypert.net/tcn_iproute2_2_6_23

Signed-off-by: Ariane Keller <arkeller@ee.ethz.ch>

---

diff -uprN originIPRoute/include/linux/pkt_sched.h 
iproute2-2.6.23/include/linux/pkt_sched.h
--- originIPRoute/include/linux/pkt_sched.h	2007-10-16 
23:27:42.000000000 +0200
+++ iproute2-2.6.23/include/linux/pkt_sched.h	2007-11-19 
18:42:48.000000000 +0100
@@ -439,6 +439,8 @@ enum
	TCA_NETEM_DELAY_DIST,
	TCA_NETEM_REORDER,
	TCA_NETEM_CORRUPT,
+	TCA_NETEM_TRACE,
+	TCA_NETEM_STATS,
	__TCA_NETEM_MAX,
};

@@ -454,6 +456,37 @@ struct tc_netem_qopt
	__u32	jitter;		/* random jitter in latency (us) */
};

+struct tc_netem_stats
+{
+	int packetcount;
+	int packetok;
+	int normaldelay;
+	int drops;
+	int dupl;
+	int corrupt;
+	int novaliddata;
+	int uninitialized;
+	int bufferunderrun;
+	int bufferinuseempty;
+	int noemptybuffer;
+	int readbehindbuffer;
+	int buffer1_reloads;
+	int buffer2_reloads;
+	int tobuffer1_switch;
+	int tobuffer2_switch;
+	int switch_to_emptybuffer1;
+	int switch_to_emptybuffer2;
+};
+
+
+struct tc_netem_trace
+{
+  __u32 fid;
+  __u32 def;
+  __u32 ticks;
+};
+
+
struct tc_netem_corr
{
	__u32	delay_corr;	/* delay correlation */
diff -uprN originIPRoute/netem/trace/flowseed.c 
iproute2-2.6.23/netem/trace/flowseed.c
--- originIPRoute/netem/trace/flowseed.c	1970-01-01 01:00:00.000000000 +0100
+++ iproute2-2.6.23/netem/trace/flowseed.c	2007-11-20 14:32:54.000000000 +0100
@@ -0,0 +1,117 @@
+/* flowseed.c    flowseedprocess to deliver values for packet delay,
+ *               duplication, loss and curruption form userspace to netem
+ *
+ *               This program is free software; you can redistribute 
it and/or
+ *               modify it under the terms of the GNU General Public License
+ *               as published by the Free Software Foundation; either version
+ *               2 of the License, or (at your option) any later version.
+ *
+ *  Authors:     Ariane Keller <arkeller@ee.ethz.ch> ETH Zurich
+ *               Rainer Baumann <baumann@hypert.net> ETH Zurich
+ */
+
+#include <ctype.h>
+#include <stdio.h>
+#include <fcntl.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <unistd.h>
+
+#define DATA_PACKAGE 4000
+#define DATA_PACKAGE_ID DATA_PACKAGE + sizeof(unsigned int) + sizeof(int)
+
+/* maximal amount of parallel flows */
+#define MAX_FLOWS 4
+
+int main(int argc, char *argv[])
+{
+	if (argc < 3) {
+		printf("usage: <tracefilename> <loop>");
+		return 0;
+	}
+	char *sendpkg;
+	sendpkg = malloc(DATA_PACKAGE_ID);
+
+	if (sendpkg == NULL) {
+		printf("out of memory\n");
+		return 0;
+	}
+
+	int fid = getpid();
+	char dirname[20];
+	char path[30];
+	int fdflowseed, fdtcn, dirsux;
+	unsigned int loop;
+	int infinity = 0;
+	int moreData = 1, r = 0, rold = 0;
+	loop = strtoul(argv[2], NULL, 10);
+
+	snprintf(dirname, sizeof(path), "/config/tcn/%d", fid);
+	dirsux = mkdir(dirname, S_IRWXO);
+	snprintf(path, sizeof(path), "%s/delayvalue", dirname);
+
+	if ((fdtcn = open(path, O_WRONLY, 0)) < 0) {
+		perror("fdtcn: ");
+		return 0;
+	}
+
+	if ((fdflowseed = open(argv[1], O_RDONLY, 0)) < 0) {
+		perror("cannot open tracefile");
+		return 0;
+	}
+
+	if (loop == 0)
+		infinity = 1;
+
+	while (loop > 0 || infinity) {
+		loop--;
+		int w;
+		/*read action values from tracefile */
+		while ((r = read(fdflowseed, sendpkg + rold, DATA_PACKAGE - rold)) >= 0) {
+			if (r + rold < DATA_PACKAGE) {
+				/* Tail of input file reached,
+				   set rest at start from next iteration */
+				rold = r;
+				if (lseek(fdflowseed, 0L, SEEK_SET) < 0)
+					perror("lseek reset");
+				break;
+			}
+			r = 0;
+			rold = 0;
+			memcpy(sendpkg + DATA_PACKAGE, &fid, sizeof(int));
+			memcpy(sendpkg + DATA_PACKAGE + sizeof(int), &moreData,
+			       sizeof(int));
+			w = write(fdtcn, sendpkg, DATA_PACKAGE_ID);
+			if (w < 0) {
+				perror("write");
+				close(fdflowseed);
+				close(fdtcn);
+				rmdir(dirname);
+				free(sendpkg);
+				return 0;
+			}
+
+		}
+	}
+	/* last packet: say kernel that no more data is available
+	   enables to distinguish between bufferunderrun and no
+	   more data available.
+	*/
+	moreData = 0;
+	memcpy(sendpkg + DATA_PACKAGE, &fid, sizeof(int));
+	memcpy(sendpkg + DATA_PACKAGE + sizeof(int), &moreData, sizeof(int));
+	int w = write(fdtcn, sendpkg, DATA_PACKAGE_ID);
+	if (w < 0)
+		perror("Failure writing last msg to kernel");
+
+	printf("Tail of input file reached. Exit.\n");
+
+	close(fdflowseed);
+	close(fdtcn);
+	rmdir(dirname);
+	free(sendpkg);
+
+	return 0;
+}
diff -uprN originIPRoute/tc/q_netem.c iproute2-2.6.23/tc/q_netem.c
--- originIPRoute/tc/q_netem.c	2007-10-16 23:27:42.000000000 +0200
+++ iproute2-2.6.23/tc/q_netem.c	2007-11-20 14:46:24.000000000 +0100
@@ -6,7 +6,12 @@
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
  *
+ *		README files: 	iproute2/netem/distribution
+ *				iproute2/netem/trace
+ *
  * Authors:	Stephen Hemminger <shemminger@osdl.org>
+ *              netem trace: Ariane Keller <arkeller@ee.ethz.ch> ETH Zurich
+ *                           Rainer Baumann <baumann@hypert.net> ETH Zurich
  *
  */

@@ -20,6 +25,10 @@
#include <arpa/inet.h>
#include <string.h>
#include <errno.h>
+#include <sys/mount.h>
+#include <ctype.h>
+#include <string.h>
+#include <sys/types.h>

#include "utils.h"
#include "tc_util.h"
@@ -42,6 +51,7 @@ static void explain1(const char *arg)
	fprintf(stderr, "Illegal \"%s\"\n", arg);
}

+#define FLOWPATH "/usr/local/bin/flowseed"
#define usage() return(-1)

/*
@@ -129,6 +139,7 @@ static int netem_parse_opt(struct qdisc_
	struct tc_netem_corr cor;
	struct tc_netem_reorder reorder;
	struct tc_netem_corrupt corrupt;
+	struct tc_netem_trace traceopt;
	__s16 *dist_data = NULL;
	int present[__TCA_NETEM_MAX];

@@ -137,6 +148,7 @@ static int netem_parse_opt(struct qdisc_
	memset(&cor, 0, sizeof(cor));
	memset(&reorder, 0, sizeof(reorder));
	memset(&corrupt, 0, sizeof(corrupt));
+	memset(&traceopt, 0, sizeof(traceopt));
	memset(present, 0, sizeof(present));

	while (argc > 0) {
@@ -243,6 +255,73 @@ static int netem_parse_opt(struct qdisc_
		} else if (strcmp(*argv, "help") == 0) {
			explain();
			return -1;
+		} else if (strcmp(*argv, "trace") == 0) {
+			int pid_tc = getpid();
+			int fd;
+			int execvl;
+			char *filename;
+			int pid;
+			/* configfs for data transfer user <-> kernel space */
+			int b = mkdir("/config", S_IRWXO);
+			if (b && errno != EEXIST) {
+				perror("mkdir");
+				return -1;
+			}
+			int a = mount("", "/config", "configfs", 0, "");
+			if (a && errno != EBUSY) {
+				perror("mounting configfs");
+				return -1;
+			}
+
+			/*get ticks correct since tracefile is in us,
+			 *and ticks may not be equal to us
+			 */
+			get_ticks(&traceopt.ticks, "1000us");
+			NEXT_ARG();
+			filename = *argv;
+			if ((fd = open(filename, O_RDONLY, 0)) < 0) {
+				fprintf(stderr, "Cannot open trace file \n");
+				return -1;
+			}
+			close(fd);
+			if (NEXT_IS_NUMBER()) {
+				NEXT_ARG();
+				/*child will load tracefile to kernel */
+				switch (pid = fork()) {
+				case -1:{
+					fprintf(stderr,
+						"Cannot fork\n");
+					return -1;
+					}
+				case 0:{
+					/* child wait for parent to die to be
+					 * sure that the kernel is ready for
+					 * for the tracefiledata
+					 */
+					while (pid_tc == getppid())
+						sleep(0);
+						execvl = execl(FLOWPATH,
+								"flowseed",
+								filename,
+								*argv, 0);
+					if (execvl < 0) {
+						fprintf(stderr,
+						"starting child failed\n");
+						return -1;
+					}
+					}
+				}
+			}
+			else {
+				explain();
+				return -1;
+			}
+			traceopt.def = 0;
+			if (NEXT_IS_NUMBER()) {
+				NEXT_ARG();
+				traceopt.def = atoi(*argv);
+			}
+			traceopt.fid = pid;
		} else {
			fprintf(stderr, "What is \"%s\"?\n", *argv);
			explain();
@@ -291,7 +370,13 @@ static int netem_parse_opt(struct qdisc_
			      dist_data, dist_size*sizeof(dist_data[0])) < 0)
			return -1;
	}
-	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
+	if (traceopt.fid) {
+		if (addattr_l(n, TCA_BUF_MAX, TCA_NETEM_TRACE, &traceopt,
+		     sizeof(traceopt)) < 0)
+			return -1;
+	}
+
+	tail->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail;
	return 0;
}

@@ -300,6 +385,8 @@ static int netem_print_opt(struct qdisc_
	const struct tc_netem_corr *cor = NULL;
	const struct tc_netem_reorder *reorder = NULL;
	const struct tc_netem_corrupt *corrupt = NULL;
+	const struct tc_netem_trace *traceopt = NULL;
+	const struct tc_netem_stats *tracestats = NULL;
	struct tc_netem_qopt qopt;
	int len = RTA_PAYLOAD(opt) - sizeof(qopt);
	SPRINT_BUF(b1);
@@ -333,9 +420,49 @@ static int netem_print_opt(struct qdisc_
				return -1;
			corrupt = RTA_DATA(tb[TCA_NETEM_CORRUPT]);
		}
+		if (tb[TCA_NETEM_TRACE]) {
+			if (RTA_PAYLOAD(tb[TCA_NETEM_TRACE]) < sizeof(*traceopt))
+				return -1;
+			traceopt = RTA_DATA(tb[TCA_NETEM_TRACE]);
+		}
+		if (tb[TCA_NETEM_STATS]) {
+			if (RTA_PAYLOAD(tb[TCA_NETEM_STATS]) < sizeof(*tracestats))
+				return -1;
+			tracestats = RTA_DATA(tb[TCA_NETEM_STATS]);
+		}
	}

	fprintf(f, "limit %d", qopt.limit);
+	if (traceopt->fid) {
+		fprintf(f, " trace\n");
+
+		fprintf(f, "packetcount= %d\n", tracestats->packetcount);
+		fprintf(f, "packetok= %d\n", tracestats->packetok);
+		fprintf(f, "normaldelay= %d\n", tracestats->normaldelay);
+		fprintf(f, "drops= %d\n", tracestats->drops);
+		fprintf(f, "dupl= %d\n", tracestats->dupl);
+		fprintf(f, "corrupt= %d\n", tracestats->corrupt);
+		fprintf(f, "novaliddata= %d\n", tracestats->novaliddata);
+		fprintf(f, "uninitialized= %d\n", tracestats->uninitialized);
+		fprintf(f, "bufferunderrun= %d\n", tracestats->bufferunderrun);
+		fprintf(f, "bufferinuseempty= %d\n",
+			tracestats->bufferinuseempty);
+		fprintf(f, "noemptybuffer= %d\n", tracestats->noemptybuffer);
+		fprintf(f, "readbehindbuffer= %d\n",
+			tracestats->readbehindbuffer);
+		fprintf(f, "buffer1_reloads= %d\n",
+			tracestats->buffer1_reloads);
+		fprintf(f, "buffer2_reloads= %d\n",
+			tracestats->buffer2_reloads);
+		fprintf(f, "tobuffer1_switch= %d\n",
+			tracestats->tobuffer1_switch);
+		fprintf(f, "tobuffer2_switch= %d\n",
+			tracestats->tobuffer2_switch);
+		fprintf(f, "switch_to_emptybuffer1= %d\n",
+			tracestats->switch_to_emptybuffer1);
+		fprintf(f, "switch_to_emptybuffer2= %d\n",
+			tracestats->switch_to_emptybuffer2);
+	}

	if (qopt.latency) {
		fprintf(f, " delay %s", sprint_ticks(qopt.latency, b1));

