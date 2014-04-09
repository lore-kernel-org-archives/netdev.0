From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] net: sctp: test if association is dead in
 sctp_wake_up_waiters
Date: Wed, 09 Apr 2014 12:38:22 -0400 (EDT)
Message-ID: <20140409.123822.794558130334051918.davem@davemloft.net>
References: <1397052620-412-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevic@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933100AbaDIQiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 12:38:24 -0400
In-Reply-To: <1397052620-412-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed,  9 Apr 2014 16:10:20 +0200

> In function sctp_wake_up_waiters(), we need to involve a test
> if the association is declared dead. If so, we don't have any
> reference to a possible sibling association anymore and need
> to invoke sctp_write_space() instead, and normally walk the
> socket's associations and notify them of new wmem space. The
> reason for special casing is that otherwise, we could run
> into the following issue when a sctp_primitive_SEND() call
> from sctp_sendmsg() fails, and tries to flush an association's
> outq, i.e. in the following way:
 ...
> Therefore, only walk the list in an 'optimized' way if we find
> that the current association is still active. We could also use
> list_del_init() in addition when we call sctp_association_free(),
> but as Vlad suggests, we want to trap such bugs and thus leave
> it poisoned as is.
> 
> Why is it safe to resolve the issue by testing for asoc->base.dead?
> Parallel calls to sctp_sendmsg() are protected under socket lock,
> that is lock_sock()/release_sock(). Only within that path under
> lock held, we're setting skb/chunk owner via sctp_set_owner_w().
> Eventually, chunks are freed directly by an association still
> under that lock. So when traversing association list on destruction
> time from sctp_wake_up_waiters() via sctp_wfree(), a different
> CPU can't be running sctp_wfree() while another one calls
> sctp_association_free() as both happens under the same lock.
> Therefore, this can also not race with setting/testing against
> asoc->base.dead as we are guaranteed for this to happen in order,
> under lock. Further, Vlad says: the times we check asoc->base.dead
> is when we've cached an association pointer for later processing.
> In between cache and processing, the association may have been
> freed and is simply still around due to reference counts. We check
> asoc->base.dead under a lock, so it should always be safe to check
> and not race against sctp_association_free(). Stress-testing seems
> fine now, too.
> 
> Fixes: cd253f9f357d ("net: sctp: wake up all assocs if sndbuf policy is per socket")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Acked-by: Vlad Yasevich <vyasevic@redhat.com>

Applied and queued up for -stable, thanks!
