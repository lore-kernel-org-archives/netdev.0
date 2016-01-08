From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [RFC PATCH net-next] bonding: Use notifiers for slave link state
 detection
Date: Fri, 8 Jan 2016 12:36:45 +0800
Message-ID: <568F3CDD.6040606@gmail.com>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com>
 <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com>
 <16587.1452148421@famine> <27321.1452216515@famine>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050003070606090800010609"
Cc: mkubecek@suse.cz, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, boris.shteinbock@windriver.com
To: Jay Vosburgh <jay.vosburgh@canonical.com>,
	emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33394 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612AbcAHEg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 23:36:58 -0500
Received: by mail-pf0-f182.google.com with SMTP id e65so3891424pfe.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 20:36:58 -0800 (PST)
In-Reply-To: <27321.1452216515@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050003070606090800010609
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit

Hi, Jay

Thank for your help.
I made a new patch based on the latest linux kernel. Now it is in the 
attachment.
When I run "make", the following errors will pop up.
And I can not find notifier callbacks in the patch.

   CHK     include/config/kernel.release
   CHK     include/generated/uapi/linux/version.h
   CHK     include/generated/utsrelease.h
   CHK     include/generated/bounds.h
   CHK     include/generated/timeconst.h
   CHK     include/generated/asm-offsets.h
   CALL    scripts/checksyscalls.sh
   CHK     include/generated/compile.h
   CC      block/blk-mq.o
   LD      block/built-in.o
   CC [M]  drivers/mtd/mtdcore.o
   LD [M]  drivers/mtd/mtd.o
   CC [M]  drivers/net/bonding/bond_main.o
drivers/net/bonding/bond_main.c: In function ‘bond_miimon_inspect_slave’:
drivers/net/bonding/bond_main.c:1996:3: error: too many arguments to 
function ‘bond_set_slave_link_state’
include/net/bonding.h:507:20: note: declared here
drivers/net/bonding/bond_main.c:2010:4: error: too many arguments to 
function ‘bond_set_slave_link_state’
include/net/bonding.h:507:20: note: declared here
drivers/net/bonding/bond_main.c:2030:3: error: too many arguments to 
function ‘bond_set_slave_link_state’
include/net/bonding.h:507:20: note: declared here
drivers/net/bonding/bond_main.c:2041:4: error: too many arguments to 
function ‘bond_set_slave_link_state’
include/net/bonding.h:507:20: note: declared here
make[3]: *** [drivers/net/bonding/bond_main.o] Error 1
make[2]: *** [drivers/net/bonding] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

Best Regards!
Zhu Yanjun

On 01/08/2016 09:28 AM, Jay Vosburgh wrote:
> 	TEST PATCH
>
> 	This patch modifies bonding to utilize notifier callbacks to
> detect slave link state changes.  It is intended to be used with miimon
> set to zero, and does not support the updelay or downdelay options to
> bonding.  It's not as complicated as it looks; most of the change set is
> to break out the inner loop of bond_miimon_inspect into its own
> function.
>
> 	Yanjun, can you test this with miimon=0 and see if it changes
> the behavior you're seeing?
>
> 	Thanks,
>
> 	-J
>
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index cab99fd..6fe68b1 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2012,104 +2012,103 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
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
> +	slave->new_link = BOND_LINK_NOCHANGE;
>   
> -		link_state = bond_check_dev_link(bond, slave->dev, 0);
> +	link_state = bond_check_dev_link(bond, slave->dev, 0);
>   
> -		switch (slave->link) {
> -		case BOND_LINK_UP:
> -			if (link_state)
> -				continue;
> +	switch (slave->link) {
> +	case BOND_LINK_UP:
> +		if (link_state)
> +			return 0;
>   
> -			bond_set_slave_link_state(slave, BOND_LINK_FAIL,
> +		bond_set_slave_link_state(slave, BOND_LINK_FAIL,
> +					  BOND_SLAVE_NOTIFY_LATER);
> +		slave->delay = bond->params.downdelay;
> +		if (slave->delay) {
> +			netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
> +				    (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP) ?
> +				    (bond_is_active_slave(slave) ?
> +				     "active " : "backup ") : "",
> +				    slave->dev->name,
> +				    bond->params.downdelay * bond->params.miimon);
> +		}
> +		/*FALLTHRU*/
> +	case BOND_LINK_FAIL:
> +		if (link_state) {
> +			/* recovered before downdelay expired */
> +			bond_set_slave_link_state(slave, BOND_LINK_UP,
>   						  BOND_SLAVE_NOTIFY_LATER);
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
> -				bond_set_slave_link_state(slave, BOND_LINK_UP,
> -							  BOND_SLAVE_NOTIFY_LATER);
> -				slave->last_link_up = jiffies;
> -				netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
> -					    (bond->params.downdelay - slave->delay) *
> -					    bond->params.miimon,
> -					    slave->dev->name);
> -				continue;
> -			}
> +			slave->last_link_up = jiffies;
> +			netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
> +				    (bond->params.downdelay - slave->delay) *
> +				    bond->params.miimon, slave->dev->name);
> +			return 0;
> +		}
>   
> -			if (slave->delay <= 0) {
> -				slave->new_link = BOND_LINK_DOWN;
> -				commit++;
> -				continue;
> -			}
> +		if (slave->delay <= 0) {
> +			slave->new_link = BOND_LINK_DOWN;
> +			return 1;
> +		}
>   
> -			slave->delay--;
> -			break;
> +		slave->delay--;
> +		break;
>   
> -		case BOND_LINK_DOWN:
> -			if (!link_state)
> -				continue;
> +	case BOND_LINK_DOWN:
> +		if (!link_state)
> +			return 0;
>   
> -			bond_set_slave_link_state(slave, BOND_LINK_BACK,
> -						  BOND_SLAVE_NOTIFY_LATER);
> -			slave->delay = bond->params.updelay;
> -
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
> -							  BOND_LINK_DOWN,
> -							  BOND_SLAVE_NOTIFY_LATER);
> -				netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
> -					    (bond->params.updelay - slave->delay) *
> -					    bond->params.miimon,
> -					    slave->dev->name);
> +		bond_set_slave_link_state(slave, BOND_LINK_BACK,
> +					  BOND_SLAVE_NOTIFY_LATER);
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
> +			bond_set_slave_link_state(slave, BOND_LINK_DOWN,
> +						  BOND_SLAVE_NOTIFY_LATER);
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
>   	return commit;
>   }
>   
> @@ -3016,6 +3015,9 @@ static int bond_slave_netdev_event(unsigned long event,
>   			bond_3ad_adapter_speed_duplex_changed(slave);
>   		/* Fallthrough */
>   	case NETDEV_DOWN:
> +		if (bond_miimon_inspect_slave(bond, slave))
> +			bond_miimon_commit(bond);
> +
>   		/* Refresh slave-array if applicable!
>   		 * If the setup does not use miimon or arpmon (mode-specific!),
>   		 * then these events will not cause the slave-array to be
>
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com


--------------050003070606090800010609
Content-Type: text/x-patch;
 name="0001-bonding-utilize-notifier-callbacks-to-detect-slave-l.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-bonding-utilize-notifier-callbacks-to-detect-slave-l.pa";
 filename*1="tch"

>From 62c5cf3a4aa944bac0397748d3ce1dd28b358f79 Mon Sep 17 00:00:00 2001
From: Zhu Yanjun <yanjun.zhu@windriver.com>
Date: Fri, 8 Jan 2016 11:35:19 +0800
Subject: [PATCH 1/1] bonding: utilize notifier callbacks to detect slave link
 state changes

This patch modifies bonding to utilize notifier callbacks to
detect slave link state changes.  It is intended to be used with miimon
set to zero, and does not support the updelay or downdelay options to
bonding.  It's not as complicated as it looks; most of the change set is
to break out the inner loop of bond_miimon_inspect into its own
function.

Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
---
 drivers/net/bonding/bond_main.c |  154 ++++++++++++++++++++-------------------
 1 file changed, 78 insertions(+), 76 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9e0f8a7..b28d6fd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1977,101 +1977,100 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 /*-------------------------------- Monitoring -------------------------------*/
 
 /* called with rcu_read_lock() */
-static int bond_miimon_inspect(struct bonding *bond)
+static int bond_miimon_inspect_slave(struct bonding *bond, struct slave *slave)
 {
-	int link_state, commit = 0;
-	struct list_head *iter;
-	struct slave *slave;
+	int link_state;
 	bool ignore_updelay;
 
 	ignore_updelay = !rcu_dereference(bond->curr_active_slave);
 
-	bond_for_each_slave_rcu(bond, slave, iter) {
-		slave->new_link = BOND_LINK_NOCHANGE;
-
-		link_state = bond_check_dev_link(bond, slave->dev, 0);
+	slave->new_link = BOND_LINK_NOCHANGE;
 
-		switch (slave->link) {
-		case BOND_LINK_UP:
-			if (link_state)
-				continue;
+	link_state = bond_check_dev_link(bond, slave->dev, 0);
 
-			bond_set_slave_link_state(slave, BOND_LINK_FAIL);
-			slave->delay = bond->params.downdelay;
-			if (slave->delay) {
-				netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
-					    (BOND_MODE(bond) ==
-					     BOND_MODE_ACTIVEBACKUP) ?
-					     (bond_is_active_slave(slave) ?
-					      "active " : "backup ") : "",
-					    slave->dev->name,
-					    bond->params.downdelay * bond->params.miimon);
-			}
-			/*FALLTHRU*/
-		case BOND_LINK_FAIL:
-			if (link_state) {
-				/* recovered before downdelay expired */
-				bond_set_slave_link_state(slave, BOND_LINK_UP);
-				slave->last_link_up = jiffies;
-				netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
-					    (bond->params.downdelay - slave->delay) *
-					    bond->params.miimon,
-					    slave->dev->name);
-				continue;
-			}
+	switch (slave->link) {
+	case BOND_LINK_UP:
+		if (link_state)
+			return 0;
 
-			if (slave->delay <= 0) {
-				slave->new_link = BOND_LINK_DOWN;
-				commit++;
-				continue;
-			}
+		bond_set_slave_link_state(slave, BOND_LINK_FAIL, BOND_SLAVE_NOTIFY_LATER);
+		slave->delay = bond->params.downdelay;
+		if (slave->delay) {
+			netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
+				    (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP) ?
+				    (bond_is_active_slave(slave) ?
+			 	     "active " : "backup ") : "",
+				    slave->dev->name,
+				    bond->params.downdelay * bond->params.miimon);
+		}
+		/*FALLTHRU*/
+	case BOND_LINK_FAIL:
+		if (link_state) {
+			/* recovered before downdelay expired */
+			bond_set_slave_link_state(slave, BOND_LINK_UP, BOND_SLAVE_NOTIFY_LATER);
+			slave->last_link_up = jiffies;
+			netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
+				    (bond->params.downdelay - slave->delay) *
+				    bond->params.miimon, slave->dev->name);
+			return 0;
+		}
 
-			slave->delay--;
-			break;
+		if (slave->delay <= 0) {
+			slave->new_link = BOND_LINK_DOWN;
+			return 1;
+		}
 
-		case BOND_LINK_DOWN:
-			if (!link_state)
-				continue;
+		slave->delay--;
+		break;
 
-			bond_set_slave_link_state(slave, BOND_LINK_BACK);
-			slave->delay = bond->params.updelay;
+	case BOND_LINK_DOWN:
+		if (!link_state)
+			return 0;
 
-			if (slave->delay) {
-				netdev_info(bond->dev, "link status up for interface %s, enabling it in %d ms\n",
-					    slave->dev->name,
-					    ignore_updelay ? 0 :
-					    bond->params.updelay *
-					    bond->params.miimon);
-			}
-			/*FALLTHRU*/
-		case BOND_LINK_BACK:
-			if (!link_state) {
-				bond_set_slave_link_state(slave,
-							  BOND_LINK_DOWN);
-				netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
-					    (bond->params.updelay - slave->delay) *
-					    bond->params.miimon,
-					    slave->dev->name);
+		bond_set_slave_link_state(slave, BOND_LINK_BACK, BOND_SLAVE_NOTIFY_LATER);
+		slave->delay = bond->params.updelay;
 
-				continue;
-			}
+		if (slave->delay) {
+			netdev_info(bond->dev, "link status up for interface %s, enabling it in %d ms\n",
+				    slave->dev->name, ignore_updelay ? 0 :
+				    bond->params.updelay * bond->params.miimon);
+		}
+		/*FALLTHRU*/
+	case BOND_LINK_BACK:
+		if (!link_state) {
+			bond_set_slave_link_state(slave, BOND_LINK_DOWN, BOND_SLAVE_NOTIFY_LATER);
+			netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
+				    (bond->params.updelay - slave->delay) *
+				    bond->params.miimon, slave->dev->name);
 
-			if (ignore_updelay)
-				slave->delay = 0;
+			return 0;
+		}
 
-			if (slave->delay <= 0) {
-				slave->new_link = BOND_LINK_UP;
-				commit++;
-				ignore_updelay = false;
-				continue;
-			}
+		if (ignore_updelay)
+			slave->delay = 0;
 
-			slave->delay--;
-			break;
+		if (slave->delay <= 0) {
+			slave->new_link = BOND_LINK_UP;
+			return 1;
 		}
+
+		slave->delay--;
+		break;
 	}
 
-	return commit;
+	return 0;
+}
+
+static int bond_miimon_inspect(struct bonding *bond)
+{
+	struct list_head *iter;
+	struct slave *slave;
+	int commit = 0;
+
+	bond_for_each_slave_rcu(bond, slave, iter)
+		commit += bond_miimon_inspect_slave(bond, slave);
+
+ 	return commit;
 }
 
 static void bond_miimon_commit(struct bonding *bond)
@@ -2969,6 +2968,9 @@ static int bond_slave_netdev_event(unsigned long event,
 			bond_3ad_adapter_speed_duplex_changed(slave);
 		/* Fallthrough */
 	case NETDEV_DOWN:
+		if (bond_miimon_inspect_slave(bond, slave))
+			bond_miimon_commit(bond);
+
 		/* Refresh slave-array if applicable!
 		 * If the setup does not use miimon or arpmon (mode-specific!),
 		 * then these events will not cause the slave-array to be
-- 
1.7.9.5


--------------050003070606090800010609--
