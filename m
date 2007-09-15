From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPV4 : convert rt_check_expire() from softirq
 processing to workqueue
Date: Sat, 15 Sep 2007 10:58:08 -0700 (PDT)
Message-ID: <20070915.105808.15258300.davem@davemloft.net>
References: <20070912153444.bb564a6f.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:49072
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751919AbXIOR7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2007 13:59:20 -0400
In-Reply-To: <20070912153444.bb564a6f.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 12 Sep 2007 15:34:44 +0200

> On loaded/big hosts, rt_check_expire() if of litle use, because it
> generally breaks out of its main loop because of a jiffies change.
> 
> It can take a long time (read : timer invocations) to actually
> scan the whole hash table, freeing unused entries.
> 
> Converting it to use a workqueue instead of softirq is a nice
> move because we can allow rt_check_expire() to do the scan
> it is supposed to do, without hogging the CPU.
> 
> This has an impact on the average number of entries in cache, 
> reducing ram usage. Cache is more responsive to parameter
> changes (/proc/sys/net/ipv4/route/gc_timeout and
> /proc/sys/net/ipv4/route/gc_interval)
> 
> Note: Maybe the default value of gc_interval (60 seconds)
> is too high, since this means we actually need 5 (300/60)
> invocations to scan the whole table.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.  I'm rebasing my net-2.6.24 tree over the
weekend so it may take a little time for this to show up.

It just occurred to me that we need to fix something in these two
workqueue conversions.  If it runs for more than a jiffy this can
unfairly penalize other tasks that want to run on that cpu.

Therefore, we need to add a need_resched() or similar check in the
loop.
