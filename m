From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Let's do P4
Date: Mon, 31 Oct 2016 10:39:22 +0100
Message-ID: <20161031093922.GA2895@nanopsycho.orion>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com>
 <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain>
 <20161030163836.GC1686@nanopsycho.orion>
 <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
        John Fastabend <john.fastabend@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
        davem@davemloft.net, jhs@mojatatu.com, roopa@cumulusnetworks.com,
        simon.horman@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        prem@barefootnetworks.com, hannes@stressinduktion.org,
        jbenc@redhat.com, tom@herbertland.com, mattyk@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        nogahf@mellanox.com, ogerlitz@mellanox.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com,
        Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36236 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932765AbcJaJjZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 05:39:25 -0400
Received: by mail-wm0-f46.google.com with SMTP id p190so135854281wmp.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 02:39:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 30, 2016 at 11:39:05PM CET, alexei.starovoitov@gmail.com wrote:
>On Sun, Oct 30, 2016 at 05:38:36PM +0100, Jiri Pirko wrote:
>> Sun, Oct 30, 2016 at 11:26:49AM CET, tgraf@suug.ch wrote:
>> >On 10/30/16 at 08:44am, Jiri Pirko wrote:
>> >> Sat, Oct 29, 2016 at 06:46:21PM CEST, john.fastabend@gmail.com wrote:
>> >> >On 16-10-29 07:49 AM, Jakub Kicinski wrote:
>> >> >> On Sat, 29 Oct 2016 09:53:28 +0200, Jiri Pirko wrote:
>> >> >>> Hi all.
>> >> >>>
>
>sorry for delay. travelling to KS, so probably missed something in
>this thread and comments can be totally off...
>
>the subject "let's do P4" is imo misleading, since it reads like
>we don't do P4 at the moment, whereas the opposite is true.
>Several p4->bpf compilers is a proof.

We don't do p4 in kernel now, we don't do p4 offloading now. That is
the reason I started this discussion.


>
>> The network world is divided into 2 general types of hw:
>> 1) network ASICs - network specific silicon, containing things like TCAM
>>    These ASICs are suitable to be programmed by P4.
>
>i think the opposite is the case in case of P4.
>when hw asic has tcam it's still far far away from being usable with P4
>which requires fully programmable protocol parser, arbitrary tables and so on.
>P4 doesn't even define TCAM as a table type. The p4 program can declare
>a desired algorithm of search in the table and compiler has to figure out
>what HW resources to use to satisfy such p4 program.
>
>> 2) network processors - basically a general purpose CPUs
>>    These processors are suitable to be programmed by eBPF.
>
>I think this statement is also misleading, since it positions
>p4 and bpf as competitors whereas that's not the case.
>p4 is the language. bpf is an instruction set.

I wanted to say that we are having 2 approaches in silicon, 2 different
paradigms. Sure you can do p4>bpf. But hard to do it the opposite way.


>
>> Exactly. Following drawing shows p4 pipeline setup for SW and Hw:
>> 
>>                                  |
>>                                  |               +--> ebpf engine
>>                                  |               |
>>                                  |               |
>>                                  |           compilerB
>>                                  |               ^
>>                                  |               |
>> p4src --> compilerA --> p4ast --TCNL--> cls_p4 --+-> driver -> compilerC -> HW
>>                                  |
>>                        userspace | kernel
>>                                  |
>
>frankly this diagram smells very much like kernel bypass to me,

what? That is well defined kernel API, in-kernel sw consumer and offload
in driver. Same API for both.

Alex, you have very odd sense about what's bypassing kernel. That kind
of freaks me out...


>since I cannot see how one can put the whole p4 language compiler
>into the driver, so this last step of p4ast->hw, I presume, will be
>done by firmware, which will be running full compiler in an embedded cpu

In case of mlxsw, that compiler would be in driver.


>on the switch. To me that's precisely the kernel bypass, since we won't
>have a clue what HW capabilities actually are and won't be able to fine
>grain control them.
>Please correct me if I'm wrong.

You are wrong. By your definition, everything has to be figured out in
driver and FW does nothing. Otherwise it could do "something else" and
that would be a bypass? Does not make any sense to me whatsoever.


>
>> Plus the thing I cannot imagine in the model you propose is table fillup.
>> For ebpf, you use maps. For p4 you would have to have a separate HW-only
>> API. This is very similar to the original John's Flow-API. And therefore
>> a kernel bypass.
>
>I think John's flow api is a better way to expose mellanox switch capabilities.

We are under impression that p4 suits us nicely. But it is not about
us, it is about finding the common way to do this.


>I also think it's not fair to call it 'bypass'. I see nothing in it
>that justify such 'swear word' ;)

John's Flow-API was a kernel bypass. Why? It was a API specifically
designed to directly work with HW tables, without kernel being involved.


>The goal of flow api was to expose HW features to user space, so that
>user space can program it. For something simple as mellanox switch
>asic it fits perfectly well.

Again, this is not mlx-asic-specific. And again, that is a kernel bypass.


>Unless I misunderstand the bigger goal of this discussion and it's
>about programming ezchip devices.

No. For network processors, I believe that BPF is nicely offloadable, no
need to do the excercise for that.


>
>If the goal is to model hw tcam in the linux kernel then just introduce
>tcam bpf map type. It will be dog slow in user space, but it will
>match exactly what is happnening in the HW and user space can make
>sensible trade-offs.

No, you got me completely wrong. This is not about the TCAM. This is
about differences in the 2 words (p4/bpf).
Again, for "p4-ish" devices, you have to translate BPF. And as you
noted, it's an instruction set. Very hard if not impossible to parse in
order to get back the original semantics.
