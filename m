From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets - continued
Date: Wed, 9 Mar 2011 23:56:15 +0200
Message-ID: <20110309215537.GA11516@redhat.com>
References: <201103071631.41964.tahm@linux.vnet.ibm.com>
 <20110309071558.GA25757@redhat.com>
 <201103091411.09062.tahm@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: Tom Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201103091411.09062.tahm@linux.vnet.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 09, 2011 at 02:11:07PM -0600, Tom Lendacky wrote:
> Here are the results again with the addition of the interrupt rate that 
> occurred on the guest virtio_net device:
> 
> Here is the KVM baseline (average of six runs):
>   Txn Rate: 87,070.34 Txn/Sec, Pkt Rate: 172,992 Pkts/Sec
>   Exits: 148,444.58 Exits/Sec
>   TxCPU: 2.40%  RxCPU: 99.35%
>   Virtio1-input  Interrupts/Sec (CPU0/CPU1): 5,154/5,222
>   Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0
> 
> About 42% of baremetal.
> 
> Delayed freeing of TX buffers (average of six runs):
>   Txn Rate: 90,886.19 Txn/Sec, Pkt Rate: 180,571 Pkts/Sec
>   Exits: 142,681.67 Exits/Sec
>   TxCPU: 2.78%  RxCPU: 99.36%
>   Virtio1-input  Interrupts/Sec (CPU0/CPU1): 4,796/4,908
>   Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0
> 
> About a 4% increase over baseline and about 44% of baremetal.

Looks like delayed freeing is a good idea generally.
Is this my patch? Yours?



> Delaying kick_notify (kick every 5 packets -average of six runs):
>   Txn Rate: 107,106.36 Txn/Sec, Pkt Rate: 212,796 Pkts/Sec
>   Exits: 102,587.28 Exits/Sec
>   TxCPU: 3.03%  RxCPU: 99.33%
>   Virtio1-input  Interrupts/Sec (CPU0/CPU1): 4,200/4,293
>   Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0
> 
> About a 23% increase over baseline and about 52% of baremetal.
> 
> Delaying kick_notify and pinning virtio1-input to CPU0 (average of six runs):

What exactly moves the interrupt handler between CPUs?
irqbalancer?  Does it matter which CPU you pin it to?
If yes, do you have any idea why?

Also, what happens without delaying kick_notify
but with pinning?

>   Txn Rate: 153,696.59 Txn/Sec, Pkt Rate: 305,358 Pkgs/Sec
>   Exits: 62,603.37 Exits/Sec
>   TxCPU: 3.73%  RxCPU: 98.52%
>   Virtio1-input  Interrupts/Sec (CPU0/CPU1): 11,564/0
>   Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0
> 
> About a 77% increase over baseline and about 74% of baremetal.

Hmm we get about 20 packets per interrupt on average.
That's pretty decent. The problem is with exits.
Let's try something adaptive in the host?

-- 
MST
