From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix for a race condition in the inet frag code
Date: Mon, 03 Mar 2014 16:34:51 -0500 (EST)
Message-ID: <20140303.163451.1125160365051117173.davem@davemloft.net>
References: <1393855520-18334-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590AbaCCVex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 16:34:53 -0500
In-Reply-To: <1393855520-18334-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Mon,  3 Mar 2014 15:05:20 +0100

> I stumbled upon this very serious bug while hunting for another one,
> it's a very subtle race condition between inet_frag_evictor,
> inet_frag_intern and the IPv4/6 frag_queue and expire functions (basically
> the users of inet_frag_kill/inet_frag_put).
> What happens is that after a fragment has been added to the hash chain but
> before it's been added to the lru_list (inet_frag_lru_add), it may get
> deleted (either by an expired timer if the system load is high or the
> timer sufficiently low, or by the fraq_queue function for different
> reasons) before it's added to the lru_list, then after it gets added
> it's a matter of time for the evictor to get to a piece of memory which
> has been freed leading to a number of different bugs depending on what's
> left there. I've been able to trigger this on both IPv4 and IPv6 (which
> is normal as the frag code is the same), but it's been much more
> difficult to trigger on IPv4 due to the protocol differences about how
> fragments are treated. The setup I used to reproduce this is:
> 2 machines with 4 x 10G bonded in a RR bond, so the same flow can be
> seen on multiple cards at the same time. Then I used multiple instances
> of ping/ping6 to generate fragmented packets and flood the machines with
> them while running other processes to load the attacked machine.
> *It is very important to have the _same flow_ coming in on multiple CPUs
> concurrently. Usually the attacked machine would die in less than 30
> minutes, if configured properly to have many evictor calls and timeouts
> it could happen in 10 minutes or so.
> 
> The fix is simple, just move the lru_add under the hash chain locked
> region so when a removing function is called it'll have to wait for the
> fragment to be added to the lru_list, and then it'll remove it (it works
> because the hash chain removal is done before the lru_list one and
> there's no window between the two list adds when the frag can get
> dropped). With this fix applied I couldn't kill the same machine in 24
> hours with the same setup.
> 
> Fixes: 3ef0eb0db4bf ("net: frag, move LRU list maintenance outside of
> rwlock")
> 
> CC: Jesper Dangaard Brouer <brouer@redhat.com>
> CC: David S. Miller <davem@davemloft.net>
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Nik, please beef up the commit message a bit and resubmit.

Some of your replies explained the situation a bit better.  Don't
be afraid of making the commit message too long or too verbose :-)

Thanks!
