From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/6] ebpf: add a seccomp program type
Date: Wed, 9 Sep 2015 09:07:45 -0700
Message-ID: <20150909160744.GA3526@Alexeis-MBP-2.westell.com>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-2-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5j+9YvL6XzX=x8krZbdJXFpe-3FuMu=hAZX9Ew=hYyuK7Q@mail.gmail.com>
 <20150904210615.GR26679@smitten>
 <CAGXu5jKGBuD15KBfXKoYbGB40cNsbh=Dz8GM=bmUL-oECRhzxA@mail.gmail.com>
 <20150909155035.GA26679@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150909155035.GA26679@smitten>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 09, 2015 at 09:50:35AM -0600, Tycho Andersen wrote:
> > >
> > > That's effectively what this patch does; when the eBPF is loaded via
> > > bpf(), you tell bpf() you want a BPF_PROG_TYPE_SECCOMP, and it invokes
> > > this validation/translation code, i.e. it uses
> > > seccomp_is_valid_access() to check and make sure access are aligned
> > > and inside struct seccomp_data.
> > 
> > What about limiting the possible instructions?
> 
> I totally overlooked this. A quick glance through the eBPF verifier
> makes me think that we can just add another function to struct
> bpf_verifier_ops called valid_instruction, which shouldn't be too
> hard. Perhaps a more interesting question is what to allow:
> 
> BPF_LD(X) and BPF_ST(X): it looks like all types of stores are
>   allowed, and only BPF_MEM and BPF_IMM loads are allowed; I think
>   these can stay the same. BPF_XADD is new in eBPF, and I don't think
>   we need it for seccomp (yet), since we don't have any shared memory
>   via maps.
> 
> BPF_ALU: It looks like we're also not allowing regular BPF_ALU
>   instruction BPF_MOD; eBPF adds a few ones: BPF_MOV (register move),
>   BPF_ARSH (sign extended right shift), and BPF_END (endianness
>   conversion), wich I think should all be safe. In particular, we need
>   to allow BPF_MOV at least, since that's how the converter implements
>   BPF_MISC | BPF_TAX from classic.
> 
> BPF_ALU64: I think we can safely allow all these as above, since
>   they're just the 64-bit versions.
> 
> BPF_JMP: eBPF adds BPF_JNE, BPF_JSGT, BPF_JSGE, BPF_CALL, and
>   BPF_EXIT, which I think all should be safe (except maybe BPF_CALL
>   since we're not allowing functions really). Again we have to allow
>   one of the new eBPF codes, as the converter implements BPF_RET as
>   BPF_JMP | BPF_EXIT.
> 
> Thoughts?

Please do not add any per-instruction hacks. None of them are
necessary. Classic had to do extra ugly checks in seccomp only
because verifier wasn't flexible enough.
If you don't want to see any BPF_CALL in seccomp, just have
empty get_func_proto() callback for BPF_PROG_TYPE_SECCOMP
and verifier will reject all calls.
Currently we have only two non-generic instrucitons
LD_ABS and LD_IND that are avaialable for sockets/TC only,
because these are legacy instructions and we had to make
exceptions for them.
