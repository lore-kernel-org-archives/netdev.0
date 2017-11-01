From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 05/12] xdp: allow attaching programs loaded for specific device
Date: Tue, 31 Oct 2017 18:52:10 -0700
Message-ID: <20171101015217.10666-6-jakub.kicinski@netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:50858 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932868AbdKABxD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:53:03 -0400
Received: by mail-pf0-f196.google.com with SMTP id b6so725841pfh.7
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:53:03 -0700 (PDT)
In-Reply-To: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass the netdev pointer to bpf_prog_get_type().  This way
BPF code can decide whether the device matches what the
code was loaded/translated for.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 include/linux/bpf.h  | 10 ++++++++++
 kernel/bpf/syscall.c | 33 +++++++++++++++++++++++++++++----
 net/core/dev.c       |  6 +++++-
 3 files changed, 44 insertions(+), 5 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 98bacd0fa5cc..c397934f91dd 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -335,6 +335,8 @@ extern const struct bpf_verifier_ops xdp_analyzer_ops;
 
 struct bpf_prog *bpf_prog_get(u32 ufd);
 struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type);
+struct bpf_prog *bpf_prog_get_type_dev(u32 ufd, enum bpf_prog_type type,
+				       struct net_device *netdev);
 struct bpf_prog * __must_check bpf_prog_add(struct bpf_prog *prog, int i);
 void bpf_prog_sub(struct bpf_prog *prog, int i);
 struct bpf_prog * __must_check bpf_prog_inc(struct bpf_prog *prog);
@@ -428,6 +430,14 @@ static inline struct bpf_prog *bpf_prog_get_type(u32 ufd,
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
+
+static inline struct bpf_prog *bpf_prog_get_type_dev(u32 ufd,
+						     enum bpf_prog_type type,
+						     struct net_device *netdev)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
 static inline struct bpf_prog * __must_check bpf_prog_add(struct bpf_prog *prog,
 							  int i)
 {
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 6712df2aa057..8c988025c8d3 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1057,7 +1057,22 @@ struct bpf_prog *bpf_prog_inc_not_zero(struct bpf_prog *prog)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_inc_not_zero);
 
-static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *attach_type)
+static bool bpf_prog_can_attach(struct bpf_prog *prog,
+				enum bpf_prog_type *attach_type,
+				struct net_device *netdev)
+{
+	struct bpf_dev_offload *offload = prog->aux->offload;
+
+	if (prog->type != *attach_type)
+		return false;
+	if (offload && offload->netdev != netdev)
+		return false;
+
+	return true;
+}
+
+static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *attach_type,
+				       struct net_device *netdev)
 {
 	struct fd f = fdget(ufd);
 	struct bpf_prog *prog;
@@ -1065,7 +1080,7 @@ static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *attach_type)
 	prog = ____bpf_prog_get(f);
 	if (IS_ERR(prog))
 		return prog;
-	if (attach_type && (prog->type != *attach_type || prog->aux->offload)) {
+	if (attach_type && !bpf_prog_can_attach(prog, attach_type, netdev)) {
 		prog = ERR_PTR(-EINVAL);
 		goto out;
 	}
@@ -1078,12 +1093,12 @@ static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *attach_type)
 
 struct bpf_prog *bpf_prog_get(u32 ufd)
 {
-	return __bpf_prog_get(ufd, NULL);
+	return __bpf_prog_get(ufd, NULL, NULL);
 }
 
 struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type)
 {
-	struct bpf_prog *prog = __bpf_prog_get(ufd, &type);
+	struct bpf_prog *prog = __bpf_prog_get(ufd, &type, NULL);
 
 	if (!IS_ERR(prog))
 		trace_bpf_prog_get_type(prog);
@@ -1091,6 +1106,16 @@ struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_get_type);
 
+struct bpf_prog *bpf_prog_get_type_dev(u32 ufd, enum bpf_prog_type type,
+				       struct net_device *netdev)
+{
+	struct bpf_prog *prog = __bpf_prog_get(ufd, &type, netdev);
+
+	if (!IS_ERR(prog))
+		trace_bpf_prog_get_type(prog);
+	return prog;
+}
+
 /* last field in 'union bpf_attr' used by this command */
 #define	BPF_PROG_LOAD_LAST_FIELD prog_ifindex
 
diff --git a/net/core/dev.c b/net/core/dev.c
index abed566e1b1d..9d84650598e0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7156,7 +7156,11 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 		    __dev_xdp_attached(dev, bpf_op, NULL))
 			return -EBUSY;
 
-		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
+		if (bpf_op == ops->ndo_bpf)
+			prog = bpf_prog_get_type_dev(fd, BPF_PROG_TYPE_XDP,
+						     dev);
+		else
+			prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
 		if (IS_ERR(prog))
 			return PTR_ERR(prog);
 	}
-- 
2.14.1
