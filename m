From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] bpf: avoid copying junk bytes in bpf_get_current_comm()
Date: Wed, 9 Mar 2016 20:02:33 -0800
Message-ID: <1457582553-395600-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Tobias Waldekranz <tobias@waldekranz.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lots of places in the kernel use memcpy(buf, comm, TASK_COMM_LEN); but
the result is typically passed to print("%s", buf) and extra bytes
after zero don't cause any harm.
In bpf the result of bpf_get_current_comm() is used as the part of
map key and was causing spurious hash map mismatches.
Use strlcpy() to guarantee zero-terminated string.
bpf verifier checks that output buffer is zero-initialized,
so even for short task names the output buffer don't have junk bytes.
Note it's not a security concern, since kprobe+bpf is root only.

Fixes: ffeedafbf023 ("bpf: introduce current->pid, tgid, uid, gid, comm accessors")
Reported-by: Tobias Waldekranz <tobias@waldekranz.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
Targeting net-next, since it's too late for net.
I think it makes sense for stable as well.

 kernel/bpf/helpers.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 4504ca66118d..50da680c479f 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -166,7 +166,7 @@ static u64 bpf_get_current_comm(u64 r1, u64 size, u64 r3, u64 r4, u64 r5)
 	if (!task)
 		return -EINVAL;
 
-	memcpy(buf, task->comm, min_t(size_t, size, sizeof(task->comm)));
+	strlcpy(buf, task->comm, min_t(size_t, size, sizeof(task->comm)));
 	return 0;
 }
 
-- 
2.8.0.rc1
