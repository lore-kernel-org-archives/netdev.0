From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: fix RCU races on dst refcounts
Date: Mon, 30 Jul 2012 17:40:44 -0700 (PDT)
Message-ID: <20120730.174044.968236168485282216.davem@davemloft.net>
References: <1343640037.21269.15.camel@edumazet-glaptop>
	<20120730.145637.906924670032055493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959Ab2GaAkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 20:40:47 -0400
In-Reply-To: <20120730.145637.906924670032055493.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 30 Jul 2012 14:56:37 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 30 Jul 2012 11:20:37 +0200
> 
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> We need instead regular dst refcounting (dst_release()) and make
>> sure dst_release() is aware of RCU grace periods :

Eric, we really cannot do this.

We absolutely must call dst_free() directly when cached entries
are flushed.

Your delayed scheme using dst_release() doesn't work, it exposes us to
the "stale netdevice references" issue even for cached entries.  This
exact issue is why I moved away from a dst_release() based scheme to
a !DST_NOCACHE + dst_free() one.

dst_free() is special.  It is special in that if there are existing
references, it adds the dst onto the generic GC list of busy dsts in
net/core/dst.c

This is important, because it means that even if references are still
held on the dst, we will still be able to purge spurious netdevice
references when those netdevices try to go down or unregister
themselves.

You can't defer the dst_free() to the final refcount drop like your
code does now.  A socket, or other dst caching entity, can hold onto
the dst forever, do no socket operations at all, and therefore hold
onto a netdevice for an infinite amount of time.

Look at how net/core/dst.c:dst_dev_event() walks dst_busy_list.

That's why we must propagate cached dsts into dst_busy_list no later
than when we trim them from ->nh_rth_{input,output}

I noticed this because I'm trying to work on a fix the lingering dst
netdevice reference problem for non-cached dsts.
