From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 4/8] ebpf: make internal bpf API independent of CONFIG_BPF_SYSCALL ifdefs
Date: Sun,  1 Mar 2015 12:31:44 +0100
Message-ID: <5ae80bf0637ad4c725c5d0a093170ed924d130e2.1425208502.git.daniel@iogearbox.net>
References: <cover.1425208501.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52013 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbbCALcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 06:32:14 -0500
In-Reply-To: <cover.1425208501.git.daniel@iogearbox.net>
In-Reply-To: <cover.1425208501.git.daniel@iogearbox.net>
References: <cover.1425208501.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Socket filter code and other subsystems with upcoming eBPF support should
not need to deal with the fact that we have CONFIG_BPF_SYSCALL defined or
not.

Having the bpf syscall as a config option is a nice thing and I'd expect
it to stay that way for expert users (I presume one day the default setting
of it might change, though), but code making use of it should not care if
it's actually enabled or not.

Instead, hide this via header files and let the rest deal with it.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 7844686..9c45814 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -113,8 +113,6 @@ struct bpf_prog_type_list {
 	enum bpf_prog_type type;
 };
 
-void bpf_register_prog_type(struct bpf_prog_type_list *tl);
-
 struct bpf_prog;
 
 struct bpf_prog_aux {
@@ -129,11 +127,25 @@ struct bpf_prog_aux {
 };
 
 #ifdef CONFIG_BPF_SYSCALL
+void bpf_register_prog_type(struct bpf_prog_type_list *tl);
+
 void bpf_prog_put(struct bpf_prog *prog);
+struct bpf_prog *bpf_prog_get(u32 ufd);
 #else
-static inline void bpf_prog_put(struct bpf_prog *prog) {}
+static inline void bpf_register_prog_type(struct bpf_prog_type_list *tl)
+{
+}
+
+static inline struct bpf_prog *bpf_prog_get(u32 ufd)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static inline void bpf_prog_put(struct bpf_prog *prog)
+{
+}
 #endif
-struct bpf_prog *bpf_prog_get(u32 ufd);
+
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
 
-- 
1.9.3
