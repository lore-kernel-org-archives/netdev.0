From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3 2/3] ARM: net: bpf_jit: make code generation less
 dependent on struct sk_filter.
Date: Fri, 26 Apr 2013 13:09:48 -0700
Message-ID: <20130426130948.cbfd2f6256afc0e3ee7abeed@linux-foundation.org>
References: <1366824429-26652-1-git-send-email-nschichan@freebox.fr>
	<1366824429-26652-3-git-send-email-nschichan@freebox.fr>
	<3592414.M8kQZLCXlW@wuerfel>
	<20130426122601.10ec05fcb4860df1b0a5b409@linux-foundation.org>
	<517AD9E2.2090704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Will Drewry <wad@chromium.org>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <517AD9E2.2090704@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 Apr 2013 21:47:46 +0200 Daniel Borkmann <dborkman@redhat.com> wrote:

> On 04/26/2013 09:26 PM, Andrew Morton wrote:
> > On Fri, 26 Apr 2013 16:04:44 +0200 Arnd Bergmann <arnd@arndb.de> wrote:
> >> On Wednesday 24 April 2013 19:27:08 Nicolas Schichan wrote:
> >>> @@ -858,7 +858,7 @@ b_epilogue:
> >>>   }
> >>>
> >>>
> >>> -void bpf_jit_compile(struct sk_filter *fp)
> >>> +static void __bpf_jit_compile(struct jit_ctx *out_ctx)
> >>>   {
> >>>          struct jit_ctx ctx;
> >>>          unsigned tmp_idx;
> >>> @@ -867,11 +867,10 @@ void bpf_jit_compile(struct sk_filter *fp)
> >>>          if (!bpf_jit_enable)
> >>>                  return;
> >>>
> >>> -       memset(&ctx, 0, sizeof(ctx));
> >>> -       ctx.skf         = fp;
> >>> +       ctx = *out_ctx;
> >>>          ctx.ret0_fp_idx = -1;
> >>>
> >>> -       ctx.offsets = kzalloc(4 * (ctx.skf->len + 1), GFP_KERNEL);
> >>> +       ctx.offsets = kzalloc(4 * (ctx.prog_len + 1), GFP_KERNEL);
> >>>          if (ctx.offsets == NULL)
> >>>                  return;
> >>>
> >>> @@ -921,13 +920,26 @@ void bpf_jit_compile(struct sk_filter *fp)
> >>>                  print_hex_dump(KERN_INFO, "BPF JIT code: ",
> >>>                                 DUMP_PREFIX_ADDRESS, 16, 4, ctx.target,
> >>>                                 alloc_size, false);
> >>> -
> >>> -       fp->bpf_func = (void *)ctx.target;
> >>>   out:
> >>>          kfree(ctx.offsets);
> >>> +
> >>> +       *out_ctx = ctx;
> >>>          return;
> >>
> >> This part of the patch, in combination with 79617801e "filter: bpf_jit_comp:
> >> refactor and unify BPF JIT image dump output" is now causing build errors
> >> in linux-next:
> >>
> >> arch/arm/net/bpf_jit_32.c: In function '__bpf_jit_compile':
> >> arch/arm/net/bpf_jit_32.c:930:16: error: 'fp' undeclared (first use in this function)
> >>     bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
> >
> > Thanks, I did this.  There may be a smarter way...
> 
> I think also seccomp_jit_compile() would need this change then, otherwise the build
> with CONFIG_SECCOMP_FILTER_JIT might break.

urgh, that tears it.

> I can fix this up for you if not already applied. I presume it's against
> linux-next tree?

Yup, please send something.
