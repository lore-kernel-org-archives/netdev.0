From: jamal <hadi@cyberus.ca>
Subject: Re: [RFR] gianfar ethernet driver
Date: 08 Jul 2004 19:08:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089328099.1046.24.camel@jzny.localdomain>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com>
	 <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com>
	 <1089170282.1038.80.camel@jzny.localdomain>
	 <20040707032913.GA1822@havoc.gtf.org>
	 <1089171693.1037.87.camel@jzny.localdomain>  <40EB8B84.7040301@pobox.com>
	 <1089224952.1027.340.camel@jzny.localdomain>  <40EDC7A7.8060906@pobox.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
        Kumar Gala <kumar.gala@freescale.com>, netdev@oss.sgi.com,
        dwmw2@infradead.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40EDC7A7.8060906@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-08 at 18:16, Jeff Garzik wrote:

> To see if I understand you correctly, tell me if these two rules are 
> right or wrong:
> 
> 1) If netif_stop_queue() is called, return 1

Return 1 _iff_ you dont stash the packet on ring. If you return
1, the toplayer will retry later with the same skb. If you stash it on
the ring, the danger is tx complete will try to free it later while the
toplayer code is still referencing it. A good oops.

> 2) Otherwise, return 0

This will always work, but not the most optimal.

> ?
> 
> Note carefully that with #1, you have two sub-cases:
> a)	queue packet
> 	check free descriptors
> 	maybe stop queue
> b)	check free descriptors
> 	maybe stop queue
> 	queue packet
> 	...

In both above cases return 0.

c) check free descriptors
   if no space
      stop queue; return 1
/* free space */
    queue packet

> i.e. the packet passed to dev->hard_start_xmit may or may not have been 
> sent to hardware's DMA ring, when you stop the queue and return 1.

Dangerous to return 1 and queue packet.

> Second point of note:
> 
> I worry that returning 1 when skb has -not- been queued to DMA ring will 
> result in loss of packet, with certain packet schedulers.  For example, 
> a real-time packet scheduler may choose to drop rather than requeue the 
> skb, as the NIC driver author would intend.

This is well taken care queueing code; if the scheduler
decides that the packet to be returned is the one thats to be dropped
then thats the responsibility of the scheduler. all we do is hand it a
packet and say "please requeue that". This is a clean separation of
tasks in Alexeys architecture. The driver is just a transmitter; the
intelligence(real time, rate control) is above it.

> While it may be reasonable for the packet scheduler to drop the packet, 
> in normal use with skb fragments (sendfile/TSO) that would result in a 
> packet potentially being dropped each time the NIC driver's 
> dev->hard_start_xmit() could not queue a packet to hardware.  The test 
> (described in another email) of "free descriptors < MAX_SKB_FRAGS" 
> following the queueing of an skb to hardware is intended to avoid this 
> condition.

I think if thats what the scheduler is designed to do, it should, None
of the current schedulers that mostly do rate control do so.

cheers,
jamal
