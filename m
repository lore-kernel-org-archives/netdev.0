From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 07/29] x86: bpf_jit, use ENTRY+ENDPROC
Date: Mon, 24 Apr 2017 09:47:19 -0700
Message-ID: <20170424164717.GA80404@ast-mbp.thefacebook.com>
References: <697947f4-0a2c-1480-0995-9919556dc020@suse.cz>
 <20170424.104132.950580313142367896.davem@davemloft.net>
 <f7a94f4e-6d93-a447-a62f-3f290e66c647@suse.cz>
 <20170424.110844.1321374394090353753.davem@davemloft.net>
 <614ca52b-8a43-244e-8a3a-c39145ecc3e8@suse.cz>
 <20170424155507.miyqef7ld4hbmsej@gmail.com>
 <71301a81-1c61-fd4d-5b1b-5154fa723859@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>,
        mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com,
        x86@kernel.org, jpoimboe@redhat.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, daniel@iogearbox.net, edumazet@google.com
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33307 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S974880AbdDXQrX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 12:47:23 -0400
Content-Disposition: inline
In-Reply-To: <71301a81-1c61-fd4d-5b1b-5154fa723859@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 06:02:51PM +0200, Jiri Slaby wrote:
> On 04/24/2017, 05:55 PM, Ingo Molnar wrote:
> > * Jiri Slaby <jslaby@suse.cz> wrote:
> > 
> >> On 04/24/2017, 05:08 PM, David Miller wrote:
> >>> If you align the entry points, then the code sequence as a whole is
> >>> are no longer densely packed.
> >>
> >> Sure.
> >>
> >>> Or do I misunderstand how your macros work?
> >>
> >> Perhaps. So the suggested macros for the code are:
> >> #define BPF_FUNC_START_LOCAL(name) \
> >> 		SYM_START(name, SYM_V_LOCAL, SYM_A_NONE)
> >> #define BPF_FUNC_START(name) \
> >> 		SYM_START(name, SYM_V_GLOBAL, SYM_A_NONE)
> >>
> >> and they differ from the standard ones:
> >> #define SYM_FUNC_START_LOCAL(name)                      \
> >>         SYM_START(name, SYM_V_LOCAL, SYM_A_ALIGN)
> >> #define SYM_FUNC_START(name)                            \
> >>         SYM_START(name, SYM_V_GLOBAL, SYM_A_ALIGN)
> >>
> >>
> >> The difference is SYM_A_NONE vs. SYM_A_ALIGN, which means:
> >> #define SYM_A_ALIGN                             ALIGN
> >> #define SYM_A_NONE                              /* nothing */
> >>
> >> Does it look OK now?
> > 
> > No, the patch changes alignment which is undesirable, it needs to preserve the 
> > existing (non-)alignment of the symbols!
> 
> OK, so I am not expressing myself explicitly enough, it seems.
> 
> So, correct, the patch v3 adds alignments. I suggested in the discussion
> the macros above. They do not add alignments. If everybody is OK with
> that, v4 of the patch won't add alignments. OK?

can we go back to what problem this patch set is trying to solve?
Sounds like you want to add _function_ start/end marks to aid debugging?
Debugging with what? What tool will recognize this stuff?

Take a look at what your patch does:
+ENTRY(sk_load_word)
        test    %esi,%esi
        js      bpf_slow_path_word_neg
+ENDPROC(sk_load_word)

Does above two assembler instructions look like a function?

or this:
+ENTRY(sk_load_byte_positive_offset)
        cmp     %esi,%r9d   /* if (offset >= hlen) goto bpf_slow_path_byte */
        jle     bpf_slow_path_byte
        movzbl  (SKBDATA,%rsi),%eax
        ret
+ENDPROC(sk_load_byte_positive_offset)

This assembler code doesn't represent functions. There is no prologue/epilogue
and no stack frame. JITed code uses 'call' insn to jump into them, but they're
not your typical C functions.
Take a look at bpf_slow_path_common() macro that creates the frame before
calling into C code with 'call skb_copy_bits;'

I still think that this code should be left alone.
Even macro names you're proposing:
 #define BPF_FUNC_START_LOCAL
don't sound right. These are not functions.
