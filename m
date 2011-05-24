From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Tue, 24 May 2011 16:01:23 -0400 (EDT)
Message-ID: <20110524.160123.2051949867829317339.davem@davemloft.net>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932674Ab1EXUBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 16:01:25 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4OK1NKs004695
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 13:01:24 -0700
In-Reply-To: <20110517.143342.1566027350038182221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 17 May 2011 14:33:42 -0400 (EDT)

> 
> It seems to me that we can solve the UDP fragmentation problem for
> flow steering very simply by creating a (saddr/daddr/IPID) entry in a
> table that maps to the corresponding RPS flow entry.
> 
> When we see the initial frag with the UDP header, we create the
> saddr/daddr/IPID mapping, and we tear it down when we hit the
> saddr/daddr/IPID mapping and the packet has the IP_MF bit clear.
> 
> We only inspect the saddr/daddr/IPID cache when iph->frag_off is
> non-zero.

So I looked into implementing this now that it has been established
that we changed even Linux to emit fragments in-order.

The first problem we run into is that there is no "context" we can
use in all the places where skb_get_rxhash() gets called.

Part of the problem is that we call it from strange places, such as
egress packet schedulers.  That's completely bogus.

Examples, FLOW classifier, META e-match, CHOKE, and SFB.

In fact, for the classifiers this means they aren't making use of the
precomputed TX hash values in the sockets like __skb_tx_hash() will
make use of.  So this makes these packet schedulers operate
potentially more expensively than they need to.

If we could get rid of those silly cases, the stuff that remains
(macvtap and net/core/dev.c) could work with a NAPI context during
rxhash computation and use that to store the IP fragmentation
on-behind cached information.
