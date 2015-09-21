From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp/dccp: fix timewait races in timer handling
Date: Mon, 21 Sep 2015 16:32:45 -0700 (PDT)
Message-ID: <20150921.163245.1066159200155037848.davem@davemloft.net>
References: <1442678914.29850.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycai@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbbIUXcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:32:46 -0400
In-Reply-To: <1442678914.29850.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 Sep 2015 09:08:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When creating a timewait socket, we need to arm the timer before
> allowing other cpus to find it. The signal allowing cpus to find
> the socket is setting tw_refcnt to non zero value.
> 
> As we set tw_refcnt in __inet_twsk_hashdance(), we therefore need to
> call inet_twsk_schedule() first.
> 
> This also means we need to remove tw_refcnt changes from
> inet_twsk_schedule() and let the caller handle it.
> 
> Note that because we use mod_timer_pinned(), we have the guarantee
> the timer wont expire before we set tw_refcnt as we run in BH context.
> 
> To make things more readable I introduced inet_twsk_reschedule() helper.
> 
> When rearming the timer, we can use mod_timer_pending() to make sure
> we do not rearm a canceled timer.
> 
> Note: This bug can possibly trigger if packets of a flow can hit
> multiple cpus. This does not normally happen, unless flow steering
> is broken somehow. This explains this bug was spotted ~5 months after
> its introduction.
> 
> A similar fix is needed for SYN_RECV sockets in reqsk_queue_hash_req(),
> but will be provided in a separate patch for proper tracking.
> 
> Fixes: 789f558cfb36 ("tcp/dccp: get rid of central timewait timer")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Ying Cai <ycai@google.com>

Applied and queued up for -stable.
