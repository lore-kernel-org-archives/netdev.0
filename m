From: David Miller <davem@davemloft.net>
Subject: Re: Leak in ipv6_gso_segment()?
Date: Fri, 02 Jun 2017 14:05:06 -0400 (EDT)
Message-ID: <20170602.140506.1833605091602891315.davem@davemloft.net>
References: <1496233562.3992.10.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kraig@google.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45882 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdFBSFI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:05:08 -0400
In-Reply-To: <1496233562.3992.10.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 31 May 2017 13:26:02 +0100

> If I'm not mistaken, ipv6_gso_segment() now leaks segs if
> ip6_find_1stfragopt() fails.  I'm not sure whether the fix would be as
> simple as adding a kfree_skb(segs) or whether more complex cleanup is
> needed.

I think we need to use kfree_skb_list(), like the following.

Can someone please audit and review this for me?  We need to
get this to -stable.

Thanks.

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 280268f..cdb3728 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -116,8 +116,10 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 
 		if (udpfrag) {
 			int err = ip6_find_1stfragopt(skb, &prevhdr);
-			if (err < 0)
+			if (err < 0) {
+				kfree_skb_list(segs);
 				return ERR_PTR(err);
+			}
 			fptr = (struct frag_hdr *)((u8 *)ipv6h + err);
 			fptr->frag_off = htons(offset);
 			if (skb->next)
