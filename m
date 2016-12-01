From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v7 net-next 5/6] samples/bpf: Update bpf loader for cgroup section names
Date: Thu,  1 Dec 2016 08:48:07 -0800
Message-ID: <1480610888-31082-6-git-send-email-dsa@cumulusnetworks.com>
References: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:32791 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757842AbcLAQsZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:48:25 -0500
Received: by mail-pg0-f50.google.com with SMTP id 3so96814314pgd.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:48:20 -0800 (PST)
In-Reply-To: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for section names starting with cgroup/skb and cgroup/sock.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v7
- no change

v6
- new patch for version 6

 samples/bpf/bpf_load.c | 14 +++++++++++---
 samples/bpf/bpf_load.h |  1 +
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 62f54d6eb8bf..49b45ccbe153 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -52,6 +52,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_tracepoint = strncmp(event, "tracepoint/", 11) == 0;
 	bool is_xdp = strncmp(event, "xdp", 3) == 0;
 	bool is_perf_event = strncmp(event, "perf_event", 10) == 0;
+	bool is_cgroup_skb = strncmp(event, "cgroup/skb", 10) == 0;
+	bool is_cgroup_sk = strncmp(event, "cgroup/sock", 11) == 0;
 	enum bpf_prog_type prog_type;
 	char buf[256];
 	int fd, efd, err, id;
@@ -72,6 +74,10 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		prog_type = BPF_PROG_TYPE_XDP;
 	} else if (is_perf_event) {
 		prog_type = BPF_PROG_TYPE_PERF_EVENT;
+	} else if (is_cgroup_skb) {
+		prog_type = BPF_PROG_TYPE_CGROUP_SKB;
+	} else if (is_cgroup_sk) {
+		prog_type = BPF_PROG_TYPE_CGROUP_SOCK;
 	} else {
 		printf("Unknown event '%s'\n", event);
 		return -1;
@@ -85,7 +91,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
-	if (is_xdp || is_perf_event)
+	if (is_xdp || is_perf_event || is_cgroup_skb || is_cgroup_sk)
 		return 0;
 
 	if (is_socket) {
@@ -334,7 +340,8 @@ int load_bpf_file(char *path)
 			    memcmp(shname_prog, "tracepoint/", 11) == 0 ||
 			    memcmp(shname_prog, "xdp", 3) == 0 ||
 			    memcmp(shname_prog, "perf_event", 10) == 0 ||
-			    memcmp(shname_prog, "socket", 6) == 0)
+			    memcmp(shname_prog, "socket", 6) == 0 ||
+			    memcmp(shname_prog, "cgroup/", 7) == 0)
 				load_and_attach(shname_prog, insns, data_prog->d_size);
 		}
 	}
@@ -353,7 +360,8 @@ int load_bpf_file(char *path)
 		    memcmp(shname, "tracepoint/", 11) == 0 ||
 		    memcmp(shname, "xdp", 3) == 0 ||
 		    memcmp(shname, "perf_event", 10) == 0 ||
-		    memcmp(shname, "socket", 6) == 0)
+		    memcmp(shname, "socket", 6) == 0 ||
+		    memcmp(shname, "cgroup/", 7) == 0)
 			load_and_attach(shname, data->d_buf, data->d_size);
 	}
 
diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index dfa57fe65c8e..4adeeef53ad6 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -7,6 +7,7 @@
 extern int map_fd[MAX_MAPS];
 extern int prog_fd[MAX_PROGS];
 extern int event_fd[MAX_PROGS];
+extern int prog_cnt;
 
 /* parses elf file compiled by llvm .c->.o
  * . parses 'maps' section and creates maps via BPF syscall
-- 
2.1.4
