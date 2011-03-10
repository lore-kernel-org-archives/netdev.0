From: Tom Lendacky <tahm@linux.vnet.ibm.com>
Subject: Re: Network performance with small packets - continued
Date: Thu, 10 Mar 2011 09:23:42 -0600
Message-ID: <201103100923.44184.tahm@linux.vnet.ibm.com>
References: <201103071631.41964.tahm@linux.vnet.ibm.com> <201103091725.12992.tahm@linux.vnet.ibm.com> <20110310065457.GA22820@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110310065457.GA22820@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, March 10, 2011 12:54:58 am Michael S. Tsirkin wrote:
> On Wed, Mar 09, 2011 at 05:25:11PM -0600, Tom Lendacky wrote:
> > As for which CPU the interrupt gets pinned to, that doesn't matter - see
> > below.
> 
> So what hurts us the most is that the IRQ jumps between the VCPUs?

Yes, it appears that allowing the IRQ to run on more than one vCPU hurts.  
Without the publish last used index patch, vhost keeps injecting an irq for 
every received packet until the guest eventually turns off notifications. 
Because the irq injections end up overlapping we get contention on the 
irq_desc_lock_class lock. Here are some results using the "baseline" setup 
with irqbalance running.

  Txn Rate: 107,714.53 Txn/Sec, Pkt Rate: 214,006 Pkts/Sec
  Exits: 121,050.45 Exits/Sec
  TxCPU: 9.61%  RxCPU: 99.45%
  Virtio1-input  Interrupts/Sec (CPU0/CPU1): 13,975/0
  Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0

About a 24% increase over baseline.  Irqbalance essentially pinned the virtio 
irq to CPU0 preventing the irq lock contention and resulting in nice gains.

> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
