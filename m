From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: Re: dst_ifdown breaks infiniband?
Date: Tue, 20 Mar 2007 18:02:17 +0200
Message-ID: <20070320160217.GC31495@mellanox.co.il>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318195355.GB11078@mellanox.co.il>
	<20070318201826.GB27004@ms2.inr.ac.ru>
	<20070319093632.GB8386@mellanox.co.il>
	<20070319120534.GA28187@ms2.inr.ac.ru>
	<20070319121248.GD18497@mellanox.co.il>
	<20070319125919.GA4239@ms2.inr.ac.ru>
	<20070319151336.GA24225@mellanox.co.il>
	<20070319232043.GA23359@ms2.inr.ac.ru>
Reply-To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, general@lists.openfabrics.org,
	Roland Dreier <rolandd@cisco.com>,
	David Miller <davem@davemloft.net>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:24421 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbXCTQBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 12:01:37 -0400
Received: by ug-out-1314.google.com with SMTP id 44so1658354uga
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 09:01:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070319232043.GA23359@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Quoting Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>:
> Subject: Re: dst_ifdown breaks infiniband?
> 
> Hello!
> 
> > This might work. Could you post a patch to better show what you mean to do?
> 
> Here it is.
> 
> ->neigh_destructor() is killed (not used), replaced with ->neigh_cleanup(),
> which is called when neighbor entry goes to dead state. At this point
> everything is still valid: neigh->dev, neigh->parms etc.
> 
> The device should guarantee that dead neighbor entries (neigh->dead != 0)
> do not get private part initialized, otherwise nobody will cleanup it.

OK, I stress-tested this for about 9 hours - apparently this resolves the issues
I was seeing both with hotplug device unregister and module removal.

This is an old bug, but somehow it did not trigger on
older kernels - some code restructuring in infiniband is probably
the reason - so from that POV it's a regression in 2.6.21.
So now several people are experiencing these crashes.

David, Alexey, what do you think about this patch? Is it right?
Could this patch be considered for 2.6.21?

Acked-by: Michael S. Tsirkin <mst@dev.mellanox.co.il>

> 
> I think this is enough for ipoib which is the only user of this thing.
> Initialization private part of neighbor entries happens in ipib
> start_xmit routine, which is not reached when device is down.
> But it would be better to add explicit test for neigh->dead
> in any case.

Additionally, ip over infiniband actually tests a separate flag
IPOIB_FLAG_ADMIN_UP before looking at an skb.
This flag is cleared before the device goes down.
Taken together this should be sufficient I think.

-- 
MST
