From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix liveness marking
Date: Sat, 07 Oct 2017 23:29:11 +0100 (WEST)
Message-ID: <20171007.232911.831489164694199337.davem@davemloft.net>
References: <20171005232056.2234669-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ecree@solarflare.com, netdev@vger.kernel.org,
        kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43144 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752685AbdJGW32 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 18:29:28 -0400
In-Reply-To: <20171005232056.2234669-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 5 Oct 2017 16:20:56 -0700

> while processing Rx = Ry instruction the verifier does
> regs[insn->dst_reg] = regs[insn->src_reg]
> which often clears write mark (when Ry doesn't have it)
> that was just set by check_reg_arg(Rx) prior to the assignment.
> That causes mark_reg_read() to keep marking Rx in this block as
> REG_LIVE_READ (since the logic incorrectly misses that it's
> screened by the write) and in many of its parents (until lucky
> write into the same Rx or beginning of the program).
> That causes is_state_visited() logic to miss many pruning opportunities.
> 
> Furthermore mark_reg_read() logic propagates the read mark
> for BPF_REG_FP as well (though it's readonly) which causes
> harmless but unnecssary work during is_state_visited().
> Note that do_propagate_liveness() skips FP correctly,
> so do the same in mark_reg_read() as well.
> It saves 0.2 seconds for the test below
> 
> program               before  after
> bpf_lb-DLB_L3.o       2604    2304
> bpf_lb-DLB_L4.o       11159   3723
> bpf_lb-DUNKNOWN.o     1116    1110
> bpf_lxc-DDROP_ALL.o   34566   28004
> bpf_lxc-DUNKNOWN.o    53267   39026
> bpf_netdev.o          17843   16943
> bpf_overlay.o         8672    7929
> time                  ~11 sec  ~4 sec
> 
> Fixes: dc503a8ad984 ("bpf/verifier: track liveness for pruning")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Looks great, applied.
