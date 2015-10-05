From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Tue, 06 Oct 2015 00:14:17 +0200
Message-ID: <5612F639.2050305@iogearbox.net>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com> <1444078101-29060-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43113 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbbJEWOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 18:14:25 -0400
In-Reply-To: <1444078101-29060-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2015 10:48 PM, Alexei Starovoitov wrote:
> In order to let unprivileged users load and execute eBPF programs
> teach verifier to prevent pointer leaks.
> Verifier will prevent
> - any arithmetic on pointers
>    (except R10+Imm which is used to compute stack addresses)
> - comparison of pointers
> - passing pointers to helper functions
> - indirectly passing pointers in stack to helper functions
> - returning pointer from bpf program
> - storing pointers into ctx or maps
>
> Spill/fill of pointers into stack is allowed, but mangling
> of pointers stored in the stack or reading them byte by byte is not.
>
> Within bpf programs the pointers do exist, since programs need to
> be able to access maps, pass skb pointer to LD_ABS insns, etc
> but programs cannot pass such pointer values to the outside
> or obfuscate them.
>
> Only allow BPF_PROG_TYPE_SOCKET_FILTER unprivileged programs,
> so that socket filters (tcpdump), af_packet (quic acceleration)
> and future kcm can use it.
> tracing and tc cls/act program types still require root permissions,
> since tracing actually needs to be able to see all kernel pointers
> and tc is for root only.
>
> For example, the following unprivileged socket filter program is allowed:
> int foo(struct __sk_buff *skb)
> {
>    char fmt[] = "hello %d\n";
>    bpf_trace_printk(fmt, sizeof(fmt), skb->len);
>    return 0;
> }
>
> but the following program is not:
> int foo(struct __sk_buff *skb)
> {
>    char fmt[] = "hello %p\n";
>    bpf_trace_printk(fmt, sizeof(fmt), fmt);
>    return 0;
> }
> since it would leak the kernel stack address via bpf_trace_printk().
>
> Unprivileged socket filter bpf programs have access to the
> following helper functions:
> - map lookup/update/delete (but they cannot store kernel pointers into them)
> - get_random (it's already exposed to unprivileged user space)
> - get_smp_processor_id
> - tail_call into another socket filter program
> - ktime_get_ns
> - bpf_trace_printk (for debugging)
>
> The feature is controlled by sysctl kernel.bpf_enable_unprivileged
> which is off by default.
>
> New tests were added to test_verifier:
>   unpriv: return pointer OK
>   unpriv: add const to pointer OK
>   unpriv: add pointer to pointer OK
>   unpriv: neg pointer OK
>   unpriv: cmp pointer with const OK
>   unpriv: cmp pointer with pointer OK
>   unpriv: pass pointer to printk OK
>   unpriv: pass pointer to helper function OK
>   unpriv: indirectly pass pointer on stack to helper function OK
>   unpriv: mangle pointer on stack 1 OK
>   unpriv: mangle pointer on stack 2 OK
>   unpriv: read pointer from stack in small chunks OK
>   unpriv: write pointer into ctx OK
>   unpriv: write pointer into map elem value OK
>   unpriv: partial copy of pointer OK
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

One scenario that comes to mind ... what happens when there are kernel
pointers stored in skb->cb[] (either from the current layer or an old
one from a different layer that the skb went through previously, but
which did not get overwritten)?

Socket filters could read a portion of skb->cb[] also when unprived and
leak that out through maps. I think the verifier doesn't catch that,
right?

Thanks,
Daniel
