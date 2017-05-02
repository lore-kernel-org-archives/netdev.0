From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] bpf: Do not dereference user pointer in
 bpf_test_finish().
Date: Tue, 02 May 2017 11:36:33 -0400 (EDT)
Message-ID: <20170502.113633.800987081837435647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdEBPgf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:36:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead, pass the kattr in which has a kernel side copy of this
data structure from userspace already.

Fix based upon a suggestion from Alexei Starovoitov.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/bpf/test_run.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/bpf/test_run.c b/net/bpf/test_run.c
index 8a6d0a3..f946912 100644
--- a/net/bpf/test_run.c
+++ b/net/bpf/test_run.c
@@ -49,10 +49,11 @@ static u32 bpf_test_run(struct bpf_prog *prog, void *ctx, u32 repeat, u32 *time)
 	return ret;
 }
 
-static int bpf_test_finish(union bpf_attr __user *uattr, const void *data,
+static int bpf_test_finish(const union bpf_attr *kattr,
+			   union bpf_attr __user *uattr, const void *data,
 			   u32 size, u32 retval, u32 duration)
 {
-	void __user *data_out = u64_to_user_ptr(uattr->test.data_out);
+	void __user *data_out = u64_to_user_ptr(kattr->test.data_out);
 	int err = -EFAULT;
 
 	if (data_out && copy_to_user(data_out, data, size))
@@ -140,7 +141,7 @@ int bpf_prog_test_run_skb(struct bpf_prog *prog, const union bpf_attr *kattr,
 	/* bpf program can never convert linear skb to non-linear */
 	if (WARN_ON_ONCE(skb_is_nonlinear(skb)))
 		size = skb_headlen(skb);
-	ret = bpf_test_finish(uattr, skb->data, size, retval, duration);
+	ret = bpf_test_finish(kattr, uattr, skb->data, size, retval, duration);
 	kfree_skb(skb);
 	return ret;
 }
@@ -166,7 +167,7 @@ int bpf_prog_test_run_xdp(struct bpf_prog *prog, const union bpf_attr *kattr,
 	retval = bpf_test_run(prog, &xdp, repeat, &duration);
 	if (xdp.data != data + XDP_PACKET_HEADROOM)
 		size = xdp.data_end - xdp.data;
-	ret = bpf_test_finish(uattr, xdp.data, size, retval, duration);
+	ret = bpf_test_finish(kattr, uattr, xdp.data, size, retval, duration);
 	kfree(data);
 	return ret;
 }
-- 
2.1.2.532.g19b5d50
