From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: fix liveness marking
Date: Fri, 06 Oct 2017 20:20:55 +0200
Message-ID: <59D7C987.101@iogearbox.net>
References: <20171005232056.2234669-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43711 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751489AbdJFSVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 14:21:01 -0400
In-Reply-To: <20171005232056.2234669-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2017 01:20 AM, Alexei Starovoitov wrote:
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

LGTM, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
