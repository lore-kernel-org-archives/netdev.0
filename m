From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: Question regarding failure utilizing bonding mode 5
 (balance-tlb)
Date: Tue, 1 Oct 2013 12:56:43 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52ADFFFCF@SJEXCHMB10.corp.ad.broadcom.com>
References: <1375333968.21294.30.camel@lb-tlvb-yuvalmin.il.broadcom.com>
 <7717.1375412975@death.nxdomain>
 <979A8436335E3744ADCD3A9F2A2B68A52ACF959B@SJEXCHMB10.corp.ad.broadcom.com>
 <12779.1375476808@death.nxdomain>
 <979A8436335E3744ADCD3A9F2A2B68A52ACF96BB@SJEXCHMB10.corp.ad.broadcom.com>
 <979A8436335E3744ADCD3A9F2A2B68A52ADF1DE5@SJEXCHMB10.corp.ad.broadcom.com>
 <20130930212440.GC24830@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Jay Vosburgh" <fubar@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>
To: "Veaceslav Falico" <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3944 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab3JAM4z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 08:56:55 -0400
In-Reply-To: <20130930212440.GC24830@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, Sep 30, 2013 at 11:30:40AM +0000, Yuval Mintz wrote:
> >> > >Again, I think the permanent address is restored only when the bond
> >> > >releases the slave, which I don't think happens when the slave is
> unloaded.
> >> >
> >> > 	Given a bond0 with two slaves, eth0 and eth1, in tlb mode, eth0
> >> > being the active,
> >> >
> >> > 	1) "ip link set dev eth0 down" which will fail over to eth1
> >> > 		(swapping the contents of their dev_addr fields).
> >> >
> >> > 	2) "ip link set dev eth0 up" eth0 comes back up, reprograms its
> >> > 		MAC to the wrong thing (what was in dev_addr).
> >> >
> >> > 	3) repeat steps 1 and 2 for eth1
> >> >
> >> > 	Is this correct?
> >> >
> >>
> >> Yes, sorry for the earlier confusion.
> >> I think in the case described `alb_swap_mac_addr()' will be called,
> >> replacing eth0 and eth1's dev_addr, causing eth0 to have dev_addr
> >> which defers from  the bond device's. Once eth0 reloads, it will use
> >> the different MAC address for configuring FW/HW.
> >
> >Hi,
> >
> >Did you by any chance had the time to look at this issue?
> 
> Hi Yuval,
> 
> Sorry for getting into the discussion - but I've tried to understand the
> problem and, possibly, find a fix.
> 
> I'm not sure that I completely understand it, and I don't have currently
> hardware on which to test it (though I might have it in the nearest
> future), so, again, I really am not sure that I won't suggest something
> completely stupid.
> 
> Anyway, that being said, I hope that the following patch might fix the
> problem. I've described the bug and the fix in the changelog, and the code
> is pretty self-explanitory.
> 
> And even if the patch fixes the issue - I'm not sure that it's the proper
> and correct way to do it. But it's definitely worth a try... So, if it's
> possible, could you please test this patch and see if it fixes it?
> 
> Warning: I've just compile-tested it.
> 
> So, FWIW...
> 

Like you, I don't know if yours is the proper way of fixing the issue - but it did
seem to fix it (the scenario that was described, at least)

Tested-by: Yuval Mintz <yuvalmin@broadcom.com>

Thanks,
Yuval

>  From 87e6c584b0ae0f0261610d60cf83778feb9c1edb Mon Sep 17
> 00:00:00 2001
> From: Veaceslav Falico <vfalico@redhat.com>
> Date: Mon, 30 Sep 2013 23:14:23 +0200
> Subject: [PATCH] bonding: ensure that TLB mode's active slave has correct
> mac filter
> 
> Currently, in TLB mode we change mac addresses only by memcpy-ing the to
> net_device->dev_addr, without actually setting them via
> dev_set_mac_address(). This permits us to receive all the traffic always on
> one mac address.
> 
> However, in case the interface flips, some drivers might enforce the
> mac filtering for its FW/HW based on current ->dev_addr, and thus we won't
> be able to receive traffic on that interface, in case it will be selected
> as active in TLB mode.
> 
> Fix it by setting the mac address forcefully on every new active slave that
> we select in TLB mode.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>   drivers/net/bonding/bond_alb.c | 17 +++++++++++++++++
>   1 file changed, 17 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index e960418..576ccea 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -1699,6 +1699,23 @@ void bond_alb_handle_active_change(struct
> bonding *bond, struct slave *new_slave
> 
>   	ASSERT_RTNL();
> 
> +	/* in TLB mode, the slave might flip down/up with the old dev_addr,
> +	 * and thus filter bond->dev_addr's packets, so force bond's mac
> +	 */
> +	if (bond->params.mode == BOND_MODE_TLB) {
> +		struct sockaddr sa;
> +		u8 tmp_addr[ETH_ALEN];
> +
> +		memcpy(tmp_addr, new_slave->dev->dev_addr, ETH_ALEN);
> +
> +		memcpy(sa.sa_data, bond->dev->dev_addr, bond->dev-
> >addr_len);
> +		sa.sa_family = bond->dev->type;
> +		/* we don't care if it can't change its mac, best effort */
> +		dev_set_mac_address(new_slave->dev, &sa);
> +
> +		memcpy(new_slave->dev->dev_addr, tmp_addr, ETH_ALEN);
> +	}
> +
>   	/* curr_active_slave must be set before calling alb_swap_mac_addr
> */
>   	if (swap_slave) {
>   		/* swap mac address */
> --
> 1.8.4
> 
> 
> >
> >Thanks,
> >Yuval
> >
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
