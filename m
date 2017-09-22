From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next 07/12] mlxsw: spectrum: Add the multicast
 routing offloading logic
Date: Fri, 22 Sep 2017 15:21:52 +0200
Message-ID: <20170922132152.GB31634@lunn.ch>
References: <20170921064338.1282-1-jiri@resnulli.us>
 <20170921064338.1282-8-jiri@resnulli.us>
 <20170921152654.GF27589@lunn.ch>
 <a6852db1-76a2-b4f3-c558-cd4cc0a1309b@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:52491 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751926AbdIVNV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 09:21:56 -0400
Content-Disposition: inline
In-Reply-To: <a6852db1-76a2-b4f3-c558-cd4cc0a1309b@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 22, 2017 at 11:36:59AM +0300, Yotam Gigi wrote:
> On 09/21/2017 06:26 PM, Andrew Lunn wrote:
> >> +static void mlxsw_sp_mr_route_stats_update(struct mlxsw_sp *mlxsw_sp,
> >> +					   struct mlxsw_sp_mr_route *mr_route)
> >> +{
> >> +	struct mlxsw_sp_mr *mr = mlxsw_sp->mr;
> >> +	u64 packets, bytes;
> >> +
> >> +	if (mr_route->route_action == MLXSW_SP_MR_ROUTE_ACTION_TRAP)
> >> +		return;
> >> +
> >> +	mr->mr_ops->route_stats(mlxsw_sp, mr_route->route_priv, &packets,
> >> +				&bytes);
> >> +
> >> +	switch (mr_route->mr_table->proto) {
> >> +	case MLXSW_SP_L3_PROTO_IPV4:
> >> +		mr_route->mfc4->mfc_un.res.pkt = packets;
> >> +		mr_route->mfc4->mfc_un.res.bytes = bytes;
> > What about wrong_if and lastuse? 

Hi Yotam

> wronf_if is updated by ipmr as it is trapped to the CPU.

Great.

> We did not address lastuse currently, though it can be easily
> addressed here.

Please do. I've written multicast routing daemons, where i use it to
flush out MFCs which are no longer in use. Having it always 0 is going
to break daemons.
 
> > Is an mfc with iif on the host, not the switch, not offloaded?
> 
> 
> I am not sure I followed. What do you mean MFC with iif on the host? you mean
> MFC with iif that is an external NIC which is not part of the spectrum ASIC?

Yes. We probably have different perspectives on the world. To
Mellanox, everything is a switch in a box. In the DSA world, we tend
to think of having a general purpose machine which also has a switch
connected. Think of a wireless access point, set top box, passenger
entertainment system. We have applications on the general purpose
computer, we have wifi interfaces, cable modems, etc. Think about all
the different packages in LEDE. We might have a multicast video
stream, coming from the cable modem being sent over ports of the
switch to clients.

So when i look at these patches, i try to make sure the general use
cases works, not just the plain boring Ethernet switch box use cases
:-)

> in this case, the route will not be offloaded and all traffic will
> pass in slowpath.

O.K. I was just thinking if those counters need to be +=, not =.  But
either the iif is on the host, or it is in the switch. It cannot be
both. So = is O.K.

Thanks
	Andrew
