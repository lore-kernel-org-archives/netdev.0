From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Let's do P4
Date: Wed, 02 Nov 2016 03:29:23 +0100
Message-ID: <58194F83.9020205@iogearbox.net>
References: <20161029075328.GB1692@nanopsycho.orion> <20161029154903.25deb6db@jkicinski-Precision-T1700> <5814D25D.9070200@gmail.com> <20161030074458.GB1686@nanopsycho.orion> <20161030102649.GE1810@pox.localdomain> <20161030163836.GC1686@nanopsycho.orion> <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net> <20161031093922.GA2895@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
        John Fastabend <john.fastabend@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
        davem@davemloft.net, jhs@mojatatu.com, roopa@cumulusnetworks.com,
        simon.horman@netronome.com, ast@kernel.org,
        prem@barefootnetworks.com, hannes@stressinduktion.org,
        jbenc@redhat.com, tom@herbertland.com, mattyk@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        nogahf@mellanox.com, ogerlitz@mellanox.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com,
        =?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <zenczykowski@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57716 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754575AbcKBC36 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 22:29:58 -0400
In-Reply-To: <20161031093922.GA2895@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2016 10:39 AM, Jiri Pirko wrote:
> Sun, Oct 30, 2016 at 11:39:05PM CET, alexei.starovoitov@gmail.com wrote:
>> On Sun, Oct 30, 2016 at 05:38:36PM +0100, Jiri Pirko wrote:
>>> Sun, Oct 30, 2016 at 11:26:49AM CET, tgraf@suug.ch wrote:
>>>> On 10/30/16 at 08:44am, Jiri Pirko wrote:
>>>>> Sat, Oct 29, 2016 at 06:46:21PM CEST, john.fastabend@gmail.com wrote:
>>>>>> On 16-10-29 07:49 AM, Jakub Kicinski wrote:
>>>>>>> On Sat, 29 Oct 2016 09:53:28 +0200, Jiri Pirko wrote:
>>>>>>>> Hi all.
>>
>> sorry for delay. travelling to KS, so probably missed something in
>> this thread and comments can be totally off...
>>
>> the subject "let's do P4" is imo misleading, since it reads like
>> we don't do P4 at the moment, whereas the opposite is true.
>> Several p4->bpf compilers is a proof.
>
> We don't do p4 in kernel now, we don't do p4 offloading now. That is
> the reason I started this discussion.
>
>>> The network world is divided into 2 general types of hw:
>>> 1) network ASICs - network specific silicon, containing things like TCAM
>>>     These ASICs are suitable to be programmed by P4.
>>
>> i think the opposite is the case in case of P4.
>> when hw asic has tcam it's still far far away from being usable with P4
>> which requires fully programmable protocol parser, arbitrary tables and so on.
>> P4 doesn't even define TCAM as a table type. The p4 program can declare
>> a desired algorithm of search in the table and compiler has to figure out
>> what HW resources to use to satisfy such p4 program.
>>
>>> 2) network processors - basically a general purpose CPUs
>>>     These processors are suitable to be programmed by eBPF.
>>
>> I think this statement is also misleading, since it positions
>> p4 and bpf as competitors whereas that's not the case.
>> p4 is the language. bpf is an instruction set.
>
> I wanted to say that we are having 2 approaches in silicon, 2 different
> paradigms. Sure you can do p4>bpf. But hard to do it the opposite way.
>
>>> Exactly. Following drawing shows p4 pipeline setup for SW and Hw:
>>>
>>>                                   |
>>>                                   |               +--> ebpf engine
>>>                                   |               |
>>>                                   |               |
>>>                                   |           compilerB
>>>                                   |               ^
>>>                                   |               |
>>> p4src --> compilerA --> p4ast --TCNL--> cls_p4 --+-> driver -> compilerC -> HW
>>>                                   |
>>>                         userspace | kernel
>>>                                   |

Sorry for jumping into the middle and the delay (plumbers this week). My
question would be, if the main target is for p4 *offloading* anyway, who
would use this sw fallback path? Mostly for testing purposes?

I'm not sure about compilerB here and the complexity that needs to be
pushed into the kernel along with it. I would assume this would result
in slower code than what the existing P4 -> eBPF front ends for LLVM
would generate since it could perform all kind of optimizations there,
that might not be feasible for doing inside the kernel. Thus, if I'd want
to do that in sw, I'd just use the existing LLVM facilities instead and
go via cls_bpf in that case.

What is your compilerA? Is that part of tc in user space? Maybe linked
against LLVM lib, for example? If you really want some sw path, can't tc
do this transparently from user space instead when it gets a netlink error
that it cannot get offloaded (and thus switch internally to f_bpf's loader)?
