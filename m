From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_teql: should not dereference skb after
 ndo_start_xmit
Date: Sun, 02 Aug 2009 18:59:41 -0700 (PDT)
Message-ID: <20090802.185941.120840905.davem@davemloft.net>
References: <4A11391D.8060503@cosmosbay.com>
	<20090518.151256.217066131.davem@davemloft.net>
	<4A120C8B.80108@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jussi.kivilinna@mbnet.fi
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46145
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754044AbZHCB7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 21:59:33 -0400
In-Reply-To: <4A120C8B.80108@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 19 May 2009 03:34:03 +0200

> Looking again at teql_master_xmit(), I wonder if there is another
> problem in it.
> 
>     int subq = skb_get_queue_mapping(skb);
> 
> But as a matter of fact, following code assumes subq is 0

I looked into this again, and damn this is tough to deal with.
The code works as-is, since teql devices have only 1 queue we
can assume queue 0 and we only end up using one of the slave
devices queues too.

I tried to export dev_pick_tx() (renaming it to netdev_pick_tx()
to avoid global namespace pollution) but then I realized that
we can't just whack the subq here.

If this gets punted back to the caller and we don't actually
send out the packet, we can't leave the new skb->queue_index
in there as teql's multiqueue parameters are what will be
checked and used against this SKB again.

I suppose we could restore the old queue index value when we
exhaust the slaves and can't transmit, but is getting messy for
sure.

Since the code works properly, and this is merely a performance
issue, I'm deferring this again.
