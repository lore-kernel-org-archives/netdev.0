From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: adjust verifier heuristics
Date: Wed, 17 May 2017 22:56:37 -0400 (EDT)
Message-ID: <20170517.225637.2083628580374404255.davem@davemloft.net>
References: <57a6fc1f937d985a5851016221c98a29fb1cc46a.1495068621.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753717AbdERC4l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 22:56:41 -0400
In-Reply-To: <57a6fc1f937d985a5851016221c98a29fb1cc46a.1495068621.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 18 May 2017 03:00:06 +0200

> Current limits with regards to processing program paths do not
> really reflect today's needs anymore due to programs becoming
> more complex and verifier smarter, keeping track of more data
> such as const ALU operations, alignment tracking, spilling of
> PTR_TO_MAP_VALUE_ADJ registers, and other features allowing for
> smarter matching of what LLVM generates.
> 
> This also comes with the side-effect that we result in fewer
> opportunities to prune search states and thus often need to do
> more work to prove safety than in the past due to different
> register states and stack layout where we mismatch. Generally,
> it's quite hard to determine what caused a sudden increase in
> complexity, it could be caused by something as trivial as a
> single branch somewhere at the beginning of the program where
> LLVM assigned a stack slot that is marked differently throughout
> other branches and thus causing a mismatch, where verifier
> then needs to prove safety for the whole rest of the program.
> Subsequently, programs with even less than half the insn size
> limit can get rejected. We noticed that while some programs
> load fine under pre 4.11, they get rejected due to hitting
> limits on more recent kernels. We saw that in the vast majority
> of cases (90+%) pruning failed due to register mismatches. In
> case of stack mismatches, majority of cases failed due to
> different stack slot types (invalid, spill, misc) rather than
> differences in spilled registers.
> 
> This patch makes pruning more aggressive by also adding markers
> that sit at conditional jumps as well. Currently, we only mark
> jump targets for pruning. For example in direct packet access,
> these are usually error paths where we bail out. We found that
> adding these markers, it can reduce number of processed insns
> by up to 30%. Another option is to ignore reg->id in probing
> PTR_TO_MAP_VALUE_OR_NULL registers, which can help pruning
> slightly as well by up to 7% observed complexity reduction as
> stand-alone. Meaning, if a previous path with register type
> PTR_TO_MAP_VALUE_OR_NULL for map X was found to be safe, then
> in the current state a PTR_TO_MAP_VALUE_OR_NULL register for
> the same map X must be safe as well. Last but not least the
> patch also adds a scheduling point and bumps the current limit
> for instructions to be processed to a more adequate value.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Ok, applied, but we should continue trying to make the pruner
more effective.
