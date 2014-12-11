From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net: sock: fix access via invalid file descriptor
Date: Wed, 10 Dec 2014 20:14:55 -0800
Message-ID: <1418271295-5829-1-git-send-email-ast@plumgrid.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Dave Jones <davej@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

0day robot reported the following crash:
[   21.233581] BUG: unable to handle kernel NULL pointer dereference at 0000000000000007
[   21.234709] IP: [<ffffffff8156ebda>] sk_attach_bpf+0x39/0xc2

It's due to bpf_prog_get() returning ERR_PTR.
Check it properly.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached to sockets")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
Silly mistake. I was sure I've checked this error path. Apparently not :(

 net/core/filter.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 8cc3c03078b3..ec9baea10c16 100644
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
1.7.9.5
