From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix range propagation on direct packet
 access
Date: Thu, 08 Sep 2016 17:29:02 -0700 (PDT)
Message-ID: <20160908.172902.269216777256016170.davem@davemloft.net>
References: <114cf30cb121f3b246d5e1dd436208b6dd675e32.1473288722.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43004 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbcIIA3D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:29:03 -0400
In-Reply-To: <114cf30cb121f3b246d5e1dd436208b6dd675e32.1473288722.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu,  8 Sep 2016 01:03:42 +0200

> LLVM can generate code that tests for direct packet access via
> skb->data/data_end in a way that currently gets rejected by the
> verifier, example:
 ...
> The reason why this gets rejected despite a proper test is that we
> currently call find_good_pkt_pointers() only in case where we detect
> tests like rX > pkt_end, where rX is of type pkt(id=Y,off=Z,r=0) and
> derived, for example, from a register of type pkt(id=Y,off=0,r=0)
> pointing to skb->data. find_good_pkt_pointers() then fills the range
> in the current branch to pkt(id=Y,off=0,r=Z) on success.
> 
> For above case, we need to extend that to recognize pkt_end >= rX
> pattern and mark the other branch that is taken on success with the
> appropriate pkt(id=Y,off=0,r=Z) type via find_good_pkt_pointers().
> Since eBPF operates on BPF_JGT (>) and BPF_JGE (>=), these are the
> only two practical options to test for from what LLVM could have
> generated, since there's no such thing as BPF_JLT (<) or BPF_JLE (<=)
> that we would need to take into account as well.
> 
> After the fix:
 ...
> Verifier test cases are also added in this work, one that demonstrates
> the mentioned example here and one that tries a bad packet access for
> the current/fall-through branch (the one with types pkt(id=X,off=Y,r=0),
> pkt(id=X,off=0,r=0)), then a case with good and bad accesses, and two
> with both test variants (>, >=).
> 
> Fixes: 969bf05eb3ce ("bpf: direct packet access")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied to net-next, thanks.
