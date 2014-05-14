From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 3/5] pktgen: avoid atomic_inc per packet in
 xmit loop
Date: Wed, 14 May 2014 08:35:30 -0700
Message-ID: <1400081730.7973.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140514141545.20309.28343.stgit@dragon>
	 <20140514141753.20309.19785.stgit@dragon>
	 <1400078131.7973.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140514171306.52980157@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	John Fastabend <john.r.fastabend@intel.com>, danieltt@kth.se,
	zhouzhouyi@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:50503 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbaENPfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 11:35:33 -0400
Received: by mail-pb0-f50.google.com with SMTP id ma3so1832826pbc.23
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 08:35:32 -0700 (PDT)
In-Reply-To: <20140514171306.52980157@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 17:13 +0200, Jesper Dangaard Brouer wrote:

> Ah I see, then pktgen gets stopped, I might leak a SKB.
> 
> 
> > If done properly, you probably can avoid the kfree_skb(pkt_dev->skb) in
> > pktgen_xmit(), and set initial skb->users to max(1, pkt_dev->clone_skb);
> 
> Just setting max(1, pkt_dev->clone_skb) killed my machine (and my
> netconsole didn't send the entire output before dying).

Well, of course, I did not provide a patch, only a hint ;)

If all skb->users is set to the _exact_ number of
kfree_skb()/consume_skb() done by the driver, then no kfree_skb() is
needed in pktgen.

The thing is : clone_skb == 0 means basically that you need to init
skb->users to the number of time you plan to send this packet.

This depends on pkt_dev->count - pkt_dev->sofar and other things
probably.

min(dev->clone_skb, pkt_dev->count - pkt_dev->sofar)

But don't 'try' that without making sure its the right thing !!!

Make sure to replace atomic_dec(&(pkt_dev->skb->users)) by kfree_skb()
in case of NETDEV_TX_LOCKED/NETDEV_TX_BUSY
