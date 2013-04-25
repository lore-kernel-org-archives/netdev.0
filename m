From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 4/4] net: frag LRU list per CPU
Date: Thu, 25 Apr 2013 07:18:50 -0700
Message-ID: <1366899530.8964.150.camel@edumazet-glaptop>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154848.16883.65833.stgit@dragon>
	 <1366849557.8964.110.camel@edumazet-glaptop>
	 <1366898369.26911.604.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:48239 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932256Ab3DYOSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 10:18:53 -0400
Received: by mail-da0-f49.google.com with SMTP id t11so1427146daj.8
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 07:18:52 -0700 (PDT)
In-Reply-To: <1366898369.26911.604.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 15:59 +0200, Jesper Dangaard Brouer wrote:

> Let me quote my self (which you cut out):
> 

I cut because most people don't bother to read mails with 100 lines.

Let be clear :

Q) You want performance, and LRU hurts performance
A) Remove the LRU, problem solved.

Q) You want performance and big number of frags to cope with attacks
A) resize the hash table when the admin sets a bigger limit
   If one million fragments are allowed, then hash table should be 1
million slots. A single percpu_counter is enough to track memory use.

Q) How to perform eviction if LRU is removed ?
A) In softirq handler, eviction is bad. If we hit the limit, drop the
incoming packet. There is no other solution.

   Way before hitting the limit, schedule a workqueue.
  This wq is responsible for evicting frags. Each frag has a "unsigned
long last_frag_jiffie", and you automatically evict frags that are aged
more than xxx jiffies.


As a bonus, we can remove the timer per frag and save a lot of memory
and timer overhead.
