From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] net: sock: correctly handle failed prog retrieval from fd
Date: Fri, 12 Dec 2014 00:33:48 -0500
Message-ID: <1418362428-15067-1-git-send-email-sasha.levin@oracle.com>
Cc: ast@plumgrid.com, dborkman@redhat.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit "net: sock: allow eBPF programs to be attached to sockets" didn't
correctly handle the case where there is a failure getting the prog from
a given fd.

This allows for easy NULL ptr deref from userspace.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/core/filter.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 8cc3c03..ec9baea 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1103,8 +1103,8 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 		return -EPERM;
 
 	prog = bpf_prog_get(ufd);
-	if (!prog)
-		return -EINVAL;
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
 
 	if (prog->aux->prog_type != BPF_PROG_TYPE_SOCKET_FILTER) {
 		/* valid fd, but invalid program type */
-- 
2.1.0
