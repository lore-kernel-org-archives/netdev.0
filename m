From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipv6 fragmentation-related panic in netfilter
Date: Fri, 1 Nov 2013 09:45:29 +0100
Message-ID: <20131101084529.GL31491@secunet.com>
References: <2060a7d2-c307-4e30-b1d4-0bd26c904d6f@gmail.com>
 <20131030000701.GB25469@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tomas Hlavacek <tmshlvck@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131030000701.GB25469@macbook.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 30, 2013 at 12:07:11AM +0000, Patrick McHardy wrote:
> 
> The problem is that the reassembled packet is referenced by the individual
> fragments, so we trigger the BUG_ON in pskb_expand_head(). In this
> particular case the case we BUG() on is actually OK, but I'm looking at
> a way we can fix this without special casing. Hope to have a patch for
> testing in the next hours.

Just for the record. I'm observing similar, quite reproducable crashes when
receiving fragmented icmp echo request packets on an IPsec gateway with
nf_conntrack_ipv6.

Since git commit 58a317f10 ("netfilter: ipv6: add IPv6 NAT support")
netfilter might insert a reassembled ipv6 packet with a shared skb and
local_df = 1 to the ok function. In case of xfrm, __xfrm6_output()
fragments the packet again and when adjusting the headroom later, we
crash because of a shared skb.

I can fix it by checking for a shared skb in ip6_fragment() and do
slow path fragmentation then. But we never needed such a check in
ip6_fragment(), so it's maybe better to fix it in netfilter.
