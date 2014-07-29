From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sk_filter' to
 'struct bpf_prog'
Date: Mon, 28 Jul 2014 18:12:05 -0700
Message-ID: <CAMEtUuyuxfs7Liy_HCDijUX9Q8yziY2kt0XCpJtXUyMR1P941Q@mail.gmail.com>
References: <1406275499-7822-1-git-send-email-ast@plumgrid.com>
	<53D23EAF.4000001@redhat.com>
	<20140725115414.GA4770@salvia>
	<53D254D9.9030905@redhat.com>
	<CAMEtUux+dw_GoafXE3ukvmOK2JmZWWf-y0VMobe60TSTfZeNmw@mail.gmail.com>
	<20140725221512.GA3729@salvia>
	<CAMEtUux8F4xZ77_HQADfoeV-9sibaEWm=XJcAaY+cQyDWb2caA@mail.gmail.com>
	<20140728214552.GA4049@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140728214552.GA4049@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 28, 2014 at 2:45 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> > struct sk_filter_cb {
>> >         int type;
>> >         struct module *me;
>> >         void (*charge)(struct sock *sk, struct sk_filter *fp);
>> >         void (*uncharge)(struct sock *sk, struct sk_filter *fp);
>> >         unsigned int (*run_filter)(struct sk_filter *fp, struct sk_buff *skb);
>> > };
>>
>> Pablo,
>>
>> I don't think you understand the scope of BPF.
>> 'struct module *'? to attach nft to sockets? ouch.
>
> The idea is that there will be one sk_filter_cb per socket filtering
> approach. The structure module is just there in case one of the
> approach is loadable as kernel module, it's the typical code pattern
> in the kernel. You can git grep for similar code.

socket filtering is available to unprivileged users.
So you're proposing to let them increment refcnt of modules?!
That's not secure.
You're also ignoring kernel address leak issue of xt_bpf
pointed out earlier. Userspace should not be able to see kernel
address inside 'struct xt_bpf_info'.
xtables need some sort of scrub_matchinfo callback to clean it
before passing back to user.

> This is extracted from one of your recent patches:
>
>  void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
>  {
> -       atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
> +       if (!fp->ebpf)
> +               atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
>         sk_filter_release(fp);
>  }
>
>  void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
>  {
>         atomic_inc(&fp->refcnt);
> -       atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
> +       if (!fp->ebpf)
> +               atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
>  }
>
> Basically, that looks to me like two different socket filtering
> approach. You only have to define the struct sock_filter_cb, set the
> fields to point to the functions and register the approach in the
> socket filtering engine. That will allow a simple way to look up the
> filtering approach when loading the filter from userspace.

You're taking things out of context. Quoted code is from patch #9.
This rename is patch #0
Once it's all properly named it will look like:
void sk_filter_charge(struct sock *sk, struct bpf_prog *fp)
{
  atomic_inc(&fp->refcnt);
  if (!fp->ebpf)
    atomic_add(bpf_filter_size(fp->len), &sk->sk_omem_alloc);
}

so it's one sk_filter_charge() function to deal with two variants of
bpf_prog (native ebpf and converted to ebpf).
In all cases the programs inside are in ebpf isa.
fp->ebpf flag means that program arrived from userspace as
native ebpf  (and not was a result of conversion from classic).
So splitting this function in two would not make sense at all.

> By quick git grepping you already can find clients of this that do not
> need rcu / refcount: cls_bpf.c, net_cls.c, xt_bpf.c and

you can also see a lot of clients that don't use jit and 'work' field
is unused. That doesn't mean that these flags should be in
different structure.

> ptp_classifier.  Moreover, I only see the refcnt bumped from
> sk_filter_charge(), I didn't find it neither in git nor in your
> patches.

in the patch #9 that you already quoted there is this part:

+/* called from sk_attach_filter_ebpf() or from tracing filter attach
+ * pairs with
+ * sk_detach_filter()->sk_filter_uncharge()->sk_filter_release()
+ * or with
+ * sk_unattached_filter_destroy()->sk_filter_release()
+ */
+struct sk_filter *bpf_prog_get(u32 ufd)
+{
+       struct fd f = fdget(ufd);
+       struct sk_filter *prog;
+
+       prog = get_prog(f);
+
+       if (IS_ERR(prog))
+               return prog;
+
+       atomic_inc(&prog->refcnt);
+       fdput(f);
+       return prog;
+}

see how 'native ebpf' reuses all existing structs?
Only renaming of 'struct sk_filter' and 'sk_filter_release()' is missing.
sk_filter_uncharge() name should stay as-is, since it is working
on 'struct sock*', whereas sk_filter_release() is working on bpf prog,
so should be renamed as well into 'bpf_prog_release()'

> I don't think rcu_head and refcnt are really part of the
> filter *in any case*, they just provide the way to link/unlink objects
> in a safe way in some situations.

what is a program then? a sequence of instructions only? if so,
what do you call a structure that carries refcnt, rcu, work and flags?
Using your logic task_struct should only have fields that describe
the task and all auxiliary fields should be moved to different struct?

> By renaming this, you're not fixing up things the semantics. It seems
> to me you just want to find a quick path to solve inconsistencies in
> your code.

Please point to inconsistencies.
It sounds to me that you're arguing only because you think that this
renaming will make it harder for you to add nft to socket filtering.
That is not the case. sk_filter_cb can be added later.

> Agreed, this looks just like messing around with naming to me.

guys, I don't see an alternative to renaming. All fields of 'struct sk_filter'
are used and needed to be part of bpf program.
Just look at 'bpf: expand BPF syscall with program load/unload' patch:
https://git.kernel.org/cgit/linux/kernel/git/ast/bpf.git/commit/?id=7a5b36ee1cb57e5fcb3e2414645dc9f5fdc3c404

There I blend 'native epbf' into 'struct sk_filter' like:
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -30,12 +30,17 @@ struct sock_fprog_kern {
 struct sk_buff;
 struct sock;
 struct seccomp_data;
+struct bpf_prog_info;

 struct sk_filter {
        atomic_t                refcnt;
        u32                     jited:1,        /* Is our filter JIT'ed? */
-                               len:31;         /* Number of filter blocks */
-       struct sock_fprog_kern  *orig_prog;     /* Original BPF program */
+                               ebpf:1,         /* Is it eBPF program ? */
+                               len:30;         /* Number of filter blocks */
+       union {
+               struct sock_fprog_kern  *orig_prog;     /* Original
BPF program */
+               struct bpf_prog_info    *info;
+       };
        struct rcu_head         rcu;
        unsigned int            (*bpf_func)(const struct sk_buff *skb,
                                            const struct bpf_insn *filter);

where 'struct bpf_prog_info' carries additional info about bpf maps, etc:
that is ideal code reuse. All existing and new ebpf infra and structures
are common and shared. Only 'struct sk_filter' name doesn't make sense.

The alternative is to copy paste all of 'struct sk_filter' fields into new
structure ? You seriously think it's a better option?

I cannot see how the arguments about some future sk_filter_cb apply here.
When we get to the point of having multiple socket filtering engines,
we can add new 'struct sk_filter' and callbacks if necessary.
Today 'struct sk_filter' is all about bpf. Keep calling it something else
but 'bpf_prog' just denying the reality.
