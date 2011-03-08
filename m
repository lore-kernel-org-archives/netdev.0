From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch V2] bonding: fix netpoll in active-backup mode
Date: Tue, 8 Mar 2011 16:41:31 -0500
Message-ID: <20110308214131.GE19669@hmsreliant.think-freely.org>
References: <1299578336-5888-1-git-send-email-amwang@redhat.com>
 <20110308212405.GX11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40851 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329Ab1CHVll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 16:41:41 -0500
Content-Disposition: inline
In-Reply-To: <20110308212405.GX11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2011 at 04:24:05PM -0500, Andy Gospodarek wrote:
> On Tue, Mar 08, 2011 at 05:58:56PM +0800, Amerigo Wang wrote:
> > V2: avoid calling slave_diable_netpoll() with write_lock_bh() held.
> > 
> > netconsole doesn't work in active-backup mode, because we don't do anything
> > for nic failover in active-backup mode. We should disable netpoll on the
> > failing slave when it is detected down and enable netpoll when it becomes
> > the active slave.
> > 
> > Tested by ifdown the current active slave and ifup it again for several times,
> > netconsole works well.
> > 
> > Signed-off-by: WANG Cong <amwang@redhat.com>
> > Cc: Neil Horman <nhorman@tuxdriver.com>
> > 
> 
> It seems like you are going to a lot of trouble to fix a bug where
> netpoll will not be setup on any interface that is down when enslaved.
> That seems to be the only path that would not have slave->np setup
> properly at enslavement.
> 
> Did you ever try just this?
> 
+1, this is what I was suggesting.  Just setup netpoll on all the slaves
regardless of status, and let their netpoll state follow that of the bond.
Neil

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 0592e6d..8d93044 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1352,8 +1352,6 @@ static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
>  
>  	read_lock(&bond->lock);
>  	bond_for_each_slave(bond, slave, i) {
> -		if (!IS_UP(slave->dev))
> -			continue;
>  		err = slave_enable_netpoll(slave);
>  		if (err) {
>  			__bond_netpoll_cleanup(bond);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
