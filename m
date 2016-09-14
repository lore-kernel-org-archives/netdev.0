From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: [RFC v3 09/22] seccomp: Move struct seccomp_filter in seccomp.h
Date: Wed, 14 Sep 2016 09:24:02 +0200
Message-ID: <20160914072415.26021-10-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160914072415.26021-1-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Set struct seccomp_filter public because of the next use of
the new field thread_prev added for Landlock LSM.

Signed-off-by: Mickaël Salaün <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 include/linux/seccomp.h | 27 ++++++++++++++++++++++++++-
 kernel/seccomp.c        | 26 --------------------------
 2 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index ecc296c137cd..a0459a7315ce 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -10,7 +10,32 @@
 #include <linux/thread_info.h>
 #include <asm/seccomp.h>
 
-struct seccomp_filter;
+/**
+ * struct seccomp_filter - container for seccomp BPF programs
+ *
+ * @usage: reference count to manage the object lifetime.
+ *         get/put helpers should be used when accessing an instance
+ *         outside of a lifetime-guarded section.  In general, this
+ *         is only needed for handling filters shared across tasks.
+ * @prev: points to a previously installed, or inherited, filter
+ * @prog: the BPF program to evaluate
+ *
+ * seccomp_filter objects are organized in a tree linked via the @prev
+ * pointer.  For any task, it appears to be a singly-linked list starting
+ * with current->seccomp.filter, the most recently attached or inherited filter.
+ * However, multiple filters may share a @prev node, by way of fork(), which
+ * results in a unidirectional tree existing in memory.  This is similar to
+ * how namespaces work.
+ *
+ * seccomp_filter objects should never be modified after being attached
+ * to a task_struct (other than @usage).
+ */
+struct seccomp_filter {
+	atomic_t usage;
+	struct seccomp_filter *prev;
+	struct bpf_prog *prog;
+};
+
 /**
  * struct seccomp - the state of a seccomp'ed process
  *
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index dccfc05cb3ec..1867bbfa7c6c 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -33,32 +33,6 @@
 #include <linux/tracehook.h>
 #include <linux/uaccess.h>
 
-/**
- * struct seccomp_filter - container for seccomp BPF programs
- *
- * @usage: reference count to manage the object lifetime.
- *         get/put helpers should be used when accessing an instance
- *         outside of a lifetime-guarded section.  In general, this
- *         is only needed for handling filters shared across tasks.
- * @prev: points to a previously installed, or inherited, filter
- * @prog: the BPF program to evaluate
- *
- * seccomp_filter objects are organized in a tree linked via the @prev
- * pointer.  For any task, it appears to be a singly-linked list starting
- * with current->seccomp.filter, the most recently attached or inherited filter.
- * However, multiple filters may share a @prev node, by way of fork(), which
- * results in a unidirectional tree existing in memory.  This is similar to
- * how namespaces work.
- *
- * seccomp_filter objects should never be modified after being attached
- * to a task_struct (other than @usage).
- */
-struct seccomp_filter {
-	atomic_t usage;
-	struct seccomp_filter *prev;
-	struct bpf_prog *prog;
-};
-
 /* Limit any path through the tree to 256KB worth of instructions. */
 #define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
 
-- 
2.9.3
