From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets - continued
Date: Thu, 10 Mar 2011 17:34:22 +0200
Message-ID: <20110310153422.GA28557@redhat.com>
References: <201103071631.41964.tahm@linux.vnet.ibm.com>
 <201103091725.12992.tahm@linux.vnet.ibm.com>
 <20110310065457.GA22820@redhat.com>
 <201103100923.44184.tahm@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: Tom Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2135 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752052Ab1CJPel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 10:34:41 -0500
Content-Disposition: inline
In-Reply-To: <201103100923.44184.tahm@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2011 at 09:23:42AM -0600, Tom Lendacky wrote:
> On Thursday, March 10, 2011 12:54:58 am Michael S. Tsirkin wrote:
> > On Wed, Mar 09, 2011 at 05:25:11PM -0600, Tom Lendacky wrote:
> > > As for which CPU the interrupt gets pinned to, that doesn't matter - see
> > > below.
> > 
> > So what hurts us the most is that the IRQ jumps between the VCPUs?
> 
> Yes, it appears that allowing the IRQ to run on more than one vCPU hurts.  
> Without the publish last used index patch, vhost keeps injecting an irq for 
> every received packet until the guest eventually turns off notifications. 

Are you sure you see that? If yes publish used should help a lot.

> Because the irq injections end up overlapping we get contention on the 
> irq_desc_lock_class lock. Here are some results using the "baseline" setup 
> with irqbalance running.
> 
>   Txn Rate: 107,714.53 Txn/Sec, Pkt Rate: 214,006 Pkts/Sec
>   Exits: 121,050.45 Exits/Sec
>   TxCPU: 9.61%  RxCPU: 99.45%
>   Virtio1-input  Interrupts/Sec (CPU0/CPU1): 13,975/0
>   Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0
> 
> About a 24% increase over baseline.  Irqbalance essentially pinned the virtio 
> irq to CPU0 preventing the irq lock contention and resulting in nice gains.

OK, so we probably want some form of delayed free for TX
on top, and that should get us nice results already.

> > --
> > To unsubscribe from this list: send the line "unsubscribe kvm" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
