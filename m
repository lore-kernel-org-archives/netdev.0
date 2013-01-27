From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: loopback: fix a dst refcounting issue
Date: Sun, 27 Jan 2013 01:32:41 -0500 (EST)
Message-ID: <20130127.013241.1524448507498580112.davem@davemloft.net>
References: <1358989843.12374.1334.camel@edumazet-glaptop>
	<1358991906.12374.1356.camel@edumazet-glaptop>
	<1359135881.12374.3249.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755925Ab3A0Gcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 01:32:42 -0500
In-Reply-To: <1359135881.12374.3249.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 25 Jan 2013 09:44:41 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Ben Greear reported crashes in ip_rcv_finish() on a stress
> test involving many macvlans.
> 
> We tracked the bug to a dst use after free. ip_rcv_finish()
> was calling dst->input() and got garbage for dst->input value.
> 
> It appears the bug is in loopback driver, lacking
> a skb_dst_force() before calling netif_rx().
> 
> As a result, a non refcounted dst, normally protected by a
> RCU read_lock section, was escaping this section and could
> be freed before the packet being processed.
 ...
> This bug was introduced in linux-2.6.35, in commit
> 7fee226ad2397b (net: add a noref bit on skb dst)
> 
> skb_dst_force() is enforced in dev_queue_xmit() for devices having a
> qdisc. 
> 
> Reported-by: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Ben Greear <greearb@candelatech.com>

Applied, I suspect we need to tree wide audit for other instances of
this situation.  Probably greps for skb_orphan() would be a good
start.
