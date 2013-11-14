From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net] bonding: fix two race conditions in
 bond_store_updelay/downdelay
Date: Thu, 14 Nov 2013 11:17:54 +0100
Message-ID: <20131114101754.GR19702@redhat.com>
References: <1384358866-15157-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757Ab3KNKUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 05:20:17 -0500
Content-Disposition: inline
In-Reply-To: <1384358866-15157-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 05:07:46PM +0100, Nikolay Aleksandrov wrote:
>This patch fixes two race conditions between bond_store_updelay/downdelay
>and bond_store_miimon which could lead to division by zero as miimon can
>be set to 0 while either updelay/downdelay are being set and thus miss the
>zero check in the beginning, the zero div happens because updelay/downdelay
>are stored as new_value / bond->params.miimon. Use rtnl to synchronize with
>miimon setting.
>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>CC: Veaceslav Falico <vfalico@redhat.com>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Nice, thanks! :)

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>---
> drivers/net/bonding/bond_sysfs.c | 6 ++++++
> 1 file changed, 6 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index bc8fd36..8f8a607 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -701,6 +701,8 @@ static ssize_t bonding_store_downdelay(struct device *d,
> 	int new_value, ret = count;
> 	struct bonding *bond = to_bond(d);
>
>+	if (!rtnl_trylock())
>+		return restart_syscall();
> 	if (!(bond->params.miimon)) {
> 		pr_err("%s: Unable to set down delay as MII monitoring is disabled\n",
> 		       bond->dev->name);
>@@ -734,6 +736,7 @@ static ssize_t bonding_store_downdelay(struct device *d,
> 	}
>
> out:
>+	rtnl_unlock();
> 	return ret;
> }
> static DEVICE_ATTR(downdelay, S_IRUGO | S_IWUSR,
>@@ -756,6 +759,8 @@ static ssize_t bonding_store_updelay(struct device *d,
> 	int new_value, ret = count;
> 	struct bonding *bond = to_bond(d);
>
>+	if (!rtnl_trylock())
>+		return restart_syscall();
> 	if (!(bond->params.miimon)) {
> 		pr_err("%s: Unable to set up delay as MII monitoring is disabled\n",
> 		       bond->dev->name);
>@@ -789,6 +794,7 @@ static ssize_t bonding_store_updelay(struct device *d,
> 	}
>
> out:
>+	rtnl_unlock();
> 	return ret;
> }
> static DEVICE_ATTR(updelay, S_IRUGO | S_IWUSR,
>-- 
>1.8.1.4
>
