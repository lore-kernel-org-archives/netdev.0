From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Question about potential problem in net/ipv4/route.c
Date: Wed, 11 Oct 2006 22:05:06 -0700 (PDT)
Message-ID: <20061011.220506.76273501.davem@davemloft.net>
References: <20061011090504.GC2938@mellanox.co.il>
	<20061011.022015.63051509.davem@davemloft.net>
	<200610111511.19028.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2759
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965269AbWJLFE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 01:04:59 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200610111511.19028.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 11 Oct 2006 15:11:18 +0200

> Using memcmp(ptr1, ptr2, sizeof(SOMEFIELD)) is dangerous because 
> sizeof(SOMEFIELD) can be larger than the underlying object, because of 
> alignment constraints.
> 
> In this case, sizeof(fl1->nl_u.ip4_u) is 16, while fl1->nl_u.ip4_u is :
> 
>                 struct {
>                         __u32                   daddr;
>                         __u32                   saddr;
>                         __u32                   fwmark;
>                         __u8                    tos;
>                         __u8                    scope;
>                 } ip4_u;
> 
> So 14 bytes are really initialized, and 2 padding bytes might contain random 
> values...

We always explicitly initialize the flows, and even for local stack
assignment based initialization, gcc zeros out the padding bytes
always.  For non-stack-local cases we do explicit memset()'s over the
entire object.  So I think while not perfect, we're very much safe
here.

> fast comparison, we should do some clever long/int XOR operations to avoid 
> many test/branches, like the optim we did in compare_ether_addr())
> 
> As shown in profiles, "repz cmpsb" is really a dog... (and its use of 
> esi/edi/ecx registers a high pressure for the compiler/optimizer)

Yes, for the fast comparisons it is almost certainly worth it to do
something saner in compare_keys().

But looking at this further, compare_keys() is only used in hotpath
situations where we are optimizing for a miss, such as during hash
insert.  The optimization therefore might be less justified as a
result.
