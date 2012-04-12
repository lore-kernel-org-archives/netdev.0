From: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH v18 04/15] net/compat.c,linux/filter.h: share compat_sock_fprog
Date: Thu, 12 Apr 2012 16:47:53 -0500
Message-ID: <1334267284-19166-4-git-send-email-wad@chromium.org>
References: <1334267284-19166-1-git-send-email-wad@chromium.org>
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org,
	mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, mcgrathr-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org,
	luto-3s7WtUTddSA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
	djm-ilwOsaqNJrtAfugRpC6u6w@public.gmane.org, scarybeasts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, indan-1J6HnF7K7zE@public.gmane.org,
	pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, corbet-T1hC0tSOHrs@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, markus-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	coreyb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334267284-19166-1-git-send-email-wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Any other users of bpf_*_filter that take a struct sock_fprog from
userspace will need to be able to also accept a compat_sock_fprog
if the arch supports compat calls.  This change allows the existing
compat_sock_fprog be shared.

Signed-off-by: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Acked-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

v18: tasered by the apostrophe police
v14: rebase/nochanges
v13: rebase on to 88ebdda6159ffc15699f204c33feb3e431bf9bdc
v12: rebase on to linux-next
v11: introduction
---
 include/linux/filter.h |   11 +++++++++++
 net/compat.c           |    8 --------
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index aaa2e80..f2e5315 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -10,6 +10,7 @@
 
 #ifdef __KERNEL__
 #include <linux/atomic.h>
+#include <linux/compat.h>
 #endif
 
 /*
@@ -132,6 +133,16 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 
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
index e055708..242c828 100644
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
