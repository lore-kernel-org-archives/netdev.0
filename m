From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BUG] netpoll is unable to handle skb's using packet split
Date: Mon, 14 Nov 2005 22:45:45 -0800 (PST)
Message-ID: <20051114.224545.101398810.davem@davemloft.net>
References: <20051114.213922.16377460.davem@davemloft.net>
	<20051114.214130.57199557.davem@davemloft.net>
	<20051115062947.GI31287@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932315AbVKOGpn@vger.kernel.org>
To: mpm@selenic.com
In-Reply-To: <20051115062947.GI31287@waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Mon, 14 Nov 2005 22:29:47 -0800

> Can we make any assumptions about the size and position of fragments.
> For instance, will the first N data bytes of a UDP packet all be in
> the same fragment?

Nope, they can be fragmented any way possible.

For packet parsing, you don't need any of this anyways.
Just use the things that the normal network input stack
uses, for example you could use something like
skb_header_pointer(), or pskb_may_pull().

For example, a clean way to parse a UDP header at the
front of an SKB is:

	struct udphdr *uh, _tmp;

	uh = skb_header_pointer(skb, 0, sizeof(_tmp), &_tmp);
	if (uh->sport = foo && uh->dport == bar)
		...

The UDP input path uses:

	struct udphdr *uh;

	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
		goto header_error;

	uh = skb->h.uh;

Unfortunately, pskb_may_pull() may need to call __pskb_pull_tail()
which in turn might do a pskb_expand_head() and thus a GFP_ATOMIC
memory allocation.
