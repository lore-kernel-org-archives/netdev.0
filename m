From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix IP early demux races
Date: Mon, 14 Dec 2015 23:52:27 -0500 (EST)
Message-ID: <20151214.235227.679144571237513640.davem@davemloft.net>
References: <20151214112802.Horde.BK3A-grfQxyYIrszzKdCZg1@ltc.linux.ibm.com>
	<1450110986.8474.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<1450130933.8474.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwilder@us.ibm.com, netdev@vger.kernel.org, predeep@us.ibm.com,
	mjtarsel@us.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933146AbbLOEw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 23:52:29 -0500
In-Reply-To: <1450130933.8474.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Dec 2015 14:08:53 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> David Wilder reported crashes caused by dst reuse.
> 
> <quote David>
>   I am seeing a crash on a distro V4.2.3 kernel caused by a double
>   release of a dst_entry.  In ipv4_dst_destroy() the call to  
>   list_empty() finds a poisoned next pointer, indicating the dst_entry  
>   has already been removed from the list and freed. The crash occurs  
>   18 to 24 hours into a run of a network stress exerciser.
> </quote>
> 
> Thanks to his detailed report and analysis, we were able to understand
> the core issue.
> 
> IP early demux can associate a dst to skb, after a lookup in TCP/UDP
> sockets.
> 
> When socket cache is not properly set, we want to store into
> sk->sk_dst_cache the dst for future IP early demux lookups,
> by acquiring a stable refcount on the dst.
> 
> Problem is this acquisition is simply using an atomic_inc(),
> which works well, unless the dst was queued for destruction from
> dst_release() noticing dst refcount went to zero, if DST_NOCACHE
> was set on dst.
> 
> We need to make sure current refcount is not zero before incrementing
> it, or risk double free as David reported.
> 
> This patch, being a stable candidate, adds two new helpers, and use
> them only from IP early demux problematic paths.
> 
> It might be possible to merge in net-next skb_dst_force() and
> skb_dst_force_safe(), but I prefer having the smallest patch for stable
> kernels : Maybe some skb_dst_force() callers do not expect skb->dst
> can suddenly be cleared.
> 
> Can probably be backported back to linux-3.6 kernels
> 
> Reported-by: David J. Wilder <dwilder@us.ibm.com>
> Tested-by: David J. Wilder <dwilder@us.ibm.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
