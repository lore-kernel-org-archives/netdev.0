From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net] net/bonding: Enforce active-backup policy for IPoIB
 bonds
Date: Wed, 20 Jul 2016 10:20:48 -0700
Message-ID: <20160720172048.GF1984@gospo.cumulusnetworks.com>
References: <1469025860-15690-1-git-send-email-saeedm@mellanox.com>
 <20160720164735.GD1984@gospo.cumulusnetworks.com>
 <845.1469034827@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Veaceslav Falico <vfalico@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Mark Bloch <markb@mellanox.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34791 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbcGTRVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 13:21:01 -0400
Received: by mail-pf0-f171.google.com with SMTP id p64so21100979pfb.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 10:21:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <845.1469034827@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 10:13:47AM -0700, Jay Vosburgh wrote:
> Andy Gospodarek <gospo@cumulusnetworks.com> wrote:
> 
> >On Wed, Jul 20, 2016 at 05:44:20PM +0300, Saeed Mahameed wrote:
> >> From: Mark Bloch <markb@mellanox.com>
> >> 
> >> When using an IPoIB bond currently only active-backup mode is a valid
> >> use case and this commit strengthens it.
> >> 
> >> Since commit 2ab82852a270 ("net/bonding: Enable bonding to enslave
> >> netdevices not supporting set_mac_address()") was introduced till
> >> 4.7-rc1, IPoIB didn't support the set_mac_address ndo, and hence
> >> the fail over mac policy always applied to IPoIB bonds.
> >> 
> >> With the introduction of commit 492a7e67ff83 ("IB/IPoIB: Allow setting
> >> the device address"), that doesn't hold and practically IPoIB bonds are
> >> broken as of that. To fix it, lets go to fail over mac if the device
> >> doesn't support the ndo OR this is IPoIB device.
> >> 
> >> As a by-product, this commit also prevents a stack corruption which
> >> occurred when trying to copy 20 bytes (IPoIB) device address
> >> to a sockaddr struct that has only 16 bytes of storage.
> >> 
> >> Signed-off-by: Mark Bloch <markb@mellanox.com>
> >> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> >> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> >> ---
> >>  drivers/net/bonding/bond_main.c | 10 +++++++++-
> >>  1 file changed, 9 insertions(+), 1 deletion(-)
> >> 
> >> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> >> index a2afa3b..ccd4003 100644
> >> --- a/drivers/net/bonding/bond_main.c
> >> +++ b/drivers/net/bonding/bond_main.c
> >> @@ -1422,7 +1422,15 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> >>  		return -EINVAL;
> >>  	}
> >>  
> >> -	if (slave_ops->ndo_set_mac_address == NULL) {
> >> +	if (slave_dev->type == ARPHRD_INFINIBAND &&
> >> +	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
> >> +		netdev_warn(bond_dev, "Type (%d) supports only active-backup mode\n",
> >> +			    slave_dev->type);
> >
> >Seems like we should propagate the failure back to the caller.
> >Something like this?
> >
> >		return -EOPNOTSUPP;
> 
> 	Agreed, although I think it needs to be
> 
> 	res = -EOPNOTSUPP;
> 	goto err_undo_flags;
> 

Good catch, Jay.  That was _actually_ what I meant to put as we do want
to unroll everything, but apparently my paste buffer was wrong!

> 	The code has to undo the the ARPHRD_INFINIBAND setting in
> bond_dev->type and other stuff done by bond_setup_by_slave.  If we don't
> switch the fields back to the ARPHRD_ETHER related values, then we could
> have an invalid dereference on the header_ops pointer if something
> unloads the IB module.
> 
> 	-J
> 
> >> +		goto err_undo_flags;
> >> +	}
> >> +
> >> +	if (!slave_ops->ndo_set_mac_address ||
> >> +	    slave_dev->type == ARPHRD_INFINIBAND) {
> >>  		netdev_warn(bond_dev, "The slave device specified does not support setting the MAC address\n");
> >>  		if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP &&
> >>  		    bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
> >
> >The rest of the patch seems logical, so I'm fine with it.
> 
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
