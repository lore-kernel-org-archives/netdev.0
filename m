From: Patrick McHardy <kaber@trash.net>
Subject: Re: Bridge + Conntrack + SKB Recycle: Fragment Reassembly Errors
Date: Sun, 22 Nov 2009 01:21:17 +0100
Message-ID: <4B0883FD.2090806@trash.net>
References: <767BAF49E93AFB4B815B11325788A8ED45F0BA@L01SLCXDB03.calltower.com>	<4AF999DE.9060206@trash.net> <20091121.110832.213888237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: ben@bigfootnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36589 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbZKVAVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 19:21:14 -0500
In-Reply-To: <20091121.110832.213888237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 10 Nov 2009 17:50:38 +0100
> 
>> This code in ip_fragment() looks suspicious:
>>
>> 	if (skb_has_frags(skb)) {
>> 	...
>> 		skb_walk_frags(skb, frag) {
>> 			...
>> 			if (skb->sk) {
>> 				frag->sk = skb->sk;
>> 				frag->destructor = sock_wfree;
>> 				truesizes += frag->truesize;
>> 			}
>>
>> truesizes is later used to adjust truesize of the head skb.
>> For some reason this is only done when it originated from a
>> local socket.
> 
> Well, it shouldn't look _that_ suspicious.
> 
> What this code is doing is making sure that after we make all of these
> changes, the truesize of the SKBs referrng to the socket do not
> change.
> 
> It's simply making sure that the math works out when all the
> sock_wfree() calls occur later.
> 
> If we don't have a socket involved, there is no reason to make
> these adjustments.

That seems to be the assumption. But ip_defrag() uses skb->truesize
as well to make sure the defragmentation memory limits are not exceeded.
In this case what seems to be happening is:

- gianfar with skb recycling enabled receives a number of fragments
  on a bridge (~64000b total)

- conntrack defragments the packet using ip_defrag(), which causes
  skb->truesize of the head fragment to account for all the fragments

- the packet is refragmented in the bridging code using ip_fragment().
  This doesn't re-adjust skb->truesize of the head fragment when the
  packet is not associated with a socket

- the head is recycled in gianfar

- another fragment is received and reuses the recycled skb with a
  huge truesize

- the defragmentation limits are exceeded due to the huge truesize

So it seems we need to adjust skb->truesize in ip_fragment() since
skb_recycle_check() assumes the skb is linear (and therefore
skb->truesize reflects the linear size). Ben's suggestions of adding
an upper limit based on the requested size to skb_recycle_check()
makes sense to me as well to avoid this problem when recycling large
linear skbs.
