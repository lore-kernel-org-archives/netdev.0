From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: move inet_dport/inet_num in sock_common
Date: Tue, 27 Nov 2012 20:11:58 -0800
Message-ID: <1354075918.14302.77.camel@edumazet-glaptop>
References: <1354028815.14302.35.camel@edumazet-glaptop>
	 <1354037000.2116.19.camel@joe-AO722>
	 <1354051475.14302.42.camel@edumazet-glaptop>
	 <1354069414.8918.13.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ling Ma <ling.ma.program@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34701 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889Ab2K1EMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 23:12:01 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so9410862pbc.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 20:12:00 -0800 (PST)
In-Reply-To: <1354069414.8918.13.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 18:23 -0800, Joe Perches wrote:

> Still, the logical tests that are likely to be in the same
> cacheline could be ANDed together to avoid a test and jump.

The point of having the cond jump on sk_hash/hash was that in one
compare, we catch the yes/no status with 99.999999 % success rate.

All the following compares are predicted by the cpu and essentially are
free. Adding the AND or OR will basically have the same cpu cost.

If we wanted to do a full test of all tuple fields and a single
conditional jump, we would not have to include hash test at all.

(If the 4-tuple matches, then sk_hash/hash value _must_ be the same by
definition)

Note its quite different from the optimization we did in
ipv6_addr_equal(), as it allowed fewer memory loads and instructions.

I would say this can come later, as the meat of my patch was about
avoiding a full cache line miss, which is far more expensive than any
tricks we can even think about.

Note it will be hard to actually measure any further gains, since I did
TCP_RR tests (200 threads) and the lookup cost went from 1.4 % to 0.8 %
of the grand total, mostly dominated by the atomic to increase socket
refcount.
