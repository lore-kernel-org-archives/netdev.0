From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH/RFC] Reduce call chain length in netfilter
Date: Thu, 27 Jan 2005 18:50:50 +0100
Message-ID: <41F929FA.3050800@trash.net>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>	<p73zn0ccaee.fsf@verdi.suse.de>	<1105117559.11753.34.camel@baythorne.infradead.org>	<20050107100017.454ddadc@dxpl.pdx.osdl.net>	<1105133241.3375.16.camel@localhost.localdomain>	<20050118135735.4b77d38d.davem@davemloft.net>	<1106433059.4486.11.camel@localhost.localdomain>	<1106436153.20995.42.camel@tux.rsn.bth.se>	<1106484019.3376.5.camel@localhost.localdomain>	<1106496509.1085.1.camel@tux.rsn.bth.se>	<20050125220558.6e824f8a.davem@davemloft.net>	<1106730510.4041.4.camel@localhost.localdomain>	<41F82C6D.7020006@trash.net> <20050126231801.7bf90338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, snort2004@mail.ru,
        rusty@rustcorp.com.au, ak@suse.de, bridge@osdl.org,
        gandalf@wlug.westbo.se, dwmw2@infradead.org, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050126231801.7bf90338.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>While reviewing I thought it may be an issue that the new macros
>potentially change skb.  It really isn't an issue because NF_HOOK()
>calls pass ownership of the SKB over from the caller.
>
>Although technically, someone could go:
>
>	skb_get(skb);
>	err = NF_HOOK(... skb ...);
>	... do stuff with skb ...
>	kfree_skb(skb);
>
>but that would cause other problems and I audited the entire tree
>and nobody attempts anything like this currently.  'skb' always
>dies at the NF_HOOK() call site.
>
Yes, it has always been illegal to use the skb after NF_HOOK.

>Another huge downside to this change I was worried about
>was from a code generation point of view.  Since we now take the
>address of "skb", gcc cannot generate tail-calls for the common
>case of:
>
>	return NF_HOOK(...);
>
>when netfilter is enabled.  Ho hum...
>
 From what I can see it doesn't generate tail-calls currently:

 34c:   45 31 c0                xor    %r8d,%r8d
 34f:   4c 89 e2                mov    %r12,%rdx
 352:   be 01 00 00 00          mov    $0x1,%esi
 357:   bf 02 00 00 00          mov    $0x2,%edi
 35c:   c7 04 24 00 00 00 80    movl   $0x80000000,(%rsp)
 363:   e8 00 00 00 00          callq  368 <ip_local_deliver+0x248>
                        364: R_X86_64_PC32      
nf_hook_slow+0xfffffffffffffffc
 368:   48 83 c4 10             add    $0x10,%rsp
 36c:   5b                      pop    %rbx
 36d:   5d                      pop    %rbp
 36e:   41 5c                   pop    %r12
 370:   c3                      retq

According to something I found on the internet, gcc only optimizes
tail-calls if some conditions are met, in this case most importantly
the space required for the arguments to the function called at the tail
must not exceed the space required for the arguments of the function
itself. nf_hook_slow takes 6 arguments, probably more than any caller.

Regards
Patrick
