From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RxRPC: Fix a potential deadlock between the call
 resend_timer and state_lock
Date: Wed, 04 Aug 2010 21:55:10 -0700 (PDT)
Message-ID: <20100804.215510.258099641.davem@davemloft.net>
References: <20100804123417.29580.95095.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59449
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756069Ab0HEEyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 00:54:51 -0400
In-Reply-To: <20100804123417.29580.95095.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Wed, 04 Aug 2010 13:34:17 +0100

> RxRPC can potentially deadlock as rxrpc_resend_time_expired() wants to get
> call->state_lock so that it can alter the state of an RxRPC call.  However, its
> caller (call_timer_fn()) has an apparent lock on the timer struct.
> 
> The problem is that rxrpc_resend_time_expired() isn't permitted to lock
> call->state_lock as this could cause a deadlock against rxrpc_send_abort() as
> that takes state_lock and then attempts to delete the resend timer by calling
> del_timer_sync().
> 
> The deadlock can occur because del_timer_sync() will sit there forever waiting
> for rxrpc_resend_time_expired() to return, but the latter may then wait for
> call->state_lock, which rxrpc_send_abort() holds around del_timer_sync()...
> 
> This leads to a warning appearing in the kernel log that looks something like
> the attached.
> 
> It should be sufficient to simply dispense with the locks.  It doesn't matter
> if we set the resend timer expired event bit and queue the event processor
> whilst we're changing state to one where the resend timer is irrelevant as the
> event can just be ignored by the processor thereafter.
 ...
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks!
