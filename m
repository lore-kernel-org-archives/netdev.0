From: David Miller <davem@davemloft.net>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Wed, 03 Jun 2009 22:41:04 -0700 (PDT)
Message-ID: <20090603.224104.222901210.davem@davemloft.net>
References: <alpine.DEB.1.10.0906021044430.15692@gentwo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org, yosefe@Voltaire.COM
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40436
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751493AbZFDFlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 01:41:04 -0400
In-Reply-To: <alpine.DEB.1.10.0906021044430.15692@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Tue, 2 Jun 2009 10:49:21 -0400 (EDT)

> IPoIB: Fix multicast packet drops before join is complete
> 
> The IPoIB layer drops multicast packets after queueing 3 as long as a
> multicast group is not ready. The multicast group not being ready may
> occur on first use or after a period of silence on a MC group.
> 
> What should happen is that packet are queued up until the maximum queue
> size is reached (set by sk_sndbuf). Then the socket layer would put
> the sending process to sleep until space in the queue becomes available
> (after the multicast group becomes ready and after the initial messages
> have been sent).
> 
> With the IPoIB layer dropping packets this does not occur. The process
> can continue sending multicast packets and they are all dropped until
> the multicast group becomes ready. The receiver will see the initial 3
> multicast packets that have been significantly delayed, then a large
> gap of missing packet before getting packets that have not been delayed.
> 
> After this patch the socket queue will build up and the sender will be
> throttled until the MC group becomes ready.
> 
> If old behavior is desired then the application can configure
> the send queue size to only allow 3 packet and specify MSG_DONTWAIT
> for send operations.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

I don't think using an infinite backlog for this is wise.

We don't do this for ARP, for example.  We have a 3 packet limit just
like IPoIB implements for multicast here.

I'm all for increasing those limits, but eliminating them I cannot
agree with.
