From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Mon, 19 Mar 2007 07:19:34 +0200
Message-ID: <20070319051934.GS11078@mellanox.co.il>
References: <m3tzwi8a20.fsf@maxwell.lnxi.com>
	<20070318223653.GO11078@mellanox.co.il>
	<20070318224234.GP11078@mellanox.co.il>
	<20070318.171337.112622504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070318.171337.112622504.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

> Quoting David Miller <davem@davemloft.net>:
> Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
> 
> From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
> Date: Mon, 19 Mar 2007 00:42:34 +0200
> 
> > > Quoting Michael S. Tsirkin <mst@dev.mellanox.co.il>:
> > > Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
> > > 
> > > > Quoting Eric W. Biederman <ebiederman@lnxi.com>:
> > > > Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
> > > > 
> > > > "Michael S. Tsirkin" <mst@dev.mellanox.co.il> writes:
> > > > 
> > > > >> > Why is neighbour->dev changed here?
> > > > >> 
> > > > >> It holds reference to device and prevents its destruction.
> > > > >> If dst is held somewhere, we cannot destroy the device and deadlock
> > > > >> while unregister.
> > > > >
> > > > > BTW, can this ever happen for the loopback device itself?
> > > > > Is it ever unregistered?
> > > > 
> > > > Well I don't think the loopback device is currently but as soon
> > > > as we get network namespace support we will have multiple loopback
> > > > devices and they will get unregistered when we remove the network
> > > > namespace.
> > > 
> > > Hmm. Then the code moving dst->dev to point to the loopback
> > > device will have to be fixed too. I'll post a patch a bit later.
> > 
> > Does this look sane (untested)?
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@dev.mellanox.co.il>
> 
> You can't point it at NULL, we don't point it at loopback
> just for fun.
> 
> There can be asynchronous paths elsewhere in the networking still
> referencing the neigh or dst and they will (correctly) feel free to
> derefence whatever device is hanging there.  So transitioning
> to NULL is invalid.
> 
> You guys will need to come up with a better solution for this silly
> situation with network namespaces.  Loopback is always available to
> point dead routes and neighbour entries at, and this assumption is
> massively rooted in the networking.

Yes, I see this now.

I guess it's best to focus on the original problem with dst_ifdown breaking
infiniband for now.

For that, we have to audit all the places where dst->neighbour is dereferenced for
RCU safety, and this is already a massive task.

-- 
MST
