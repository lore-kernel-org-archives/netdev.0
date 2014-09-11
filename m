From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Thu, 11 Sep 2014 13:33:26 -0700
Message-ID: <CAMEtUuziPptHxtw_7fkOdR-paB+8BatNmRPoo3txP8wOp9D6Tw@mail.gmail.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
	<541013CE.6020307@redhat.com>
	<CAMEtUuwrHX4ENK9cZ0C+XVB=wkMz1=wLphX_GVLvd8pyJKMXeQ@mail.gmail.com>
	<5411FC42.3070505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5411FC42.3070505-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 11, 2014 at 12:47 PM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 09/10/2014 07:32 PM, Alexei Starovoitov wrote:
>>
>> On Wed, Sep 10, 2014 at 2:03 AM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> wrote:
>>>>
>>>>              struct { /* anonymous struct used by BPF_PROG_LOAD command
>>>> */
>>>>                  enum bpf_prog_type    prog_type;
>>>>                  __u32                 insn_cnt;
>>>>                  const struct bpf_insn *insns;
>>>>                  const char            *license;
>>>>                  __u32                 log_level; /* verbosity level of
>>>> eBPF verifier */
>>>>                  __u32                 log_size;  /* size of user buffer
>>>> */
>>>>                  void                  *log_buf;  /* user supplied
>>>> buffer
>>>> */
>>>
>>>
>>>
>>> What is log buffer? Would that mean the verifier will return an error
>>> string if the program will not pass it, or if not, what other data?
>>> I think the man page is missing how to examine the returned verifier
>>> log buffer data.
>>
>>
>> yes. it's an error log (as text string for humans) from verifier.
>
> I was confused due to the void pointer. But that also means that the text

ahh. ok. will change it to 'char *' then.

> string becomes part of the ABI; aren't eBPF specific error codes (perhaps
> a tuple of [line + error code]), though ugly as well, but perhaps the better
> solution to this [which user space can then map to an actual string]?

the verifier log contains full trace. Last unsafe instruction + error
in many cases is useless. What we found empirically from using
it over last 2 years is that developers have different learning curve
to adjust to 'safe' style of C. Pretty much everyone couldn't
figure out why program is rejected based on last error. Therefore
verifier emits full log. From the 1st insn all the way till the last
'unsafe' instruction. So the log is multiline output.
'Understanding eBPF verifier messages' section of
Documentation/networking/filter.txt provides few trivial
examples of these multiline messages.
Like for the program:
  BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
  BPF_LD_MAP_FD(BPF_REG_1, 0),
  BPF_CALL_FUNC(BPF_FUNC_map_lookup_elem),
  BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
  BPF_ST_MEM(BPF_DW, BPF_REG_0, 4, 0),
  BPF_EXIT_INSN(),
the verifier log_buf is:
  0: (7a) *(u64 *)(r10 -8) = 0
  1: (bf) r2 = r10
  2: (07) r2 += -8
  3: (b7) r1 = 0
  4: (85) call 1
  5: (15) if r0 == 0x0 goto pc+1
   R0=map_ptr R10=fp
  6: (7a) *(u64 *)(r0 +4) = 0
  misaligned access off 4 size 8

It will surely change over time as verifier becomes smarter,
supports new types, optimizations and so on.
So this log is not an ABI. It's for humans to read.
The log explains _how_ verifier came to conclusion
that the program is unsafe.
