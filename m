From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v6 01/12] bpf: add XDP prog type for early driver filter
Date: Mon, 11 Jul 2016 09:51:42 -0700
Message-ID: <20160711165140.GB22729@gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-2-git-send-email-bblanco@plumgrid.com>
 <CALx6S343W6nyV51fXqu4Mx5pLL9OZGv=WyMj6gxEHAUn80DQxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35811 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754934AbcGKQvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 12:51:46 -0400
Received: by mail-pa0-f45.google.com with SMTP id dx3so36396640pab.2
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 09:51:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S343W6nyV51fXqu4Mx5pLL9OZGv=WyMj6gxEHAUn80DQxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 10, 2016 at 03:56:02PM -0500, Tom Herbert wrote:
> On Thu, Jul 7, 2016 at 9:15 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> > Add a new bpf prog type that is intended to run in early stages of the
> > packet rx path. Only minimal packet metadata will be available, hence a
> > new context type, struct xdp_md, is exposed to userspace. So far only
> > expose the packet start and end pointers, and only in read mode.
> >
> > An XDP program must return one of the well known enum values, all other
> > return codes are reserved for future use. Unfortunately, this
> > restriction is hard to enforce at verification time, so take the
> > approach of warning at runtime when such programs are encountered. The
> > driver can choose to implement unknown return codes however it wants,
> > but must invoke the warning helper with the action value.
> >
> > Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> > ---
> >  include/linux/filter.h   | 18 ++++++++++
> >  include/uapi/linux/bpf.h | 19 ++++++++++
> >  kernel/bpf/verifier.c    |  1 +
> >  net/core/filter.c        | 91 ++++++++++++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 129 insertions(+)
> >
> > diff --git a/include/linux/filter.h b/include/linux/filter.h
> > index 6fc31ef..522dbc9 100644
> > --- a/include/linux/filter.h
> > +++ b/include/linux/filter.h
> > @@ -368,6 +368,11 @@ struct bpf_skb_data_end {
> >         void *data_end;
> >  };
> >
> > +struct xdp_buff {
> > +       void *data;
> > +       void *data_end;
> > +};
> > +
> >  /* compute the linear packet data range [data, data_end) which
> >   * will be accessed by cls_bpf and act_bpf programs
> >   */
> > @@ -429,6 +434,18 @@ static inline u32 bpf_prog_run_clear_cb(const struct bpf_prog *prog,
> >         return BPF_PROG_RUN(prog, skb);
> >  }
> >
> > +static inline u32 bpf_prog_run_xdp(const struct bpf_prog *prog,
> > +                                  struct xdp_buff *xdp)
> > +{
> > +       u32 ret;
> > +
> > +       rcu_read_lock();
> > +       ret = BPF_PROG_RUN(prog, (void *)xdp);
> > +       rcu_read_unlock();
> > +
> > +       return ret;
> > +}
> > +
> >  static inline unsigned int bpf_prog_size(unsigned int proglen)
> >  {
> >         return max(sizeof(struct bpf_prog),
> > @@ -509,6 +526,7 @@ bool bpf_helper_changes_skb_data(void *func);
> >
> >  struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
> >                                        const struct bpf_insn *patch, u32 len);
> > +void bpf_warn_invalid_xdp_action(int act);
> >
> >  #ifdef CONFIG_BPF_JIT
> >  extern int bpf_jit_enable;
> > diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> > index c14ca1c..5b47ac3 100644
> > --- a/include/uapi/linux/bpf.h
> > +++ b/include/uapi/linux/bpf.h
> > @@ -94,6 +94,7 @@ enum bpf_prog_type {
> >         BPF_PROG_TYPE_SCHED_CLS,
> >         BPF_PROG_TYPE_SCHED_ACT,
> >         BPF_PROG_TYPE_TRACEPOINT,
> > +       BPF_PROG_TYPE_XDP,
> >  };
> >
> >  #define BPF_PSEUDO_MAP_FD      1
> > @@ -430,4 +431,22 @@ struct bpf_tunnel_key {
> >         __u32 tunnel_label;
> >  };
> >
> > +/* User return codes for XDP prog type.
> > + * A valid XDP program must return one of these defined values. All other
> > + * return codes are reserved for future use. Unknown return codes will result
> > + * in driver-dependent behavior.
> > + */
> > +enum xdp_action {
> > +       XDP_DROP,
> > +       XDP_PASS,
> > +};
> > +
> > +/* user accessible metadata for XDP packet hook
> > + * new fields must be added to the end of this structure
> > + */
> > +struct xdp_md {
> > +       __u32 data;
> > +       __u32 data_end;
> > +};
> > +
> >  #endif /* _UAPI__LINUX_BPF_H__ */
> > diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> > index e206c21..a8d67d0 100644
> > --- a/kernel/bpf/verifier.c
> > +++ b/kernel/bpf/verifier.c
> > @@ -713,6 +713,7 @@ static int check_ptr_alignment(struct verifier_env *env, struct reg_state *reg,
> >         switch (env->prog->type) {
> >         case BPF_PROG_TYPE_SCHED_CLS:
> >         case BPF_PROG_TYPE_SCHED_ACT:
> > +       case BPF_PROG_TYPE_XDP:
> >                 break;
> >         default:
> >                 verbose("verifier is misconfigured\n");
> > diff --git a/net/core/filter.c b/net/core/filter.c
> > index 10c4a2f..4ba446f 100644
> > --- a/net/core/filter.c
> > +++ b/net/core/filter.c
> > @@ -2369,6 +2369,12 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
> >         }
> >  }
> >
> > +static const struct bpf_func_proto *
> > +xdp_func_proto(enum bpf_func_id func_id)
> > +{
> > +       return sk_filter_func_proto(func_id);
> > +}
> > +
> >  static bool __is_valid_access(int off, int size, enum bpf_access_type type)
> >  {
> >         if (off < 0 || off >= sizeof(struct __sk_buff))
> 
> Can off be size_t to eliminate <0 check?
No, this is coming directly from struct bpf_insn, where it is a __s16.
This function signature shows up in lots of different places and would
be a pain to fixup.
> 
> > @@ -2436,6 +2442,56 @@ static bool tc_cls_act_is_valid_access(int off, int size,
> >         return __is_valid_access(off, size, type);
> >  }
> >
> > +static bool __is_valid_xdp_access(int off, int size,
> > +                                 enum bpf_access_type type)
> > +{
> > +       if (off < 0 || off >= sizeof(struct xdp_md))
> > +               return false;
> > +       if (off % size != 0)
> 
> off & 3 != 0
Feasible, but was intending to keep with the surrounding style. What do
the other bpf maintainers think?
> 
> > +               return false;
> > +       if (size != 4)
> > +               return false;
> 
> If size must always be 4 why is it even an argument?
Because this is the first time that the verifier has a chance to check
it, and size == 4 could potentially be a prog_type-specific requirement.
> 
> > +
> > +       return true;
> > +}
> > +
> > +static bool xdp_is_valid_access(int off, int size,
> > +                               enum bpf_access_type type,
> > +                               enum bpf_reg_type *reg_hint)
> > +{
> > +       if (type == BPF_WRITE)
> > +               return false;
> > +
> > +       switch (off) {
> > +       case offsetof(struct xdp_md, data):
> > +               *reg_hint = PTR_TO_PACKET;
> > +               break;
> > +       case offsetof(struct xdp_md, data_end):
> > +               *reg_hint = PTR_TO_PACKET_END;
> > +               break;
> case sizeof(int) for below?
> 
> > +       }
> > +
> > +       return __is_valid_xdp_access(off, size, type);
> > +}
> > +
> > +void bpf_warn_invalid_xdp_action(int act)
> > +{
> > +       WARN_ONCE(1, "\n"
> > +                    "*****************************************************\n"
> > +                    "**   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **\n"
> > +                    "**                                               **\n"
> > +                    "** XDP program returned unknown value %-10u **\n"
> > +                    "**                                               **\n"
> > +                    "** XDP programs must return a well-known return  **\n"
> > +                    "** value. Invalid return values will result in   **\n"
> > +                    "** undefined packet actions.                     **\n"
> > +                    "**                                               **\n"
> > +                    "**   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **\n"
> > +                    "*****************************************************\n",
> > +                 act);
> 
> Seems a little verbose to be. Just do a simple WARN_ONCE and probably
> more important to bump a counter.
The verbosity is intentional, modeled after the warning in
trace_printk_init_buffers(). Do you feel strongly on this?

A counter where? It would have to be outside of this function, there is
no common bpf infra for such things. Driver ethtool aware stats were
already mentioned.

> Also function should take the skb in
> question as an argument in case we want to do more inspection or
> logging in the future.
There is no skb to pass in, we're operating on dma'ed memory.
> 
> > +}
> > +EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
> > +
> >  static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
> >                                       int src_reg, int ctx_off,
> >                                       struct bpf_insn *insn_buf,
> > @@ -2587,6 +2643,29 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
> >         return insn - insn_buf;
> >  }
> >
> > +static u32 xdp_convert_ctx_access(enum bpf_access_type type, int dst_reg,
> > +                                 int src_reg, int ctx_off,
> > +                                 struct bpf_insn *insn_buf,
> > +                                 struct bpf_prog *prog)
> > +{
> > +       struct bpf_insn *insn = insn_buf;
> > +
> > +       switch (ctx_off) {
> > +       case offsetof(struct xdp_md, data):
> > +               *insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct xdp_buff, data)),
> > +                                     dst_reg, src_reg,
> > +                                     offsetof(struct xdp_buff, data));
> > +               break;
> > +       case offsetof(struct xdp_md, data_end):
> > +               *insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct xdp_buff, data_end)),
> > +                                     dst_reg, src_reg,
> > +                                     offsetof(struct xdp_buff, data_end));
> > +               break;
> > +       }
> > +
> > +       return insn - insn_buf;
> > +}
> > +
> >  static const struct bpf_verifier_ops sk_filter_ops = {
> >         .get_func_proto         = sk_filter_func_proto,
> >         .is_valid_access        = sk_filter_is_valid_access,
> > @@ -2599,6 +2678,12 @@ static const struct bpf_verifier_ops tc_cls_act_ops = {
> >         .convert_ctx_access     = bpf_net_convert_ctx_access,
> >  };
> >
> > +static const struct bpf_verifier_ops xdp_ops = {
> > +       .get_func_proto         = xdp_func_proto,
> > +       .is_valid_access        = xdp_is_valid_access,
> > +       .convert_ctx_access     = xdp_convert_ctx_access,
> > +};
> > +
> >  static struct bpf_prog_type_list sk_filter_type __read_mostly = {
> >         .ops    = &sk_filter_ops,
> >         .type   = BPF_PROG_TYPE_SOCKET_FILTER,
> > @@ -2614,11 +2699,17 @@ static struct bpf_prog_type_list sched_act_type __read_mostly = {
> >         .type   = BPF_PROG_TYPE_SCHED_ACT,
> >  };
> >
> > +static struct bpf_prog_type_list xdp_type __read_mostly = {
> > +       .ops    = &xdp_ops,
> > +       .type   = BPF_PROG_TYPE_XDP,
> > +};
> > +
> >  static int __init register_sk_filter_ops(void)
> >  {
> >         bpf_register_prog_type(&sk_filter_type);
> >         bpf_register_prog_type(&sched_cls_type);
> >         bpf_register_prog_type(&sched_act_type);
> > +       bpf_register_prog_type(&xdp_type);
> >
> >         return 0;
> >  }
> > --
> > 2.8.2
> >
