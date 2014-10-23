From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 2/3] xen-netback: fix unlimited guest Rx internal queue
 and carrier flapping
Date: Thu, 23 Oct 2014 12:40:17 +0100
Message-ID: <20141023114017.GG9188@zion.uk.xensource.com>
References: <1413983335-8307-1-git-send-email-david.vrabel@citrix.com>
 <1413983335-8307-3-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:47541 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377AbaJWLkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 07:40:18 -0400
Content-Disposition: inline
In-Reply-To: <1413983335-8307-3-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 02:08:54PM +0100, David Vrabel wrote:
> Netback needs to discard old to-guest skb's (guest Rx queue drain) and
> it needs detect guest Rx stalls (to disable the carrier so packets are
> discarded earlier), but the current implementation is very broken.
> 
> 1. The check in hard_start_xmit of the slot availability did not
>    consider the number of packets that were already in the guest Rx
>    queue.  This could allow the queue to grow without bound.
> 
>    The guest stops consuming packets and the ring was allowed to fill
>    leaving S slot free.  Netback queues a packet requiring more than S
>    slots (ensuring that the ring stays with S slots free).  Netback
>    queue indefinately packets provided that then require S or fewer
>    slots.
> 
> 2. The Rx stall detection is not triggered in this case since the
>    (host) Tx queue is not stopped.
> 
> 3. If the Tx queue is stopped and a guest Rx interrupt occurs, netback
>    will consider this an Rx purge event which may result in it taking
>    the carrier down unnecessarily.  It also considers a queue with
>    only 1 slot free as unstalled (even though the next packet might
>    not fit in this).
> 
> The internal guest Rx queue is limited by a byte length (to 512 Kib,
> enough for half the ring).  The (host) Tx queue is stopped and started
> based on this limit.  This sets an upper bound on the amount of memory
> used by packets on the internal queue.
> 
> This allows the estimatation of the number of slots for an skb to be
> removed (it wasn't a very good estimate anyway).  Instead, the guest

+1 for this.

> Rx thread just waits for enough free slots for a maximum sized packet.
> 
> skbs queued on the internal queue have an 'expires' time (set to the
> current time plus the drain timeout).  The guest Rx thread will detect
> when the skb at the head of the queue has expired and discard expired
> skbs.  This sets a clear upper bound on the length of time an skb can
> be queued for.  For a guest being destroyed the maximum time needed to
> wait for all the packets it sent to be dropped is still the drain
> timeout (10 s) since it will not be sending new packets.
> 
> Rx stall detection is reintroduced in a later commit.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>
