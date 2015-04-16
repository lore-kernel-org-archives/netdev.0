From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next v2] tc: built-in eBPF exec proxy
Date: Thu, 16 Apr 2015 21:20:06 +0200
Message-ID: <d41d6003521cbb231112e4a78c10cb8c07f05cc2.1429211530.git.daniel@iogearbox.net>
Cc: hannes@stressinduktion.org, ast@plumgrid.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58640 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbbDPTUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 15:20:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work follows upon commit 6256f8c9e45f ("tc, bpf: finalize eBPF
support for cls and act front-end") and takes up the idea proposed by
Hannes Frederic Sowa to spawn a shell (or any other command) that holds
generated eBPF map file descriptors.

File descriptors, based on their id, are being fetched from the same
unix domain socket as demonstrated in the bpf_agent, the shell spawned
via execvpe(2) and the map fds passed over the environment, and thus
are made available to applications in the fashion of std{in,out,err}
for read/write access, for example in case of iproute2's examples/bpf/:

  # env | grep BPF
  BPF_NUM_MAPS=3
  BPF_MAP1=6        <- BPF_MAP_ID_QUEUE (id 1)
  BPF_MAP0=5        <- BPF_MAP_ID_PROTO (id 0)
  BPF_MAP2=7        <- BPF_MAP_ID_DROPS (id 2)

  # ls -la /proc/self/fd
  [...]
  lrwx------. 1 root root 64 Apr 14 16:46 0 -> /dev/pts/4
  lrwx------. 1 root root 64 Apr 14 16:46 1 -> /dev/pts/4
  lrwx------. 1 root root 64 Apr 14 16:46 2 -> /dev/pts/4
  [...]
  lrwx------. 1 root root 64 Apr 14 16:46 5 -> anon_inode:bpf-map
  lrwx------. 1 root root 64 Apr 14 16:46 6 -> anon_inode:bpf-map
  lrwx------. 1 root root 64 Apr 14 16:46 7 -> anon_inode:bpf-map

The advantage (as opposed to the direct/native usage) is that now the
shell is map fd owner and applications can terminate and easily reattach
to descriptors w/o any kernel changes. Moreover, multiple applications
can easily read/write eBPF maps simultaneously.

To further allow users for experimenting with that, next step is to add
a small helper that can get along with simple data types, so that also
shell scripts can make use of bpf syscall, f.e to read/write into maps.

Generally, this allows for prepopulating maps, or any runtime altering
which could influence eBPF program behaviour (f.e. different run-time
classifications, skb modifications, ...), dumping of statistics, etc.

Reference: http://thread.gmane.org/gmane.linux.network/357471/focus=357860
Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 ( Stephen, this applies to current net-next branch of iproute2. )
 v1 -> v2:
  - s/bpf_map_set_env/bpf_map_get_from_env/ as suggested by Alexei
  - Rest as is, also kept reviewer acks

 examples/bpf/bpf_agent.c |  55 ++++++++++++++----
 examples/bpf/bpf_prog.c  |  27 +++++++++
 tc/Makefile              |   7 ++-
 tc/e_bpf.c               | 147 +++++++++++++++++++++++++++++++++++++++++++++++
 tc/f_bpf.c               |   2 +-
 tc/m_action.c            |   2 +-
 tc/m_bpf.c               |   2 +-
 tc/tc.c                  |   9 +--
 tc/tc_bpf.c              |  98 ++++++++++++++++++++++++++++---
 tc/tc_bpf.h              |  15 ++++-
 tc/tc_common.h           |   3 +
 tc/tc_exec.c             | 109 +++++++++++++++++++++++++++++++++++
 tc/tc_filter.c           |   2 +-
 tc/tc_util.h             |  16 ++++--
 14 files changed, 454 insertions(+), 40 deletions(-)
 create mode 100644 tc/e_bpf.c
 create mode 100644 tc/tc_exec.c

diff --git a/examples/bpf/bpf_agent.c b/examples/bpf/bpf_agent.c
index 0f481b1..426b880 100644
--- a/examples/bpf/bpf_agent.c
+++ b/examples/bpf/bpf_agent.c
@@ -24,6 +24,8 @@
  *   -- Happy eBPF hacking! ;)
  */
 
+#define _GNU_SOURCE
+
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -31,6 +33,7 @@
 #include <unistd.h>
 #include <stdint.h>
 #include <assert.h>
+
 #include <sys/un.h>
 #include <sys/types.h>
 #include <sys/stat.h>
@@ -102,6 +105,23 @@ static void bpf_dump_proto(int fd)
 	printf("\n");
 }
 
+static void bpf_dump_map_data(int *tfd)
+{
+	int i;
+
+	for (i = 0; i < 30; i++) {
+		const int period = 5;
+
+		printf("data, period: %dsec\n", period);
+
+		bpf_dump_drops(tfd[BPF_MAP_ID_DROPS]);
+		bpf_dump_queue(tfd[BPF_MAP_ID_QUEUE]);
+		bpf_dump_proto(tfd[BPF_MAP_ID_PROTO]);
+
+		sleep(period);
+	}
+}
+
 static void bpf_info_loop(int *fds, struct bpf_map_aux *aux)
 {
 	int i, tfd[BPF_MAP_ID_MAX];
@@ -122,16 +142,22 @@ static void bpf_info_loop(int *fds, struct bpf_map_aux *aux)
 		tfd[aux->ent[i].id] = fds[i];
 	}
 
-	for (i = 0; i < 30; i++) {
-		int period = 5;
+	bpf_dump_map_data(tfd);
+}
 
-		printf("data, period: %dsec\n", period);
+static void bpf_map_get_from_env(int *tfd)
+{
+	char key[64], *val;
+	int i;
 
-		bpf_dump_drops(tfd[BPF_MAP_ID_DROPS]);
-		bpf_dump_queue(tfd[BPF_MAP_ID_QUEUE]);
-		bpf_dump_proto(tfd[BPF_MAP_ID_PROTO]);
+	for (i = 0; i < BPF_MAP_ID_MAX; i++) {
+		memset(key, 0, sizeof(key));
+		snprintf(key, sizeof(key), "BPF_MAP%d", i);
 
-		sleep(period);
+		val = secure_getenv(key);
+		assert(val != NULL);
+
+		tfd[i] = atoi(val);
 	}
 }
 
@@ -186,9 +212,17 @@ int main(int argc, char **argv)
 	struct sockaddr_un addr;
 	int fd, ret, i;
 
-	if (argc < 2) {
-		fprintf(stderr, "Usage: %s <path-uds>\n", argv[0]);
-		exit(1);
+	/* When arguments are being passed, we take it as a path
+	 * to a Unix domain socket, otherwise we grab the fds
+	 * from the environment to demonstrate both possibilities.
+	 */
+	if (argc == 1) {
+		int tfd[BPF_MAP_ID_MAX];
+
+		bpf_map_get_from_env(tfd);
+		bpf_dump_map_data(tfd);
+
+		return 0;
 	}
 
 	fd = socket(AF_UNIX, SOCK_DGRAM, 0);
@@ -218,6 +252,7 @@ int main(int argc, char **argv)
 
 	for (i = 0; i < aux.num_ent; i++)
 		close(fds[i]);
+
 	close(fd);
 	return 0;
 }
diff --git a/examples/bpf/bpf_prog.c b/examples/bpf/bpf_prog.c
index ca9b54f..4dc00c3 100644
--- a/examples/bpf/bpf_prog.c
+++ b/examples/bpf/bpf_prog.c
@@ -58,6 +58,33 @@
  *    random type none pass val 0
  *    index 38 ref 1 bind 1
  *
+ * Notes on BPF agent:
+ *
+ * In the above example, the bpf_agent creates the unix domain socket
+ * natively. "tc exec" can also spawn a shell and hold the socktes there:
+ *
+ *  # tc exec bpf imp /tmp/bpf-uds
+ *  # tc filter add dev em1 parent 1: bpf obj bpf.o exp /tmp/bpf-uds flowid 1:1 \
+ *                             action bpf obj bpf.o sec action-mark            \
+ *                             action bpf obj bpf.o sec action-rand ok
+ *  sh-4.2# (shell spawned from tc exec)
+ *  sh-4.2# bpf_agent
+ *  [...]
+ *
+ * This will read out fds over environment and produce the same data dump
+ * as below. This has the advantage that the spawned shell owns the fds
+ * and thus if the agent is restarted, it can reattach to the same fds, also
+ * various programs can easily read/modify the data simultaneously from user
+ * space side.
+ *
+ * If the shell is unnecessary, the agent can also just be spawned directly
+ * via tc exec:
+ *
+ *  # tc exec bpf imp /tmp/bpf-uds run bpf_agent
+ *  # tc filter add dev em1 parent 1: bpf obj bpf.o exp /tmp/bpf-uds flowid 1:1 \
+ *                             action bpf obj bpf.o sec action-mark            \
+ *                             action bpf obj bpf.o sec action-rand ok
+ *
  * BPF agent example output:
  *
  * ver: 1
diff --git a/tc/Makefile b/tc/Makefile
index 2eff082..3935d0a 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -1,6 +1,6 @@
-TCOBJ= tc.o tc_qdisc.o tc_class.o tc_filter.o tc_util.o \
-       tc_monitor.o tc_bpf.o m_police.o m_estimator.o m_action.o \
-       m_ematch.o emp_ematch.yacc.o emp_ematch.lex.o
+TCOBJ= tc.o tc_qdisc.o tc_class.o tc_filter.o tc_util.o tc_monitor.o \
+       tc_exec.o tc_bpf.o m_police.o m_estimator.o m_action.o m_ematch.o \
+       emp_ematch.yacc.o emp_ematch.lex.o
 
 include ../Config
 
@@ -62,6 +62,7 @@ TCMODULES += q_fq_codel.o
 TCMODULES += q_fq.o
 TCMODULES += q_pie.o
 TCMODULES += q_hhf.o
+TCMODULES += e_bpf.o
 
 ifeq ($(TC_CONFIG_IPSET), y)
   ifeq ($(TC_CONFIG_XT), y)
diff --git a/tc/e_bpf.c b/tc/e_bpf.c
new file mode 100644
index 0000000..218ba40
--- /dev/null
+++ b/tc/e_bpf.c
@@ -0,0 +1,147 @@
+/*
+ * e_bpf.c	BPF exec proxy
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Daniel Borkmann <daniel@iogearbox.net>
+ */
+
+#include <stdio.h>
+#include <unistd.h>
+
+#include "utils.h"
+
+#include "tc_util.h"
+#include "tc_bpf.h"
+
+#include "bpf_elf.h"
+#include "bpf_scm.h"
+
+#define BPF_DEFAULT_CMD	"/bin/sh"
+
+static char *argv_default[] = { BPF_DEFAULT_CMD, NULL };
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... bpf [ import UDS_FILE ] [ run CMD ]\n\n");
+	fprintf(stderr, "Where UDS_FILE provides the name of a unix domain socket file\n");
+	fprintf(stderr, "to import eBPF maps and the optional CMD denotes the command\n");
+	fprintf(stderr, "to be executed (default: \'%s\').\n", BPF_DEFAULT_CMD);
+}
+
+static int bpf_num_env_entries(void)
+{
+	char **envp;
+	int num;
+
+	for (num = 0, envp = environ; *envp != NULL; envp++)
+		num++;
+	return num;
+}
+
+static int parse_bpf(struct exec_util *eu, int argc, char **argv)
+{
+	char **argv_run = argv_default, **envp_run, *tmp;
+	int ret, i, env_old, env_num, env_map;
+	const char *bpf_uds_name = NULL;
+	int fds[BPF_SCM_MAX_FDS];
+	struct bpf_map_aux aux;
+
+	if (argc == 0)
+		return 0;
+
+	while (argc > 0) {
+		if (matches(*argv, "run") == 0) {
+			NEXT_ARG();
+			argv_run = argv;
+			break;
+		} else if (matches(*argv, "import") == 0 ||
+			   matches(*argv, "imp") == 0) {
+			NEXT_ARG();
+			bpf_uds_name = *argv;
+		} else {
+			explain();
+			return -1;
+		}
+
+		argc--;
+		argv++;
+	}
+
+	if (!bpf_uds_name) {
+		fprintf(stderr, "bpf: No import parameter provided!\n");
+		explain();
+		return -1;
+	}
+
+	if (argv_run != argv_default && argc == 0) {
+		fprintf(stderr, "bpf: No run command provided!\n");
+		explain();
+		return -1;
+	}
+
+	memset(fds, 0, sizeof(fds));
+	memset(&aux, 0, sizeof(aux));
+
+	ret = bpf_recv_map_fds(bpf_uds_name, fds, &aux, ARRAY_SIZE(fds));
+	if (ret < 0) {
+		fprintf(stderr, "bpf: Could not receive fds!\n");
+		return -1;
+	}
+
+	if (aux.num_ent == 0) {
+		envp_run = environ;
+		goto out;
+	}
+
+	env_old = bpf_num_env_entries();
+	env_num = env_old + aux.num_ent + 2;
+	env_map = env_old + 1;
+
+	envp_run = malloc(sizeof(*envp_run) * env_num);
+	if (!envp_run) {
+		fprintf(stderr, "bpf: No memory left to allocate env!\n");
+		goto err;
+	}
+
+	for (i = 0; i < env_old; i++)
+		envp_run[i] = environ[i];
+
+	ret = asprintf(&tmp, "BPF_NUM_MAPS=%u", aux.num_ent);
+	if (ret < 0)
+		goto err_free;
+
+	envp_run[env_old] = tmp;
+
+	for (i = env_map; i < env_num - 1; i++) {
+		ret = asprintf(&tmp, "BPF_MAP%u=%u",
+			       aux.ent[i - env_map].id,
+			       fds[i - env_map]);
+		if (ret < 0)
+			goto err_free_env;
+
+		envp_run[i] = tmp;
+	}
+
+	envp_run[env_num - 1] = NULL;
+out:
+	return execvpe(argv_run[0], argv_run, envp_run);
+
+err_free_env:
+	for (--i; i >= env_old; i--)
+		free(envp_run[i]);
+err_free:
+	free(envp_run);
+err:
+	for (i = 0; i < aux.num_ent; i++)
+		close(fds[i]);
+	return -1;
+}
+
+struct exec_util bpf_exec_util = {
+	.id = "bpf",
+	.parse_eopt = parse_bpf,
+};
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 8bdd602..11d6db0 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -205,7 +205,7 @@ opt_bpf:
 	tail->rta_len = (((void *)n) + n->nlmsg_len) - (void *)tail;
 
 	if (bpf_uds_name)
-		ret = bpf_handoff_map_fds(bpf_uds_name, bpf_obj);
+		ret = bpf_send_map_fds(bpf_uds_name, bpf_obj);
 
 	return ret;
 }
diff --git a/tc/m_action.c b/tc/m_action.c
index 486123e..7a83f0d 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -54,7 +54,7 @@ static void act_usage(void)
 			"\tACTSPEC := action <ACTDETAIL> [INDEXSPEC]\n"
 			"\tINDEXSPEC := index <32 bit indexvalue>\n"
 			"\tACTDETAIL := <ACTNAME> <ACTPARAMS>\n"
-			"\t\tExample ACTNAME is gact, mirred etc\n"
+			"\t\tExample ACTNAME is gact, mirred, bpf, etc\n"
 			"\t\tEach action has its own parameters (ACTPARAMS)\n"
 			"\n");
 
diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index c817579..16468f2 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -216,7 +216,7 @@ opt_bpf:
 	*argv_p = argv;
 
 	if (bpf_uds_name)
-		ret = bpf_handoff_map_fds(bpf_uds_name, bpf_obj);
+		ret = bpf_send_map_fds(bpf_uds_name, bpf_obj);
 
 	return ret;
 }
diff --git a/tc/tc.c b/tc/tc.c
index 22c3be4..46ff371 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -190,7 +190,7 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: tc [ OPTIONS ] OBJECT { COMMAND | help }\n"
 			"       tc [-force] -batch filename\n"
-	                "where  OBJECT := { qdisc | class | filter | action | monitor }\n"
+	                "where  OBJECT := { qdisc | class | filter | action | monitor | exec }\n"
 	                "       OPTIONS := { -s[tatistics] | -d[etails] | -r[aw] | -p[retty] | -b[atch] [filename] | "
 			"-n[etns] name |\n"
 			"                    -nm | -nam[es] | { -cf | -conf } path }\n");
@@ -200,19 +200,16 @@ static int do_cmd(int argc, char **argv)
 {
 	if (matches(*argv, "qdisc") == 0)
 		return do_qdisc(argc-1, argv+1);
-
 	if (matches(*argv, "class") == 0)
 		return do_class(argc-1, argv+1);
-
 	if (matches(*argv, "filter") == 0)
 		return do_filter(argc-1, argv+1);
-
 	if (matches(*argv, "actions") == 0)
 		return do_action(argc-1, argv+1);
-
 	if (matches(*argv, "monitor") == 0)
 		return do_tcmonitor(argc-1, argv+1);
-
+	if (matches(*argv, "exec") == 0)
+		return do_exec(argc-1, argv+1);
 	if (matches(*argv, "help") == 0) {
 		usage();
 		return 0;
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 326d098..7c282aa 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -626,8 +626,8 @@ out:
 }
 
 static int
-bpf_map_set_xmit(int fd, struct sockaddr_un *addr, unsigned int addr_len,
-		 const struct bpf_map_data *aux, unsigned int ents)
+bpf_map_set_send(int fd, struct sockaddr_un *addr, unsigned int addr_len,
+		 const struct bpf_map_data *aux, unsigned int entries)
 {
 	struct bpf_map_set_msg msg;
 	int *cmsg_buf, min_fd;
@@ -637,7 +637,7 @@ bpf_map_set_xmit(int fd, struct sockaddr_un *addr, unsigned int addr_len,
 	memset(&msg, 0, sizeof(msg));
 
 	msg.aux.uds_ver = BPF_SCM_AUX_VER;
-	msg.aux.num_ent = ents;
+	msg.aux.num_ent = entries;
 
 	strncpy(msg.aux.obj_name, aux->obj, sizeof(msg.aux.obj_name));
 	memcpy(&msg.aux.obj_st, aux->st, sizeof(msg.aux.obj_st));
@@ -645,11 +645,10 @@ bpf_map_set_xmit(int fd, struct sockaddr_un *addr, unsigned int addr_len,
 	cmsg_buf = bpf_map_set_init(&msg, addr, addr_len);
 	amsg_buf = (char *)msg.aux.ent;
 
-	for (i = 0; i < ents; i += min_fd) {
+	for (i = 0; i < entries; i += min_fd) {
 		int ret;
 
-		min_fd = min(BPF_SCM_MAX_FDS * 1U, ents - i);
-
+		min_fd = min(BPF_SCM_MAX_FDS * 1U, entries - i);
 		bpf_map_set_init_single(&msg, min_fd);
 
 		memcpy(cmsg_buf, &aux->fds[i], sizeof(aux->fds[0]) * min_fd);
@@ -663,7 +662,54 @@ bpf_map_set_xmit(int fd, struct sockaddr_un *addr, unsigned int addr_len,
 	return 0;
 }
 
-int bpf_handoff_map_fds(const char *path, const char *obj)
+static int
+bpf_map_set_recv(int fd, int *fds,  struct bpf_map_aux *aux,
+		 unsigned int entries)
+{
+	struct bpf_map_set_msg msg;
+	int *cmsg_buf, min_fd;
+	char *amsg_buf, *mmsg_buf;
+	unsigned int needed = 1;
+	int i;
+
+	cmsg_buf = bpf_map_set_init(&msg, NULL, 0);
+	amsg_buf = (char *)msg.aux.ent;
+	mmsg_buf = (char *)&msg.aux;
+
+	for (i = 0; i < min(entries, needed); i += min_fd) {
+		struct cmsghdr *cmsg;
+		int ret;
+
+		min_fd = min(entries, entries - i);
+		bpf_map_set_init_single(&msg, min_fd);
+
+		ret = recvmsg(fd, &msg.hdr, 0);
+		if (ret <= 0)
+			return ret ? : -1;
+
+		cmsg = CMSG_FIRSTHDR(&msg.hdr);
+		if (!cmsg || cmsg->cmsg_type != SCM_RIGHTS)
+			return -EINVAL;
+		if (msg.hdr.msg_flags & MSG_CTRUNC)
+			return -EIO;
+		if (msg.aux.uds_ver != BPF_SCM_AUX_VER)
+			return -ENOSYS;
+
+		min_fd = (cmsg->cmsg_len - sizeof(*cmsg)) / sizeof(fd);
+		if (min_fd > entries || min_fd <= 0)
+			return -EINVAL;
+
+		memcpy(&fds[i], cmsg_buf, sizeof(fds[0]) * min_fd);
+		memcpy(&aux->ent[i], amsg_buf, sizeof(aux->ent[0]) * min_fd);
+		memcpy(aux, mmsg_buf, offsetof(struct bpf_map_aux, ent));
+
+		needed = aux->num_ent;
+	}
+
+	return 0;
+}
+
+int bpf_send_map_fds(const char *path, const char *obj)
 {
 	struct sockaddr_un addr;
 	struct bpf_map_data bpf_aux;
@@ -695,12 +741,46 @@ int bpf_handoff_map_fds(const char *path, const char *obj)
 	bpf_aux.obj = obj;
 	bpf_aux.st = &bpf_st;
 
-	ret = bpf_map_set_xmit(fd, &addr, sizeof(addr), &bpf_aux,
+	ret = bpf_map_set_send(fd, &addr, sizeof(addr), &bpf_aux,
 			       bpf_maps_count());
 	if (ret < 0)
-		fprintf(stderr, "Cannot xmit fds to %s: %s\n",
+		fprintf(stderr, "Cannot send fds to %s: %s\n",
+			path, strerror(errno));
+
+	close(fd);
+	return ret;
+}
+
+int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
+		     unsigned int entries)
+{
+	struct sockaddr_un addr;
+	int fd, ret;
+
+	fd = socket(AF_UNIX, SOCK_DGRAM, 0);
+	if (fd < 0) {
+		fprintf(stderr, "Cannot open socket: %s\n",
+			strerror(errno));
+		return -1;
+	}
+
+	memset(&addr, 0, sizeof(addr));
+	addr.sun_family = AF_UNIX;
+	strncpy(addr.sun_path, path, sizeof(addr.sun_path));
+
+	ret = bind(fd, (struct sockaddr *)&addr, sizeof(addr));
+	if (ret < 0) {
+		fprintf(stderr, "Cannot bind to socket: %s\n",
+			strerror(errno));
+		return -1;
+	}
+
+	ret = bpf_map_set_recv(fd, fds, aux, entries);
+	if (ret < 0)
+		fprintf(stderr, "Cannot recv fds from %s: %s\n",
 			path, strerror(errno));
 
+	unlink(addr.sun_path);
 	close(fd);
 	return ret;
 }
diff --git a/tc/tc_bpf.h b/tc/tc_bpf.h
index 8b214b8..4a239aa 100644
--- a/tc/tc_bpf.h
+++ b/tc/tc_bpf.h
@@ -23,6 +23,7 @@
 #include <stdint.h>
 
 #include "utils.h"
+#include "bpf_scm.h"
 
 int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 		     char **bpf_string, bool *need_release,
@@ -36,7 +37,10 @@ const char *bpf_default_section(const enum bpf_prog_type type);
 #ifdef HAVE_ELF
 int bpf_open_object(const char *path, enum bpf_prog_type type,
 		    const char *sec);
-int bpf_handoff_map_fds(const char *path, const char *obj);
+
+int bpf_send_map_fds(const char *path, const char *obj);
+int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
+		     unsigned int entries);
 
 static inline __u64 bpf_ptr_to_u64(const void *ptr)
 {
@@ -62,9 +66,16 @@ static inline int bpf_open_object(const char *path, enum bpf_prog_type type,
 	return -1;
 }
 
-static inline int bpf_handoff_map_fds(const char *path, const char *obj)
+static inline int bpf_send_map_fds(const char *path, const char *obj)
 {
 	return 0;
 }
+
+static inline int bpf_recv_map_fds(const char *path, int *fds,
+				   struct bpf_map_aux *aux,
+				   unsigned int entries)
+{
+	return -1;
+}
 #endif /* HAVE_ELF */
 #endif /* _TC_BPF_H_ */
diff --git a/tc/tc_common.h b/tc/tc_common.h
index 96a0e20..a2f3898 100644
--- a/tc/tc_common.h
+++ b/tc/tc_common.h
@@ -2,11 +2,14 @@
 #define TCA_BUF_MAX	(64*1024)
 
 extern struct rtnl_handle rth;
+
 extern int do_qdisc(int argc, char **argv);
 extern int do_class(int argc, char **argv);
 extern int do_filter(int argc, char **argv);
 extern int do_action(int argc, char **argv);
 extern int do_tcmonitor(int argc, char **argv);
+extern int do_exec(int argc, char **argv);
+
 extern int print_action(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
 extern int print_filter(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
 extern int print_qdisc(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
diff --git a/tc/tc_exec.c b/tc/tc_exec.c
new file mode 100644
index 0000000..61be672
--- /dev/null
+++ b/tc/tc_exec.c
@@ -0,0 +1,109 @@
+/*
+ * tc_exec.c	"tc exec".
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Daniel Borkmann <daniel@iogearbox.net>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <dlfcn.h>
+
+#include "utils.h"
+
+#include "tc_util.h"
+#include "tc_common.h"
+
+static struct exec_util *exec_list;
+static void *BODY = NULL;
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: tc exec [ EXEC_TYPE ] [ help | OPTIONS ]\n");
+	fprintf(stderr, "Where:\n");
+	fprintf(stderr, "EXEC_TYPE := { bpf | etc. }\n");
+	fprintf(stderr, "OPTIONS := ... try tc exec <desired EXEC_KIND> help\n");
+}
+
+static int parse_noeopt(struct exec_util *eu, int argc, char **argv)
+{
+	if (argc) {
+		fprintf(stderr, "Unknown exec \"%s\", hence option \"%s\" "
+			"is unparsable\n", eu->id, *argv);
+		return -1;
+	}
+
+	return 0;
+}
+
+static struct exec_util *get_exec_kind(const char *name)
+{
+	struct exec_util *eu;
+	char buf[256];
+	void *dlh;
+
+	for (eu = exec_list; eu; eu = eu->next)
+		if (strcmp(eu->id, name) == 0)
+			return eu;
+
+	snprintf(buf, sizeof(buf), "%s/e_%s.so", get_tc_lib(), name);
+	dlh = dlopen(buf, RTLD_LAZY);
+	if (dlh == NULL) {
+		dlh = BODY;
+		if (dlh == NULL) {
+			dlh = BODY = dlopen(NULL, RTLD_LAZY);
+			if (dlh == NULL)
+				goto noexist;
+		}
+	}
+
+	snprintf(buf, sizeof(buf), "%s_exec_util", name);
+	eu = dlsym(dlh, buf);
+	if (eu == NULL)
+		goto noexist;
+reg:
+	eu->next = exec_list;
+	exec_list = eu;
+
+	return eu;
+noexist:
+	eu = malloc(sizeof(*eu));
+	if (eu) {
+		memset(eu, 0, sizeof(*eu));
+		strncpy(eu->id, name, sizeof(eu->id) - 1);
+		eu->parse_eopt = parse_noeopt;
+		goto reg;
+	}
+
+	return eu;
+}
+
+int do_exec(int argc, char **argv)
+{
+	struct exec_util *eu;
+	char kind[16];
+
+	if (argc < 1) {
+		fprintf(stderr, "No command given, try \"tc exec help\".\n");
+		return -1;
+	}
+
+	if (matches(*argv, "help") == 0) {
+		usage();
+		return 0;
+	}
+
+	memset(kind, 0, sizeof(kind));
+	strncpy(kind, *argv, sizeof(kind) - 1);
+
+	eu = get_exec_kind(kind);
+
+	argc--;
+	argv++;
+
+	return eu->parse_eopt(eu, argc, argv);
+}
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index 609fbe9..c1038a4 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -38,7 +38,7 @@ static void usage(void)
 	fprintf(stderr, "\n");
 	fprintf(stderr, "       tc filter show [ dev STRING ] [ root | parent CLASSID ]\n");
 	fprintf(stderr, "Where:\n");
-	fprintf(stderr, "FILTER_TYPE := { rsvp | u32 | fw | route | etc. }\n");
+	fprintf(stderr, "FILTER_TYPE := { rsvp | u32 | bpf | fw | route | etc. }\n");
 	fprintf(stderr, "FILTERID := ... format depends on classifier, see there\n");
 	fprintf(stderr, "OPTIONS := ... try tc filter add <desired FILTER_KIND> help\n");
 	return;
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 1be1b50..61e60b1 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -19,8 +19,7 @@ enum
 #define TCA_PRIO_MAX    (__TCA_PRIO_MAX - 1)
 #endif
 
-struct qdisc_util
-{
+struct qdisc_util {
 	struct  qdisc_util *next;
 	const char *id;
 	int	(*parse_qopt)(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n);
@@ -32,8 +31,7 @@ struct qdisc_util
 };
 
 extern __u16 f_proto;
-struct filter_util
-{
+struct filter_util {
 	struct filter_util *next;
 	char	id[16];
 	int	(*parse_fopt)(struct filter_util *qu, char *fhandle, int argc,
@@ -41,8 +39,7 @@ struct filter_util
 	int	(*print_fopt)(struct filter_util *qu, FILE *f, struct rtattr *opt, __u32 fhandle);
 };
 
-struct action_util
-{
+struct action_util {
 	struct  action_util *next;
 	char    id[16];
 	int     (*parse_aopt)(struct action_util *a, int *argc, char ***argv,
@@ -51,6 +48,12 @@ struct action_util
 	int     (*print_xstats)(struct action_util *au, FILE *f, struct rtattr *xstats);
 };
 
+struct exec_util {
+	struct	exec_util *next;
+	char	id[16];
+	int	(*parse_eopt)(struct exec_util *eu, int argc, char **argv);
+};
+
 extern const char *get_tc_lib(void);
 
 extern struct qdisc_util *get_qdisc_kind(const char *str);
@@ -69,6 +72,7 @@ extern void print_size(char *buf, int len, __u32 size);
 extern void print_qdisc_handle(char *buf, int len, __u32 h);
 extern void print_time(char *buf, int len, __u32 time);
 extern void print_linklayer(char *buf, int len, unsigned linklayer);
+
 extern char * sprint_rate(__u64 rate, char *buf);
 extern char * sprint_size(__u32 size, char *buf);
 extern char * sprint_qdisc_handle(__u32 h, char *buf);
-- 
1.9.3
