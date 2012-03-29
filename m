From: Will Drewry <wad@chromium.org>
Subject: [PATCH v17 03/15] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Thu, 29 Mar 2012 15:01:48 -0500
Message-ID: <1333051320-30872-4-git-send-email-wad@chromium.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Cc: linux-security-module@vger.kernel.org,
	linux-arch@vger.kernel.org,
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
	jmorris@namei.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-1178-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1333051320-30872-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

Introduces a new BPF ancillary instruction that all LD calls will be
mapped through when skb_run_filter() is being used for seccomp BPF.  The
rewriting will be done using a secondary chk_filter function that is run
after skb_chk_filter.

The code change is guarded by CONFIG_SECCOMP_FILTER which is added,
along with the seccomp_bpf_load() function later in this series.

This is based on http://lkml.org/lkml/2012/3/2/141

v17: rebase
v16: -
v15: include seccomp.h explicitly for when seccomp_bpf_load exists.
v14: First cut using a single additional instruction
... v13: made bpf functions generic.

Suggested-by: Indan Zupancic <indan@nul.nu>
Signed-off-by: Will Drewry <wad@chromium.org>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/filter.h |    1 +
 net/core/filter.c      |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 8eeb205..aaa2e80 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -228,6 +228,7 @@ enum {
 	BPF_S_ANC_HATYPE,
 	BPF_S_ANC_RXHASH,
 	BPF_S_ANC_CPU,
+	BPF_S_ANC_SECCOMP_LD_W,
 };
 
 #endif /* __KERNEL__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index cf4989a..b6caa49 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -38,6 +38,7 @@
 #include <linux/filter.h>
 #include <linux/reciprocal_div.h>
 #include <linux/ratelimit.h>
+#include <linux/seccomp.h>
 
 /* No hurry in this branch */
 static void *__load_pointer(const struct sk_buff *skb, int k, unsigned int size)
@@ -349,6 +350,11 @@ load_b:
 				A = 0;
 			continue;
 		}
+#ifdef CONFIG_SECCOMP_FILTER
+		case BPF_S_ANC_SECCOMP_LD_W:
+			A = seccomp_bpf_load(fentry->k);
+			continue;
+#endif
 		default:
 			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
 				       fentry->code, fentry->jt,
-- 
1.7.5.4
