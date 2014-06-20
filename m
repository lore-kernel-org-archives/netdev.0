From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH v6 net-next 1/4] net: flow_dissector: avoid multiple calls
 in eBPF
Date: Fri, 20 Jun 2014 14:56:21 -0700
Message-ID: <CA+ZOOTONwNt2xpwUc=tqhP=m31KZTzij-rrAHVh6g3hVYgKaEw@mail.gmail.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	<1401389758-13252-1-git-send-email-chema@google.com>
	<5387C8AD.6000909@redhat.com>
	<CA+ZOOTNobzzJPgQnVVZ+b6rRD=0_pdjUB8q5FQVkbO+dob0BSg@mail.gmail.com>
	<538C6FD8.9040305@redhat.com>
	<CAMEtUuyduk1sHBeVm=d5GYEgB4ma7sVFYeBLdapbeEpQY9nA1Q@mail.gmail.com>
	<538D884E.5030007@redhat.com>
	<CAMEtUuxK5hV_eORRLaSHSiwF5X82Ae91vL6W0-6au48v8H6bAA@mail.gmail.com>
	<CA+ZOOTPdDDeGxZVGXVRZmjkxqkGefgDLrawo_9YXbjwTQ_FLzA@mail.gmail.com>
	<538EDE1A.8060305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <538EDE1A.8060305@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'll try to revive the discussion for this patch, in case I can
convince you about its implementation. I rebased it to the latest
HEAD, and I'm ready to re-submit.

On Wed, Jun 4, 2014 at 1:51 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 06/03/2014 11:12 PM, Chema Gonzalez wrote:
> ...
>
>> Your approach needs it too. Citing from your pseudo-code:
>>
>>> ld #5     <-- indicates to fill the first 5 slots of M[], so M[0] to M[4]
>>> ld #keys  <-- triggers the extension to fill the M[] slots
>>> ld M[0]   <-- loads nhoff from M[0] into accu
>>
>>
>> How does the "ld M[0]" know that the actual flow dissector has already
>> been called? What if the insn just before the "ld #5" was "jmp +2" ?
>> In that case, the "ld #keys" would have never been called.
>
>
> But that case would be no different from doing something like ...
>
> [...]
>   jmp foo
>   ldi #42
>   st M[0]
> foo:
>   ld M[0]
> [...]
>
> ... and would then not pass the checker in check_load_and_stores(),
> which, as others have already stated, would need to be extended,
> of course. It's one possible approach.

As Alexei/you have noted, this is moving the complexity to
check_load_and_stores(). It's more complicated than the current
ensure-there's-a-store-preceding-each-load-for-each-M[]-position
check. In particular, your approach requires 2 insns before a memory
position can be considered filled, namely the "ld #5" and the "ld
#keys". That means adding intra-instruction state to the FSM in
check_load_and_stores().

A second issue is that you need to ensure that M[0:5] does not get
polluted between the moment you call "ld #5; ld #keys" and the moment
the code uses the flow-dissector values. This is more complex than
just ensuring the code doesn't access uninit'ed M[].

There's also some concerns about effectively adding a prologue. We
already have that:

$ cat net/core/filter.c
...
int sk_convert_filter(struct sock_filter *prog, int len,
          struct sock_filter_int *new_prog, int *new_len)
{
  ...
  if (new_insn)
    *new_insn = BPF_MOV64_REG(BPF_REG_CTX, BPF_REG_ARG1);
  new_insn++;

  for (i = 0; i < len; fp++, i++) {
    ...

The current prologue is embedded in sk_convert_filter(). The patch
just moves it to its own function, and (potentially) adds another
instruction (which zeroes flow_inited iff there's any call to the flow
dissector).

>>> Anyway as I said before I'm not excited about either.
>>> I don't think we should be adding classic BPF extensions any more.
>>> The long term headache of supporting classic BPF extensions
>>> outweighs the short term benefits.
>> I see a couple of issues with (effectively) freezing classic BPF
>> development while waiting for direct eBPF access to happen. The first
>> one is that the kernel has to accept it. I can see many questions
>> about this, especially security and usability (I'll send an email
>> about the "split BPF out of core later"). Now, the main issue is
>> whether/when the tools will support it. IMO, this is useful iff I can
>> quickly write/reuse filters and run tcpdump filters based on them. I'm
>> trying to get upstream libpcap to accept support for raw (classic) BPF
>> filters, and it's taking a long time. I can imagine how they may be
>> less receptive about supporting a Linux-only eBPF mechanism. Tools do
>> matter.
This is a high-level decision, more than a technical one. Do we want
to freeze classic BPF development in linux, even before we have a
complete eBPF replacement, and zero eBPF tool (libpcap) support?

> Grepping through libpcap code, which tries to be platform independent,
> it seems after all the years, the only thing where you can see support
> for in their code is SKF_AD_PKTTYPE and SKF_AD_PROTOCOL. Perhaps they
Actually they recently added MOD/XOR support. Woo-hoo!

> just don't care, perhaps they do, who knows, but it looks to me a bit
> that they are reluctant to these improvements, maybe for one reason
> that other OSes don't support it.
>From the comments in the MOD/XOR patch, the latter seem to be the issue.

> That was also one of the reasons that
> led me to start writing bpf_asm (net/tools/) for having a small DSL
> for more easily trying out BPF code while having _full_ control over it.
>
> Maybe someone should start a binary-compatible Linux-only version of
> libpcap, where tcpdump will transparently make use of these low level
> improvements eventually. </rant> ;)
There's too much code dependent on libpcap to make a replacement possible.

Thanks,
-Chema
