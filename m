From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: CPU scheduler to TXQ binding? (ixgbe vs. igb)
Date: Thu, 18 Sep 2014 09:28:50 +0200
Message-ID: <20140918092850.117d4c15@redhat.com>
References: <20140917152653.1c824a22@redhat.com>
	<1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
	<5419A1E7.8040109@intel.com>
	<20140918085640.0815df6d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756052AbaIRH27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 03:28:59 -0400
In-Reply-To: <20140918085640.0815df6d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Sep 2014 08:56:40 +0200
Jesper Dangaard Brouer <jbrouer@redhat.com> wrote:

> On Wed, 17 Sep 2014 07:59:51 -0700
> Alexander Duyck <alexander.h.duyck@intel.com> wrote:
> 
> > On 09/17/2014 07:32 AM, Eric Dumazet wrote:
> > > On Wed, 2014-09-17 at 15:26 +0200, Jesper Dangaard Brouer wrote:
> > >> The CPU to TXQ binding behavior of ixgbe vs. igb NIC driver are
> > >> somehow different.  Normally I setup NIC IRQ-to-CPU bindings 1-to-1,
> > >> with script set_irq_affinity [1].
> > >>
> > >> For forcing use of a specific HW TXQ, I normally force the CPU binding
> > >> of the process, either with "taskset" or with "netperf -T lcpu,rcpu".
> > >>
> > >> This works fine with driver ixgbe, but not with driver igb.  That is
> > >> with igb, the program forced to specific CPU, can still use another
> > >> TXQ. What am I missing?
> > >>
> > >>
> > >> I'm monitoring this with both:
> > >>  1) watch -d sudo tc -s -d q ls dev ethXX
> > >>  2) https://github.com/ffainelli/bqlmon
> > >>
> > >> [1] https://github.com/netoptimizer/network-testing/blob/master/bin/set_irq_affinity
> > > 
> > > Have you setup XPS ?
> > > 
> > > echo 0001 >/sys/class/net/ethX/queues/tx-0/xps_cpus
> > > echo 0002 >/sys/class/net/ethX/queues/tx-1/xps_cpus
> > > echo 0004 >/sys/class/net/ethX/queues/tx-2/xps_cpus
> > > echo 0008 >/sys/class/net/ethX/queues/tx-3/xps_cpus
> > > echo 0010 >/sys/class/net/ethX/queues/tx-4/xps_cpus
> > > echo 0020 >/sys/class/net/ethX/queues/tx-5/xps_cpus
> > > echo 0040 >/sys/class/net/ethX/queues/tx-6/xps_cpus
> > > echo 0080 >/sys/class/net/ethX/queues/tx-7/xps_cpus
> > > 
> > > Or something like that, depending on number of cpus and TX queues.
> > > 
> > 
> > That was what I was thinking as well.
> > 
> > ixgbe has ATR which makes use of XPS to setup the transmit queues for a
> > 1:1 mapping.  The receive side of the flow is routed back to the same Rx
> > queue through flow director mappings.
> > 
> > In the case of igb it only has RSS and doesn't set a default XPS
> > configuration.  So you should probably setup XPS and you might also want
> > to try and make use of RPS to try and steer receive packets since the Rx
> > queues won't match the Tx queues.
> 
> After setting up XPS to CPU 1:1 binding, it works most of the time.
> Meaning, most of the traffic will go through the TXQ I've bound the
> process to, BUT some packets can still choose another TXQ (observed
> monitoring tc output and blqmon).
> 
> Could this be related to the missing RPS setup?

It helped setting up RPS, but not 100%.  I see small periods of packets
going out on other TXQs, and sometimes as before some heavy flow will
find its way to another TXQ.

 
> Can I get some hints setting up RPS?

My setup command now maps both XPS and RPS 1:1 to CPUs.

# Setup both RPS and XPS with a 1:1 binding to CPUs
export DEV=eth1 ; export NR_CPUS=11 ; \
for txq in `seq 0 $NR_CPUS` ; do \
  file_xps=/sys/class/net/${DEV}/queues/tx-${txq}/xps_cpus \
  file_rps=/sys/class/net/${DEV}/queues/rx-${txq}/rps_cpus \
  mask=`printf %X $((1<<$txq))`
  test -e $file_xps && sudo sh -c "echo $mask > $file_xps" && grep . -H $file_xps ;\
  test -e $file_rps && sudo sh -c "echo $mask > $file_rps" && grep . -H $file_rps ;\
done

Output:
/sys/class/net/eth1/queues/tx-0/xps_cpus:001
/sys/class/net/eth1/queues/rx-0/rps_cpus:001
/sys/class/net/eth1/queues/tx-1/xps_cpus:002
/sys/class/net/eth1/queues/rx-1/rps_cpus:002
/sys/class/net/eth1/queues/tx-2/xps_cpus:004
/sys/class/net/eth1/queues/rx-2/rps_cpus:004
/sys/class/net/eth1/queues/tx-3/xps_cpus:008
/sys/class/net/eth1/queues/rx-3/rps_cpus:008
/sys/class/net/eth1/queues/tx-4/xps_cpus:010
/sys/class/net/eth1/queues/rx-4/rps_cpus:010
/sys/class/net/eth1/queues/tx-5/xps_cpus:020
/sys/class/net/eth1/queues/rx-5/rps_cpus:020
/sys/class/net/eth1/queues/tx-6/xps_cpus:040
/sys/class/net/eth1/queues/rx-6/rps_cpus:040
/sys/class/net/eth1/queues/tx-7/xps_cpus:080
/sys/class/net/eth1/queues/rx-7/rps_cpus:080


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
