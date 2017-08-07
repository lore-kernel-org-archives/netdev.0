From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v1 1/2] bpf: Move check_uarg_tail_zero() upward
Date: Mon,  7 Aug 2017 18:36:04 +0200
Message-ID: <20170807163605.14194-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Kees Cook <keescook@chromium.org>,
        Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function check_uarg_tail_zero() may be useful for other part of the
code in the syscall.c file. Move this function at the beginning of the
file.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Martin KaFai Lau <kafai@fb.com>
---

This is needed for the Landlock patch series. :)
---
 kernel/bpf/syscall.c | 52 ++++++++++++++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 26 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 6c772adabad2..c653ee0bd162 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -48,6 +48,32 @@ static const struct bpf_map_ops * const bpf_map_types[] = {
 #undef BPF_MAP_TYPE
 };
 
+static int check_uarg_tail_zero(void __user *uaddr,
+				size_t expected_size,
+				size_t actual_size)
+{
+	unsigned char __user *addr;
+	unsigned char __user *end;
+	unsigned char val;
+	int err;
+
+	if (actual_size <= expected_size)
+		return 0;
+
+	addr = uaddr + expected_size;
+	end  = uaddr + actual_size;
+
+	for (; addr < end; addr++) {
+		err = get_user(val, addr);
+		if (err)
+			return err;
+		if (val)
+			return -E2BIG;
+	}
+
+	return 0;
+}
+
 static struct bpf_map *find_and_alloc_map(union bpf_attr *attr)
 {
 	struct bpf_map *map;
@@ -1246,32 +1272,6 @@ static int bpf_map_get_fd_by_id(const union bpf_attr *attr)
 	return fd;
 }
 
-static int check_uarg_tail_zero(void __user *uaddr,
-				size_t expected_size,
-				size_t actual_size)
-{
-	unsigned char __user *addr;
-	unsigned char __user *end;
-	unsigned char val;
-	int err;
-
-	if (actual_size <= expected_size)
-		return 0;
-
-	addr = uaddr + expected_size;
-	end  = uaddr + actual_size;
-
-	for (; addr < end; addr++) {
-		err = get_user(val, addr);
-		if (err)
-			return err;
-		if (val)
-			return -E2BIG;
-	}
-
-	return 0;
-}
-
 static int bpf_prog_get_info_by_fd(struct bpf_prog *prog,
 				   const union bpf_attr *attr,
 				   union bpf_attr __user *uattr)
-- 
2.13.3
