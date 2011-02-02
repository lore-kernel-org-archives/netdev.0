From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Wed, 02 Feb 2011 13:03:05 -0800
Message-ID: <1296680585.25430.98.camel@localhost.localdomain>
References: <1296627549.26937.856.camel@localhost.localdomain>
	 <OFF5778D3C.84F46700-ON6525782B.00230A94-6525782B.00240890@in.ibm.com>
	 <20110202104832.GA8505@redhat.com>
	 <1296661185.25430.10.camel@localhost.localdomain>
	 <20110202154706.GA12738@redhat.com>
	 <1296666635.25430.35.camel@localhost.localdomain>
	 <20110202173213.GA13907@redhat.com>
	 <1296670311.25430.49.camel@localhost.localdomain>
	 <20110202182720.GB14257@redhat.com>
	 <1296674975.25430.59.camel@localhost.localdomain>
	 <20110202201731.GB15150@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110202201731.GB15150@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-02-02 at 22:17 +0200, Michael S. Tsirkin wrote:
> Well, this is also the only case where the queue is stopped, no?
Yes. I got some debugging data, I saw that sometimes there were so many
packets were waiting for free in guest between vhost_signal & guest xmit
callback. Looks like the time spent too long from vhost_signal to guest
xmit callback?

> > I tried to accumulate multiple guest to host notifications for TX
> xmits,
> > it did help multiple streams TCP_RR results;
> I don't see a point to delay used idx update, do you?

It might cause per vhost handle_tx processed more packets.

> So delaying just signal seems better, right?

I think I need to define the test matrix to collect data for TX xmit
from guest to host here for different tests.

Data to be collected:
---------------------
1. kvm_stat for VM, I/O exits
2. cpu utilization for both guest and host
3. cat /proc/interrupts on guest
4. packets rate from vhost handle_tx per loop
5. guest netif queue stop rate
6. how many packets are waiting for free between vhost signaling and
guest callback
7. performance results

Test
----
1. TCP_STREAM single stream test for 1K to 4K message size
2. TCP_RR (64 instance test): 128 - 1K request/response size

Different hacks
---------------
1. Base line data ( with the patch to fix capacity check first,
free_old_xmit_skbs returns number of skbs)

2. Drop packet data (will put some debugging in generic networking code)

3. Delay guest netif queue wake up until certain descriptors (1/2 ring
size, 1/4 ring size...) are available once the queue has stopped.

4. Accumulate more packets per vhost signal in handle_tx?

5. 3 & 4 combinations

6. Accumulate more packets per guest kick() (TCP_RR) by adding a timer? 

7. Accumulate more packets per vhost handle_tx() by adding some delay?

> Haven't noticed that part, how does your patch make it
handle more packets?

Added a delay in handle_tx().

What else?

It would take sometimes to do this.

Shirley

