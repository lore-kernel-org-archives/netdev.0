From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Fix wildcard as tunnel source
Date: Mon, 18 Sep 2006 09:51:21 +0200
Message-ID: <450E4FF9.9030406@trash.net>
References: <44F99954.1040606@trash.net> <20060918.001904.105429466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36487 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964882AbWIRHuf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:50:35 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060918.001904.105429466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Unfortunately, this break scalability of the xfrm state layer when the
> source is equally as varying as the destination.  In such setups you
> have an enormous number of entries with destination being the local
> system and only the source address changing.
> 
> BTW, how can the source be specified as wildcard?  There is no prefix
> component, it is simply an xfrm_address_t.  And there are several
> macros which check for x->props.saddr equality directly with no
> special prefixing or wildcard logic.

The tunnel endpoint in the template (either source or destination,
depending on the direction) is set to 0.0.0.0. For outbound SAs,
the address is compared using xfrm_state_addr_check(), which interprets
0.0.0.0 as wildcard. When no matching SA is present, the address
is resolved using routing and filled in the ACQ SA. The keying daemon
will then install SAs with the proper source. For inbound SAs the
tunnel destination from the template is ignored.

> I really don't want to remove this as it's fairly critical performance
> wise for the scalability problems all my changes were meant to address.
> I hope I really don't have to do something like what was needed for
> the policy layer, having a linked list and a hash table to handle the
> two cases.

We could query the address before the SA lookup. It will cost an
additional route lookup in case a matching SA is already present,
but I guess thats still better than removing the source from the
hash. I'll try if it works and send a new patch.

