From: Tom Lendacky <tahm@linux.vnet.ibm.com>
Subject: Re: Network performance with small packets - continued
Date: Fri, 18 Mar 2011 10:38:27 -0500
Message-ID: <201103181038.29490.tahm@linux.vnet.ibm.com>
References: <201103071631.41964.tahm@linux.vnet.ibm.com> <20110310153422.GA28557@redhat.com> <201103101116.13212.tahm@linux.vnet.ibm.com>
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
In-Reply-To: <201103101116.13212.tahm@linux.vnet.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, March 10, 2011 11:16:11 am Tom Lendacky wrote:
> On Thursday, March 10, 2011 09:34:22 am Michael S. Tsirkin wrote:
> > On Thu, Mar 10, 2011 at 09:23:42AM -0600, Tom Lendacky wrote:
> > > On Thursday, March 10, 2011 12:54:58 am Michael S. Tsirkin wrote:
> > > > On Wed, Mar 09, 2011 at 05:25:11PM -0600, Tom Lendacky wrote:
> > > > > As for which CPU the interrupt gets pinned to, that doesn't matter
> > > > > - see below.
> > > > 
> > > > So what hurts us the most is that the IRQ jumps between the VCPUs?
> > > 
> > > Yes, it appears that allowing the IRQ to run on more than one vCPU
> > > hurts. Without the publish last used index patch, vhost keeps
> > > injecting an irq for every received packet until the guest eventually
> > > turns off notifications.
> > 
> > Are you sure you see that? If yes publish used should help a lot.
> 
> I definitely see that.  I ran lockstat in the guest and saw the contention
> on the lock when the irq was able to run on either vCPU.  Once the irq was
> pinned the contention disappeared.  The publish used index patch should
> eliminate the extra irq injections and then the pinning or use of
> irqbalance shouldn't be required.  I'm getting a kernel oops during boot
> with the publish last used patches that I pulled from the mailing list - I
> had to make some changes in order to get them to apply and compile and
> might not have done the right things.  Can you re-spin that patchset
> against kvm.git?
> 

Here are the results for the publish last used index patch (with the baseline 
provided again for reference).

Here is the KVM baseline (average of six runs):
  Txn Rate: 87,070.34 Txn/Sec, Pkt Rate: 172,992 Pkts/Sec
  Exits: 148,444.58 Exits/Sec
  TxCPU: 2.40%  RxCPU: 99.35%
  Virtio1-input  Interrupts/Sec (CPU0/CPU1): 5,154/5,222
  Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0

Using the publish last used index w/o irqbalance (average of six runs):
  Txn Rate: 112,180.10 Txn/Sec, Pkt Rate: 222,878.33 Pkts/Sec
  Exits: 96,280.11 Exits/Sec
  TxCPU: 1.14%  RxCPU: 99.33%
  Virtio1-input  Interrupts/Sec (CPU0/CPU1): 3,400/3,400
  Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0

About a 29% increase over baseline.

Using the publish last used index w/  irqbalance (average of six runs):
  Txn Rate: 110,891.12 Txn/Sec, Pkt Rate: 220,315.67 Pkts/Sec
  Exits: 97,190.68 Exits/Sec
  TxCPU: 1.10%  RxCPU: 99.38%
  Virtio1-input  Interrupts/Sec (CPU0/CPU1): 7,040/0
  Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0

About a 27% increase over baseline.

Here is data from running without the publish last used index patch but with 
irqbalance running (pinning results were near identical):
  Txn Rate: 107,714.53 Txn/Sec, Pkt Rate: 214,006 Pkts/Sec
  Exits: 121,050.45 Exits/Sec
  TxCPU: 9.61%  RxCPU: 99.45%
  Virtio1-input  Interrupts/Sec (CPU0/CPU1): 13,975/0
  Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0

The publish last used index patch provides a 3%-4% improvement while reducing 
the exit rate and interrupt rate in the guest as well as reducing the 
transmitting system CPU% quite dramatically.

> > > Because the irq injections end up overlapping we get contention on the
> > > irq_desc_lock_class lock. Here are some results using the "baseline"
> > > setup with irqbalance running.
> > > 
> > >   Txn Rate: 107,714.53 Txn/Sec, Pkt Rate: 214,006 Pkts/Sec
> > >   Exits: 121,050.45 Exits/Sec
> > >   TxCPU: 9.61%  RxCPU: 99.45%
> > >   Virtio1-input  Interrupts/Sec (CPU0/CPU1): 13,975/0
> > >   Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0
> > > 
> > > About a 24% increase over baseline.  Irqbalance essentially pinned the
> > > virtio irq to CPU0 preventing the irq lock contention and resulting in
> > > nice gains.
> > 
> > OK, so we probably want some form of delayed free for TX
> > on top, and that should get us nice results already.
> > 
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe kvm" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe kvm" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
