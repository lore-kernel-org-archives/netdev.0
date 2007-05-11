From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 13:00:48 +0530
Message-ID: <OFA0B8100C.1A34288C-ON652572D8.002808B3-652572D8.002945CB@in.ibm.com>
References: <adazm4czaxt.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:56804 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143AbXEKHb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 03:31:57 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4B7Xdgr7925766
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 17:33:39 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B7ZMqR016392
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 17:35:24 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B7Vpk2008290
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 17:31:51 +1000
In-Reply-To: <adazm4czaxt.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Roland,

Roland Dreier <rdreier@cisco.com> wrote on 05/11/2007 01:51:50 AM:

> This is pretty interesting to me for IP-over-InfiniBand, for a couple
> of reasons.  First of all, I can push multiple send requests to the
> underlying adapter in one go, which saves taking and dropping the same
> lock and also probably allows fewer MMIO writes for doorbells.
>
> However the second reason this is useful is actually more
> interesting.  Right now we request a send completion interrupt for
> every packet we send because most current IB adapters don't really
> have very good interrupt mitigation features.  If we don't signal a
> send completion for every packet, then we might run into a situation
> where we don't get a completion for the last packet that gets sent and
> end up stalling the interface because the stack never gives us another
> packet to send.  However, if I have a whole queue of packets passed to
> my xmit routine, then I only have to request a completion for the last
> packet in the list, which could potentially cut down on interrupts and
> completion processing a lot.

Sounds a good idea. I had a question on error handling. What happens if
the driver asynchronously returns an error for this WR (single WR
containing multiple skbs) ? Does it mean all the skbs failed to be sent ?
Requeuing all of them is a bad idea since it leads to infinitely doing the
same thing, so should every skb be free'd ? Isn't that harsh (if first skb
is bad and others are fine) and how do we avoid that ? Infact we don't
know which skb was transmitted and which failed. If we requeue skbs,
there will also be out-of-order skbs as the callback is asynchronous.

Thanks,

- KK

