From: Quentin Monnet <quentin.monnet@6wind.com>
Subject: [PATCH net-next 2/2] cls_bpf: send back eBPF bytecode through netlink socket
Date: Fri, 15 Apr 2016 12:07:36 +0200
Message-ID: <1460714856-7221-3-git-send-email-quentin.monnet@6wind.com>
References: <1460714856-7221-1-git-send-email-quentin.monnet@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37623 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbcDOKIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 06:08:14 -0400
Received: by mail-wm0-f52.google.com with SMTP id n3so25139068wmn.0
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 03:08:13 -0700 (PDT)
In-Reply-To: <1460714856-7221-1-git-send-email-quentin.monnet@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As for act_bpf in a former patch, this patch makes the scheduler send
eBPF bytecode through the netlink socket for BPF filters set up with tc.
The existing TCA_BPF_FLAGS netlink attribute is used to embed a new flag
signaling eBPF bytecode, so as to identify the BPF version when reading
from the socket on userspace side.

Signed-off-by: Quentin Monnet <quentin.monnet@6wind.com>
---
 include/uapi/linux/pkt_cls.h |  1 +
 net/sched/cls_bpf.c          | 25 +++++++++++++++++++++++--
 2 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index c43c5f78b9c4..09d726fc2c5a 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -376,6 +376,7 @@ enum {
 /* BPF classifier */
 
 #define TCA_BPF_FLAG_ACT_DIRECT		(1 << 0)
+#define TCA_BPF_FLAG_EBPF		(1 << 1)
 
 enum {
 	TCA_BPF_UNSPEC,
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 425fe6a0eda3..f1d9057d8d94 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -450,6 +450,25 @@ static int cls_bpf_dump_bpf_info(const struct cls_bpf_prog *prog,
 static int cls_bpf_dump_ebpf_info(const struct cls_bpf_prog *prog,
 				  struct sk_buff *skb)
 {
+	struct bpf_prog *filter;
+
+	rcu_read_lock();
+	filter = rcu_dereference(prog->filter);
+	if (filter) {
+		if (nla_put_u16(skb, TCA_BPF_OPS_LEN, filter->len)) {
+			rcu_read_unlock();
+			return -EMSGSIZE;
+		}
+
+		if (nla_put(skb, TCA_BPF_OPS,
+			    filter->len * sizeof(struct sock_filter),
+			    filter->insnsi)) {
+			rcu_read_unlock();
+			return -EMSGSIZE;
+		}
+	}
+	rcu_read_unlock();
+
 	if (nla_put_u32(skb, TCA_BPF_FD, prog->bpf_fd))
 		return -EMSGSIZE;
 
@@ -481,10 +500,12 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_BPF_CLASSID, prog->res.classid))
 		goto nla_put_failure;
 
-	if (cls_bpf_is_ebpf(prog))
+	if (cls_bpf_is_ebpf(prog)) {
+		bpf_flags |= TCA_BPF_FLAG_EBPF;
 		ret = cls_bpf_dump_ebpf_info(prog, skb);
-	else
+	} else {
 		ret = cls_bpf_dump_bpf_info(prog, skb);
+	}
 	if (ret)
 		goto nla_put_failure;
 
-- 
2.7.4
