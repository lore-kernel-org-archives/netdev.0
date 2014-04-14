From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] tuntap: add flow control to support back pressure
Date: Mon, 14 Apr 2014 10:02:39 +0300
Message-ID: <20140414070239.GA15082@redhat.com>
References: <5347487B.4040608@adjacentlink.com>
 <20140413141745.GB17839@redhat.com>
 <534B3A33.9090401@adjacentlink.com>
 <20140413.214004.1087903132047842986.davem@davemloft.net>
 <534B61C2.1080700@adjacentlink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jasowang@redhat.com,
	xemul@parallels.com, wuzhy@linux.vnet.ibm.com, therbert@google.com,
	yamato@redhat.com, richardcochran@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Brian.Adamson@nrl.navy.mil, jgiovatto@adjacentlink.com
To: Steven Galgano <sgalgano@adjacentlink.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <534B61C2.1080700@adjacentlink.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 14, 2014 at 12:19:14AM -0400, Steven Galgano wrote:
> On 04/13/2014 09:40 PM, David Miller wrote:
> > From: Steven Galgano <sgalgano@adjacentlink.com>
> > Date: Sun, 13 Apr 2014 21:30:27 -0400
> > 
> >> Added optional per queue flow control support using IFF_FLOW_CONTROL. When the IFF_FLOW_CONTROL TUNSETIFF flag is specified it will set a per queue flag to indicate that the queue should be stopped using netif_tx_stop_queue(), rather than discarding frames once full. After reading a frame from the respective stopped queue, a netif_tx_wake_queue() is issued to signal resource availability.
> >>
> >> The per queue TUN_FLOW_CONTROL flag is stored in struct tun_file. This provides the flexibility to enable flow control on all, none or some queues when using IFF_MULTI_QUEUE. When not using IFF_MULTI_QUEUE, IFF_FLOW_CONTROL will apply to the single queue. No changes were made to the default drop frame policy.
> >>
> >> This change adds support for back pressure use cases.
> >>
> >> Reported-by: Brian Adamson <brian.adamson@nrl.navy.mil>
> >> Tested-by: Joseph Giovatto <jgiovatto@djacentlink.com>
> >> Signed-off-by: Steven Galgano <sgalgano@adjacentlink.com>
> > 
> > Please format your commit messages to ~80 columns of text.
> > 
> > It won't be automatically formatted by GIT and in fact it looks ugly
> > with all the wrapping in text based tools.
> > 
> Added optional per queue flow control support using IFF_FLOW_CONTROL. When the 
> IFF_FLOW_CONTROL TUNSETIFF flag is specified it will set a per queue flag to 
> indicate that the queue should be stopped using netif_tx_stop_queue(), rather 
> than discarding frames once full. After reading a frame from the respective 
> stopped queue, a netif_tx_wake_queue() is issued to signal resource 
> availability.
> 
> The per queue TUN_FLOW_CONTROL flag is stored in struct tun_file. This provides 
> the flexibility to enable flow control on all, none or some queues when using 
> IFF_MULTI_QUEUE. When not using IFF_MULTI_QUEUE, IFF_FLOW_CONTROL will apply to 
> the single queue. No changes were made to the default drop frame policy.
> 
> This change adds support for back pressure use cases.
> 
> Reported-by: Brian Adamson <brian.adamson@nrl.navy.mil>
> Tested-by: Joseph Giovatto <jgiovatto@djacentlink.com>
> Signed-off-by: Steven Galgano <sgalgano@adjacentlink.com>
> 

Yes, doing this per-queue is an improvement - but still not ideal.

The issue here is still that a daemon would set the flow control
because it deals with a specific protocol - and affect behaviour of all
potentially unrelated applications - they might deadlock
simply because a packet made its way to tun's qdisc.

I do understand this simple patch works for you for simple setups where
there's more or less a single tun device in the system, but I think it's
worth it to try to address a slightly bigger issue:
both to make the feature more generally applicable, and
to prevent potential problems in case where it's not.

I've been thinking about ways to address it issue, and I think I
see a way, though still a bit vaguely.
Basically, I think the problem would be at least partially solved if we
use a queue that limits packet delay (if I understand correctly
e.g. codel doesn't do this exactly in that it won't drop packets
if queues never fill up).
So instead of QUEUE_STATE_DRV_XOFF tun would set some other bit, that means
"we want to stop transmit queue but can't guarantee we'll
restart it within reasonable time". This bit would also have to be
rate-limited, to prevent not just full deadlock but also performance
degradation.

This could then be done unconditionally: instead of setting
the FLOW_CONTROL bit user would configure this "flow control" queue.

Sorry about posting such rough thoughts, no patch yet but I thought this might
be preferable to silence as I'm going offline for a couple of days.

-- 
MST
