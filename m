From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 08/10] samples/bpf: add tracepoint support to bpf loader
Date: Wed, 6 Apr 2016 18:43:29 -0700
Message-ID: <1459993411-2754735-9-git-send-email-ast@fb.com>
References: <1459993411-2754735-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:5762 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753173AbcDGBnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 21:43:37 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u371hPaO031778
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2016 18:43:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22596yh2tb-5
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 18:43:36 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 241b56c4fc6211e59da024be05956610-ed3df3f0 for <netdev@vger.kernel.org>;	Wed,
 06 Apr 2016 18:43:34 -0700
In-Reply-To: <1459993411-2754735-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recognize "tracepoint/" section name prefix and attach the program
to that tracepoint.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/bpf_load.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 58f86bd11b3d..022af71c2bb5 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -49,6 +49,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_socket = strncmp(event, "socket", 6) == 0;
 	bool is_kprobe = strncmp(event, "kprobe/", 7) == 0;
 	bool is_kretprobe = strncmp(event, "kretprobe/", 10) == 0;
+	bool is_tracepoint = strncmp(event, "tracepoint/", 11) == 0;
 	enum bpf_prog_type prog_type;
 	char buf[256];
 	int fd, efd, err, id;
@@ -63,6 +64,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		prog_type = BPF_PROG_TYPE_SOCKET_FILTER;
 	} else if (is_kprobe || is_kretprobe) {
 		prog_type = BPF_PROG_TYPE_KPROBE;
+	} else if (is_tracepoint) {
+		prog_type = BPF_PROG_TYPE_TRACEPOINT;
 	} else {
 		printf("Unknown event '%s'\n", event);
 		return -1;
@@ -111,12 +114,23 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 			       event, strerror(errno));
 			return -1;
 		}
-	}
 
-	strcpy(buf, DEBUGFS);
-	strcat(buf, "events/kprobes/");
-	strcat(buf, event);
-	strcat(buf, "/id");
+		strcpy(buf, DEBUGFS);
+		strcat(buf, "events/kprobes/");
+		strcat(buf, event);
+		strcat(buf, "/id");
+	} else if (is_tracepoint) {
+		event += 11;
+
+		if (*event == 0) {
+			printf("event name cannot be empty\n");
+			return -1;
+		}
+		strcpy(buf, DEBUGFS);
+		strcat(buf, "events/");
+		strcat(buf, event);
+		strcat(buf, "/id");
+	}
 
 	efd = open(buf, O_RDONLY, 0);
 	if (efd < 0) {
@@ -304,6 +318,7 @@ int load_bpf_file(char *path)
 
 			if (memcmp(shname_prog, "kprobe/", 7) == 0 ||
 			    memcmp(shname_prog, "kretprobe/", 10) == 0 ||
+			    memcmp(shname_prog, "tracepoint/", 11) == 0 ||
 			    memcmp(shname_prog, "socket", 6) == 0)
 				load_and_attach(shname_prog, insns, data_prog->d_size);
 		}
@@ -320,6 +335,7 @@ int load_bpf_file(char *path)
 
 		if (memcmp(shname, "kprobe/", 7) == 0 ||
 		    memcmp(shname, "kretprobe/", 10) == 0 ||
+		    memcmp(shname, "tracepoint/", 11) == 0 ||
 		    memcmp(shname, "socket", 6) == 0)
 			load_and_attach(shname, data->d_buf, data->d_size);
 	}
-- 
2.8.0
