From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next PATCH 3/5] net: introduce XDP driver features
 interface
Date: Fri, 19 May 2017 19:37:26 -0400 (EDT)
Message-ID: <20170519.193726.1790829446714961930.davem@davemloft.net>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
        <149512210317.14733.15039298820296846614.stgit@firesoul>
        <591F27B9.9070003@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, borkmann@iogearbox.net,
        alexei.starovoitov@gmail.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751818AbdESXh3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 19:37:29 -0400
In-Reply-To: <591F27B9.9070003@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 19 May 2017 19:13:29 +0200

> The problem is that once you add bits markers to bpf_prog like we
> used to do in the past, then as you do in patch 4/5 with the
> xdp_rxhash_needed bit, they will need to be turned /on/
> unconditionally when a prog has tail calls.

Yeah that's the problem with feature checks, once you have tail calls
involved we have to say "entire universe" of features is possible
because it is (intentionally) not possible to track all paths
reachable via tail calls, and in fact these paths can dynamically and
arbitrarily change after the program using tail calls have been loaded
and verified completely.

For example, let's assume we have eBPF program A that uses tail calls
via slots in bpf MAP "M".  At verification time, sure, we could see
the MAP "M" points to programs B and C, which don't use tail calls and
look at what features they use.

But after loading "A", anyone with access to bpf MAP "M" can change
the tail call slots to point to bpf programs other than "B" and "C".
And maybe those new programs use features outside of the set we tested
for when "A" was verified.

So it is impossible to test feature "sets" with eBPF like this.
