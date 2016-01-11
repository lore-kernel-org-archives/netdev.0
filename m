From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net v2] bonding: Prevent IPv6 link local address on
 enslaved devices
Date: Mon, 11 Jan 2016 16:08:48 -0500
Message-ID: <20160111210845.GB51745@gospo.home.greyhouse.net>
References: <1452518923-9420-1-git-send-email-kheiss@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
To: Karl Heiss <kheiss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:35986 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbcAKVIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 16:08:52 -0500
Received: by mail-qg0-f51.google.com with SMTP id e32so324326013qgf.3
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 13:08:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452518923-9420-1-git-send-email-kheiss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 08:28:43AM -0500, Karl Heiss wrote:
> Commit 1f718f0f4f97 ("bonding: populate neighbour's private on enslave")
> undoes the fix provided by commit c2edacf80e15 ("bonding / ipv6: no addrconf
> for slaves separately from master") by effectively setting the slave flag
> after the slave has been opened.  If the slave comes up quickly enough, it
> will go through the IPv6 addrconf before the slave flag has been set and
> will get a link local IPv6 address.
> 
> In order to ensure that addrconf knows to ignore the slave devices on state
> change, set IFF_SLAVE before dev_open() during bonding enslavement.
> 
> Fixes: 1f718f0f4f97 ("bonding: populate neighbour's private on enslave")
> 
> Signed-off-by: Karl Heiss <kheiss@gmail.com>

Good find.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
> - Changes since 'v1':
>   - Revert clearing the IFF_SLAVE flag later during bond release so that
>     RTM_NEWLINK messages will correctly reflect the slave state.
>   - Update commit message for clarity.
> ---
>  drivers/net/bonding/bond_main.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 9e0f8a7..f1692e4 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1207,7 +1207,6 @@ static int bond_master_upper_dev_link(struct net_device *bond_dev,
>  	err = netdev_master_upper_dev_link_private(slave_dev, bond_dev, slave);
>  	if (err)
>  		return err;
> -	slave_dev->flags |= IFF_SLAVE;
>  	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL);
>  	return 0;
>  }
> @@ -1465,6 +1464,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		}
>  	}
>  
> +	/* set slave flag before open to prevent IPv6 addrconf */
> +	slave_dev->flags |= IFF_SLAVE;
> +
>  	/* open the slave since the application closed it */
>  	res = dev_open(slave_dev);
>  	if (res) {
> @@ -1725,6 +1727,7 @@ err_close:
>  	dev_close(slave_dev);
>  
>  err_restore_mac:
> +	slave_dev->flags &= ~IFF_SLAVE;
>  	if (!bond->params.fail_over_mac ||
>  	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
>  		/* XXX TODO - fom follow mode needs to change master's
> -- 
> 1.7.1
> 
