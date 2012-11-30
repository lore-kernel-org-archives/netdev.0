From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Fri, 30 Nov 2012 06:52:14 -0800
Message-ID: <1354287134.3299.67.camel@edumazet-glaptop>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161052.17754.85017.stgit@dragon>
	 <20121129.124427.1093031685966728935.davem@davemloft.net>
	 <1354227470.11754.348.camel@localhost>
	 <1354230100.3299.40.camel@edumazet-glaptop>
	 <1354269846.11754.381.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:54604 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030480Ab2K3OwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 09:52:17 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so731022ieb.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 06:52:17 -0800 (PST)
In-Reply-To: <1354269846.11754.381.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-30 at 11:04 +0100, Jesper Dangaard Brouer wrote:
> So, let me instead show, with tests, that the evictor strategy is
> broken, while keeping the original default thresh settings:
> 
> # grep . /proc/sys/net/ipv4/ipfrag_*_thresh
> /proc/sys/net/ipv4/ipfrag_high_thresh:262144
> /proc/sys/net/ipv4/ipfrag_low_thresh:196608
> 
> Test purpose, I will on a single 10G link demonstrate, that starting
> several "N" netperf UDP fragmentation flows, will hurt performance, and
> then claim this is caused by the bad evictor strategy.
> 
> Test setup:
>  - Disable Ethernet flow control
>  - netperf packet size 65507
>  - Run netserver on one NUMA node
>  - Start netperf clients against a NIC on the other NUMA node
>  - (The NUMA imbalance helps the effect occur at lower N) 
> 
> Result: N=1  8040 Mbit/s
> Result: N=2  9584 Mbit/s (4739+4845)
> Result: N=3  4055 Mbit/s (1436+1371+1248)
> Result: N=4  2247 Mbit/s (1538+29+54+626)
> Result: N=5   879 Mbit/s (78+152+226+125+298)
> Result: N=6   293 Mbit/s (85+55+32+57+46+18)
> Result: N=7   354 Mbit/s (70+47+33+80+20+72+32)
> 
> Can we, now, agree that the current evictor strategy is broken?!?

Your setup is broken for sure. I dont know how you expect that many
datagrams being correctly reassembled with ipfrag_high_thresh=262144 

No matter strategy is implemented, an attacker knows it and can send
frags so that regular workload is denied. Kernel cant decide which
packets are more likely to be completed.

BTW, install fq_codel at the sender side, so that frags are nicely
interleaved. Because on real networks, frags of an UDP datagram rarely
come to destination in a single train with no alien packets inside the
train.

You focus on a particular lab setup and particular workload, you
should consider that if an application _really_ depends on frags, then
the receiver is likely to be a target for various frag attacks.
