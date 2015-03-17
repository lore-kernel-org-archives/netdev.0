From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] act_bpf: allow non-default TC_ACT opcodes as BPF
 exec outcome
Date: Tue, 17 Mar 2015 15:16:12 -0700
Message-ID: <5508A7AC.1090903@plumgrid.com>
References: <98364de656ad8034f008999121f57940af767b93.1426619298.git.daniel@iogearbox.net> <CAHA+R7PhYvs2hPgQ1Rj+UjWdASsQq759_8o8125-mvmOKJzWKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <cwang@twopensource.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34991 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350AbbCQWQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 18:16:08 -0400
Received: by pdbop1 with SMTP id op1so22060729pdb.2
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 15:16:08 -0700 (PDT)
In-Reply-To: <CAHA+R7PhYvs2hPgQ1Rj+UjWdASsQq759_8o8125-mvmOKJzWKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/17/15 2:53 PM, Cong Wang wrote:
> On Tue, Mar 17, 2015 at 12:25 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> Revisiting commit d23b8ad8ab23 ("tc: add BPF based action") with regards
>> to eBPF support, I was thinking that it might be better to improve
>> return semantics from a BPF program invoked through BPF_PROG_RUN().
>>
>> Currently, in case filter_res is 0, we overwrite the default action
>> opcode with TC_ACT_SHOT. A default action opcode configured through tc's
>> m_bpf can be: TC_ACT_RECLASSIFY, TC_ACT_PIPE, TC_ACT_SHOT, TC_ACT_UNSPEC,
>> TC_ACT_OK.
>>
>> In cls_bpf, we have the possibility to overwrite the default class
>> associated with the classifier in case filter_res is _not_ 0xffffffff
>> (-1).
>>
>> That allows us to fold multiple [e]BPF programs into a single one, where
>> they would otherwise need to be defined as a separate classifier with
>> its own classid, needlessly redoing parsing work, etc.
>>
>> Similarly, we could do better in act_bpf: Since above TC_ACT* opcodes
>> are exported to UAPI anyway, we reuse them for return-code-to-tc-opcode
>> mapping, where we would allow above possibilities. Thus, like in cls_bpf,
>> a filter_res of 0xffffffff (-1) means that the configured _default_ action
>> is used. Any unkown return code from the BPF program would fail in
>> tcf_bpf() with TC_ACT_UNSPEC.
>>
>
> So you allow bpf bytecode to override the action code specified
> in cmdline, I doubt this is user-friendly since if I run different
> bytecode I would see different behaviors even if I specify the same
> action in cmdline. Allowing cmdline to override bytecode makes
> more sense to me.
>
> A even cleaner solution is not to override either of them, that is
> either bytecode or cmdline fully controls the action code.
>

There was ambiguity in priority. Whether program decides
the action or default/fallback action taken from command line...
This patch is trying to make both of them useful by saying
that program result has higher priority than 'default/fallback' action.
To avoid priorities we can drop command line action and just
let program decide. But that is less flexible. I think default
action is useful too. The user can have one program that returns
act_unspec and fine tune it via command line by changing default action.
