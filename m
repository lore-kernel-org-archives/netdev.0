From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH v3 07/29] x86: bpf_jit, use ENTRY+ENDPROC
Date: Tue, 25 Apr 2017 16:41:48 +0200
Message-ID: <bd853573-04d3-20a2-c124-7114f7684477@suse.cz>
References: <71301a81-1c61-fd4d-5b1b-5154fa723859@suse.cz>
 <20170424164717.GA80404@ast-mbp.thefacebook.com>
 <26f5afd7-d70b-effa-e528-8d0a2b95717a@suse.cz>
 <20170424.142420.290668473718207530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, mingo@kernel.org, mingo@redhat.com,
        tglx@linutronix.de, hpa@zytor.com, x86@kernel.org,
        jpoimboe@redhat.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, daniel@iogearbox.net, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33931 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948064AbdDYOlv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 10:41:51 -0400
In-Reply-To: <20170424.142420.290668473718207530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2017, 08:24 PM, David Miller wrote:
> From: Jiri Slaby <jslaby@suse.cz>
> Date: Mon, 24 Apr 2017 19:51:54 +0200
> 
>> For example what's the point of making the sk_load_word_positive_offset
>> label a global, callable function? Note that this is exactly the reason
>> why this particular two hunks look weird to you even though the
>> annotations only mechanically paraphrase what is in the current code.
> 
> So that it can be referenced by the eBPF JIT, because these are
> helpers for eBPF JIT generated code.  Every architecture implementing
> an eBPF JIT has this "mess".

I completely understand the needs for this, but I am complaining about
the way it is written. That is not the best -- unbalanced annotations, C
macros in lowercase (apart from that, C macros in .S need semicolons &
backslashes), FUNC macro, etc.

> You can't even put a tracepoint or kprobe on these things and expect
> to see "arguments" or "return PC" values in the usual spots.  This
> code has special calling conventions and register usage as Alexei
> explained.

Yes, I can see that.

> I would suggest that you read and understand how this assembler is
> designed, how it is called from the generated JIT code, and what it's
> semantics and register usage are, before trying to annotating it.

Of course I studied the code. I only missed macro CHOOSE_LOAD_FUNC which
I see now. So that answers why sk_load_word_positive_offset & similar
are marked as .globl.


But the original question I asked still remains: why do you mind calling
them BPF_FUNC_START & *_END, given:

1) the functions are marked by "FUNC" already:
$ git grep FUNC linus/master arch/x86/net/bpf_jit.S
linus/master:arch/x86/net/bpf_jit.S:#define FUNC(name) \
linus/master:arch/x86/net/bpf_jit.S:FUNC(sk_load_word)
linus/master:arch/x86/net/bpf_jit.S:FUNC(sk_load_word_positive_offset)
linus/master:arch/x86/net/bpf_jit.S:FUNC(sk_load_half)
linus/master:arch/x86/net/bpf_jit.S:FUNC(sk_load_half_positive_offset)
linus/master:arch/x86/net/bpf_jit.S:FUNC(sk_load_byte)
linus/master:arch/x86/net/bpf_jit.S:FUNC(sk_load_byte_positive_offset)
linus/master:arch/x86/net/bpf_jit.S:FUNC(sk_load_word_negative_offset)
linus/master:arch/x86/net/bpf_jit.S:FUNC(sk_load_half_negative_offset)
linus/master:arch/x86/net/bpf_jit.S:FUNC(sk_load_byte_negative_offset)

2) they _are_ all callable from within the JIT code:
EMIT1_off32(0xE8, jmp_offset);

Yes, I fucked up the ENDs. They should be on different locations. But
the pieces are still functions from my POV and should be annotated
accordingly.

thanks,
-- 
js
suse labs
