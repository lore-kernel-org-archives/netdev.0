From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 08/19] ipv6: Add ipv6_renew_options_kern() that accepts a kernel mem pointer.
Date: Mon, 20 Jun 2016 14:36:48 +0100
Message-ID: <1466429819-12707-9-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

The functionality is equivalent to ipv6_renew_options() except
that the newopt pointer is in kernel, not user, memory

The kernel memory implementation will be used by the CALIPSO network
labelling engine, which needs to be able to set IPv6 hop-by-hop
options.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 include/net/ipv6.h |  6 ++++++
 net/ipv6/exthdrs.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 1be050a..917036f 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -308,6 +308,12 @@ struct ipv6_txoptions *ipv6_renew_options(struct sock *sk,
 					  int newtype,
 					  struct ipv6_opt_hdr __user *newopt,
 					  int newoptlen);
+struct ipv6_txoptions *
+ipv6_renew_options_kern(struct sock *sk,
+			struct ipv6_txoptions *opt,
+			int newtype,
+			struct ipv6_opt_hdr *newopt,
+			int newoptlen);
 struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 					  struct ipv6_txoptions *opt);
 
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index ea7c4d6..d5fd3e7 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -758,6 +758,27 @@ static int ipv6_renew_option(void *ohdr,
 	return 0;
 }
 
+/**
+ * ipv6_renew_options - replace a specific ext hdr with a new one.
+ *
+ * @sk: sock from which to allocate memory
+ * @opt: original options
+ * @newtype: option type to replace in @opt
+ * @newopt: new option of type @newtype to replace (user-mem)
+ * @newoptlen: length of @newopt
+ *
+ * Returns a new set of options which is a copy of @opt with the
+ * option type @newtype replaced with @newopt.
+ *
+ * @opt may be NULL, in which case a new set of options is returned
+ * containing just @newopt.
+ *
+ * @newopt may be NULL, in which case the specified option type is
+ * not copied into the new set of options.
+ *
+ * The new set of options is allocated from the socket option memory
+ * buffer of @sk.
+ */
 struct ipv6_txoptions *
 ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
 		   int newtype,
@@ -830,6 +851,34 @@ out:
 	return ERR_PTR(err);
 }
 
+/**
+ * ipv6_renew_options_kern - replace a specific ext hdr with a new one.
+ *
+ * @sk: sock from which to allocate memory
+ * @opt: original options
+ * @newtype: option type to replace in @opt
+ * @newopt: new option of type @newtype to replace (kernel-mem)
+ * @newoptlen: length of @newopt
+ *
+ * See ipv6_renew_options().  The difference is that @newopt is
+ * kernel memory, rather than user memory.
+ */
+struct ipv6_txoptions *
+ipv6_renew_options_kern(struct sock *sk, struct ipv6_txoptions *opt,
+			int newtype, struct ipv6_opt_hdr *newopt,
+			int newoptlen)
+{
+	struct ipv6_txoptions *ret_val;
+	const mm_segment_t old_fs = get_fs();
+
+	set_fs(KERNEL_DS);
+	ret_val = ipv6_renew_options(sk, opt, newtype,
+				     (struct ipv6_opt_hdr __user *)newopt,
+				     newoptlen);
+	set_fs(old_fs);
+	return ret_val;
+}
+
 struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 					  struct ipv6_txoptions *opt)
 {
-- 
2.7.4

