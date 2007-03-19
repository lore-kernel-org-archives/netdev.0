From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Sun, 18 Mar 2007 17:13:37 -0700 (PDT)
Message-ID: <20070318.171337.112622504.davem@davemloft.net>
References: <m3tzwi8a20.fsf@maxwell.lnxi.com>
	<20070318223653.GO11078@mellanox.co.il>
	<20070318224234.GP11078@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederman@lnxi.com, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: mst@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58915
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964817AbXCSANi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 20:13:38 -0400
In-Reply-To: <20070318224234.GP11078@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Date: Mon, 19 Mar 2007 00:42:34 +0200

> > Quoting Michael S. Tsirkin <mst@dev.mellanox.co.il>:
> > Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
> > 
> > > Quoting Eric W. Biederman <ebiederman@lnxi.com>:
> > > Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
> > > 
> > > "Michael S. Tsirkin" <mst@dev.mellanox.co.il> writes:
> > > 
> > > >> > Why is neighbour->dev changed here?
> > > >> 
> > > >> It holds reference to device and prevents its destruction.
> > > >> If dst is held somewhere, we cannot destroy the device and deadlock
> > > >> while unregister.
> > > >
> > > > BTW, can this ever happen for the loopback device itself?
> > > > Is it ever unregistered?
> > > 
> > > Well I don't think the loopback device is currently but as soon
> > > as we get network namespace support we will have multiple loopback
> > > devices and they will get unregistered when we remove the network
> > > namespace.
> > 
> > Hmm. Then the code moving dst->dev to point to the loopback
> > device will have to be fixed too. I'll post a patch a bit later.
> 
> Does this look sane (untested)?
> 
> Signed-off-by: Michael S. Tsirkin <mst@dev.mellanox.co.il>

You can't point it at NULL, we don't point it at loopback
just for fun.

There can be asynchronous paths elsewhere in the networking still
referencing the neigh or dst and they will (correctly) feel free to
derefence whatever device is hanging there.  So transitioning
to NULL is invalid.

You guys will need to come up with a better solution for this silly
situation with network namespaces.  Loopback is always available to
point dead routes and neighbour entries at, and this assumption is
massively rooted in the networking.
