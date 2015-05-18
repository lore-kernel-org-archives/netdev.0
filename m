From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 13/13] xen-netfront: implement RX persistent
 grants
Date: Mon, 18 May 2015 17:04:28 +0100
Message-ID: <555A0D8C.4020309@citrix.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-14-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:1935 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754103AbbERQHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 12:07:07 -0400
In-Reply-To: <1431451117-70051-14-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/15 18:18, Joao Martins wrote:
> It allows a newly allocated skb to reuse the gref taken from the
> pending_ring, which means xennet will grant the pages once and release
> them only when freeing the device. It changes how netfront handles news
> skbs to be able to reuse the allocated pages similarly to how netback
> is already doing for the netback TX path.
> 
> alloc_rx_buffers() will consume pages from the pending_ring to
> allocate new skbs. When responses are handled we will move the grants
> from the grant_rx to the pending_grants. The latter is a shadow ring
> that keeps all grants belonging to inflight skbs. Finally chaining
> all skbs ubuf_info together to finally pass the packet up to the
> network stack. We make use of SKBTX_DEV_ZEROCOPY to get notified
> once the skb is freed to be able to reuse pages. On the destructor
> callback we will then add the grant to the pending_ring.
> 
> The only catch about this approach is: when we orphan frags, there
> will be a memcpy on skb_copy_ubufs() (if frags bigger than 0).
> Depending on the CPU and number of queues this leads to a performance
> drop of between 7-11%. For this reason, SKBTX_DEV_ZEROCOPY skbs will
> only be used with persistent grants.

This means that skbs are passed further up the stack while they are
still granted to the backend.

I think this makes it too difficult to validate that the backend can't
fiddle with the skb frags inappropriately (both now in the the future
when other changes in the network stack are made).

David
