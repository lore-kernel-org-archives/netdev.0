From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next ] mpls: In mpls_egress verify the packet
 length.
Date: Thu, 12 Mar 2015 18:25:58 -0400 (EDT)
Message-ID: <20150312.182558.447886504045770209.davem@davemloft.net>
References: <5500BB5E.4070909@brocade.com>
	<87385a13jz.fsf@x220.int.ebiederm.org>
	<87wq2mym03.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbbCLW0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 18:26:02 -0400
In-Reply-To: <87wq2mym03.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 12 Mar 2015 15:54:52 -0500

> Robert Shearman noticed that mpls_egress is failing to verify that
> the bytes to be examined are in fact present in the packet before
> mpls_egress reads those bytes.
> 
> Reported-by: Robert Shearman <rshearma@brocade.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Let's see if we can consolidate these pskb_may_pull() calls into one,
in the fast path they are relatively cheap but not zero cost.

The caller (mpls_forward()) is doing one as well.

All you care about is the version field and the hop_limit/ttl.

For ipv4, version is in byte 0, and ttl is in byte 9.

For ipv6, version is also in byte zero and hop_limit is in byte 7.

Therefore if you do pskb_may_pull(skb, 10) it will cover all cases
whilst not exceeding the size of either protocol's total header.

Above the pskb_may_pull() call can add a big comment explaining what
you are doing and why this is sufficient.
