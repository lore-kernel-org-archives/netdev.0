From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vlan: pull on __vlan_insert_tag error path and fix
 csum correction
Date: Fri, 01 Apr 2016 15:00:00 -0400 (EDT)
Message-ID: <20160401.150000.1165010490623034251.davem@davemloft.net>
References: <244f8d5684800cc98545932aa6851bf73f7326e2.1459503053.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, alexei.starovoitov@gmail.com, jesse@kernel.org,
	tom@herbertland.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbcDATAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 15:00:02 -0400
In-Reply-To: <244f8d5684800cc98545932aa6851bf73f7326e2.1459503053.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  1 Apr 2016 11:41:03 +0200

> Moreover, I noticed that when in the non-error path the __skb_pull()
> is done and the original offset to mac header was non-zero, we fixup
> from a wrong skb->data offset in the checksum complete processing.
> 
> So the skb_postpush_rcsum() really needs to be done before __skb_pull()
> where skb->data still points to the mac header start.

Ugh, what a mess, are you sure any of this is right even after your
change?  What happens (outside of the csum part) is this:

	__skb_push(offset);
	__vlan_insert_tag(); {
		skb_push(VLAN_HLEN);
	...
		memmove(skb->data, skb->data + VLAN_HLEN, 2 * ETH_ALEN);
	}
	__skb_pull(offset);

If I understand this correctly, the last pull will therefore put
skb->data pointing at vlan_ethhdr->h_vlan_TCI of the new VLAN header
pushed by __vlan_insert_tag().

That is assuming skb->data began right after the original ethernet
header.

To me, that postpull csum currently is absolutely in the correct spot,
because it's acting upon the pull done by __vlan_insert_tag(), not the
one done here by skb_vlan_push().

Right?

Can you tell me how you tested this?  Just curious...
