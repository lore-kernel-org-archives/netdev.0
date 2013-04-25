From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 4/4] net: frag LRU list per CPU
Date: Wed, 24 Apr 2013 17:25:57 -0700
Message-ID: <1366849557.8964.110.camel@edumazet-glaptop>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154848.16883.65833.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:43148 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758491Ab3DYAZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 20:25:59 -0400
Received: by mail-pd0-f182.google.com with SMTP id 3so1454223pdj.13
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 17:25:59 -0700 (PDT)
In-Reply-To: <20130424154848.16883.65833.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 17:48 +0200, Jesper Dangaard Brouer wrote:
> The global LRU list is the major bottleneck in fragmentation handling
> (after the recent frag optimization).
> 
> Simply change to use a LRU list per CPU, instead of a single shared
> LRU list.  This was the simples approach of removing the LRU list, I
> could come up with.  The previous "direct hash cleaning" approach was
> getting too complicated, and interacted badly with netns.
> 
> The /proc/sys/net/ipv4/ipfrag_*_thresh values are now per CPU limits,
> and have been reduced to 2 Mbytes (from 4 MB).
> 
> Performance compared to net-next (953c96e):
> 
> Test-type:  20G64K    20G3F    20G64K+DoS  20G3F+DoS  20G64K+MQ 20G3F+MQ
> ----------  -------   -------  ----------  ---------  --------  -------
> (953c96e)
>  net-next:  17417.4   11376.5   3853.43     6170.56     174.8    402.9
> LRU-pr-CPU: 19047.0   13503.9  10314.10    12363.20    1528.7   2064.9

Having per cpu memory limit is going to be a nightmare for machines with
64+ cpus

Most machines use a single cpu to receive network packets. In some
situations, every network interrupt is balanced onto all cpus. fragments
for the same reassembled packet can be serviced on different cpus.

So your results are good because your irq affinities were properly
tuned.

Why don't you remove the lru instead ?

Clearly, removing the oldest frag was an implementation choice.

We know that a slow sender has no chance to complete a packet if the
attacker can create new fragments fast enough : frag_evictor() will keep
the attacker fragments in memory and throw away good fragments.

I wish we could make all this code simpler instead of more complex.
