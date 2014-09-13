From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] net: bpf: correctly handle errors in sk_attach_filter()
Date: Sat, 13 Sep 2014 00:06:30 -0400
Message-ID: <1410581190-31922-1-git-send-email-sasha.levin@oracle.com>
Cc: ast@plumgrid.com, keescook@chromium.org,
	hannes@stressinduktion.org, dborkman@redhat.com,
	spender@grsecurity.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit "net: bpf: make eBPF interpreter images read-only" has changed bpf_prog
to be vmalloc()ed but never handled some of the errors paths of the old code.

On error within sk_attach_filter (which userspace can easily trigger), we'd
kfree() the vmalloc()ed memory, and leak the internal bpf_work_struct.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/core/filter.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index dfc716f..09e1c4a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1074,7 +1074,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 		return -ENOMEM;
 
 	if (copy_from_user(prog->insns, fprog->filter, fsize)) {
-		kfree(prog);
+		__bpf_prog_free(prog);
 		return -EFAULT;
 	}
 
@@ -1082,7 +1082,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 
 	err = bpf_prog_store_orig_filter(prog, fprog);
 	if (err) {
-		kfree(prog);
+		__bpf_prog_free(prog);
 		return -ENOMEM;
 	}
 
-- 
1.9.1
