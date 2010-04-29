From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC][PATCH v4 00/18] Provide a zero-copy method on KVM
	virtio-net.
Date: Thu, 29 Apr 2010 09:33:02 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D7902DF999649@shsmsx502.ccr.corp.intel.com>
References: <1272187206-18534-17-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-18-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-19-git-send-email-xiaohui.xin@intel.com>
 <20100425.025529.123989625.davem@davemloft.net>
 <20100425104604.GA10238@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100425104604.GA10238@redhat.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > The idea is simple, just to pin the guest VM user space and then let
> > host NIC driver has the chance to directly DMA to it.
> >
> >Isn't it much easier to map the RX ring of the network device into the
> >guest's address space, have DMA map calls translate guest addresses to
> >physical/DMA addresses as well as do all of this crazy page pinning
> >stuff, and provide the translations and protections via the IOMMU?

>This means we need guest know how the specific network device works.
>So we won't be able to, for example, move guest between different hosts.
>There are other problems: many physical systems do not have an iommu,
>some guest OS-es do not support DMA map calls, doing VM exit
>on each DMA map call might turn out to be very slow. And so on.

This solution is what now we can think of to implement zero-copy. Some
modifications are made to net core to try to avoid network device driver
changes.  The major change is to __alloc_skb(), in which we added a dev
parameter to indicate whether the device will DMA to/from guest/user buffer
which is pointed by host skb->data. We also modify skb_release_data() and
skb_reserve(). We made it now works with ixgbe driver with PS mode disabled,
and got some performance data with it.
  
	using netperf with GSO/TSO disabled, 10G NIC, 
	disabled packet split mode, with raw socket case compared to vhost.

	bindwidth will be from 1.1Gbps to 1.7Gbps
	CPU % from 120%-140% to 140%-160%

We are now trying to get decent performance data with advanced features.
Do you have any other concerns with this solution? 

>> What's being proposed here looks a bit over-engineered.

>This is an attempt to reduce overhead for virtio (paravirtualization).
>'Don't use PV' is kind of an alternative, but I do not
>think it's a simpler one.

-- 
MST
