From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH 1/6] ebpf: add a seccomp program type
Date: Wed, 9 Sep 2015 09:50:35 -0600
Message-ID: <20150909155035.GA26679@smitten>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-2-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5j+9YvL6XzX=x8krZbdJXFpe-3FuMu=hAZX9Ew=hYyuK7Q@mail.gmail.com>
 <20150904210615.GR26679@smitten>
 <CAGXu5jKGBuD15KBfXKoYbGB40cNsbh=Dz8GM=bmUL-oECRhzxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5jKGBuD15KBfXKoYbGB40cNsbh=Dz8GM=bmUL-oECRhzxA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2015 at 02:08:37PM -0700, Kees Cook wrote:
> On Fri, Sep 4, 2015 at 2:06 PM, Tycho Andersen
> <tycho.andersen@canonical.com> wrote:
> > On Fri, Sep 04, 2015 at 01:34:12PM -0700, Kees Cook wrote:
> >> On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
> >> <tycho.andersen@canonical.com> wrote:
> >> > +static const struct bpf_func_proto *
> >> > +seccomp_func_proto(enum bpf_func_id func_id)
> >> > +{
> >> > +       /* Right now seccomp eBPF loading doesn't support maps; seccomp filters
> >> > +        * are considered to be read-only after they're installed, so map fds
> >> > +        * probably need to be invalidated when a seccomp filter with maps is
> >> > +        * installed.
> >> > +        *
> >> > +        * The rest of these might be reasonable to call from seccomp, so we
> >> > +        * export them.
> >> > +        */
> >> > +       switch (func_id) {
> >> > +       case BPF_FUNC_ktime_get_ns:
> >> > +               return &bpf_ktime_get_ns_proto;
> >> > +       case BPF_FUNC_trace_printk:
> >> > +               return bpf_get_trace_printk_proto();
> >> > +       case BPF_FUNC_get_prandom_u32:
> >> > +               return &bpf_get_prandom_u32_proto;
> >> > +       case BPF_FUNC_get_smp_processor_id:
> >> > +               return &bpf_get_smp_processor_id_proto;
> >> > +       case BPF_FUNC_tail_call:
> >> > +               return &bpf_tail_call_proto;
> >> > +       case BPF_FUNC_get_current_pid_tgid:
> >> > +               return &bpf_get_current_pid_tgid_proto;
> >> > +       case BPF_FUNC_get_current_uid_gid:
> >> > +               return &bpf_get_current_uid_gid_proto;
> >> > +       case BPF_FUNC_get_current_comm:
> >> > +               return &bpf_get_current_comm_proto;
> >> > +       default:
> >> > +               return NULL;
> >> > +       }
> >> > +}
> >>
> >> While this list is probably fine, I don't want to mix the addition of
> >> eBPF functions to the seccomp ABI with the CRIU changes. No function
> >> calls are currently possible and it should stay that way.
> >
> > Ok, I can remove them.
> >
> >> I was expecting to see a validator, similar to the existing BPF
> >> validator that is called when creating seccomp filters currently. Can
> >> we add a similar validator for new BPF_PROG_TYPE_SECCOMP?
> >
> > That's effectively what this patch does; when the eBPF is loaded via
> > bpf(), you tell bpf() you want a BPF_PROG_TYPE_SECCOMP, and it invokes
> > this validation/translation code, i.e. it uses
> > seccomp_is_valid_access() to check and make sure access are aligned
> > and inside struct seccomp_data.
> 
> What about limiting the possible instructions?

I totally overlooked this. A quick glance through the eBPF verifier
makes me think that we can just add another function to struct
bpf_verifier_ops called valid_instruction, which shouldn't be too
hard. Perhaps a more interesting question is what to allow:

BPF_LD(X) and BPF_ST(X): it looks like all types of stores are
  allowed, and only BPF_MEM and BPF_IMM loads are allowed; I think
  these can stay the same. BPF_XADD is new in eBPF, and I don't think
  we need it for seccomp (yet), since we don't have any shared memory
  via maps.

BPF_ALU: It looks like we're also not allowing regular BPF_ALU
  instruction BPF_MOD; eBPF adds a few ones: BPF_MOV (register move),
  BPF_ARSH (sign extended right shift), and BPF_END (endianness
  conversion), wich I think should all be safe. In particular, we need
  to allow BPF_MOV at least, since that's how the converter implements
  BPF_MISC | BPF_TAX from classic.

BPF_ALU64: I think we can safely allow all these as above, since
  they're just the 64-bit versions.

BPF_JMP: eBPF adds BPF_JNE, BPF_JSGT, BPF_JSGE, BPF_CALL, and
  BPF_EXIT, which I think all should be safe (except maybe BPF_CALL
  since we're not allowing functions really). Again we have to allow
  one of the new eBPF codes, as the converter implements BPF_RET as
  BPF_JMP | BPF_EXIT.

Thoughts?

Tycho
