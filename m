From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/12] netfilter: xt_bpf: Fix XT_BPF_MODE_FD_PINNED mode of 'xt_bpf_info_v1'
Date: Mon,  9 Oct 2017 18:25:46 +0200
Message-ID: <1507566346-32553-13-git-send-email-pablo@netfilter.org>
References: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57858 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755275AbdJIQ0J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 12:26:09 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4BFE4C0B38
        for <netdev@vger.kernel.org>; Mon,  9 Oct 2017 18:26:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 39603DA398
        for <netdev@vger.kernel.org>; Mon,  9 Oct 2017 18:26:07 +0200 (CEST)
In-Reply-To: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Commit 2c16d6033264 ("netfilter: xt_bpf: support ebpf") introduced
support for attaching an eBPF object by an fd, with the
'bpf_mt_check_v1' ABI expecting the '.fd' to be specified upon each
IPT_SO_SET_REPLACE call.

However this breaks subsequent iptables calls:

 # iptables -A INPUT -m bpf --object-pinned /sys/fs/bpf/xxx -j ACCEPT
 # iptables -A INPUT -s 5.6.7.8 -j ACCEPT
 iptables: Invalid argument. Run `dmesg' for more information.

That's because iptables works by loading existing rules using
IPT_SO_GET_ENTRIES to userspace, then issuing IPT_SO_SET_REPLACE with
the replacement set.

However, the loaded 'xt_bpf_info_v1' has an arbitrary '.fd' number
(from the initial "iptables -m bpf" invocation) - so when 2nd invocation
occurs, userspace passes a bogus fd number, which leads to
'bpf_mt_check_v1' to fail.

One suggested solution [1] was to hack iptables userspace, to perform a
"entries fixup" immediatley after IPT_SO_GET_ENTRIES, by opening a new,
process-local fd per every 'xt_bpf_info_v1' entry seen.

However, in [2] both Pablo Neira Ayuso and Willem de Bruijn suggested to
depricate the xt_bpf_info_v1 ABI dealing with pinned ebpf objects.

This fix changes the XT_BPF_MODE_FD_PINNED behavior to ignore the given
'.fd' and instead perform an in-kernel lookup for the bpf object given
the provided '.path'.

It also defines an alias for the XT_BPF_MODE_FD_PINNED mode, named
XT_BPF_MODE_PATH_PINNED, to better reflect the fact that the user is
expected to provide the path of the pinned object.

Existing XT_BPF_MODE_FD_ELF behavior (non-pinned fd mode) is preserved.

References: [1] https://marc.info/?l=netfilter-devel&m=150564724607440&w=2
            [2] https://marc.info/?l=netfilter-devel&m=150575727129880&w=2

Reported-by: Rafael Buchbinder <rafi@rbk.ms>
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Acked-by: Willem de Bruijn <willemb@google.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/bpf.h                   |  5 +++++
 include/uapi/linux/netfilter/xt_bpf.h |  1 +
 kernel/bpf/inode.c                    |  1 +
 net/netfilter/xt_bpf.c                | 22 ++++++++++++++++++++--
 4 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 8390859e79e7..f1af7d63d678 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -368,6 +368,11 @@ static inline void __bpf_prog_uncharge(struct user_struct *user, u32 pages)
 {
 }
 
+static inline int bpf_obj_get_user(const char __user *pathname)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline struct net_device  *__dev_map_lookup_elem(struct bpf_map *map,
 						       u32 key)
 {
diff --git a/include/uapi/linux/netfilter/xt_bpf.h b/include/uapi/linux/netfilter/xt_bpf.h
index b97725af2ac0..da161b56c79e 100644
--- a/include/uapi/linux/netfilter/xt_bpf.h
+++ b/include/uapi/linux/netfilter/xt_bpf.h
@@ -23,6 +23,7 @@ enum xt_bpf_modes {
 	XT_BPF_MODE_FD_PINNED,
 	XT_BPF_MODE_FD_ELF,
 };
+#define XT_BPF_MODE_PATH_PINNED XT_BPF_MODE_FD_PINNED
 
 struct xt_bpf_info_v1 {
 	__u16 mode;
diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index e833ed914358..be1dde967208 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -363,6 +363,7 @@ int bpf_obj_get_user(const char __user *pathname)
 	putname(pname);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(bpf_obj_get_user);
 
 static void bpf_evict_inode(struct inode *inode)
 {
diff --git a/net/netfilter/xt_bpf.c b/net/netfilter/xt_bpf.c
index 38986a95216c..29123934887b 100644
--- a/net/netfilter/xt_bpf.c
+++ b/net/netfilter/xt_bpf.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/syscalls.h>
 #include <linux/skbuff.h>
 #include <linux/filter.h>
 #include <linux/bpf.h>
@@ -49,6 +50,22 @@ static int __bpf_mt_check_fd(int fd, struct bpf_prog **ret)
 	return 0;
 }
 
+static int __bpf_mt_check_path(const char *path, struct bpf_prog **ret)
+{
+	mm_segment_t oldfs = get_fs();
+	int retval, fd;
+
+	set_fs(KERNEL_DS);
+	fd = bpf_obj_get_user(path);
+	set_fs(oldfs);
+	if (fd < 0)
+		return fd;
+
+	retval = __bpf_mt_check_fd(fd, ret);
+	sys_close(fd);
+	return retval;
+}
+
 static int bpf_mt_check(const struct xt_mtchk_param *par)
 {
 	struct xt_bpf_info *info = par->matchinfo;
@@ -66,9 +83,10 @@ static int bpf_mt_check_v1(const struct xt_mtchk_param *par)
 		return __bpf_mt_check_bytecode(info->bpf_program,
 					       info->bpf_program_num_elem,
 					       &info->filter);
-	else if (info->mode == XT_BPF_MODE_FD_PINNED ||
-		 info->mode == XT_BPF_MODE_FD_ELF)
+	else if (info->mode == XT_BPF_MODE_FD_ELF)
 		return __bpf_mt_check_fd(info->fd, &info->filter);
+	else if (info->mode == XT_BPF_MODE_PATH_PINNED)
+		return __bpf_mt_check_path(info->path, &info->filter);
 	else
 		return -EINVAL;
 }
-- 
2.1.4
