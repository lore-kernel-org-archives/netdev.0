From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 16:54:03 -0700
Message-ID: <CALx6S37uZah89sNgH9wuD1J+_WEhd34Z5zmrnG8Qp-AQ7Ew=Jg@mail.gmail.com>
References: <20151219070009.GA4634@1wt.eu>
	<CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
	<20151221204127.GC8018@1wt.eu>
	<CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
	<20160324061222.GA6807@1wt.eu>
	<1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160324142222.GB7237@1wt.eu>
	<1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160324153053.GA7569@1wt.eu>
	<1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160324165047.GA7585@1wt.eu>
	<1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALx6S36Ej1es8qFi2Q3=199f+rmG=Za02N5ZBWT5DCRqrBEWvQ@mail.gmail.com>
	<56F42A00.7050002@iogearbox.net>
	<CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
	<1458859788.6473.2.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAKQ1sVPJoaaf1gRfgYPRygfMFVqk08Q0K74wn6kLHV+vy=8w1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Craig Gallek <cgallek@google.com>,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Yann Ylavic <ylavic.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:32950 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbcCXXyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 19:54:04 -0400
Received: by mail-io0-f180.google.com with SMTP id c63so102792549iof.0
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 16:54:04 -0700 (PDT)
In-Reply-To: <CAKQ1sVPJoaaf1gRfgYPRygfMFVqk08Q0K74wn6kLHV+vy=8w1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 4:40 PM, Yann Ylavic <ylavic.dev@gmail.com> wrote:
> On Thu, Mar 24, 2016 at 11:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2016-03-24 at 23:40 +0100, Yann Ylavic wrote:
>>
>>> FWIW, I find:
>>>
>>>     const struct bpf_insn prog[] = {
>>>         /* BPF_MOV64_REG(BPF_REG_6, BPF_REG_1) */
>>>         { BPF_ALU64 | BPF_MOV | BPF_X, BPF_REG_6, BPF_REG_1, 0, 0 },
>>>         /* BPF_LD_ABS(BPF_W, 0) R0 = (uint32_t)skb[0] */
>>>         { BPF_LD | BPF_ABS | BPF_W, 0, 0, 0, 0 },
>>>         /* BPF_ALU64_IMM(BPF_MOD, BPF_REG_0, mod) */
>>>         { BPF_ALU64 | BPF_MOD | BPF_K, BPF_REG_0, 0, 0, mod },
>>>         /* BPF_EXIT_INSN() */
>>>         { BPF_JMP | BPF_EXIT, 0, 0, 0, 0 }
>>>     };
>>> (and all the way to make it run)
>>>
>>> something quite unintuitive from a web server developper perspective,
>>> simply to make SO_REUSEPORT work with forked TCP listeners (probably
>>> as it should out of the box)...
>>
>>
>> That is why EBPF has LLVM backend.
>>
>> Basically you can write your "BPF" program in C, and let llvm convert it
>> into EBPF.
>
> I'll learn how to do this to get the best performances from the
> server, but having to do so to work around what looks like a defect
> (for simple/default SMP configurations at least, no NUMA or clever
> CPU-affinity or queuing policy involved) seems odd in the first place.
>
I disagree with your assessment that there is a defect. SO_REUSEPORT
is designed to spread packets amongst _equivalent_ connections. In the
server draining case sockets are no longer equivalent, but that is a
special case.

> From this POV, draining the (ending) listeners is already non obvious
> but might be reasonable, (e)BPF sounds really overkill.
>
Just the opposite, it's a simplification. With BPF we no longer to add
interfaces for all these special cases. This is an important point,
because the question is going to be raised for any proposed interface
change that could be accomplished with BPF (i.e. adding new interfaces
in the kernel becomes the overkill).

Please try to work with it. As I mentioned, the part that we may be
missing are some real world programs that we can direct people to use,
but aside from that I don't think we've seen any arguments that BPF is
overkill or too hard to use for stuff like this.

Tom

> But there are surely plenty of good reasons for it, and I won't be
> able to dispute your technical arguments in any case ;)
>
>>
>> Sure, you still can write BPF manually, as you could write HTTPS server
>> in assembly.
>
> OK, I'll take your previous proposal :)
