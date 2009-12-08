From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/1] Defer skb allocation for both mergeable buffers
	and big packets in virtio_net
Date: Tue, 8 Dec 2009 14:21:34 +0200
Message-ID: <20091208122134.GA17286@redhat.com>
References: <1258697359.7416.14.camel@localhost.localdomain> <200911231123.18898.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9082 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754290AbZLHMYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 07:24:16 -0500
Content-Disposition: inline
In-Reply-To: <200911231123.18898.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2009 at 11:23:18AM +1030, Rusty Russell wrote:
> On Fri, 20 Nov 2009 04:39:19 pm Shirley Ma wrote:
> > Guest virtio_net receives packets from its pre-allocated vring 
> > buffers, then it delivers these packets to upper layer protocols
> > as skb buffs. So it's not necessary to pre-allocate skb for each
> > mergable buffer, then frees it when it's useless. 
> > 
> > This patch has deferred skb allocation when receiving packets for
> > both big packets and mergeable buffers. It reduces skb pre-allocations 
> > and skb_frees.
> > 
> > Based on Mickael & Avi's suggestion. A destroy function has been created
> > to push virtio free buffs to vring for unused pages, and used page private
> > to maintain page list.
> > 
> > I didn't touch small packet skb allocation to avoid extra copies for small
> > packets.
> > 
> > This patch has tested and measured against 2.6.32-rc5 git. It is built again
> >  2.6.32-rc7 kernel. Tests have been done for small packets, big packets and
> > mergeable buffers.
> > 
> > The single netperf TCP_STREAM performance improved for host to guest. 
> > It also reduces UDP packets drop rate.
> > 
> > The netperf laptop results were:
> > 
> > mtu=1500
> > netperf -H xxx -l 120
> > 
> > 		w/o patch	w/i patch (two runs)	
> > guest to host:  3336.84Mb/s   3730.14Mb/s ~ 3582.88Mb/s
> > 
> > host to guest:  3165.10Mb/s   3370.39Mb/s ~ 3407.96Mb/s
> 
> Nice!
> 
> Is this using mergeable_rx_bufs?  Or just big_packets?
> 
> I'd like to drop big packet support from our driver, but I don't know
> how many kvm hosts will not offer mergable rx bufs yet.


One issue with mergeable buffers is that they can work well with zero
copy RX, but only if hardware merges RX buffers in the same way virtio
does.

However, I suspect that most hardware can not do this, and simply
scatters data to a buffer you give it and then reports completion.
For such simple hardware, RX can work without extra data copies when guest
uses big packets (just scatter data into guest buffers), but when guest
tries to use mergeable buffers, host will have to merge them and post a
single big packet to hardware.  Thus host will be able to only post
about 16 buffers to hardware, and performance will suffer.


-- 
MST
