From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v2 net] bonding: don't use stale speed and duplex
 information
Date: Sun, 14 Feb 2016 10:36:53 +0800
Message-ID: <56BFE845.30608@huawei.com>
References: <25869.1454962202@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>,
	<netdev@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:22226 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603AbcBNChO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 21:37:14 -0500
In-Reply-To: <25869.1454962202@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/2/9 4:10, Jay Vosburgh wrote:
> 
> 	There is presently a race condition between the bonding periodic
> link monitor and the updating of a slave's speed and duplex.  The former
> occurs on a periodic basis, and the latter in response to a driver's
> calling of netif_carrier_on.
> 
> 	It is possible for the periodic monitor to run between the
> driver call of netif_carrier_on and the receipt of the NETDEV_CHANGE
> event that causes bonding to update the slave's speed and duplex.  This
> manifests most notably as a report that a slave is up and "0 Mbps full
> duplex" after enslavement, but in principle could report an incorrect
> speed and duplex after any link up event if the device comes up with a
> different speed or duplex.  This affects the 802.3ad aggregator
> selection, as the speed and duplex are selection criteria.
> 
> 	This is fixed by updating the speed and duplex in the periodic
> monitor, prior to using that information.
> 
> 	This was done historically in bonding, but the call to
> bond_update_speed_duplex was removed in commit 876254ae2758 ("bonding:
> don't call update_speed_duplex() under spinlocks"), as it might sleep
> under lock.  Later, the locking was changed to only hold RTNL, and so
> after commit 876254ae2758 ("bonding: don't call update_speed_duplex()
> under spinlocks") this call is again safe.
> 
> Tested-by: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> Cc: Veaceslav Falico <vfalico@gmail.com>
> Cc: dingtianhong <dingtianhong@huawei.com>
> Fixes: 876254ae2758 ("bonding: don't call update_speed_duplex() under spinlocks")
> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

Acked-by: Ding Tianhong <dingtianhong@huawei.com>

> 
> ---
> 
> v2: Correct Veaceslav's email address
> 
> Note: The "Fixes" commit is the commit that makes this operation safe
> again, not the commit that originally introduced the race.  I don't see
> any simple way to resolve this bug between these two commits.
> 
>  drivers/net/bonding/bond_main.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 56b560558884..cabaeb61333d 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2127,6 +2127,7 @@ static void bond_miimon_commit(struct bonding *bond)
>  			continue;
>  
>  		case BOND_LINK_UP:
> +			bond_update_speed_duplex(slave);
>  			bond_set_slave_link_state(slave, BOND_LINK_UP,
>  						  BOND_SLAVE_NOTIFY_NOW);
>  			slave->last_link_up = jiffies;
> 
