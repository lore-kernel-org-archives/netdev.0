From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC net-next 12/14] samples: bpf: add mini eBPF library to manipulate maps and programs
Date: Fri, 27 Jun 2014 17:06:04 -0700
Message-ID: <1403913966-4927-13-git-send-email-ast@plumgrid.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:56715 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754702AbaF1AGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 20:06:50 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so5043988pdj.22
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 17:06:50 -0700 (PDT)
In-Reply-To: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the library includes a trivial set of BPF syscall wrappers:

int bpf_delete_map(int map_id);

int bpf_create_map(int map_id, int key_size, int value_size, int max_entries);

int bpf_update_elem(int map_id, void *key, void *value);

int bpf_lookup_elem(int map_id, void *key, void *value);

int bpf_delete_elem(int map_id, void *key);

int bpf_get_next_key(int map_id, void *key, void *next_key);

int bpf_prog_load(int prog_id, enum bpf_prog_type prog_type,
		  struct sock_filter_int *insns, int insn_cnt,
		  const char *license);

int bpf_prog_unload(int prog_id);

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/libbpf.c |  114 ++++++++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/libbpf.h |   18 ++++++++
 2 files changed, 132 insertions(+)
 create mode 100644 samples/bpf/libbpf.c
 create mode 100644 samples/bpf/libbpf.h

diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
new file mode 100644
index 000000000000..763eaf4b9814
--- /dev/null
+++ b/samples/bpf/libbpf.c
@@ -0,0 +1,114 @@
+/* eBPF mini library */
+#include <stdlib.h>
+#include <linux/unistd.h>
+#include <unistd.h>
+#include <string.h>
+#include <linux/netlink.h>
+#include <linux/bpf.h>
+#include <errno.h>
+#include "libbpf.h"
+
+struct nlattr_u32 {
+	__u16 nla_len;
+	__u16 nla_type;
+	__u32 val;
+};
+
+int bpf_delete_map(int map_id)
+{
+	return syscall(__NR_bpf, BPF_MAP_DELETE, map_id);
+}
+
+int bpf_create_map(int map_id, int key_size, int value_size, int max_entries)
+{
+	struct nlattr_u32 attr[] = {
+		{
+			.nla_len = sizeof(struct nlattr_u32),
+			.nla_type = BPF_MAP_KEY_SIZE,
+			.val = key_size,
+		},
+		{
+			.nla_len = sizeof(struct nlattr_u32),
+			.nla_type = BPF_MAP_VALUE_SIZE,
+			.val = value_size,
+		},
+		{
+			.nla_len = sizeof(struct nlattr_u32),
+			.nla_type = BPF_MAP_MAX_ENTRIES,
+			.val = max_entries,
+		},
+	};
+	int err;
+
+	err = syscall(__NR_bpf, BPF_MAP_CREATE, map_id, BPF_MAP_TYPE_HASH, attr, sizeof(attr));
+	if (err > 0 && err != map_id && map_id != 0) {
+		bpf_delete_map(err);
+		errno = EEXIST;
+		err = -1;
+	}
+	return err;
+}
+
+
+int bpf_update_elem(int map_id, void *key, void *value)
+{
+	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, map_id, key, value);
+}
+
+int bpf_lookup_elem(int map_id, void *key, void *value)
+{
+	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, map_id, key, value);
+}
+
+int bpf_delete_elem(int map_id, void *key)
+{
+	return syscall(__NR_bpf, BPF_MAP_DELETE_ELEM, map_id, key);
+}
+
+int bpf_get_next_key(int map_id, void *key, void *next_key)
+{
+	return syscall(__NR_bpf, BPF_MAP_GET_NEXT_KEY, map_id, key, next_key);
+}
+
+#define ROUND_UP(x, n) (((x) + (n) - 1u) & ~((n) - 1u))
+
+int bpf_prog_load(int prog_id, enum bpf_prog_type prog_type,
+		  struct sock_filter_int *insns, int prog_len,
+		  const char *license)
+{
+	int nlattr_size, license_len, err;
+	void *nlattr, *ptr;
+
+	license_len = strlen(license) + 1;
+	nlattr_size = sizeof(struct nlattr) + prog_len + sizeof(struct nlattr) +
+		ROUND_UP(license_len, 4);
+
+	ptr = nlattr = malloc(nlattr_size);
+
+	*(struct nlattr *) ptr = (struct nlattr) {
+		.nla_len = prog_len + sizeof(struct nlattr),
+		.nla_type = BPF_PROG_TEXT,
+	};
+	ptr += sizeof(struct nlattr);
+
+	memcpy(ptr, insns, prog_len);
+	ptr += prog_len;
+
+	*(struct nlattr *) ptr = (struct nlattr) {
+		.nla_len = ROUND_UP(license_len, 4) + sizeof(struct nlattr),
+		.nla_type = BPF_PROG_LICENSE,
+	};
+	ptr += sizeof(struct nlattr);
+
+	memcpy(ptr, license, license_len);
+
+	err = syscall(__NR_bpf, BPF_PROG_LOAD, prog_id, prog_type, nlattr,
+		      nlattr_size);
+	free(nlattr);
+	return err;
+}
+
+int bpf_prog_unload(int prog_id)
+{
+	return syscall(__NR_bpf, BPF_PROG_UNLOAD, prog_id);
+}
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
new file mode 100644
index 000000000000..408368e6d4d5
--- /dev/null
+++ b/samples/bpf/libbpf.h
@@ -0,0 +1,18 @@
+/* eBPF mini library */
+#ifndef __LIBBPF_H
+#define __LIBBPF_H
+
+struct sock_filter_int;
+
+int bpf_delete_map(int map_id);
+int bpf_create_map(int map_id, int key_size, int value_size, int max_entries);
+int bpf_update_elem(int map_id, void *key, void *value);
+int bpf_lookup_elem(int map_id, void *key, void *value);
+int bpf_delete_elem(int map_id, void *key);
+int bpf_get_next_key(int map_id, void *key, void *next_key);
+int bpf_prog_load(int prog_id, enum bpf_prog_type prog_type,
+		  struct sock_filter_int *insns, int insn_cnt,
+		  const char *license);
+int bpf_prog_unload(int prog_id);
+
+#endif
-- 
1.7.9.5
