From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: Re: [PATCH 3/4] bonding: Fix work rearming
Date: Tue, 22 Jan 2008 12:35:23 +0900
Message-ID: <4795647B.9090905@miraclelinux.com>
References: <20080115090532.GB1696@ff.dom.local> <478D77D7.60703@miraclelinux.com> <20080116133646.GE2307@ff.dom.local> <478EE7FC.4040301@miraclelinux.com> <20080117111822.GB1710@ff.dom.local> <4790ACF2.1090207@miraclelinux.com> <479127C6.1080701@gmail.com> <47912B83.5010407@gmail.com> <479419B6.9000000@miraclelinux.com> <20080121133338.GH1789@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Makito SHIOKAWA <mshiokawa@miraclelinux.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:2065 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbYAVDdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 22:33:17 -0500
In-Reply-To: <20080121133338.GH1789@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No: you mentioned about treating new_value == 0 like new_value < 0
> with 'if (new_value <= 0)', and I didn't understand this idea...
I'm sorry to have misunderstood you. I wanted to say that there is a way just
to fix 'if (new_value < 0)' to 'if (new_value <= 0)' and reject miimon == 0,
instead of PATCH 3/4. (Of course, you won't be able to stop mii monitor only
in that case.)

> Alas I don't understand the reason of this change in bond_main()...
> Some comment?
It was unnecessary any more..., thanks.


Signed-off-by: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
---
  drivers/net/bonding/bond_main.c  |    7 ++-----
  drivers/net/bonding/bond_sysfs.c |   19 +++++++++++++++++--
  2 files changed, 19 insertions(+), 7 deletions(-)

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2801,8 +2801,7 @@ void bond_loadbalance_arp_mon(struct wor
  	}

  re_arm:
-	if (bond->params.arp_interval)
-		queue_delayed_work(bond->wq, &bond->lb_arp_work, delta_in_ticks);
+	queue_delayed_work(bond->wq, &bond->lb_arp_work, delta_in_ticks);
  out:
  	read_unlock(&bond->lock);
  }
@@ -3058,9 +3057,7 @@ void bond_activebackup_arp_mon(struct wo
  	}

  re_arm:
-	if (bond->params.arp_interval) {
-		queue_delayed_work(bond->wq, &bond->ab_arp_work, delta_in_ticks);
-	}
+	queue_delayed_work(bond->wq, &bond->ab_arp_work, delta_in_ticks);
  out:
  	read_unlock(&bond->lock);
  }
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -644,6 +644,15 @@ static ssize_t bonding_store_arp_interva
  	       ": %s: Setting ARP monitoring interval to %d.\n",
  	       bond->dev->name, new_value);
  	bond->params.arp_interval = new_value;
+	if (bond->params.arp_interval == 0 && (bond->dev->flags & IFF_UP)) {
+		printk(KERN_INFO DRV_NAME
+		       ": %s: Disabling ARP monitoring.\n",
+		       bond->dev->name);
+		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+			cancel_delayed_work_sync(&bond->ab_arp_work);
+		else
+			cancel_delayed_work_sync(&bond->lb_arp_work);
+	}
  	if (bond->params.miimon) {
  		printk(KERN_INFO DRV_NAME
  		       ": %s: ARP monitoring cannot be used with MII monitoring. "
@@ -658,7 +667,7 @@ static ssize_t bonding_store_arp_interva
  		       "but no ARP targets have been specified.\n",
  		       bond->dev->name);
  	}
-	if (bond->dev->flags & IFF_UP) {
+	if (bond->params.arp_interval && (bond->dev->flags & IFF_UP)) {
  		/* If the interface is up, we may need to fire off
  		 * the ARP timer.  If the interface is down, the
  		 * timer will get fired off when the open function
@@ -997,6 +1006,12 @@ static ssize_t bonding_store_miimon(stru
  		       ": %s: Setting MII monitoring interval to %d.\n",
  		       bond->dev->name, new_value);
  		bond->params.miimon = new_value;
+		if (bond->params.miimon == 0 && (bond->dev->flags & IFF_UP)) {
+			printk(KERN_INFO DRV_NAME
+			       ": %s: Disabling MII monitoring...\n",
+			       bond->dev->name);
+			cancel_delayed_work_sync(&bond->mii_work);
+		}
  		if(bond->params.updelay)
  			printk(KERN_INFO DRV_NAME
  			      ": %s: Note: Updating updelay (to %d) "
@@ -1026,7 +1041,7 @@ static ssize_t bonding_store_miimon(stru
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
