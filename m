From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v4 net-next 3/5] net: filter: rename sk_chk_filter() -> bpf_check_classic()
Date: Wed, 30 Jul 2014 20:34:14 -0700
Message-ID: <1406777656-27755-4-git-send-email-ast@plumgrid.com>
References: <1406777656-27755-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406777656-27755-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

trivial rename to indicate that this functions performs classic BPF checking

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 Documentation/networking/filter.txt |    2 +-
 include/linux/filter.h              |    2 +-
 kernel/bpf/core.c                   |    2 +-
 kernel/seccomp.c                    |    4 ++--
 net/core/filter.c                   |   10 +++++-----
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index ee78eba78a9d..712068be8171 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -591,7 +591,7 @@ sk_unattached_filter_destroy() for destroying it. The macro
 SK_RUN_FILTER(filter, ctx) transparently invokes eBPF interpreter or JITed
 code to run the filter. 'filter' is a pointer to struct sk_filter that we
 got from sk_unattached_filter_create(), and 'ctx' the given context (e.g.
-skb pointer). All constraints and restrictions from sk_chk_filter() apply
+skb pointer). All constraints and restrictions from bpf_check_classic() apply
 before a conversion to the new layout is being done behind the scenes!
 
 Currently, the classic BPF format is being used for JITing on most of the
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 3769341a745d..c4d0be4c5e75 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -361,7 +361,7 @@ void sk_unattached_filter_destroy(struct sk_filter *fp);
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 int sk_detach_filter(struct sock *sk);
 
-int sk_chk_filter(const struct sock_filter *filter, unsigned int flen);
+int bpf_check_classic(const struct sock_filter *filter, unsigned int flen);
 int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 		  unsigned int len);
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 265a02cc822d..b479807ec383 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -18,7 +18,7 @@
  * 2 of the License, or (at your option) any later version.
  *
  * Andi Kleen - Fix a few bad bugs and races.
- * Kris Katterjohn - Added many additional checks in sk_chk_filter()
+ * Kris Katterjohn - Added many additional checks in bpf_check_classic()
  */
 #include <linux/filter.h>
 #include <linux/skbuff.h>
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 565743db5384..f4a77d23f209 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -87,7 +87,7 @@ static void populate_seccomp_data(struct seccomp_data *sd)
  *	@filter: filter to verify
  *	@flen: length of filter
  *
- * Takes a previously checked filter (by sk_chk_filter) and
+ * Takes a previously checked filter (by bpf_check_classic) and
  * redirects all filter code that loads struct sk_buff data
  * and related data through seccomp_bpf_load.  It also
  * enforces length and alignment checking of those loads.
@@ -239,7 +239,7 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 		goto free_prog;
 
 	/* Check and rewrite the fprog via the skb checker */
-	ret = sk_chk_filter(fp, fprog->len);
+	ret = bpf_check_classic(fp, fprog->len);
 	if (ret)
 		goto free_prog;
 
diff --git a/net/core/filter.c b/net/core/filter.c
index d6cb287e4f59..5740ea08a3ad 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -18,7 +18,7 @@
  * 2 of the License, or (at your option) any later version.
  *
  * Andi Kleen - Fix a few bad bugs and races.
- * Kris Katterjohn - Added many additional checks in sk_chk_filter()
+ * Kris Katterjohn - Added many additional checks in bpf_check_classic()
  */
 
 #include <linux/module.h>
@@ -721,7 +721,7 @@ static bool chk_code_allowed(u16 code_to_probe)
 }
 
 /**
- *	sk_chk_filter - verify socket filter code
+ *	bpf_check_classic - verify socket filter code
  *	@filter: filter to verify
  *	@flen: length of filter
  *
@@ -734,7 +734,7 @@ static bool chk_code_allowed(u16 code_to_probe)
  *
  * Returns 0 if the rule set is legal or -EINVAL if not.
  */
-int sk_chk_filter(const struct sock_filter *filter, unsigned int flen)
+int bpf_check_classic(const struct sock_filter *filter, unsigned int flen)
 {
 	bool anc_found;
 	int pc;
@@ -808,7 +808,7 @@ int sk_chk_filter(const struct sock_filter *filter, unsigned int flen)
 
 	return -EINVAL;
 }
-EXPORT_SYMBOL(sk_chk_filter);
+EXPORT_SYMBOL(bpf_check_classic);
 
 static int sk_store_orig_filter(struct sk_filter *fp,
 				const struct sock_fprog *fprog)
@@ -968,7 +968,7 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp)
 	fp->bpf_func = NULL;
 	fp->jited = 0;
 
-	err = sk_chk_filter(fp->insns, fp->len);
+	err = bpf_check_classic(fp->insns, fp->len);
 	if (err) {
 		__sk_filter_release(fp);
 		return ERR_PTR(err);
-- 
1.7.9.5
