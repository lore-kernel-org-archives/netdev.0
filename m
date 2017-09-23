From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [patch net-next 07/12] mlxsw: spectrum: Add the multicast routing
 offloading logic
Date: Sat, 23 Sep 2017 12:32:11 +0300
Message-ID: <a4193a32-7ba3-a13f-fa21-da247228be74@mellanox.com>
References: <20170921064338.1282-1-jiri@resnulli.us>
 <20170921064338.1282-8-jiri@resnulli.us> <20170921152654.GF27589@lunn.ch>
 <a6852db1-76a2-b4f3-c558-cd4cc0a1309b@mellanox.com>
 <20170922132152.GB31634@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0087.outbound.protection.outlook.com ([104.47.2.87]:36496
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750766AbdIWJcY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 23 Sep 2017 05:32:24 -0400
In-Reply-To: <20170922132152.GB31634@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2017 04:21 PM, Andrew Lunn wrote:
> On Fri, Sep 22, 2017 at 11:36:59AM +0300, Yotam Gigi wrote:
>> On 09/21/2017 06:26 PM, Andrew Lunn wrote:
>>>> +static void mlxsw_sp_mr_route_stats_update(struct mlxsw_sp *mlxsw_sp,
>>>> +					   struct mlxsw_sp_mr_route *mr_route)
>>>> +{
>>>> +	struct mlxsw_sp_mr *mr = mlxsw_sp->mr;
>>>> +	u64 packets, bytes;
>>>> +
>>>> +	if (mr_route->route_action == MLXSW_SP_MR_ROUTE_ACTION_TRAP)
>>>> +		return;
>>>> +
>>>> +	mr->mr_ops->route_stats(mlxsw_sp, mr_route->route_priv, &packets,
>>>> +				&bytes);
>>>> +
>>>> +	switch (mr_route->mr_table->proto) {
>>>> +	case MLXSW_SP_L3_PROTO_IPV4:
>>>> +		mr_route->mfc4->mfc_un.res.pkt = packets;
>>>> +		mr_route->mfc4->mfc_un.res.bytes = bytes;
>>> What about wrong_if and lastuse? 
> Hi Yotam
>
>> wronf_if is updated by ipmr as it is trapped to the CPU.
> Great.
>
>> We did not address lastuse currently, though it can be easily
>> addressed here.
> Please do. I've written multicast routing daemons, where i use it to
> flush out MFCs which are no longer in use. Having it always 0 is going
> to break daemons.

I will. Thanks for the feedback!

>  
>>> Is an mfc with iif on the host, not the switch, not offloaded?
>>
>> I am not sure I followed. What do you mean MFC with iif on the host? you mean
>> MFC with iif that is an external NIC which is not part of the spectrum ASIC?
> Yes. We probably have different perspectives on the world. To
> Mellanox, everything is a switch in a box. In the DSA world, we tend
> to think of having a general purpose machine which also has a switch
> connected. Think of a wireless access point, set top box, passenger
> entertainment system. We have applications on the general purpose
> computer, we have wifi interfaces, cable modems, etc. Think about all
> the different packages in LEDE. We might have a multicast video
> stream, coming from the cable modem being sent over ports of the
> switch to clients.
>
> So when i look at these patches, i try to make sure the general use
> cases works, not just the plain boring Ethernet switch box use cases
> :-)

So when doing it, we did think about multi-ASIC situations, so I think it should
fit :)

>
>> in this case, the route will not be offloaded and all traffic will
>> pass in slowpath.
> O.K. I was just thinking if those counters need to be +=, not =.  But
> either the iif is on the host, or it is in the switch. It cannot be
> both. So = is O.K.
>
> Thanks
> 	Andrew
