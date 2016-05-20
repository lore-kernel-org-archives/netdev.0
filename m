From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/2] bpf: support decreasing order in direct packet access
Date: Thu, 19 May 2016 18:17:13 -0700
Message-ID: <1463707034-2372430-2-git-send-email-ast@fb.com>
References: <1463707034-2372430-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:24706 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754063AbcETBRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 21:17:19 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u4K1EQRO008456
	for <netdev@vger.kernel.org>; Thu, 19 May 2016 18:17:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 231agk704d-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 May 2016 18:17:18 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 96a61b381e2811e6a78024be05956610-2ce4c6d0 for <netdev@vger.kernel.org>;	Thu,
 19 May 2016 18:17:15 -0700
In-Reply-To: <1463707034-2372430-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when packet headers are accessed in 'decreasing' order (like TCP port
may be fetched before the program reads IP src) the llvm may generate
the following code:
[...]                // R7=pkt(id=0,off=22,r=70)
r2 = *(u32 *)(r7 +0) // good access
[...]
r7 += 40             // R7=pkt(id=0,off=62,r=70)
r8 = *(u32 *)(r7 +0) // good access
[...]
r1 = *(u32 *)(r7 -20) // this one will fail though it's within a safe range
                      // it's doing *(u32*)(skb->data + 42)
Fix verifier to recognize such code pattern

Alos turned out that 'off > range' condition is not a verifier bug.
It's a buggy program that may do something like:
if (ptr + 50 > data_end)
  return 0;
ptr += 60;
*(u32*)ptr;
in such case emit
"invalid access to packet, off=0 size=4, R1(id=0,off=60,r=50)" error message,
so all information is available for the program author to fix the program.

Fixes: 969bf05eb3ce ("bpf: direct packet access")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index a08d66215245..d54e34874579 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -683,15 +683,11 @@ static int check_packet_access(struct verifier_env *env, u32 regno, int off,
 {
 	struct reg_state *regs = env->cur_state.regs;
 	struct reg_state *reg = &regs[regno];
-	int linear_size = (int) reg->range - (int) reg->off;
 
-	if (linear_size < 0 || linear_size >= MAX_PACKET_OFF) {
-		verbose("verifier bug\n");
-		return -EFAULT;
-	}
-	if (off < 0 || off + size > linear_size) {
-		verbose("invalid access to packet, off=%d size=%d, allowed=%d\n",
-			off, size, linear_size);
+	off += reg->off;
+	if (off < 0 || off + size > reg->range) {
+		verbose("invalid access to packet, off=%d size=%d, R%d(id=%d,off=%d,r=%d)\n",
+			off, size, regno, reg->id, reg->off, reg->range);
 		return -EACCES;
 	}
 	return 0;
-- 
2.8.0
