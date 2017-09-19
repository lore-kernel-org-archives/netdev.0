From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bpf: fix ri->map_owner pointer on
 bpf_prog_realloc
Date: Tue, 19 Sep 2017 16:39:06 -0700 (PDT)
Message-ID: <20170919.163906.470248374127437464.davem@davemloft.net>
References: <19ba0964a02127c74fbf6fb41f06ab68117d9989.1505860401.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, ast@kernel.org, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51342 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751471AbdISXjH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:39:07 -0400
In-Reply-To: <19ba0964a02127c74fbf6fb41f06ab68117d9989.1505860401.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 20 Sep 2017 00:44:21 +0200

> Commit 109980b894e9 ("bpf: don't select potentially stale
> ri->map from buggy xdp progs") passed the pointer to the prog
> itself to be loaded into r4 prior on bpf_redirect_map() helper
> call, so that we can store the owner into ri->map_owner out of
> the helper.
> 
> Issue with that is that the actual address of the prog is still
> subject to change when subsequent rewrites occur that require
> slow path in bpf_prog_realloc() to alloc more memory, e.g. from
> patching inlining helper functions or constant blinding. Thus,
> we really need to take prog->aux as the address we're holding,
> which also works with prog clones as they share the same aux
> object.
> 
> Instead of then fetching aux->prog during runtime, which could
> potentially incur cache misses due to false sharing, we are
> going to just use aux for comparison on the map owner. This
> will also keep the patchlet of the same size, and later check
> in xdp_map_invalid() only accesses read-only aux pointer from
> the prog, it's also in the same cacheline already from prior
> access when calling bpf_func.
> 
> Fixes: 109980b894e9 ("bpf: don't select potentially stale ri->map from buggy xdp progs")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  v1->v2:
>   - Decided to go with prog->aux instead.

Applied, thanks Daniel.
