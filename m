From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [v2] bonding:fix speed unknown,lacp bonding failed
Date: Tue, 9 Jul 2013 15:43:08 +0200
Message-ID: <20130709134308.GA29882@redhat.com>
References: <1373331122-10052-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, lizefan@huawei.com,
	zhangdianfang@huawei.com
To: Wangyufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25143 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753656Ab3GINnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jul 2013 09:43:40 -0400
Content-Disposition: inline
In-Reply-To: <1373331122-10052-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 09, 2013 at 08:52:02AM +0800, Wangyufen wrote:
>From: "Wang Yufen" <wangyufen@huawei.com>
>
>We bonded nic using LACP mode repeatedly, occasionally LACP bonding failed,
>because a slave nic port speed was unknown. But when we used ethtool to
>check the slave NIC status, the nic status was normal,speed was 10000Mb/s.
>	
>Bonding get the NIC speed from NIC drivers,just when enslave nic
>and receive NETDEV_CHANGE event.We call bond_update_speed_duplex to
>update speed and duplex when miimon inspect slave link is OK and slave
>speed is unknown.

This is the wrong way to fix it. The real problem here is that the NIC
doesn't send NETDEV_CHANGE when it changes its speed/duplex. Try finding
out why it doesn't and fix it.

And, as Ben mentioned earlier, bond_update_speed_duplex() can sleep, and
thus should not be called from atomic context. Take a look at the caller -
bond_mii_monitor() - the bond_miimon_inspect() is under bond->lock, for a
good reason.

For reference, see the patch 876254ae2758d50dcb08c7bd00caf6a806571178
("bonding: don't call update_speed_duplex() under spinlocks") - it
specifically removes the _update_speed_duplex() from _miimon_commit().

>	
>	
>Signed-off-by: Wang Yufen <wangyufen@huawei.com>
>
>---
>drivers/net/bonding/bond_main.c | 16 +++++++++++++++-
> 1 file changed, 15 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index f975696..4ccc173 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2301,8 +2301,22 @@ static int bond_miimon_inspect(struct bonding *bond)
>
> 		switch (slave->link) {
> 		case BOND_LINK_UP:
>-			if (link_state)
>+			if (link_state) {
>+				if (slave->speed == SPEED_UNKNOWN) {
>+					rtnl_lock();
>+					bond_update_speed_duplex(slave);
>+					if (slave->speed != SPEED_UNKNOWN
>+					&& bond->params.mode
>+					== BOND_MODE_8023AD) {
>+						bond_3ad_adapter_speed_changed(
>+						slave);
>+						bond_3ad_adapter_duplex_changed(
>+						slave);
>+					}
>+					rtnl_unlock();
>+				}
> 				continue;
>+			}
>
> 			slave->link = BOND_LINK_FAIL;
> 			slave->delay = bond->params.downdelay;
