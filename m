From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v4 net-next 19/26] samples: bpf: add mini eBPF library to manipulate maps and programs
Date: Wed, 13 Aug 2014 00:57:30 -0700
Message-ID: <1407916658-8731-20-git-send-email-ast@plumgrid.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the library includes a trivial set of BPF syscall wrappers:

int bpf_create_map(int key_size, int value_size, int max_entries);

int bpf_update_elem(int fd, void *key, void *value);

int bpf_lookup_elem(int fd, void *key, void *value);

int bpf_delete_elem(int fd, void *key);

int bpf_get_next_key(int fd, void *key, void *next_key);

int bpf_prog_load(enum bpf_prog_type prog_type,
		  const struct sock_filter_int *insns, int insn_len,
		  const char *license);

bpf_prog_load() stores verifier log into global bpf_log_buf[] array

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/libbpf.c |  138 ++++++++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/libbpf.h |   21 ++++++++
 2 files changed, 159 insertions(+)
 create mode 100644 samples/bpf/libbpf.c
 create mode 100644 samples/bpf/libbpf.h

diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
new file mode 100644
index 000000000000..81396dab5caa
--- /dev/null
+++ b/samples/bpf/libbpf.c
@@ -0,0 +1,138 @@
+/* eBPF mini library */
+#include <stdlib.h>
+#include <stdio.h>
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
+int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
+		   int max_entries)
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
+
+	return syscall(__NR_bpf, BPF_MAP_CREATE, map_type, attr, sizeof(attr), 0);
+}
+
+
+int bpf_update_elem(int fd, void *key, void *value)
+{
+	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, fd, key, value, 0);
+}
+
+int bpf_lookup_elem(int fd, void *key, void *value)
+{
+	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, fd, key, value, 0);
+}
+
+int bpf_delete_elem(int fd, void *key)
+{
+	return syscall(__NR_bpf, BPF_MAP_DELETE_ELEM, fd, key, 0, 0);
+}
+
+int bpf_get_next_key(int fd, void *key, void *next_key)
+{
+	return syscall(__NR_bpf, BPF_MAP_GET_NEXT_KEY, fd, key, next_key, 0);
+}
+
+#define ROUND_UP(x, n) (((x) + (n) - 1u) & ~((n) - 1u))
+
+char bpf_log_buf[LOG_BUF_SIZE];
+
+int bpf_prog_load(enum bpf_prog_type prog_type,
+		  const struct bpf_insn *insns, int prog_len,
+		  const char *license)
+{
+	int nlattr_size, license_len, err;
+	void *nlattr, *ptr;
+	char *log_buf = bpf_log_buf;
+	int log_size = LOG_BUF_SIZE;
+	int log_level = 1;
+
+	log_buf[0] = 0;
+
+	license_len = strlen(license) + 1;
+	nlattr_size = sizeof(struct nlattr) + prog_len + sizeof(struct nlattr) +
+		ROUND_UP(license_len, 4) +
+		sizeof(struct nlattr) + sizeof(log_level) +
+		sizeof(struct nlattr) + sizeof(log_buf) +
+		sizeof(struct nlattr) + sizeof(log_size);
+
+	ptr = nlattr = malloc(nlattr_size);
+	if (!ptr) {
+		errno = ENOMEM;
+		return -1;
+	}
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
+	ptr += ROUND_UP(license_len, 4);
+
+	*(struct nlattr *) ptr = (struct nlattr) {
+		.nla_len = sizeof(log_level) + sizeof(struct nlattr),
+		.nla_type = BPF_PROG_LOG_LEVEL,
+	};
+	ptr += sizeof(struct nlattr);
+	memcpy(ptr, &log_level, sizeof(log_level));
+	ptr += sizeof(log_level);
+
+	*(struct nlattr *) ptr = (struct nlattr) {
+		.nla_len = sizeof(log_buf) + sizeof(struct nlattr),
+		.nla_type = BPF_PROG_LOG_BUF,
+	};
+	ptr += sizeof(struct nlattr);
+	memcpy(ptr, &log_buf, sizeof(log_buf));
+	ptr += sizeof(log_buf);
+
+	*(struct nlattr *) ptr = (struct nlattr) {
+		.nla_len = sizeof(log_size) + sizeof(struct nlattr),
+		.nla_type = BPF_PROG_LOG_SIZE,
+	};
+	ptr += sizeof(struct nlattr);
+	memcpy(ptr, &log_size, sizeof(log_size));
+	ptr += sizeof(log_size);
+
+	err = syscall(__NR_bpf, BPF_PROG_LOAD, prog_type, nlattr, nlattr_size, 0);
+
+	free(nlattr);
+	return err;
+}
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
new file mode 100644
index 000000000000..b19e39794291
--- /dev/null
+++ b/samples/bpf/libbpf.h
@@ -0,0 +1,21 @@
+/* eBPF mini library */
+#ifndef __LIBBPF_H
+#define __LIBBPF_H
+
+struct bpf_insn;
+
+int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
+		   int max_entries);
+int bpf_update_elem(int fd, void *key, void *value);
+int bpf_lookup_elem(int fd, void *key, void *value);
+int bpf_delete_elem(int fd, void *key);
+int bpf_get_next_key(int fd, void *key, void *next_key);
+
+int bpf_prog_load(enum bpf_prog_type prog_type,
+		  const struct bpf_insn *insns, int insn_len,
+		  const char *license);
+
+#define LOG_BUF_SIZE 8192
+extern char bpf_log_buf[LOG_BUF_SIZE];
+
+#endif
-- 
1.7.9.5
