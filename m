From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v2 2/2] bpf: Extend check_uarg_tail_zero() checks
Date: Mon,  7 Aug 2017 20:45:20 +0200
Message-ID: <20170807184520.8130-2-mic@digikod.net>
References: <20170807184520.8130-1-mic@digikod.net>
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
In-Reply-To: <20170807184520.8130-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function check_uarg_tail_zero() was created from bpf(2) for
BPF_OBJ_GET_INFO_BY_FD without taking the access_ok() nor the PAGE_SIZE
checks. Make this checks more generally available while unlikely to be
triggered, extend the memory range check and add an explanation
including why the ToCToU should not be a security concern.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Martin KaFai Lau <kafai@fb.com>
Link: https://lkml.kernel.org/r/CAGXu5j+vRGFvJZmjtAcT8Hi8B+Wz0e1b6VKYZHfQP_=DXzC4CQ@mail.gmail.com
---
 kernel/bpf/syscall.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c653ee0bd162..fbe09a0cccf4 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -48,6 +48,15 @@ static const struct bpf_map_ops * const bpf_map_types[] = {
 #undef BPF_MAP_TYPE
 };
 
+/*
+ * If we're handed a bigger struct than we know of, ensure all the unknown bits
+ * are 0 - i.e. new user-space does not rely on any kernel feature extensions
+ * we don't know about yet.
+ *
+ * There is a ToCToU between this function call and the following
+ * copy_from_user() call. However, this is not a concern since this function is
+ * meant to be a future-proofing of bits.
+ */
 static int check_uarg_tail_zero(void __user *uaddr,
 				size_t expected_size,
 				size_t actual_size)
@@ -57,6 +66,12 @@ static int check_uarg_tail_zero(void __user *uaddr,
 	unsigned char val;
 	int err;
 
+	if (unlikely(actual_size > PAGE_SIZE))	/* silly large */
+		return -E2BIG;
+
+	if (unlikely(!access_ok(VERIFY_READ, uaddr, actual_size)))
+		return -EFAULT;
+
 	if (actual_size <= expected_size)
 		return 0;
 
@@ -1393,17 +1408,6 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	if (!capable(CAP_SYS_ADMIN) && sysctl_unprivileged_bpf_disabled)
 		return -EPERM;
 
-	if (!access_ok(VERIFY_READ, uattr, 1))
-		return -EFAULT;
-
-	if (size > PAGE_SIZE)	/* silly large */
-		return -E2BIG;
-
-	/* If we're handed a bigger struct than we know of,
-	 * ensure all the unknown bits are 0 - i.e. new
-	 * user-space does not rely on any kernel feature
-	 * extensions we dont know about yet.
-	 */
 	err = check_uarg_tail_zero(uattr, sizeof(attr), size);
 	if (err)
 		return err;
-- 
2.13.3
