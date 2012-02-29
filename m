From: Will Drewry <wad@chromium.org>
Subject: [PATCH v12 02/13] net/compat.c,linux/filter.h: share compat_sock_fprog
Date: Wed, 29 Feb 2012 17:53:29 -0600
Message-ID: <1330559620-23543-2-git-send-email-wad@chromium.org>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Cc: linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org,
	x86@kernel.org,
	arnd@arndb.de,
	davem@davemloft.net,
	hpa@zytor.com,
	mingo@redhat.com,
	oleg@redhat.com,
	peterz@infradead.org,
	rdunlap@xenotime.net,
	mcgrathr@chromium.org,
	tglx@linutronix.de,
	luto@mit.edu,
	eparis@redhat.com,
	serge.hallyn@canonical.com,
	djm@mindrot.org,
	scarybeasts@gmail.com,
	indan@nul.nu,
	pmoore@redhat.com,
	akpm@linux-foundation.org,
	corbet@lwn.net,
	eric.dumazet@gmail.com,
	markus@chromium.org,
	coreyb@linux.vnet.ibm.com,
	keescook@chromium.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-1007-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1330559620-23543-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

Any other users of bpf_*_filter that take a struct sock_fprog from
userspace will need to be able to also accept a compat_sock_fprog
if the arch supports compat calls.  This change let's the existing
compat_sock_fprog be shared.

Signed-off-by: Will Drewry <wad@chromium.org>

v11: introduction
---
 include/linux/filter.h |   11 +++++++++++
 net/compat.c           |    8 --------
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index bdd02f9..f052f5c 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -10,6 +10,7 @@
 
 #ifdef __KERNEL__
 #include <linux/atomic.h>
+#include <linux/compat.h>
 #endif
 
 /*
@@ -135,6 +136,16 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 
 #ifdef __KERNEL__
 
+#ifdef CONFIG_COMPAT
+/*
+ * A struct sock_filter is architecture independent.
+ */
+struct compat_sock_fprog {
+	u16		len;
+	compat_uptr_t	filter;		/* struct sock_filter * */
+};
+#endif
+
 struct sk_buff;
 struct sock;
 
diff --git a/net/compat.c b/net/compat.c
index 73bf0e0..5ba1bdc 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -328,14 +328,6 @@ void scm_detach_fds_compat(struct msghdr *kmsg, struct scm_cookie *scm)
 	__scm_destroy(scm);
 }
 
-/*
- * A struct sock_filter is architecture independent.
- */
-struct compat_sock_fprog {
-	u16		len;
-	compat_uptr_t	filter;		/* struct sock_filter * */
-};
-
 static int do_set_attach_filter(struct socket *sock, int level, int optname,
 				char __user *optval, unsigned int optlen)
 {
-- 
1.7.5.4
