From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] net: sched: run ingress qdisc without locks
Date: Sun, 03 May 2015 22:12:43 -0700
Message-ID: <5546FFCB.50903@plumgrid.com>
References: <1430544448-19777-1-git-send-email-ast@plumgrid.com> <20150503174208.5b1548ba@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34274 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbbEDFMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 01:12:39 -0400
Received: by iget9 with SMTP id t9so60114004ige.1
        for <netdev@vger.kernel.org>; Sun, 03 May 2015 22:12:38 -0700 (PDT)
In-Reply-To: <20150503174208.5b1548ba@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/15 8:42 AM, Jesper Dangaard Brouer wrote:
>
> I was actually expecting to see a higher performance boost.
 > improvement diff     = -2.85 ns
...
> The patch is removing two atomic operations, spin_{un,}lock, which I
> have benchmarked[1] to cost approx 14ns on my system.  Your system
> likely is faster, but not that much (p.s. benchmark your own system
> with [1])
>
> [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_sample.c

have tried you tight loop spin_lock test on my box and it showed:
time_bench: Type:spin_lock_unlock Per elem: 40 cycles(tsc) 11.070 ns
and yet the total single cpu gain from removal of spin_lock/unlock
in ingress path is smaller than 11ns. I think this observation is
telling us that tight loop benchmarking is inherently flawed.
I'm guessing that uops that cmpxchg is broken into can execute in
parallel with uops of other insns, so tight loops of the same sequence
of uops has more alu dependencies whereas in more normal insn flow
these uops can mix and match better. Would be great if intel microarch
experts can chime in.
