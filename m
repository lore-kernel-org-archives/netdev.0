From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 1/1] tipc: fix a race condition leading to
 subscriber refcnt bug
Date: Thu, 14 Apr 2016 16:47:16 -0400 (EDT)
Message-ID: <20160414.164716.663524805527628179.davem@davemloft.net>
References: <1460459121-2403-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbcDNUrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 16:47:18 -0400
In-Reply-To: <1460459121-2403-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Tue, 12 Apr 2016 13:05:21 +0200

> Until now, the requests sent to topology server are queued
> to a workqueue by the generic server framework.
> These messages are processed by worker threads and trigger the
> registered callbacks.
> To reduce latency on uniprocessor systems, explicit rescheduling
> is performed using cond_resched() after MAX_RECV_MSG_COUNT(25)
> messages.
> 
> This implementation on SMP systems leads to an subscriber refcnt
> error as described below:
> When a worker thread yields by calling cond_resched() in a SMP
> system, a new worker is created on another CPU to process the
> pending workitem. Sometimes the sleeping thread wakes up before
> the new thread finishes execution.
> This breaks the assumption on ordering and being single threaded.
> The fault is more frequent when MAX_RECV_MSG_COUNT is lowered.
> 
> If the first thread was processing subscription create and the
> second thread processing close(), the close request will free
> the subscriber and the create request oops as follows:
 ...
> In this commit, we
> - rename tipc_conn_shutdown() to tipc_conn_release().
> - move connection release callback execution from tipc_close_conn()
>   to a new function tipc_sock_release(), which is executed before
>   we free the connection.
> Thus we release the subscriber during connection release procedure
> rather than connection shutdown procedure.
> 
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.
