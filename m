From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: [RFC PATCH 08/17] ipv6: Add ipv6_renew_options_kern() that accepts a
 kernel mem pointer.
Date: Tue, 22 Dec 2015 11:46:44 +0000
Message-ID: <1450784813-18304-9-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

The functionality is equivalent to ipv6_renew_options() except
that the newopt pointer is in kernel, not user, memory

The kernel memory implementation will be used by the CALIPSO network
labelling engine, which needs to be able to set IPv6 hop-by-hop
options.

Signed-off-by: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
---
 include/net/ipv6.h |   6 +++
 net/ipv6/exthdrs.c | 131 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 125 insertions(+), 12 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 9a5c9f0..5a72ffd 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -304,6 +304,12 @@ struct ipv6_txoptions *ipv6_renew_options(struct sock *sk,
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
index ea7c4d6..9426b26 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -734,11 +734,16 @@ ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt)
 EXPORT_SYMBOL_GPL(ipv6_dup_options);
 
 static int ipv6_renew_option(void *ohdr,
-			     struct ipv6_opt_hdr __user *newopt, int newoptlen,
+			     struct ipv6_opt_hdr __user *newopt_user,
+			     struct ipv6_opt_hdr *newopt,
+			     int newoptlen,
 			     int inherit,
 			     struct ipv6_opt_hdr **hdr,
 			     char **p)
 {
+	if (WARN_ON_ONCE(newopt_user && newopt))
+		return -EINVAL;
+
 	if (inherit) {
 		if (ohdr) {
 			memcpy(*p, ohdr, ipv6_optlen((struct ipv6_opt_hdr *)ohdr));
@@ -746,28 +751,65 @@ static int ipv6_renew_option(void *ohdr,
 			*p += CMSG_ALIGN(ipv6_optlen(*hdr));
 		}
 	} else {
-		if (newopt) {
-			if (copy_from_user(*p, newopt, newoptlen))
+		if (newopt_user) {
+			if (copy_from_user(*p, newopt_user, newoptlen))
 				return -EFAULT;
 			*hdr = (struct ipv6_opt_hdr *)*p;
 			if (ipv6_optlen(*hdr) > newoptlen)
 				return -EINVAL;
 			*p += CMSG_ALIGN(newoptlen);
+		} else if (newopt) {
+			memcpy(*p, newopt, newoptlen);
+			*hdr = (struct ipv6_opt_hdr *)*p;
+			if (ipv6_optlen(*hdr) > newoptlen)
+				return -EINVAL;
+			*p += CMSG_ALIGN(newoptlen);
 		}
 	}
 	return 0;
 }
 
-struct ipv6_txoptions *
-ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
-		   int newtype,
-		   struct ipv6_opt_hdr __user *newopt, int newoptlen)
+/**
+ * __ipv6_renew_options - replace a specific ext hdr with a new one.
+ *
+ * @sk: sock from which to allocate memory
+ * @opt: original options
+ * @newtype: option type to replace in @opt
+ * @newopt_user: new option of type @newtype to replace (user-mem)
+ * @newopt: new option of type @newtype to replace (kernel-mem)
+ * @newoptlen: length of @newopt_user or @newopt
+ *
+ * The implementation of ipv6_renew_options() and
+ * ipv6_renew_options_from_user().
+ *
+ * Returns a new set of options which is a copy of @opt with the
+ * option type @newtype replaced with either @newopt_user or @newopt.
+ * Only one of @newopt_user or @newopt may be non-NULL.
+ *
+ * @opt may be NULL, in which case a new set of options is returned
+ * containing just @newopt_user or @newopt.
+ *
+ * Both @newopt_user and @newopt may be NULL, in which case the
+ * specified option type is not copied into the new set of options.
+ *
+ * The new set of options is allocated from the socket option memory
+ * buffer of @sk.
+ */
+static struct ipv6_txoptions *
+__ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
+		     int newtype,
+		     struct ipv6_opt_hdr __user *newopt_user,
+		     struct ipv6_opt_hdr *newopt,
+		     int newoptlen)
 {
 	int tot_len = 0;
 	char *p;
 	struct ipv6_txoptions *opt2;
 	int err;
 
+	if (WARN_ON_ONCE(newopt_user && newopt))
+		return NULL;
+
 	if (opt) {
 		if (newtype != IPV6_HOPOPTS && opt->hopopt)
 			tot_len += CMSG_ALIGN(ipv6_optlen(opt->hopopt));
@@ -779,7 +821,7 @@ ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
 			tot_len += CMSG_ALIGN(ipv6_optlen(opt->dst1opt));
 	}
 
-	if (newopt && newoptlen)
+	if ((newopt_user || newopt) && newoptlen)
 		tot_len += CMSG_ALIGN(newoptlen);
 
 	if (!tot_len)
@@ -795,25 +837,29 @@ ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
 	opt2->tot_len = tot_len;
 	p = (char *)(opt2 + 1);
 
-	err = ipv6_renew_option(opt ? opt->hopopt : NULL, newopt, newoptlen,
+	err = ipv6_renew_option(opt ? opt->hopopt : NULL, newopt_user,
+				newopt, newoptlen,
 				newtype != IPV6_HOPOPTS,
 				&opt2->hopopt, &p);
 	if (err)
 		goto out;
 
-	err = ipv6_renew_option(opt ? opt->dst0opt : NULL, newopt, newoptlen,
+	err = ipv6_renew_option(opt ? opt->dst0opt : NULL, newopt_user,
+				newopt, newoptlen,
 				newtype != IPV6_RTHDRDSTOPTS,
 				&opt2->dst0opt, &p);
 	if (err)
 		goto out;
 
-	err = ipv6_renew_option(opt ? opt->srcrt : NULL, newopt, newoptlen,
+	err = ipv6_renew_option(opt ? opt->srcrt : NULL, newopt_user,
+				newopt, newoptlen,
 				newtype != IPV6_RTHDR,
 				(struct ipv6_opt_hdr **)&opt2->srcrt, &p);
 	if (err)
 		goto out;
 
-	err = ipv6_renew_option(opt ? opt->dst1opt : NULL, newopt, newoptlen,
+	err = ipv6_renew_option(opt ? opt->dst1opt : NULL, newopt_user,
+				newopt, newoptlen,
 				newtype != IPV6_DSTOPTS,
 				&opt2->dst1opt, &p);
 	if (err)
@@ -830,6 +876,67 @@ out:
 	return ERR_PTR(err);
 }
 
+/**
+ * ipv6_renew_options_kern - replace a specific ext hdr with a new one.
+ *
+ * @sk: sock from which to allocate memory
+ * @opt: original options
+ * @newtype: option type to replace in @opt
+ * @newopt: new option of type @newtype to replace (kernel-mem)
+ * @newoptlen: length of or @newopt
+ *
+ * Returns a new set of options which is a copy of @opt with the
+ * option type @newtype replaced with @newopt.
+ *
+ * @opt may be NULL, in which case a new set of options is returned
+ * containing just @newopt.
+ *
+ * @newopt may be NULL, in which case the specified option type is not
+ * copied into the new set of options.
+ *
+ * The new set of options is allocated from the socket option memory
+ * buffer of @sk.
+ */
+struct ipv6_txoptions *
+ipv6_renew_options_kern(struct sock *sk, struct ipv6_txoptions *opt,
+			int newtype, struct ipv6_opt_hdr *newopt,
+			int newoptlen)
+{
+	return __ipv6_renew_options(sk, opt, newtype,
+				    NULL, newopt, newoptlen);
+}
+
+/**
+ * ipv6_renew_options - replace a specific ext hdr with a new one.
+ *
+ * @sk: sock from which to allocate memory
+ * @opt: original options
+ * @newtype: option type to replace in @opt
+ * @newopt_user: new option of type @newtype to replace (user-mem)
+ * @newoptlen: length of or @newopt
+ *
+ * Returns a new set of options which is a copy of @opt with the
+ * option type @newtype replaced with @newopt_user.
+ *
+ * @opt may be NULL, in which case a new set of options is returned
+ * containing just @newopt_user.
+ *
+ * @newopt_user may be NULL, in which case the specified option type is not
+ * copied into the new set of options.
+ *
+ * The new set of options is allocated from the socket option memory
+ * buffer of @sk.
+ */
+struct ipv6_txoptions *
+ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
+		   int newtype,
+		   struct ipv6_opt_hdr __user *newopt_user,
+		   int newoptlen)
+{
+	return __ipv6_renew_options(sk, opt, newtype,
+				    newopt_user, NULL, newoptlen);
+}
+
 struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 					  struct ipv6_txoptions *opt)
 {
-- 
1.8.0

_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
