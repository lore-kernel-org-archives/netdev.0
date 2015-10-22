From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: extend broadcast link window size
Date: Wed, 21 Oct 2015 19:02:55 -0700 (PDT)
Message-ID: <20151021.190255.1998128389997821704.davem@davemloft.net>
References: <1445260897-27445-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286AbbJVBq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 21:46:29 -0400
In-Reply-To: <1445260897-27445-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon, 19 Oct 2015 09:21:37 -0400

> The default fix broadcast window size is currently set to 20 packets.
> This is a very low value, set at a time when we were still testing on
> 10 Mb/s hubs, and a change to it is long overdue.
> 
> Commit 7845989cb4b3da1db ("net: tipc: fix stall during bclink wakeup procedure")
> revealed a problem with this low value. For messages of importance LOW,
> the backlog queue limit will be  calculated to 30 packets, while a
> single, maximum sized message of 66000 bytes, carried across a 1500 MTU
> network consists of 46 packets.
> 
> This leads to the following scenario (among others leading to the same
> situation):
> 
> 1: Msg 1 of 46 packets is sent. 20 packets go to the transmit queue, 26
>    packets to the backlog queue.
> 2: Msg 2 of 46 packets is attempted sent, but rejected because there is
>    no more space in the backlog queue at this level. The sender is added
>    to the wakeup queue with a "pending packets chain size" number of 46.
> 3: Some packets in the transmit queue are acked and released. We try to
>    wake up the sender, but the pending size of 46 is bigger than the LOW
>    wakeup limit of 30, so this doesn't happen.
> 5: Subsequent acks releases all the remaining buffers. Each time we test
>    for the wakeup criteria and find that 46 still is larger than 30,
>    even after both the transmit and the backlog queues are empty.
> 6: The sender is never woken up and given a chance to send its message.
>    He is stuck.
> 
> We could now loosen the wakeup criteria (used by link_prepare_wakeup())
> to become equal to the send criteria (used by tipc_link_xmit()), i.e.,
> by ignoring the "pending packets chain size" value altogether, or we can
> just increase the queue limits so that the criteria can be satisfied
> anyway. There are good reasons (potentially multiple waiting senders) to
> not opt for the former solution, so we choose the latter one.
> 
> This commit fixes the problem by giving the broadcast link window a
> default value of 50 packets. We also introduce a new minimum link
> window size BCLINK_MIN_WIN of 32, which is enough to always avoid the
> described situation. Finally, in order to not break any existing users
> which may set the window explicitly, we enforce that the window is set
> to the new minimum value in case the user is trying to set it to
> anything lower.
> 
> Fixes: 7845989cb4b3da1db ("net: tipc: fix stall during bclink wakeup procedure")
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks Jon.
