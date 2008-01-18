From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: Re: [PATCH 3/4] bonding: Fix work rearming
Date: Fri, 18 Jan 2008 22:43:14 +0900
Message-ID: <4790ACF2.1090207@miraclelinux.com>
References: <20080115090532.GB1696@ff.dom.local> <478D77D7.60703@miraclelinux.com> <20080116133646.GE2307@ff.dom.local> <478EE7FC.4040301@miraclelinux.com> <20080117111822.GB1710@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Makito SHIOKAWA <mshiokawa@miraclelinux.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:60376 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761024AbYARNo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 08:44:58 -0500
In-Reply-To: <20080117111822.GB1710@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmm... I'm not sure I understand your point, but it seems both
> bonding_store_arp_interval() and bonding_store_miimon() where this
> field could be changed, currently use cancel_delayed_work() with
> flush_workqueue(), so I presume, there is no rtnl_lock() nor
> write_lock(&bond->lock) held, so cancel_delayed_work_sync() could
> be used, which doesn't require this additional check.
I see. I rewrited the patch as below. How about this?
(But, it may be just a matter to change 'if (new_value < 0)' to 'if (new_value
<= 0)' in bonding_store_miimon() and bonding_store_arp_interval()...)

---
  drivers/net/bonding/bond_sysfs.c |    4 +++-
  1 file changed, 3 insertions(+), 1 deletion(-)

--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -997,6 +997,8 @@ static ssize_t bonding_store_miimon(stru
  		       ": %s: Setting MII monitoring interval to %d.\n",
  		       bond->dev->name, new_value);
  		bond->params.miimon = new_value;
+		if (bond->params.miimon == 0)
+			cancel_delayed_work_sync(&bond->mii_work);
  		if(bond->params.updelay)
  			printk(KERN_INFO DRV_NAME
  			      ": %s: Note: Updating updelay (to %d) "
@@ -1026,7 +1028,7 @@ static ssize_t bonding_store_miimon(stru
  				cancel_delayed_work_sync(&bond->lb_arp_work);
  		}

-		if (bond->dev->flags & IFF_UP) {
+		if (bond->params.miimon && (bond->dev->flags & IFF_UP)) {
  			/* If the interface is up, we may need to fire off
  			 * the MII timer. If the interface is down, the
  			 * timer will get fired off when the open function


-- 
Makito SHIOKAWA
MIRACLE LINUX CORPORATION
