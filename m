From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 07/29] x86: bpf_jit, use ENTRY+ENDPROC
Date: Mon, 24 Apr 2017 10:41:32 -0400 (EDT)
Message-ID: <20170424.104132.950580313142367896.davem@davemloft.net>
References: <20170421141305.25180-7-jslaby@suse.cz>
        <20170421193213.GB91454@ast-mbp.thefacebook.com>
        <697947f4-0a2c-1480-0995-9919556dc020@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, mingo@redhat.com, tglx@linutronix.de,
        hpa@zytor.com, x86@kernel.org, jpoimboe@redhat.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, edumazet@google.com
To: jslaby@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1172642AbdDXOlg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 10:41:36 -0400
In-Reply-To: <697947f4-0a2c-1480-0995-9919556dc020@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jslaby@suse.cz>
Date: Mon, 24 Apr 2017 08:45:11 +0200

> On 04/21/2017, 09:32 PM, Alexei Starovoitov wrote:
>> On Fri, Apr 21, 2017 at 04:12:43PM +0200, Jiri Slaby wrote:
>>> Do not use a custom macro FUNC for starts of the global functions, use
>>> ENTRY instead.
>>>
>>> And while at it, annotate also ends of the functions by ENDPROC.
>>>
>>> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
>>> Cc: "David S. Miller" <davem@davemloft.net>
>>> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
>>> Cc: James Morris <jmorris@namei.org>
>>> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>>> Cc: Patrick McHardy <kaber@trash.net>
>>> Cc: Thomas Gleixner <tglx@linutronix.de>
>>> Cc: Ingo Molnar <mingo@redhat.com>
>>> Cc: "H. Peter Anvin" <hpa@zytor.com>
>>> Cc: x86@kernel.org
>>> Cc: netdev@vger.kernel.org
>>> ---
>>>  arch/x86/net/bpf_jit.S | 32 ++++++++++++++++++--------------
>>>  1 file changed, 18 insertions(+), 14 deletions(-)
>>>
>>> diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
>>> index f2a7faf4706e..762c29fb8832 100644
>>> --- a/arch/x86/net/bpf_jit.S
>>> +++ b/arch/x86/net/bpf_jit.S
>>> @@ -23,16 +23,12 @@
>>>  	32 /* space for rbx,r13,r14,r15 */ + \
>>>  	8 /* space for skb_copy_bits */)
>>>  
>>> -#define FUNC(name) \
>>> -	.globl name; \
>>> -	.type name, @function; \
>>> -	name:
>>> -
>>> -FUNC(sk_load_word)
>>> +ENTRY(sk_load_word)
>>>  	test	%esi,%esi
>>>  	js	bpf_slow_path_word_neg
>>> +ENDPROC(sk_load_word)
>> 
>> this doens't look right.
>> It will add alignment nops in critical paths of these pseudo functions.
>> I'm also not sure whether it will still work afterwards.
>> Was it tested?
>> I'd prefer if this code kept as-is.
> 
> It cannot stay as-is simply because we want to know where the functions
> end to inject debuginfo properly. The code above does not warrant for
> any exception.

I totally and completely disagree.

> Executing a nop takes a little and having externally-callable functions
> aligned can actually help performance (no, I haven't measured nor tested
> the code). But sure, the tool is generic, so I can introduce a local
> macros to avoid alignments in the functions:

Not for this case, it's a bunch of entry points all packed together
intentionally so that SKB accesses of different access sizes (which is
almost always the case) from BPF programs use the smallest amount of
I-cache as possible.
