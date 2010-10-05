From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: fix WARN_ON when writing to
 bond_master sysfs file
Date: Tue, 5 Oct 2010 09:57:13 +0900
Message-ID: <20101005095713.624ca320@s6510>
References: <20101004202112.GA27897@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40700 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922Ab0JEA5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 20:57:33 -0400
In-Reply-To: <20101004202112.GA27897@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Oct 2010 16:21:12 -0400
Neil Horman <nhorman@tuxdriver.com> wrote:

> Fix a WARN_ON failure in bond_masters sysfs file
> 
> Got a report of this warning recently
> 
> bonding: bond0 is being created...
> ------------[ cut here ]------------
> WARNING: at fs/proc/generic.c:590 proc_register+0x14d/0x185()
> Hardware name: ProLiant BL465c G1
> proc_dir_entry 'bonding/bond0' already registered
> Modules linked in: bonding ipv6 tg3 bnx2 shpchp amd64_edac_mod edac_core
> ipmi_si
> ipmi_msghandler serio_raw i2c_piix4 k8temp edac_mce_amd hpwdt microcode hpsa
> cc
> iss radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded:
> scsi_wai
> t_scan]
> Pid: 935, comm: ifup-eth Not tainted 2.6.33.5-124.fc13.x86_64 #1
> Call Trace:
> [<ffffffff8104b54c>] warn_slowpath_common+0x77/0x8f
> [<ffffffff8104b5b1>] warn_slowpath_fmt+0x3c/0x3e
> [<ffffffff8114bf0b>] proc_register+0x14d/0x185
> [<ffffffff8114c20c>] proc_create_data+0x87/0xa1
> [<ffffffffa0211e9b>] bond_create_proc_entry+0x55/0x95 [bonding]
> [<ffffffffa0215e5d>] bond_init+0x95/0xd0 [bonding]
> [<ffffffff8138cd97>] register_netdevice+0xdd/0x29e
> [<ffffffffa021240b>] bond_create+0x8e/0xb8 [bonding]
> [<ffffffffa021c4be>] bonding_store_bonds+0xb3/0x1c1 [bonding]
> [<ffffffff812aec85>] class_attr_store+0x27/0x29
> [<ffffffff8115423d>] sysfs_write_file+0x10f/0x14b
> [<ffffffff81101acf>] vfs_write+0xa9/0x106
> [<ffffffff81101be2>] sys_write+0x45/0x69
> [<ffffffff81009b02>] system_call_fastpath+0x16/0x1b
> ---[ end trace a677c3f7f8b16b1e ]---
> bonding: Bond creation failed.
> 
> It happens because a user space writer to bond_master can try to register and
> already existing bond interface name.  Fix it by teaching bond_create to check
> for the existance of devices with that name first in cases where a non-NULL name
> parameter has been passed in
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> bond_main.c |   16 +++++++++++++++-
> 1 file changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index fb70c3e..10e4ffe 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -5148,7 +5148,7 @@ static struct rtnl_link_ops bond_link_ops __read_mostly = {
>   */
>  int bond_create(struct net *net, const char *name)
>  {
> -	struct net_device *bond_dev;
> +	struct net_device *bond_dev, *check_dev;
>  	int res;
>  
>  	rtnl_lock();
> @@ -5168,6 +5168,20 @@ int bond_create(struct net *net, const char *name)
>  		res = dev_alloc_name(bond_dev, "bond%d");
>  		if (res < 0)
>  			goto out;
> +	} else {
> +		/*
> +		 * If we're given a name to register
> +		 * we need to ensure that its not already
> +		 * registered
> +		 */
> +		check_dev = dev_get_by_name(net, name);
> +
> +		res = (check_dev) ? 0 : -EEXIST;
> +
> +		dev_put(check_dev);
> +
> +		if (res)
> +			goto out;
>  	}
>  
>  	res = register_netdevice(bond_dev);

Why is this necessary?
register_netdevice does already check for duplicate name so please
use it's return value instead

If that doesn't work then use __dev_get_by_name to avoid
ref count (ie dev_put).

