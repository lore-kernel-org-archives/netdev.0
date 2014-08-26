From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Tue, 26 Aug 2014 12:13:47 +0200
Message-ID: <20140826121347.0ec7f2ac@redhat.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	<20140826082815.18034199@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934467AbaHZKOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 06:14:06 -0400
In-Reply-To: <20140826082815.18034199@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 26 Aug 2014 08:28:15 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> On Mon, 25 Aug 2014 16:34:58 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> 
> > Given Jesper's performance numbers, it's not the way to go.
> > 
> > Instead, go with a signalling scheme via new boolean skb->xmit_more.
> 
> I'll do benchmarking based on this new API proposal today.

While establish an accurate baseline for my measurements.  I'm
starting to see too much variation in my trafgen measurements.
Meaning that we unfortunately cannot use it to measure variations on
the nanosec scale.

I'm measuring the packets per sec via "ifpps", and calculating an
average over the measurements, via the following oneliner:

 $ ifpps -clod eth5 -t 1000 | awk 'BEGIN{txsum=0; rxsum=0; n=0} /[[:digit:]]/ {txsum+=$11;rxsum+=$3;n++; printf "instant rx:%u tx:%u pps n:%u average: rx:%d tx:%d pps\n", $3, $11, n, rxsum/n, txsum/n }'

Below is measurements done on the *same* kerne:
 - M1: instant tx:1572766 pps n:215 average: tx:1573360 pps (reboot#1)
 - M2: instant tx:1561930 pps n:173 average: tx:1557064 pps (reboot#2)
 - M3: instant tx:1562088 pps n:300 average: tx:1559150 pps (reboot#2)
 - M4: instant tx:1564404 pps n:120 average: tx:1564948 pps (reboot#3)

 M1->M2: +6.65ns
 M1->M3: +5.79ns
 M1->M4: +3.42ns
 M3->M4: -2.38ns

I cannot explain the variations, but some options could be
 1) how well the SKB is cache-hot cached via kmem_cache
 2) other interrups on CPU#0 could disturb us
 3) interactions with scheduler
 4) interactions with transparent hugepages
 5) CPU "turbostat" interactions

M1 tx:1573360 pps translates into 636ns per packet, and 1% change
would translate into 6.36ns.  Perhaps we just cannot accurately
measure 1% improvement.

Trying to increase the sched priority of trafgen (supported via option
--prio-high) resulted in even worse performance results.  And kernel
starts to complain "BUG: soft lockup - CPU#0 stuck for 22s!".

With --prio-high the "instant" start to fluctuate a lot see:
 - instant rx:0 tx:1529260 pps n:191 average: rx:0 tx:1528885 pps
 - instant rx:0 tx:1512640 pps n:192 average: rx:0 tx:1528800 pps
 - instant rx:0 tx:1480050 pps n:193 average: rx:0 tx:1528548 pps
 - instant rx:0 tx:1526474 pps n:194 average: rx:0 tx:1528537 pps

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
