From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] act_bpf: allow non-default TC_ACT opcodes as BPF exec outcome
Date: Tue, 17 Mar 2015 14:53:50 -0700
Message-ID: <CAHA+R7PhYvs2hPgQ1Rj+UjWdASsQq759_8o8125-mvmOKJzWKA@mail.gmail.com>
References: <98364de656ad8034f008999121f57940af767b93.1426619298.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36891 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbbCQVxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 17:53:51 -0400
Received: by igcqo1 with SMTP id qo1so26497254igc.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 14:53:50 -0700 (PDT)
In-Reply-To: <98364de656ad8034f008999121f57940af767b93.1426619298.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2015 at 12:25 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Revisiting commit d23b8ad8ab23 ("tc: add BPF based action") with regards
> to eBPF support, I was thinking that it might be better to improve
> return semantics from a BPF program invoked through BPF_PROG_RUN().
>
> Currently, in case filter_res is 0, we overwrite the default action
> opcode with TC_ACT_SHOT. A default action opcode configured through tc's
> m_bpf can be: TC_ACT_RECLASSIFY, TC_ACT_PIPE, TC_ACT_SHOT, TC_ACT_UNSPEC,
> TC_ACT_OK.
>
> In cls_bpf, we have the possibility to overwrite the default class
> associated with the classifier in case filter_res is _not_ 0xffffffff
> (-1).
>
> That allows us to fold multiple [e]BPF programs into a single one, where
> they would otherwise need to be defined as a separate classifier with
> its own classid, needlessly redoing parsing work, etc.
>
> Similarly, we could do better in act_bpf: Since above TC_ACT* opcodes
> are exported to UAPI anyway, we reuse them for return-code-to-tc-opcode
> mapping, where we would allow above possibilities. Thus, like in cls_bpf,
> a filter_res of 0xffffffff (-1) means that the configured _default_ action
> is used. Any unkown return code from the BPF program would fail in
> tcf_bpf() with TC_ACT_UNSPEC.
>

So you allow bpf bytecode to override the action code specified
in cmdline, I doubt this is user-friendly since if I run different
bytecode I would see different behaviors even if I specify the same
action in cmdline. Allowing cmdline to override bytecode makes
more sense to me.

A even cleaner solution is not to override either of them, that is
either bytecode or cmdline fully controls the action code.
