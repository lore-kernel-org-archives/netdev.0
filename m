From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: CPU scheduler to TXQ binding? (ixgbe vs. igb)
Date: Wed, 17 Sep 2014 16:55:26 +0200
Message-ID: <20140917165526.196c2013@redhat.com>
References: <20140917152653.1c824a22@redhat.com>
	<1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754363AbaIQOze (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2014 10:55:34 -0400
In-Reply-To: <1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Sep 2014 07:32:39 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2014-09-17 at 15:26 +0200, Jesper Dangaard Brouer wrote:
> > The CPU to TXQ binding behavior of ixgbe vs. igb NIC driver are
> > somehow different.  Normally I setup NIC IRQ-to-CPU bindings 1-to-1,
> > with script set_irq_affinity [1].
> > 
> > For forcing use of a specific HW TXQ, I normally force the CPU binding
> > of the process, either with "taskset" or with "netperf -T lcpu,rcpu".
> > 
> > This works fine with driver ixgbe, but not with driver igb.  That is
> > with igb, the program forced to specific CPU, can still use another
> > TXQ. What am I missing?
> > 
> > 
> > I'm monitoring this with both:
> >  1) watch -d sudo tc -s -d q ls dev ethXX
> >  2) https://github.com/ffainelli/bqlmon
> > 
> > [1] https://github.com/netoptimizer/network-testing/blob/master/bin/set_irq_affinity
> 
> Have you setup XPS ?
> 
> echo 0001 >/sys/class/net/ethX/queues/tx-0/xps_cpus
> echo 0002 >/sys/class/net/ethX/queues/tx-1/xps_cpus
> echo 0004 >/sys/class/net/ethX/queues/tx-2/xps_cpus
> echo 0008 >/sys/class/net/ethX/queues/tx-3/xps_cpus
> echo 0010 >/sys/class/net/ethX/queues/tx-4/xps_cpus
> echo 0020 >/sys/class/net/ethX/queues/tx-5/xps_cpus
> echo 0040 >/sys/class/net/ethX/queues/tx-6/xps_cpus
> echo 0080 >/sys/class/net/ethX/queues/tx-7/xps_cpus
> 
> Or something like that, depending on number of cpus and TX queues.

Thanks, that worked! They were all default set to "000" for igb, but
set correctly/like-above for ixgbe (strange).

Did:

$ export DEV=eth1 ; export NR_CPUS=11 ; \
 for txq in `seq 0 $NR_CPUS` ; do \
   file=/sys/class/net/${DEV}/queues/tx-${txq}/xps_cpus \
   mask=`printf %X $((1<<$txq))`
   test -e $file && sudo sh -c "echo $mask > $file" && \
   grep . -H $file ;\
 done
/sys/class/net/eth1/queues/tx-0/xps_cpus:001
/sys/class/net/eth1/queues/tx-1/xps_cpus:002
/sys/class/net/eth1/queues/tx-2/xps_cpus:004
/sys/class/net/eth1/queues/tx-3/xps_cpus:008
/sys/class/net/eth1/queues/tx-4/xps_cpus:010
/sys/class/net/eth1/queues/tx-5/xps_cpus:020
/sys/class/net/eth1/queues/tx-6/xps_cpus:040
/sys/class/net/eth1/queues/tx-7/xps_cpus:080
 
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
