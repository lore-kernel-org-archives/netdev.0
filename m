From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] bonding: utilize notifier callbacks to detect slave
 link state changes
Date: Fri, 8 Jan 2016 18:18:11 +0800
Message-ID: <568F8CE3.8040406@gmail.com>
References: <30904.1452233570@famine>
 <1452238910-13277-1-git-send-email-zyjzyj2000@gmail.com>
 <1452238910-13277-2-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, mkubecek@suse.cz, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org,
	boris.shteinbock@windriver.com
To: jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36503 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795AbcAHKST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 05:18:19 -0500
Received: by mail-pa0-f68.google.com with SMTP id a20so16289539pag.3
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 02:18:19 -0800 (PST)
In-Reply-To: <1452238910-13277-2-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jay

I delved into your test patch. I noticed that bond_set_slave_link_state 
would call bond_netdev_notify_work.
And your patch is based on netdev notifier.

Will it result into a notifier loop? That is, bonding driver receives 
notifier, then bonding driver sends notifier.
In the end, there are more and more notifier.

How do you think about this?

Thanks a lot.
Zhu Yanjun

On 01/08/2016 03:41 PM, zyjzyj2000@gmail.com wrote:
> From: Zhu Yanjun <yanjun.zhu@windriver.com>
>
> This patch modifies bonding to utilize notifier callbacks to
> detect slave link state changes.  It is intended to be used with miimon
> set to zero, and does not support the updelay or downdelay options to
> bonding.  It's not as complicated as it looks; most of the change set is
> to break out the inner loop of bond_miimon_inspect into its own
> function.
>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
> ---
>   drivers/net/bonding/bond_main.c |  154 ++++++++++++++++++++-------------------
>   1 file changed, 78 insertions(+), 76 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 9e0f8a7..9a0e69e 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1977,101 +1977,100 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
>   /*-------------------------------- Monitoring -------------------------------*/
>   
>   /* called with rcu_read_lock() */
> -static int bond_miimon_inspect(struct bonding *bond)
> +static int bond_miimon_inspect_slave(struct bonding *bond, struct slave *slave)
>   {
> -	int link_state, commit = 0;
> -	struct list_head *iter;
> -	struct slave *slave;
> +	int link_state;
>   	bool ignore_updelay;
>   
>   	ignore_updelay = !rcu_dereference(bond->curr_active_slave);
>   
> -	bond_for_each_slave_rcu(bond, slave, iter) {
> -		slave->new_link = BOND_LINK_NOCHANGE;
> -
> -		link_state = bond_check_dev_link(bond, slave->dev, 0);
> +	slave->new_link = BOND_LINK_NOCHANGE;
>   
> -		switch (slave->link) {
> -		case BOND_LINK_UP:
> -			if (link_state)
> -				continue;
> +	link_state = bond_check_dev_link(bond, slave->dev, 0);
>   
> -			bond_set_slave_link_state(slave, BOND_LINK_FAIL);
> -			slave->delay = bond->params.downdelay;
> -			if (slave->delay) {
> -				netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
> -					    (BOND_MODE(bond) ==
> -					     BOND_MODE_ACTIVEBACKUP) ?
> -					     (bond_is_active_slave(slave) ?
> -					      "active " : "backup ") : "",
> -					    slave->dev->name,
> -					    bond->params.downdelay * bond->params.miimon);
> -			}
> -			/*FALLTHRU*/
> -		case BOND_LINK_FAIL:
> -			if (link_state) {
> -				/* recovered before downdelay expired */
> -				bond_set_slave_link_state(slave, BOND_LINK_UP);
> -				slave->last_link_up = jiffies;
> -				netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
> -					    (bond->params.downdelay - slave->delay) *
> -					    bond->params.miimon,
> -					    slave->dev->name);
> -				continue;
> -			}
> +	switch (slave->link) {
> +	case BOND_LINK_UP:
> +		if (link_state)
> +			return 0;
>   
> -			if (slave->delay <= 0) {
> -				slave->new_link = BOND_LINK_DOWN;
> -				commit++;
> -				continue;
> -			}
> +		bond_set_slave_link_state(slave, BOND_LINK_FAIL);
> +		slave->delay = bond->params.downdelay;
> +		if (slave->delay) {
> +			netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
> +				    (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP) ?
> +				    (bond_is_active_slave(slave) ?
> +			 	     "active " : "backup ") : "",
> +				    slave->dev->name,
> +				    bond->params.downdelay * bond->params.miimon);
> +		}
> +		/*FALLTHRU*/
> +	case BOND_LINK_FAIL:
> +		if (link_state) {
> +			/* recovered before downdelay expired */
> +			bond_set_slave_link_state(slave, BOND_LINK_UP);
> +			slave->last_link_up = jiffies;
> +			netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
> +				    (bond->params.downdelay - slave->delay) *
> +				    bond->params.miimon, slave->dev->name);
> +			return 0;
> +		}
>   
> -			slave->delay--;
> -			break;
> +		if (slave->delay <= 0) {
> +			slave->new_link = BOND_LINK_DOWN;
> +			return 1;
> +		}
>   
> -		case BOND_LINK_DOWN:
> -			if (!link_state)
> -				continue;
> +		slave->delay--;
> +		break;
>   
> -			bond_set_slave_link_state(slave, BOND_LINK_BACK);
> -			slave->delay = bond->params.updelay;
> +	case BOND_LINK_DOWN:
> +		if (!link_state)
> +			return 0;
>   
> -			if (slave->delay) {
> -				netdev_info(bond->dev, "link status up for interface %s, enabling it in %d ms\n",
> -					    slave->dev->name,
> -					    ignore_updelay ? 0 :
> -					    bond->params.updelay *
> -					    bond->params.miimon);
> -			}
> -			/*FALLTHRU*/
> -		case BOND_LINK_BACK:
> -			if (!link_state) {
> -				bond_set_slave_link_state(slave,
> -							  BOND_LINK_DOWN);
> -				netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
> -					    (bond->params.updelay - slave->delay) *
> -					    bond->params.miimon,
> -					    slave->dev->name);
> +		bond_set_slave_link_state(slave, BOND_LINK_BACK);
> +		slave->delay = bond->params.updelay;
>   
> -				continue;
> -			}
> +		if (slave->delay) {
> +			netdev_info(bond->dev, "link status up for interface %s, enabling it in %d ms\n",
> +				    slave->dev->name, ignore_updelay ? 0 :
> +				    bond->params.updelay * bond->params.miimon);
> +		}
> +		/*FALLTHRU*/
> +	case BOND_LINK_BACK:
> +		if (!link_state) {
> +			bond_set_slave_link_state(slave, BOND_LINK_DOWN);
> +			netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
> +				    (bond->params.updelay - slave->delay) *
> +				    bond->params.miimon, slave->dev->name);
>   
> -			if (ignore_updelay)
> -				slave->delay = 0;
> +			return 0;
> +		}
>   
> -			if (slave->delay <= 0) {
> -				slave->new_link = BOND_LINK_UP;
> -				commit++;
> -				ignore_updelay = false;
> -				continue;
> -			}
> +		if (ignore_updelay)
> +			slave->delay = 0;
>   
> -			slave->delay--;
> -			break;
> +		if (slave->delay <= 0) {
> +			slave->new_link = BOND_LINK_UP;
> +			return 1;
>   		}
> +
> +		slave->delay--;
> +		break;
>   	}
>   
> -	return commit;
> +	return 0;
> +}
> +
> +static int bond_miimon_inspect(struct bonding *bond)
> +{
> +	struct list_head *iter;
> +	struct slave *slave;
> +	int commit = 0;
> +
> +	bond_for_each_slave_rcu(bond, slave, iter)
> +		commit += bond_miimon_inspect_slave(bond, slave);
> +
> + 	return commit;
>   }
>   
>   static void bond_miimon_commit(struct bonding *bond)
> @@ -2969,6 +2968,9 @@ static int bond_slave_netdev_event(unsigned long event,
>   			bond_3ad_adapter_speed_duplex_changed(slave);
>   		/* Fallthrough */
>   	case NETDEV_DOWN:
> +		if (bond_miimon_inspect_slave(bond, slave))
> +			bond_miimon_commit(bond);
> +
>   		/* Refresh slave-array if applicable!
>   		 * If the setup does not use miimon or arpmon (mode-specific!),
>   		 * then these events will not cause the slave-array to be
