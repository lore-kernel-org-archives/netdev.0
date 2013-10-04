From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next] fix unsafe set_memory_rw from softirq
Date: Fri, 4 Oct 2013 10:49:23 -0700
Message-ID: <CAMEtUuy0mpdUHJjztK31mHjNVahnoZ8CHo2sLLyJmt=p5+gq0w@mail.gmail.com>
References: <1380853446-30537-1-git-send-email-ast@plumgrid.com>
 <20131004075133.GA12313@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, Eric Dumazet <edumazet@google.com>,
 Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>,
 sparclinux@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
 linux-s390@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
 x86@kernel.org, James Morris <jmorris@namei.org>,
 Ingo Molnar <mingo@redhat.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Xi Wang <xi.wang@gmail.com>,
 Matt Evans <matt@ozlabs.org>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, Stelian Nirlu <steliannirlu@gmail.com>,
 Nicolas Schichan <nschichan@freebox.fr>,
 Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 Mircea Gherzan
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20131004075133.GA12313@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 4, 2013 at 12:51 AM, Ingo Molnar <mingo@kernel.org> wrote:
>> +static void bpf_jit_free_deferred(struct work_struct *work)
>> +{
>> +     struct sk_filter *fp = container_of((void *)work, struct sk_filter,
>> +                                         insns);
>> +     unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
>> +     struct bpf_binary_header *header = (void *)addr;
>> +
>> +     set_memory_rw(addr, header->pages);
>> +     module_free(NULL, header);
>> +     kfree(fp);
>> +}
>
> Using the data type suggestions I make further below, this could be
> written in a simpler form, as:
>
>         struct sk_filter *fp = container_of(work, struct sk_filter, work);

yes. I've made it already as part of V4

> Also, a question, why do you mask with PAGE_MASK here:
>
>         unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
>
> ?
>
> AFAICS bpf_func is the module_alloc() result - and module code is page
> aligned. So ->bpf_func is always page aligned here. (The sk_run_filter
> special case cannot happen here.)

randomization of bpf_func start is a prevention of jit spraying
attacks as Eric pointed out.

>>  void bpf_jit_free(struct sk_filter *fp)
>>  {
>>       if (fp->bpf_func != sk_run_filter) {
>> -             unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
>> -             struct bpf_binary_header *header = (void *)addr;
>> -
>> -             set_memory_rw(addr, header->pages);
>> -             module_free(NULL, header);
>> +             struct work_struct *work = (struct work_struct *)fp->insns;
>> +             INIT_WORK(work, bpf_jit_free_deferred);
>
> Missing newline between local variables and statements.

yes. noted and fixed in V4.

>>       unsigned int            (*bpf_func)(const struct sk_buff *skb,
>>                                           const struct sock_filter *filter);
>> -     struct rcu_head         rcu;
>> +     /* insns start right after bpf_func, so that sk_run_filter() fetches
>> +      * first insn from the same cache line that was used to call into
>> +      * sk_run_filter()
>> +      */
>>       struct sock_filter      insns[0];
>
> Please use the customary (multi-line) comment style:
>
>   /*
>    * Comment .....
>    * ...... goes here.
>    */
>
> specified in Documentation/CodingStyle.

I believe filter.h belongs to networking comment style, that's why
checkpatch didn't complain.
But I removed the comment in V4

>>  static inline unsigned int sk_filter_len(const struct sk_filter *fp)
>>  {
>> -     return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
>> +     return max(fp->len * sizeof(struct sock_filter),
>> +                sizeof(struct work_struct)) + sizeof(*fp);
>
> So, "sizeof(struct work_struct)) + sizeof(*fp)" is a pattern that repeats
> a couple of times. Might make sense to stick that into a helper of its own
> - but in general this open coded overlay allocation method looks a bit
> fragile and not very obvious in isolation.
>
> So it could be done a bit cleaner, using an anonymous union:
>
>         /*
>          * These two overlay, the work struct is used during workqueue
>          * driven teardown, when the instructions are not used anymore:
>          */
>         union {
>                 struct sock_filter      insns[0];
>                 struct work_struct      work;
>         };
>
> And then all the sizeof() calculations become obvious and sk_filter_len()
> could be eliminated - I've marked the conversions in the code further
> below.

Eric made exactly the same comment. Agreed and fixed in V4

>>  #else
>> +#include <linux/slab.h>
>
> Inlines in the middle of header files are generally frowned upon.
>
> The standard pattern is to put them at the top, that way it's easier to
> see the dependencies and there's also less .config dependent inclusion,
> which makes header hell cleanup work easier.

Agree. I only followed the style that is already in filter.h 20 lines above.
#ifdef CONFIG_BPF_JIT
#include <stdarg.h>
#include <linux/linkage.h>
#include <linux/printk.h>

as part of the cleanup can move all of them to the top. In the separate commit?

>>       struct sk_filter *fp;
>>       unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
>> +     unsigned int sk_fsize = max_t(u32, fsize, sizeof(struct work_struct))
>> +             + sizeof(*fp);
>
> Using the structure definition I suggested, this could be replaced with
> the more obvious:
>
>         unsigned int sk_fsize = max(fsize, sizeof(*fp));

with helper function it's even cleaner. Fixed in V4

> A couple of questions/suggestions:
>
> 1)
>
> I took a brief look at arch/x86/net/bpf_jit_comp.c while reviewing this
> patch.
>
> You need to split up bpf_jit_compile(), it's an obscenely large, ~600
> lines long function. We don't do that in modern, maintainable kernel code.

I had the same thought, therefore in my proposed generalization of bpf:
http://patchwork.ozlabs.org/patch/279280/
It is split into two. do_jit() is still a bit large at 400 lines. Can
split it further.

> 3)
>
> It's nice code altogether! Are there any plans to generalize its
> interfaces, to allow arbitrary bytecode to be used by other kernel
> subsystems as well? In particular tracing filters could make use of it,
> but it would also allow safe probe points.

That was exactly the reasons to generalize bpf as I proposed.
"extended BPF is a set of pseudo instructions that stitch kernel provided
data in the form of bpf_context with kernel provided set of functions in a safe
and deterministic way with minimal performance overhead vs native code"
Not sure what 'tracing filters' you have in mind, but I'm happy to try
them with extended bpf model.
imo existing bpf with two registers is too limiting for performance
and argument passing.
That's why going to 10 made it a lot more flexible and generically usable.
Sorry to hijack the thread.

Thanks
Alexei
