From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] Flow Control and Port Mirroring
Date: Sat, 30 Oct 2010 11:59:33 +0900
Message-ID: <20101030025932.GG12842@verge.net.au>
References: <20101028115403.GA16206@verge.net.au>
 <AANLkTi=QXBi4wmJS1TY0P=s+11Vjp0v=AfWOdFb4vrCj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, "Michael S. Tsirkin" <mst@redhat.com>,
	kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=QXBi4wmJS1TY0P=s+11Vjp0v=AfWOdFb4vrCj@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ CCed VHOST contacts ]

On Thu, Oct 28, 2010 at 01:22:02PM -0700, Jesse Gross wrote:
> On Thu, Oct 28, 2010 at 4:54 AM, Simon Horman <horms@verge.net.au> wrote:
> > My reasoning is that in the non-mirroring case the guest is
> > limited by the external interface through wich the packets
> > eventually flow - that is 1Gbit/s. But in the mirrored either
> > there is no flow control or the flow control is acting on the
> > rate of dummy0, which is essentailly infinate.
> >
> > Before investigating this any further I wanted to ask if
> > this behaviour is intentional.
> 
> It's not intentional but I can take a guess at what is happening.
> 
> When we send the packet to a mirror, the skb is cloned but only the
> original skb is charged to the sender.  If the original packet is
> delivered to localhost then it will be freed quickly and no longer
> accounted for, despite the fact that the "real" packet is still
> sitting in the transmit queue on the NIC.  The UDP stack will then
> send the next packet, limited only by the speed of the CPU.

That would explain what I have observed.

> Normally, this would be tracked by accounting for the memory charged
> to the socket.  However, I know that Xen tracks whether the actual
> pages of memory have been freed, which should avoid this problem since
> the memory won't be released util the last packet has been sent.  I
> don't know what KVM virtio does but I'm guessing that it similar to
> the former, since this problem is occurring.

I am also familiar of how Xen tracks pages but less sure of the
virtio side of things.

> While it would be easy to charge the socket for all clones, I also
> want to be careful about over accounting of the same data, leading to
> a very small effective socket buffer.

Agreed, we don't want to see over-charging.

