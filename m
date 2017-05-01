From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, samples: fix build warning in cookie_uid_helper_example
Date: Tue,  2 May 2017 00:47:09 +0200
Message-ID: <43325f50d66abec6b35439422b6c9b0211bd30e9.1493678555.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42290 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbdEAWri (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 18:47:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following warnings triggered by 51570a5ab2b7 ("A Sample of
using socket cookie and uid for traffic monitoring"):

  In file included from /home/foo/net-next/samples/bpf/cookie_uid_helper_example.c:54:0:
  /home/foo/net-next/samples/bpf/cookie_uid_helper_example.c: In function 'prog_load':
  /home/foo/net-next/samples/bpf/cookie_uid_helper_example.c:119:27: warning: overflow in implicit constant conversion [-Woverflow]
     -32 + offsetof(struct stats, uid)),
                           ^
  /home/foo/net-next/samples/bpf/libbpf.h:135:12: note: in definition of macro 'BPF_STX_MEM'
   .off   = OFF,     \
            ^
  /home/foo/net-next/samples/bpf/cookie_uid_helper_example.c:121:27: warning: overflow in implicit constant conversion [-Woverflow]
     -32 + offsetof(struct stats, packets), 1),
                           ^
  /home/foo/net-next/samples/bpf/libbpf.h:155:12: note: in definition of macro 'BPF_ST_MEM'
   .off   = OFF,     \
            ^
  /home/foo/net-next/samples/bpf/cookie_uid_helper_example.c:129:27: warning: overflow in implicit constant conversion [-Woverflow]
     -32 + offsetof(struct stats, bytes)),
                           ^
  /home/foo/net-next/samples/bpf/libbpf.h:135:12: note: in definition of macro 'BPF_STX_MEM'
   .off   = OFF,     \
            ^
  HOSTLD  /home/foo/net-next/samples/bpf/per_socket_stats_example

Fixes: 51570a5ab2b7 ("A Sample of using socket cookie and uid for traffic monitoring")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/cookie_uid_helper_example.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/samples/bpf/cookie_uid_helper_example.c b/samples/bpf/cookie_uid_helper_example.c
index 9ce5584..b08ab4e 100644
--- a/samples/bpf/cookie_uid_helper_example.c
+++ b/samples/bpf/cookie_uid_helper_example.c
@@ -116,9 +116,9 @@ static void prog_load(void)
 		 * is set by directly place a IMM value 1 into the stack.
 		 */
 		BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0,
-				-32 + offsetof(struct stats, uid)),
+			    -32 + (__s16)offsetof(struct stats, uid)),
 		BPF_ST_MEM(BPF_DW, BPF_REG_10,
-				-32 + offsetof(struct stats, packets), 1),
+			   -32 + (__s16)offsetof(struct stats, packets), 1),
 		/*
 		 * __sk_buff is a special struct used for eBPF program to
 		 * directly access some sk_buff field.
@@ -126,7 +126,7 @@ static void prog_load(void)
 		BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_6,
 				offsetof(struct __sk_buff, len)),
 		BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1,
-				-32 + offsetof(struct stats, bytes)),
+			    -32 + (__s16)offsetof(struct stats, bytes)),
 		/*
 		 * add new map entry using BPF_FUNC_map_update_elem, it takes
 		 * 4 parameters (R1: map_fd, R2: &socket_cookie, R3: &stats,
-- 
1.9.3
