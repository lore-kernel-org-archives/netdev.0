From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding:fix speed unknown,lacp bonding failed
Date: Fri, 05 Jul 2013 01:40:42 -0700 (PDT)
Message-ID: <20130705.014042.1794673817887092292.davem@davemloft.net>
References: <1373005979-10196-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lizefan@huawei.com,
	zhangdianfang@huawei.com
To: wangyufen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757119Ab3GEIkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 04:40:43 -0400
In-Reply-To: <1373005979-10196-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wangyufen <wangyufen@huawei.com>
Date: Fri, 5 Jul 2013 14:32:59 +0800

> @@ -2301,8 +2301,11 @@ static int bond_miimon_inspect(struct bonding *bond)

>  		switch (slave->link) {
>  		case BOND_LINK_UP:
> -			if (link_state)
> +			if (link_state) {
> +				if (slave->speed == SPEED_UNKNOWN)
> +					bond_update_speed_duplex(slave);
>  				continue;

bond_miimon_inspect() does not hold the RTNL mutex, and it is required
that the RTNL mutex is held when bond_update_speed_duplex() is called.

If you ran this new code, you should be hitting the assertion at the
beginning of __ethtool_get_settings() which reads:

	ASSERT_RTNL();

In fact, if you look at bond_miimon_inspect()'s caller it goes:

		if (!rtnl_trylock()) {

right after calling bond_miimon_inspect().
