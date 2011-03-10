From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets - continued
Date: Wed, 09 Mar 2011 16:59:05 -0800
Message-ID: <1299718745.25664.200.camel@localhost.localdomain>
References: <201103071631.41964.tahm@linux.vnet.ibm.com>
	 <20110309071558.GA25757@redhat.com>
	 <201103091411.09062.tahm@linux.vnet.ibm.com>
	 <20110309215537.GA11516@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:55084 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424Ab1CJA7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 19:59:11 -0500
In-Reply-To: <20110309215537.GA11516@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-09 at 23:56 +0200, Michael S. Tsirkin wrote:
> >   Txn Rate: 153,696.59 Txn/Sec, Pkt Rate: 305,358 Pkgs/Sec
> >   Exits: 62,603.37 Exits/Sec
> >   TxCPU: 3.73%  RxCPU: 98.52%
> >   Virtio1-input  Interrupts/Sec (CPU0/CPU1): 11,564/0
> >   Virtio1-output Interrupts/Sec (CPU0/CPU1): 0/0
> > 
> > About a 77% increase over baseline and about 74% of baremetal.
> 
> Hmm we get about 20 packets per interrupt on average.
> That's pretty decent. The problem is with exits.
> Let's try something adaptive in the host? 

I did some hack before, for 32-64 multiple stream TCP_RR cases, either
queue multiple skbs per kick or delay vhost exit from handle_tx, both
improved TCP_RR aggregation performance, but single TCP_RR latency
increased.

Here, the test is about 100 TCP_RR streams from a bare metal client to
KVM guest, the kick_notify from guest RX path should be small (every 1/2
ring size, it does a kick and even under that kick, vhost might already
disable the notification). 

The kick_notify from guest TX path seems the main reason causes the
guest huge of exits, (it does a kick for every send skb, under that kick
vhost might mostly likely exit from empty ring not reaching
VHOST_NET_WEIGH. The indirect buffer is used, so I wonder how many
packets per handle_tx processed here?

In theory, for lots of TCP_RR streams, the guest should be able to keep
sending xmit skbs to send vq, so vhost should be able to disable
notification most of the time, then number of guest exits should be
significantly reduced? Why we saw lots of guest exits here still? Is it
worth to try 256 (send queue size) TCP_RRs?

Tom's kick_notify data from Rusty's patch would be helpful to understand
what's going here.

Thanks
Shirley



