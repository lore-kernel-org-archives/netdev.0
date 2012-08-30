From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: ipv4: ipmr_expire_timer causes crash when
 removing net namespace
Date: Thu, 30 Aug 2012 12:52:33 -0400 (EDT)
Message-ID: <20120830.125233.1334599630211579060.davem@davemloft.net>
References: <CA+HUmGhEaTD7QgYyfhDB22K1=Oj3RvDi2Ny217-YFXV03HJzqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fruggeri@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389Ab2H3Qwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 12:52:35 -0400
In-Reply-To: <CA+HUmGhEaTD7QgYyfhDB22K1=Oj3RvDi2Ny217-YFXV03HJzqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Date: Fri, 24 Aug 2012 10:38:35 -0700

> When tearing down a net namespace, ipv4 mr_table structures are freed
> without first deactivating their timers. This can result in a crash in
> run_timer_softirq.
> This patch mimics the corresponding behaviour in ipv6.
> Locking and synchronization seem to be adequate.
> We are about to kfree mrt, so existing code should already make sure that
> no other references to mrt are pending or can be created by incoming traffic.
> The functions invoked here do not cause new references to mrt or other
> race conditions to be created.
> Invoking del_timer_sync guarantees that ipmr_expire_timer is inactive.
> Both ipmr_expire_process (whose completion we may have to wait in
> del_timer_sync) and mroute_clean_tables internally use mfc_unres_lock
> or other synchronizations when needed, and they both only modify mrt.
> 
> Tested in Linux 3.4.8.
> 
> Signed-off-by: Francesco Ruggeri <fruggeri@aristanetworks.com>

Applied, and queued up for -stable, thanks.

I think we have another problem.  mroute_clean_tables() skips MRT_STATIC
cache entries, and does not purge them.

I can't see anything that will ever free those static entries up at all.
