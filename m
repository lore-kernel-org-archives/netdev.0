From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Sat, 09 Jun 2007 15:23:20 -0400
Message-ID: <1181417000.4043.34.camel@localhost>
References: <1181168020.4064.46.camel@localhost>
	 <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com>
	 <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D69C@nekter>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Alex Aizman <aaizman@neterion.com>
To: Leonid Grossman <Leonid.Grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:28825 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757577AbXFITXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 15:23:25 -0400
Received: by py-out-1112.google.com with SMTP id a29so1840420pyi
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2007 12:23:25 -0700 (PDT)
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D69C@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-09-06 at 10:58 -0400, Leonid Grossman wrote:

> IMHO, in addition to current Intel and Neterion NICs, some/most upcoming
> NICs are likely to be multiqueue, since virtualization emerges as a
> major driver for hw designs (there are other things of course that drive
> hw, but these are complimentary to multiqueue).
> 
> PCI-SIG IOV extensions for pci spec are almost done, and a typical NIC
> (at least, typical 10GbE NIC that supports some subset of IOV) in the
> near future is likely to have at least 8  independent channels with its
> own tx/rx queue, MAC address, msi-x vector(s), reset that doesn't affect
> other channels, etc.

Leonid - any relation between that and data center ethernet? i.e
http://www.ieee802.org/3/ar/public/0503/wadekar_1_0503.pdf
It seems to desire to do virtualization as well. 
Is there any open spec for PCI-SIG IOV?

> Basically, each channel could be used as an independent NIC that just
> happens to share pci bus and 10GbE PHY with other channels (but has
> per-channel QoS and throughput guarantees).

Sounds very similar to data centre ethernet - except data centre
ethernet seems to map "channels" to rings; whereas the scheme you
describe maps a channel essentially to a virtual nic which seems to read
in the common case as a single tx, single rx ring. Is that right? If
yes, we should be able to do the virtual nics today without any changes
really since each one appears as a separate NIC. It will be a matter of
probably boot time partitioning and parametrization to create virtual
nics (ex of priorities of each virtual NIC etc).

> In a non-virtualized system, such NICs could be used in a mode when each
> channel runs on one core; this may eliminate some locking...  This mode
> will require btw deterministic session steering, current hashing
> approach in the patch is not sufficient; this is something we can
> contribute once Peter's code is in. 

I can actually see how the PCI-SIG approach using virtual NIC approach
could run on multiple CPUs (since each is no different from a NIC that
we have today). And our current Linux steering would also work just
fine.

In the case of non-virtual NICs, i am afraid i dont think it is as easy
as simple session steering - if you want to be generic that is; you may
wanna consider a more complex connection tracking i.e a grouping of
sessions as the basis for steering to a tx ring (and therefore tying to
a specific CPU).
If you are an ISP or a data center with customers partitioned based on
simple subnets, then i can see a simple classification based on subnets
being tied to a hw ring/CPU. And in such cases simple flow control on a
per ring basis makes sense.
Have you guys experimented on the the non-virtual case? And are you
doing the virtual case as a pair of tx/rx being a single virtual nic?

> In general, a consensus on kernel support for multiqueue NICs will be
> beneficial since multiqueue HW is here and other stacks already taking
> advantage of it. 

My main contention with the Peters approach has been to do with the 
propagating of flow control back to the qdisc queues. However, if this
PCI SIG standard is also desiring such an approach then it will shed a
different light.

cheers,
jamal

