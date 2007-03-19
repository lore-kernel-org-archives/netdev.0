From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Mon, 19 Mar 2007 11:55:45 +0200
Message-ID: <20070319095545.GF8386@mellanox.co.il>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318195355.GB11078@mellanox.co.il>
	<20070318201826.GB27004@ms2.inr.ac.ru>
	<20070319093632.GB8386@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070319093632.GB8386@mellanox.co.il>
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

> Quoting Michael S. Tsirkin <mst@dev.mellanox.co.il>:
> Subject: Re: dst_ifdown breaks infiniband?
> 
> > > Any simpler ideas?
> > 
> > Well, if inifiniband destructor really needs to take that lock... no.
> > Right now I do not see.
> 
> OK, this is actually not hard to fix - for infiniband, we can just look at
> neighbour->dev->type or compare neighbour->dev and
> neighbour->parms->dev - if they are different, device is being unregistered,
> so we do not need to do anything in the destructor.
> 
> I'll send a patch to openfabrics, shortly.
> 
> However, after implementing this fix, I hit what could be use after
> free at module unloading. Dave, Alexey, Roland, could you take a look at
> the following please?
> 
> Works fine for me (survived a couple of hours of crazy device
> loading/unloading/up/down/hotplug + link data and state activity)
> and seems to fix the issue.
> 
> ---------
> 
> If a device driver sets neigh_destructor in neigh_params, this could
> get called after the device has been unregistered and the driver module
> removed.
> 
> This is an old bug, but apparently, started to get triggered more infiniband
> after recent multicast and connected mode changes.
> 
> Fix this by delaying dev_put until the neigh_params object is removed.
> 
> Signed-off-by: Michael S. Tsirkin <mst@dev.mellanox.co.il>

The problem seems real enough but the fix seems no good -
device unregister gets blocked with
	unregister_netdevice: waiting for ib0 to become free. Usage count = 1

It seems the parms object can survive indefinitely after device is removed.

How about creating a new parms object in dst_ifdown, and pointing neighbour
to this?

Would that work?
The advantage of this approach is that neigh->parms is already protected
by RCU.

-- 
MST
