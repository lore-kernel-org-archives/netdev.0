From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rxrpc: Kernel calls get stuck in recvmsg
Date: Sun, 26 Feb 2017 21:31:04 -0500 (EST)
Message-ID: <20170226.213104.1497172987206712559.davem@davemloft.net>
References: <148797343389.26520.13921866303222644134.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33282 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdB0CjN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 21:39:13 -0500
In-Reply-To: <148797343389.26520.13921866303222644134.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Fri, 24 Feb 2017 21:57:13 +0000

> Calls made through the in-kernel interface can end up getting stuck because
> of a missed variable update in a loop in rxrpc_recvmsg_data().  The problem
> is like this:
> 
>  (1) A new packet comes in and doesn't cause a notification to be given to
>      the client as there's still another packet in the ring - the
>      assumption being that if the client will keep drawing off data until
>      the ring is empty.
> 
>  (2) The client is in rxrpc_recvmsg_data(), inside the big while loop that
>      iterates through the packets.  This copies the window pointers into
>      variables rather than using the information in the call struct
>      because:
> 
>      (a) MSG_PEEK might be in effect;
> 
>      (b) we need a barrier after reading call->rx_top to pair with the
>      	 barrier in the softirq routine that loads the buffer.
> 
>  (3) The reading of call->rx_top is done outside of the loop, and top is
>      never updated whilst we're in the loop.  This means that even through
>      there's a new packet available, we don't see it and may return -EFAULT
>      to the caller - who will happily return to the scheduler and await the
>      next notification.
> 
>  (4) No further notifications are forthcoming until there's an abort as the
>      ring isn't empty.
> 
> The fix is to move the read of call->rx_top inside the loop - but it needs
> to be done before the condition is checked.
> 
> Reported-by: Marc Dionne <marc.dionne@auristor.com>
> Signed-off-by: David Howells <dhowells@redhat.com>
> Tested-by: Marc Dionne <marc.dionne@auristor.com>

Applied, thanks.
