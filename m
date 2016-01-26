From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] bonding: Use notifiers for slave link state detection
Date: Tue, 26 Jan 2016 11:19:45 +0800
Message-ID: <56A6E5D1.7070807@gmail.com>
References: <87618083B2453E4A8714035B62D679925050766D@FMSMSX105.amr.corp.intel.com>
 <1453371388-30230-1-git-send-email-zyjzyj2000@gmail.com>
 <1453371388-30230-2-git-send-email-zyjzyj2000@gmail.com>
 <7578.1453769012@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, boris.shteinbock@windriver.com,
	emil.s.tantilov@intel.com
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33847 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932404AbcAZDTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 22:19:20 -0500
Received: by mail-pf0-f195.google.com with SMTP id 65so7624880pfd.1
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2016 19:19:20 -0800 (PST)
In-Reply-To: <7578.1453769012@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/2016 08:43 AM, Jay Vosburgh wrote:
> <zyjzyj2000@gmail.com> wrote:
>
>> From: Zhu Yanjun <zyjzyj2000@gmail.com>
>>
>> Bonding will utilize notifier callbacks to detect slave
>> link state changes. It is intended to be used with miimon
>> set to zero, and does not support the updelay or downdelay
>> options to bonding.
>>
>> Because of link flap from the slave interface, if the notifier
>> is NETDEV_UP while the actual link state is down, it is not
>> necessary to continue.
>>
>> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
> 	I haven't signed off on this patch.
>
> 	I've just started some testing, but as before immediately get an
> RCU warning; it looks to be coming from bond_miimon_inspect_slave();
>
> [  316.473050] bond1: Enslaving eth1 as a backup interface with an up link
> [  316.473059]
> [  316.473806] ===============================
> [  316.475630] [ INFO: suspicious RCU usage. ]
> [  316.477519] 4.4.0+ #38 Not tainted
> [  316.479094] -------------------------------
> [  316.480765] drivers/net/bonding/bond_main.c:2024 suspicious rcu_dereference_check() usage!
>
> 	This is presumably because the "case NETDEV_DOWN" call to
> bond_miimon_inspect_slave does not hold RCU.  It does hold RTNL, though,
> which should be safe for this usage (RTNL mutexes changes to the active
> slave).  The appended patch on top of the original makes the warning go
> away.
>
> 	I'm still testing the patch and have no comment about its
> functionality as yet.
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 9f67948..e3faee9 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2014,14 +2014,14 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
>   
>   /*-------------------------------- Monitoring -------------------------------*/
>   
> -/* called with rcu_read_lock() */
> +/* called with rcu_read_lock() or RTNL */
>   static int bond_miimon_inspect_slave(struct bonding *bond, struct slave *slave,
>   				     unsigned long event)
>   {
>   	int link_state;
>   	bool ignore_updelay;
>   
> -	ignore_updelay = !rcu_dereference(bond->curr_active_slave);
> +	ignore_updelay = !rcu_dereference_rtnl(bond->curr_active_slave);

Thanks a lot.
Because kernel v4.4 needs this kind of patch, I backport this patch from 
net-next to kernel v4.4.

If it is not appropriate, I will revert this patch.

Best Regards!
Zhu Yanjun

>   
>   	slave->new_link = BOND_LINK_NOCHANGE;
>   
>
> 	-J
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
