From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/2] bpf: fix checking xdp_adjust_head on tail calls
Date: Mon, 17 Apr 2017 03:12:07 +0200
Message-ID: <d729c74d7a3d56bd4e26eeb23cf8d14a07e54c80.1492390940.git.daniel@iogearbox.net>
References: <cover.1492390940.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, kubakici@wp.pl,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51335 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757031AbdDQBMR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 21:12:17 -0400
In-Reply-To: <cover.1492390940.git.daniel@iogearbox.net>
In-Reply-To: <cover.1492390940.git.daniel@iogearbox.net>
References: <cover.1492390940.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
added the xdp_adjust_head bit to the BPF prog in order to tell drivers
that the program that is to be attached requires support for the XDP
bpf_xdp_adjust_head() helper such that drivers not supporting this
helper can reject the program. There are also drivers that do support
the helper, but need to check for xdp_adjust_head bit in order to move
packet metadata prepended by the firmware away for making headroom.

For these cases, the current check for xdp_adjust_head bit is insufficient
since there can be cases where the program itself does not use the
bpf_xdp_adjust_head() helper, but tail calls into another program that
uses bpf_xdp_adjust_head(). As such, the xdp_adjust_head bit is still
set to 0. Since the first program has no control over which program it
calls into, we need to assume that bpf_xdp_adjust_head() helper is used
upon tail calls. Thus, for the very same reasons in cb_access, set the
xdp_adjust_head bit to 1 when the main program uses tail calls.

Fixes: 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Cc: Martin KaFai Lau <kafai@fb.com>
---
 kernel/bpf/syscall.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index ee5c969..821f9e8 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -623,6 +623,7 @@ static void fixup_bpf_calls(struct bpf_prog *prog)
 				 * in the program array.
 				 */
 				prog->cb_access = 1;
+				prog->xdp_adjust_head = 1;
 
 				/* mark bpf_tail_call as different opcode
 				 * to avoid conditional branch in
-- 
1.9.3
