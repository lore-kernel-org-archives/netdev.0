From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Thu, 26 Jun 2014 13:43:35 -0700 (PDT)
Message-ID: <20140626.134335.2147671135749217539.davem@davemloft.net>
References: <87d2dwsfh6.fsf@x220.int.ebiederm.org>
	<CAM_iQpVeVpcQLPz7GDuni_v5+bJikQkc2cSzrKee72eGuOecDQ@mail.gmail.com>
	<87lhskpizv.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	stephen@networkplumber.org, cwang@twopensource.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbaFZUnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 16:43:37 -0400
In-Reply-To: <87lhskpizv.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 25 Jun 2014 18:17:08 -0700

> I disagree that removing a global DOS prevention check is a benefit.
> Certainly large semantics changes like that should not happen without
> being discussed in the patch description.

Agreed, this is the most important core issue.

If we just make these things per netns, then as a result if you create
N namespaces we will allow N times more neighbour entries to be
sitting in the system at once.

Actually, I'm really surprised the limits get hit and this actually
causes problems.

This is simply because we don't cache neighbour table entries in route
entries any more.  They are only passively referenced during packet
output, and with no reference taken.

See net/ipv4/ip_output.c:ip_finish_output2() where it goes:

	rcu_read_lock_bh();
	nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
	if (unlikely(!neigh))
		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
	if (!IS_ERR(neigh)) {
		int res = dst_neigh_output(dst, neigh, skb);

		rcu_read_unlock_bh();
		return res;
	}
	rcu_read_unlock_bh();

Nearly identical code lives in net/ipv6/ip6_output.c:ip6_finish_output2()

So nothing is even holding onto neigh entries any more, they are trivially
recycled when demand increases and the thresholds are hit.
