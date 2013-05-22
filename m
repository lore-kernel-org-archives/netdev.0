From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: linux-next: manual merge of the akpm tree with the net-next tree
Date: Wed, 22 May 2013 11:20:51 +0200
Message-ID: <519C8DF3.7000605@redhat.com>
References: <20130521142537.00a9ccb7ca4aa81f553b61cf@canb.auug.org.au> <519B25CD.5060801@redhat.com> <20130522095436.66e63c613c41da01cd103208@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040407090900060402060109"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Schichan <nschichan@freebox.fr>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130522095436.66e63c613c41da01cd103208@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040407090900060402060109
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 05/22/2013 01:54 AM, Stephen Rothwell wrote:
> Hi Daniel,
>
> On Tue, 21 May 2013 09:44:13 +0200 Daniel Borkmann <dborkman@redhat.com> wrote:
>>
>> Also seccomp_jit_free() needs a change otherwise the kernel won't build
>> with CONFIG_SECCOMP_FILTER_JIT enabled since the work_struct is initialized
>> with the bpf_jit_free_worker() callback, which is no longer existent.
>>
>> Do you want me to send you a patch?
>
> Yes, please.

In case this is still needed, patch attached. That should fix it.

--------------040407090900060402060109
Content-Type: text/x-patch;
 name="0001-arm-bpf_jit-fixup-build-error-in-seccomp_jit_free.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-arm-bpf_jit-fixup-build-error-in-seccomp_jit_free.patch"

>From 72d68685f31b84f64826740cf3d33ba6d8d28ffc Mon Sep 17 00:00:00 2001
Message-Id: <72d68685f31b84f64826740cf3d33ba6d8d28ffc.1369214198.git.dborkman@redhat.com>
In-Reply-To: <cover.1369214198.git.dborkman@redhat.com>
References: <cover.1369214198.git.dborkman@redhat.com>
From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 22 May 2013 11:12:31 +0200
Subject: [PATCH] arm: bpf_jit: fixup build error in seccomp_jit_free

bpf_jit_free_worker() no longer exist, so get seccomp_jit_free()
in line with bpf_jit_free().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 arch/arm/net/bpf_jit_32.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 62aca35..3fe001d 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -969,18 +969,9 @@ void seccomp_jit_compile(struct seccomp_filter *fp)
 
 void seccomp_jit_free(struct seccomp_filter *fp)
 {
-	struct work_struct *work;
 	void *bpf_func = seccomp_filter_get_bpf_func(fp);
 
-	if (bpf_func != sk_run_filter) {
-		/*
-		 * seccomp_jit_free() can be called from softirq; module_free()
-		 * requires process context.
-		 */
-		work = (struct work_struct *)bpf_func;
-
-		INIT_WORK(work, bpf_jit_free_worker);
-		schedule_work(work);
-	}
+	if (bpf_func != sk_run_filter)
+		module_free(NULL, bpf_func);
 }
 #endif
-- 
1.7.11.7


--------------040407090900060402060109--
