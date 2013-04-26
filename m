From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH V3 2/3] ARM: net: bpf_jit: make code generation less dependent
 on struct sk_filter.
Date: Sat, 27 Apr 2013 00:01:10 +0200
Message-ID: <517AF926.3020302@redhat.com>
References: <1366824429-26652-1-git-send-email-nschichan@freebox.fr> <1366824429-26652-3-git-send-email-nschichan@freebox.fr> <3592414.M8kQZLCXlW@wuerfel> <20130426122601.10ec05fcb4860df1b0a5b409@linux-foundation.org> <517AD9E2.2090704@redhat.com> <20130426130948.cbfd2f6256afc0e3ee7abeed@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080108090705060902020509"
Cc: Arnd Bergmann <arnd@arndb.de>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Will Drewry <wad@chromium.org>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>,
	netdev@vger.kernel.org, Xi Wang <xi.wang@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130426130948.cbfd2f6256afc0e3ee7abeed@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080108090705060902020509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 04/26/2013 10:09 PM, Andrew Morton wrote:
> On Fri, 26 Apr 2013 21:47:46 +0200 Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 04/26/2013 09:26 PM, Andrew Morton wrote:
>>> On Fri, 26 Apr 2013 16:04:44 +0200 Arnd Bergmann <arnd@arndb.de> wrote:
>>>> On Wednesday 24 April 2013 19:27:08 Nicolas Schichan wrote:
>>>>> @@ -858,7 +858,7 @@ b_epilogue:
>>>>>    }
>>>>>
>>>>>
>>>>> -void bpf_jit_compile(struct sk_filter *fp)
>>>>> +static void __bpf_jit_compile(struct jit_ctx *out_ctx)
>>>>>    {
>>>>>           struct jit_ctx ctx;
>>>>>           unsigned tmp_idx;
>>>>> @@ -867,11 +867,10 @@ void bpf_jit_compile(struct sk_filter *fp)
>>>>>           if (!bpf_jit_enable)
>>>>>                   return;
>>>>>
>>>>> -       memset(&ctx, 0, sizeof(ctx));
>>>>> -       ctx.skf         = fp;
>>>>> +       ctx = *out_ctx;
>>>>>           ctx.ret0_fp_idx = -1;
>>>>>
>>>>> -       ctx.offsets = kzalloc(4 * (ctx.skf->len + 1), GFP_KERNEL);
>>>>> +       ctx.offsets = kzalloc(4 * (ctx.prog_len + 1), GFP_KERNEL);
>>>>>           if (ctx.offsets == NULL)
>>>>>                   return;
>>>>>
>>>>> @@ -921,13 +920,26 @@ void bpf_jit_compile(struct sk_filter *fp)
>>>>>                   print_hex_dump(KERN_INFO, "BPF JIT code: ",
>>>>>                                  DUMP_PREFIX_ADDRESS, 16, 4, ctx.target,
>>>>>                                  alloc_size, false);
>>>>> -
>>>>> -       fp->bpf_func = (void *)ctx.target;
>>>>>    out:
>>>>>           kfree(ctx.offsets);
>>>>> +
>>>>> +       *out_ctx = ctx;
>>>>>           return;
>>>>
>>>> This part of the patch, in combination with 79617801e "filter: bpf_jit_comp:
>>>> refactor and unify BPF JIT image dump output" is now causing build errors
>>>> in linux-next:
>>>>
>>>> arch/arm/net/bpf_jit_32.c: In function '__bpf_jit_compile':
>>>> arch/arm/net/bpf_jit_32.c:930:16: error: 'fp' undeclared (first use in this function)
>>>>      bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
>>>
>>> Thanks, I did this.  There may be a smarter way...
>>
>> I think also seccomp_jit_compile() would need this change then, otherwise the build
>> with CONFIG_SECCOMP_FILTER_JIT might break.
>
> urgh, that tears it.
>
>> I can fix this up for you if not already applied. I presume it's against
>> linux-next tree?
>
> Yup, please send something.

Patch is attached. However, I currently don't have an ARM toolchain at hand, so
uncompiled, untested.

@Nicolas, Xi (cc, ref: http://thread.gmane.org/gmane.linux.kernel/1481464):

If there is someday support for other archs as well, it would be nice if we
do not have each time duplicated seccomp_jit_compile() etc functions in each
JIT implementation, i.e. because they do basically the same. So follow-up
{fix,clean}up is appreciated.

Also, I find it a bit weird that seccomp_filter_get_len() and some other
_one-line_ functions from kernel/seccomp.c are not placed into the
corresponding header file as inlines.

--------------080108090705060902020509
Content-Type: text/x-patch;
 name="0001-ARM-bpf_jit-seccomp-filtering-fixup-merge-conflict.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-ARM-bpf_jit-seccomp-filtering-fixup-merge-conflict.patc";
 filename*1="h"

>From 655f4aabee7ccb909345ccfce92a405e3d173de5 Mon Sep 17 00:00:00 2001
Message-Id: <655f4aabee7ccb909345ccfce92a405e3d173de5.1367012811.git.dborkman@redhat.com>
In-Reply-To: <cover.1367012811.git.dborkman@redhat.com>
References: <cover.1367012811.git.dborkman@redhat.com>
From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 26 Apr 2013 23:41:06 +0200
Subject: [PATCH linux-next -mm] ARM: bpf_jit: seccomp filtering: fixup merge conflict

Commit e4c67f4c0479d8e3cb0 (ARM: net: bpf_jit: make code generation
less dependent on struct sk_filter.) caused a merge conflict with
commit 79617801ea0c0e6 (filter: bpf_jit_comp: refactor and unify
BPF JIT image dump output) resulting in a build failure:

arch/arm/net/bpf_jit_32.c: In function '__bpf_jit_compile':
arch/arm/net/bpf_jit_32.c:930:16: error: 'fp' undeclared (first use in this function)
    bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);

Fix this up by using ctx.prog_len that is being set before we enter
__bpf_jit_compile().

Reported-by: Arnd Bergmann <arnd@arndb.de>
Cc: Nicolas Schichan <nschichan@freebox.fr>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 arch/arm/net/bpf_jit_32.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index c5ef845..eb4daba 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -927,7 +927,7 @@ static void __bpf_jit_compile(struct jit_ctx *out_ctx)
 
 	if (bpf_jit_enable > 1)
 		/* there are 2 passes here */
-		bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
+		bpf_jit_dump(ctx.prog_len, alloc_size, 2, ctx.target);
 out:
 	kfree(ctx.offsets);
 
-- 
1.7.11.7


--------------080108090705060902020509--
