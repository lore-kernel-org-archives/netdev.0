From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 1/1] tipc: Revert "tipc: use existing
 sk_write_queue for outgoing packet chain"
Date: Thu, 03 Mar 2016 16:31:32 -0500 (EST)
Message-ID: <20160303.163132.47349805818342485.davem@davemloft.net>
References: <1456826829-21701-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787AbcCCVbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 16:31:34 -0500
In-Reply-To: <1456826829-21701-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Tue, 1 Mar 2016 11:07:09 +0100

> reverts commit 94153e36e709e ("tipc: use existing sk_write_queue for
> outgoing packet chain")
> 
> In Commit 94153e36e709e, we assume that we fill & empty the socket's
> sk_write_queue within the same lock_sock() session.
> 
> This is not true if the link is congested. During congestion, the
> socket lock is released while we wait for the congestion to cease.
> This implementation causes a nullptr exception, if the user space
> program has several threads accessing the same socket descriptor.
> 
> Consider two threads of the same program performing the following:
>      Thread1                                  Thread2
> --------------------                    ----------------------
> Enter tipc_sendmsg()                    Enter tipc_sendmsg()
> lock_sock()                             lock_sock()
> Enter tipc_link_xmit(), ret=ELINKCONG   spin on socket lock..
> sk_wait_event()                             :
> release_sock()                          grab socket lock
>     :                                   Enter tipc_link_xmit(), ret=0
>     :                                   release_sock()
> Wakeup after congestion
> lock_sock()
> skb = skb_peek(pktchain);
> !! TIPC_SKB_CB(skb)->wakeup_pending = tsk->link_cong;
> 
> In this case, the second thread transmits the buffers belonging to
> both thread1 and thread2 successfully. When the first thread wakeup
> after the congestion it assumes that the pktchain is intact and
> operates on the skb's in it, which leads to the following exception:
...
> In this commit, we maintain the skb list always in the stack.
> 
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>

Applied and queued up for -stable, thanks.
