From: Roland Dreier <rdreier@cisco.com>
Subject: depending on IPv6 symbols (was: [RFC][PATCH][IPSEC][0/3]inter address family ipsec tunnel)
Date: Tue, 06 Feb 2007 14:43:15 -0800
Message-ID: <adaodo6sy9o.fsf_-_@cisco.com>
References: <20061229144702.11ff0478.kazunori@miyazawa.org>
	<20070206.142407.48395902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kazunori@miyazawa.org, miika@iki.fi, Diego.Beltrami@hiit.fi,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, mst@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:23562 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030210AbXBFWn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 17:43:26 -0500
In-Reply-To: <20070206.142407.48395902.davem@davemloft.net> (David Miller's message of "Tue, 06 Feb 2007 14:24:07 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    David> We see so many issues with ipv6 symbols dependencies in
    David> various subsystems (netfilter, xfrm, etc.).  It is a sign
    David> that we need some kind of long range plan to deal with this
    David> problem.  Since the ipv6 module can't be unloaded anyways,
    David> and it's been broken like that forever, it might make sense
    David> to make ipv6 only available non-modular.  I know people
    David> would dislike this, but the current situation isn't good
    David> either.

Yes, coincidentally I just ran into this problem.  In the context of
reviewing a patch (IPoIB connected mode, which has to deal with
getting too-big packets for a given path) that basically wants to do

#ifdef CONFIG_IPV6
	if (...)
		icmpv6_send(...TOOBIG...)
#endif

I noticed that this exact problem already appears in
net/ipv4/ip_gre.c, which has exactly the same type of code:

#ifdef CONFIG_IPV6
	else if (skb->protocol == htons(ETH_P_IPV6)) {
		struct rt6_info *rt6 = (struct rt6_info*)skb->dst;

		if (rt6 && mtu < dst_mtu(skb->dst) && mtu >= IPV6_MIN_MTU) {
			if ((tunnel->parms.iph.daddr && !MULTICAST(tunnel->parms.iph.daddr)) ||
			    rt6->rt6i_dst.plen == 128) {
				rt6->rt6i_flags |= RTF_MODIFIED;
				skb->dst->metrics[RTAX_MTU-1] = mtu;
			}
		}

		if (mtu >= IPV6_MIN_MTU && mtu < skb->len - tunnel->hlen + gre_hlen) {
			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
			ip_rt_put(rt);
			goto tx_error;
		}
	}
#endif

now obviously this means that if ipv6 is built modular, then the
correct handling for too-big packets will never be used.  But on the
other hand, if we convert the test to

#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)

then building with CONFIG_NET_IPGRE=y and CONFIG_IPV6=m will break,
because icmpv6_send() is no longer built in.  And obviously making
NET_IPGRE depend on IPV6 doesn't make sense.

So I hope we can come up with a short-range plan to deal with the
possibility of built-in code calling icmpv6_send() at least...  As you
said, should we just convert IPV6 to a bool instead of a tristate?

Thanks,
  Roland
