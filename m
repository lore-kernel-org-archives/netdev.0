From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : convert IP route cache garbage colleciton from
 softirq processing to a workqueue
Date: Wed, 12 Sep 2007 02:05:25 -0700 (PDT)
Message-ID: <20070912.020525.39165997.davem@davemloft.net>
References: <20070911145613.4762c534.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:54838
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759807AbXILJGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 05:06:49 -0400
In-Reply-To: <20070911145613.4762c534.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 11 Sep 2007 14:56:13 +0200

> When the periodic IP route cache flush is done (every 600 seconds on 
> default configuration), some hosts suffer a lot and eventually trigger
> the "soft lockup" message.
> 
> dst_run_gc() is doing a scan of a possibly huge list of dst_entries,
> eventually freeing some (less than 1%) of them, while holding the 
> dst_lock spinlock for the whole scan.
> 
> Then it rearms a timer to redo the full thing 1/10 s later...
> The slowdown can last one minute or so, depending on how active are
> the tcp sessions.
> 
> This second version of the patch converts the processing from a softirq
> based one to a workqueue.
> 
> Even if the list of entries in garbage_list is huge, host is still
> responsive to softirqs and can make progress.
> 
> Instead of reseting gc timer to 0.1 second if one entry was freed in a
> gc run, we do this if more than 10% of entries were freed.

I like this patch a lot, some minor fix is needed though:

> +		__builtin_prefetch(&next->next, 1, 0);

Please use prefetch() instead of a direct explicit
call to a gcc-specific routine :-)
