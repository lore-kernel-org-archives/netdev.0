From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v2 net-next 14/16] samples: bpf: add mini eBPF library to manipulate maps and programs
Date: Thu, 17 Jul 2014 21:20:04 -0700
Message-ID: <1405657206-12060-15-git-send-email-ast@plumgrid.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
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
		  const char *license,
		  const struct bpf_map_fixup *fixups, int fixup_len);

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/libbpf.c |  109 ++++++++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/libbpf.h |   22 ++++++++++
 2 files changed, 131 insertions(+)
 create mode 100644 samples/bpf/libbpf.c
 create mode 100644 samples/bpf/libbpf.h

diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
new file mode 100644
index 000000000000..5460d1f3ad43
--- /dev/null
+++ b/samples/bpf/libbpf.c
@@ -0,0 +1,109 @@
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
+int bpf_create_map(int key_size, int value_size, int max_entries)
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
+	return syscall(__NR_bpf, BPF_MAP_CREATE, BPF_MAP_TYPE_HASH, attr, sizeof(attr));
+}
+
+
+int bpf_update_elem(int fd, void *key, void *value)
+{
+	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, fd, key, value);
+}
+
+int bpf_lookup_elem(int fd, void *key, void *value)
+{
+	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, fd, key, value);
+}
+
+int bpf_delete_elem(int fd, void *key)
+{
+	return syscall(__NR_bpf, BPF_MAP_DELETE_ELEM, fd, key);
+}
+
+int bpf_get_next_key(int fd, void *key, void *next_key)
+{
+	return syscall(__NR_bpf, BPF_MAP_GET_NEXT_KEY, fd, key, next_key);
+}
+
+#define ROUND_UP(x, n) (((x) + (n) - 1u) & ~((n) - 1u))
+
+int bpf_prog_load(enum bpf_prog_type prog_type,
+		  const struct bpf_insn *insns, int prog_len,
+		  const char *license,
+		  const struct bpf_map_fixup *fixups, int fixup_len)
+{
+	int nlattr_size, license_len, err;
+	void *nlattr, *ptr;
+
+	license_len = strlen(license) + 1;
+	nlattr_size = sizeof(struct nlattr) + prog_len + sizeof(struct nlattr) +
+		ROUND_UP(license_len, 4) + sizeof(struct nlattr) +
+		fixup_len;
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
+	ptr += ROUND_UP(license_len, 4);
+
+	*(struct nlattr *) ptr = (struct nlattr) {
+		.nla_len = fixup_len + sizeof(struct nlattr),
+		.nla_type = BPF_PROG_MAP_FIXUP,
+	};
+	ptr += sizeof(struct nlattr);
+
+	memcpy(ptr, fixups, fixup_len);
+	ptr += fixup_len;
+
+	err = syscall(__NR_bpf, BPF_PROG_LOAD, prog_type, nlattr, nlattr_size);
+
+	free(nlattr);
+	return err;
+}
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
new file mode 100644
index 000000000000..07f668e3dac0
--- /dev/null
+++ b/samples/bpf/libbpf.h
@@ -0,0 +1,22 @@
+/* eBPF mini library */
+#ifndef __LIBBPF_H
+#define __LIBBPF_H
+
+struct bpf_insn;
+
+int bpf_create_map(int key_size, int value_size, int max_entries);
+int bpf_update_elem(int fd, void *key, void *value);
+int bpf_lookup_elem(int fd, void *key, void *value);
+int bpf_delete_elem(int fd, void *key);
+int bpf_get_next_key(int fd, void *key, void *next_key);
+
+struct bpf_map_fixup {
+	int insn_idx;
+	int fd;
+};
+int bpf_prog_load(enum bpf_prog_type prog_type,
+		  const struct bpf_insn *insns, int insn_len,
+		  const char *license,
+		  const struct bpf_map_fixup *fixups, int fixup_len);
+
+#endif
-- 
1.7.9.5
