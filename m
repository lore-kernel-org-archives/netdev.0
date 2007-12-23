From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: Re: [PATCH 0/2] netem: trace enhancement: iproute
Date: Sun, 23 Dec 2007 20:54:56 +0100
Message-ID: <476EBD10.3040209@ee.ethz.ch>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch> <47559119.6070803@candelatech.com> <47559455.1080009@ee.ethz.ch> <47559763.9050408@candelatech.com> <4755C984.70906@ee.ethz.ch> <4755D2EB.4000807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:39092 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754069AbXLWTzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Dec 2007 14:55:06 -0500
In-Reply-To: <4755D2EB.4000807@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The iproute patch is to big to send on the mailing list,
since the distribution data have changed the directory.
For ease of discussion I add the important changes in this mail.

signed-of-by: Ariane Keller <ariane.keller@tik.ee.ethz.ch

---

diff -uprN iproute2-2.6.23/netem/trace/flowseed.c 
iproute2-2.6.23_buf/netem/trace/flowseed.c
--- iproute2-2.6.23/netem/trace/flowseed.c	1970-01-01 01:00:00.000000000 
+0100
+++ iproute2-2.6.23_buf/netem/trace/flowseed.c	2007-12-12 
08:43:01.000000000 +0100
@@ -0,0 +1,209 @@
+/* flowseed.c    flowseedprocess to deliver values for packet delay,
+ *               duplication, loss and curruption form userspace to netem
+ *
+ *               This program is free software; you can redistribute it 
and/or
+ *               modify it under the terms of the GNU General Public 
License
+ *               as published by the Free Software Foundation; either 
version
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
+#include <sys/ipc.h>
+#include <sys/sem.h>
+#include <signal.h>
+
+#include "utils.h"
+#include "linux/pkt_sched.h"
+
+#define DATA_PACKAGE 4000
+#define DATA_PACKAGE_ID DATA_PACKAGE + sizeof(unsigned int) + sizeof(int)
+#define TCA_BUF_MAX  (64*1024)
+/* maximal amount of parallel flows */
+struct rtnl_handle rth;
+unsigned int loop;
+int infinity = 0;
+int fdflowseed;
+char *sendpkg;
+int fid;
+int initialized = 0;
+int semid;
+int moreData = 1, r = 0, rold = 0;
+FILE * file;
+
+
+int printfct(const struct sockaddr_nl *who,
+		       struct nlmsghdr *n,
+		       void *arg)
+{
+	struct {
+		struct nlmsghdr 	n;
+		struct tcmsg 		t;
+		char   			buf[TCA_BUF_MAX];
+	} req;
+	struct tcmsg *t = NLMSG_DATA(n);
+	struct rtattr *tail = NULL;
+	struct tc_netem_qopt opt;
+	memset(&opt, 0, sizeof(opt));
+
+	if(n->nlmsg_type == RTM_DELQDISC) {
+		goto outerr;
+	}
+	else if(n->nlmsg_type == RTM_NEWQDISC){
+		initialized = 1;
+	
+		memset(&req, 0, sizeof(req));
+		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcmsg));
+		req.n.nlmsg_flags = NLM_F_REQUEST;
+		req.n.nlmsg_type = RTM_NEWQDISC;
+		req.t.tcm_family = AF_UNSPEC;
+		req.t.tcm_handle = t->tcm_handle;
+		req.t.tcm_parent = t->tcm_parent;
+		req.t.tcm_ifindex = t->tcm_ifindex;
+
+		tail = NLMSG_TAIL(&req.n);
+again:
+		if (loop <= 0 && !infinity){
+			goto out;
+		}
+		if ((r = read(fdflowseed, sendpkg + rold, DATA_PACKAGE - rold)) >= 0) {
+			if (r + rold < DATA_PACKAGE) {
+			/* Tail of input file reached,
+			   set rest at start from next iteration */
+				rold = r;
+				fprintf(file, "flowseed: at end of file.\n");
+
+				if (lseek(fdflowseed, 0L, SEEK_SET) < 0){
+					perror("lseek reset");
+					goto out;
+				}
+				goto again;
+			}
+			r = 0;
+			rold = 0;
+			memcpy(sendpkg + DATA_PACKAGE, &fid, sizeof(int));
+			memcpy(sendpkg + DATA_PACKAGE + sizeof(int), &moreData, sizeof(int));
+		
+			/* opt has to be added for each netem request */
+			if (addattr_l(&req.n, TCA_BUF_MAX, TCA_OPTIONS, &opt, sizeof(opt)) < 0){
+				perror("add options");
+				return -1;
+			}
+
+			if(addattr_l(&req.n, TCA_BUF_MAX, TCA_NETEM_TRACE_DATA, sendpkg, 
DATA_PACKAGE_ID) < 0){
+				perror("add data\n");
+				return -1;
+			}
+
+			tail->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)tail;
+
+			if(rtnl_send(&rth, (char*)&req, req.n.nlmsg_len) < 0){
+				perror("send data");
+				return -1;
+			}
+			return 0;
+		}
+	}
+/* no more data, what to do? we send a notification to the kernel module */
+out:
+	fprintf(stderr, "flowseed: Tail of input file reached. Exit.\n");
+	fprintf(file, "flowseed: Tail of input file reached. Exit.\n");
+	moreData = 0;
+	memcpy(sendpkg + DATA_PACKAGE, &fid, sizeof(int));
+	memcpy(sendpkg + DATA_PACKAGE + sizeof(int), &moreData, sizeof(int));
+	if (addattr_l(&req.n, TCA_BUF_MAX, TCA_OPTIONS, &opt, sizeof(opt)) < 0){
+		perror("add options");
+		goto outerr;
+	}
+	if(addattr_l(&req.n, TCA_BUF_MAX, TCA_NETEM_TRACE_DATA, sendpkg, 
DATA_PACKAGE_ID) < 0){
+		perror("add data\n");
+		goto outerr;
+	}
+	
+	tail->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)tail;
+
+	if(rtnl_send(&rth, (char*)&req, req.n.nlmsg_len) < 0){
+		perror("rtnl_send");
+	}
+outerr:
+	fprintf(file, "flowseed: outerr Exit.\n");
+	fclose(file);
+	close(fdflowseed);
+	free(sendpkg);
+	rtnl_close(&rth);
+	exit(0);
+}
+
+void sigact(int signal){
+	if(initialized){
+		return;
+	}
+	else{
+		fprintf(stderr, "flowseed: not yet initialized. Exit\n");
+		exit(0);
+	}
+}
+int main(int argc, char *argv[])
+{
+	struct sembuf buf;
+        file = fopen("flowseedout.txt", "a+");
+	fprintf(file, "flowseed: initial msg.\n");
+
+	if (argc < 3) {
+		printf("usage: <tracefilename> <loop>");
+		return -1;
+	}
+	loop = strtoul(argv[2], NULL, 10);
+	if (loop == 0)
+		infinity = 1;
+
+	if ((fdflowseed = open(argv[1], O_RDONLY, 0)) < 0) {
+		perror("cannot open tracefile");
+		return -1;
+	}
+
+	fid = getpid();
+	sendpkg = malloc(DATA_PACKAGE_ID);
+
+	if (rtnl_open(&rth, 0) < 0) {
+		perror("Cannot open rtnetlink");
+		return -1;
+	}
+	ll_init_map(&rth);
+	/* we are ready to receive notifications */
+	if((semid = semget(0x12345678, 1, IPC_CREAT | 0666))<0){
+		perror("semget");
+		return -1;
+	}
+	buf.sem_num = 0;
+	buf.sem_op = +1;
+	buf.sem_flg = SEM_UNDO;
+	if(semop(semid, &buf, 1) < 0){
+		perror("semop");
+		return -1;
+	}
+	/* if the user typed an invalid command we cannot detect this
+ 	 * therefore we set a timer, if the timer expires before we receive
+ 	 * any message from the kernel module, we assume there was an
+ 	 * error and quit.
+ 	 */
+	signal(SIGALRM, sigact);
+	alarm(3);
+
+	/* listen to notifications from kernel */
+	if (rtnl_listen(&rth, printfct, NULL) < 0) {
+		perror("listen");
+		rtnl_close(&rth);
+		exit(2);
+	}
+	return 0;
+}


diff -uprN iproute2-2.6.23/tc/q_netem.c iproute2-2.6.23_buf/tc/q_netem.c
--- iproute2-2.6.23/tc/q_netem.c	2007-10-16 23:27:42.000000000 +0200
+++ iproute2-2.6.23_buf/tc/q_netem.c	2007-12-21 19:08:19.000000000 +0100
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

@@ -20,6 +25,9 @@
  #include <arpa/inet.h>
  #include <string.h>
  #include <errno.h>
+#include <sys/types.h>
+#include <sys/ipc.h>
+#include <sys/sem.h>

  #include "utils.h"
  #include "tc_util.h"
@@ -34,7 +42,8 @@ static void explain(void)
  "                 [ drop PERCENT [CORRELATION]] \n" \
  "                 [ corrupt PERCENT [CORRELATION]] \n" \
  "                 [ duplicate PERCENT [CORRELATION]]\n" \
-"                 [ reorder PRECENT [CORRELATION] [ gap DISTANCE ]]\n");
+"                 [ reorder PRECENT [CORRELATION] [ gap DISTANCE ]]\n" \
+"                 [ trace PATH buf NR_BUFS loops NR_LOOPS [DEFAULT]\n");
  }

  static void explain1(const char *arg)
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

@@ -137,8 +148,12 @@ static int netem_parse_opt(struct qdisc_
  	memset(&cor, 0, sizeof(cor));
  	memset(&reorder, 0, sizeof(reorder));
  	memset(&corrupt, 0, sizeof(corrupt));
+	memset(&traceopt, 0, sizeof(traceopt));
  	memset(present, 0, sizeof(present));
-
+	if (argc == 0) {
+		explain();
+		return -1;
+	}
  	while (argc > 0) {
  		if (matches(*argv, "limit") == 0) {
  			NEXT_ARG();
@@ -164,7 +179,7 @@ static int netem_parse_opt(struct qdisc_
  				if (NEXT_IS_NUMBER()) {
  					NEXT_ARG();
  					++present[TCA_NETEM_CORR];
-					if (get_percent(&cor.delay_corr,							*argv)) {
+					if (get_percent(&cor.delay_corr, *argv)) {
  						explain1("latency");
  						return -1;
  					}
@@ -243,6 +258,75 @@ static int netem_parse_opt(struct qdisc_
  		} else if (strcmp(*argv, "help") == 0) {
  			explain();
  			return -1;
+		} else if (strcmp(*argv, "trace") == 0) {
+			int fd;
+			int execvl;
+			char *filename;
+			int pid;
+		
+			/*get ticks correct since tracefile is in us,
+			 *and ticks may not be equal to us
+			 */
+			get_ticks(&traceopt.ticks, "1000us");
+			NEXT_ARG();
+			filename = *argv;
+			if ((fd = open(filename, O_RDONLY, 0)) < 0) {
+				fprintf(stderr, "Cannot open trace file %s! \n", filename);
+				return -1;
+			}
+			close(fd);
+			NEXT_ARG();
+			if(strcmp(*argv, "buf") == 0) {
+				NEXT_ARG();
+				traceopt.nr_bufs = atoi(*argv);
+			}
+			else{
+				explain();
+				return -1;
+			}
+			NEXT_ARG();
+			if (strcmp(*argv, "loops") == 0 && NEXT_IS_NUMBER()) {
+				NEXT_ARG();
+				/*child will load tracefile to kernel */
+				switch (pid = fork()) {
+				case -1:{
+					fprintf(stderr,
+						"Cannot fork\n");
+					return -1;
+					}
+				case 0:{
+					execvl = execl(FLOWPATH, "flowseed", filename, *argv, NULL);
+					if (execvl < 0) {
+						fprintf(stderr,
+						"starting child failed\n");
+						return -1;
+					}
+					}
+				default:{
+					/* parent has to wait until child has done rtnl_open.
+ 					 * otherwise the kernel module cannot send a notification
+ 					 * to the child
+ 					 */
+					int semid = semget(0x12345678, 1, IPC_CREAT | 0666);
+					struct sembuf buf;
+					buf.sem_num = 0;
+					buf.sem_op = -1;
+					buf.sem_flg = SEM_UNDO;
+					semop(semid, &buf, 1);
+					semctl(semid, 0, IPC_RMID);
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
@@ -291,7 +375,13 @@ static int netem_parse_opt(struct qdisc_
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

@@ -300,6 +390,8 @@ static int netem_print_opt(struct qdisc_
  	const struct tc_netem_corr *cor = NULL;
  	const struct tc_netem_reorder *reorder = NULL;
  	const struct tc_netem_corrupt *corrupt = NULL;
+	const struct tc_netem_trace *traceopt = NULL;
+	const struct tc_netem_stats *tracestats = NULL;
  	struct tc_netem_qopt qopt;
  	int len = RTA_PAYLOAD(opt) - sizeof(qopt);
  	SPRINT_BUF(b1);
@@ -333,9 +425,31 @@ static int netem_print_opt(struct qdisc_
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
+	if (traceopt && traceopt->fid) {
+		fprintf(f, " trace\n");
+
+		fprintf(f, "packetcount= %d\n", tracestats->packetcount);
+		fprintf(f, "packetok= %d\n", tracestats->packetok);
+		fprintf(f, "normaldelay= %d\n", tracestats->normaldelay);
+		fprintf(f, "drops= %d\n", tracestats->drops);
+		fprintf(f, "dupl= %d\n", tracestats->dupl);
+		fprintf(f, "corrupt= %d\n", tracestats->corrupt);
+		fprintf(f, "novaliddata= %d\n", tracestats->novaliddata);
+		fprintf(f, "bufferreload= %d\n", tracestats->reloadbuffer);
+		}

  	if (qopt.latency) {
  		fprintf(f, " delay %s", sprint_ticks(qopt.latency, b1));

