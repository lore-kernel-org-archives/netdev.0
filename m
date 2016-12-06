From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Tue, 6 Dec 2016 17:44:05 -0500
Message-ID: <CAF=yD-L_yCTpaqM2dGYzMr38oHQBYJ+A62SW0LEfwG2JC3eOtA@mail.gmail.com>
References: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <1480972006.18162.559.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161205213001.GA16819@breakpoint.cc> <20161205223415.GA14689@salvia>
 <20161205230055.GA15379@salvia> <CAF=yD-Jk4W+zU=tdixWe3LPGcFp-sANxXLLoQTRvrkN_3=a9uw@mail.gmail.com>
 <20161205232214.GA15825@salvia> <CA+FuTSfHryyqBhRyfQCChG2VPwpj1KYBk2Z7DZ-dcYL-FbbSeA@mail.gmail.com>
 <CAF=yD-J-vcQQ_-48xG8qhMuYvLvucCr7SG99rsfJA5-okvhHzA@mail.gmail.com> <20161206002027.GD16819@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemb@google.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20161206002027.GD16819@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 5, 2016 at 7:20 PM, Florian Westphal <fw@strlen.de> wrote:
> Willem de Bruijn <willemdebruijn.kernel@gmail.com> wrote:
>> While we're discussing the patch, another question, about revisions: I
>> tested both modified and original iptables binaries on both standard
>> and modified kernels. It all works as expected, except for the case
>> where both binaries are used on a single kernel. For instance:
>>
>>   iptables -A OUTPUT -m bpf --bytecode "`./nfbpf_compile RAW 'udp port
>> 8000'`" -j LOG
>>   ./iptables.new -L
>>
>> Here the new binary will interpret the object as xt_bpf_match_v1, but
>> iptables has inserted xt_bpf_match. The same problem happens the other
>> way around. A new binary can be made robust to detect old structs, but
>> not the other way around. Specific to bpf, the existing xt_bpf code
>> has an unfortunate bug that it always prints at least one line of
>> code, even if ->bpf_program_num_elems == 0.
>>
>> I notice that other extensions also do not necessarily only extend
>> struct vN in vN+1. Is the above a known issue?
>
> Yes, I guess noone ever bothered to fix this.
>
> The kernel blob should contain the match/target revision number,
> so userspace can in fact see that 'this is bpf v42', but iirc
> the netfilter userspace just loads the highest userspace revision
> supported by the kernel (which is then different for the 2 iptables
> binaries).

We can fall back on not parsing contents on mismatch:

diff --git a/iptables/iptables.c b/iptables/iptables.c
index 540d111..ada7c94 100644
--- a/iptables/iptables.c
+++ b/iptables/iptables.c
@@ -504,7 +504,8 @@ print_match(const struct xt_entry_match *m,
                xtables_find_match(m->u.user.name, XTF_TRY_LOAD, NULL);

        if (match) {
-               if (match->print)
+               if (match->print &&
+                   m->u.user.revision == match->revision)
                        match->print(ip, m, numeric);
                else
                        printf("%s ", match->name);

> But we *could* display message like 'kernel uses revision 2 but I can
> only find 0 and 1' or fall back to the lower supported revision without
> guess-the-struct-by-size games.

That's a good idea. A special case printf() with a notice, then.
