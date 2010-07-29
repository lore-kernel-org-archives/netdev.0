From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bonding: take rtnl in bond_loadbalance_arp_mon
Date: Thu, 29 Jul 2010 10:49:51 -0700
Message-ID: <23558.1280425791@death>
References: <1280351076-19973-1-git-send-email-andy@greyhouse.net> <29111.1280353189@death> <20100729011355.GV7497@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:55024 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab0G2RuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 13:50:23 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6THeb3F019205
	for <netdev@vger.kernel.org>; Thu, 29 Jul 2010 11:40:37 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6THo5OW134184
	for <netdev@vger.kernel.org>; Thu, 29 Jul 2010 11:50:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6THnt3A017639
	for <netdev@vger.kernel.org>; Thu, 29 Jul 2010 11:49:56 -0600
In-reply-to: <20100729011355.GV7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>On Wed, Jul 28, 2010 at 02:39:49PM -0700, Jay Vosburgh wrote:
>> Andy Gospodarek <andy@greyhouse.net> wrote:
>> 
>> >With the latest code in net-next-2.6 the following (and similar) are
>> >spewed when using arp monitoring and balance-alb.
>> 
>> 	Does the ARP monitor function correctly for balance-alb?  My
>> recollection is that the ARP monitor probes interfere with the tailored
>> ARP messages that balance-alb sends.
>
>It seems to work fine here on a few tries (I only use sysfs for
>configuration anymore), but it might be blind luck that the addresses
>chosen are hashing out correctly to make arp monitoring work.

	I haven't tried it in a long time, but I think the problem for
balance-alb also had to do with snooping switches updating the MAC table
from the arp monitor traffic instead of (or in addition to) the
"authentic" ARPs.  I don't remember if it caused actual communication
breaks, or just messed up the traffic balance.

>> The bond_check_params function
>> disallows setting arp_interval (it forces miimon on).  I suspect this
>> nuance was missed when setting up the sysfs code, but if it does work,
>> then perhaps it is too strict.
>
>You are correct, it does.  It is clear that some checks should be added
>to the sysfs code and it also seems like some work should be done to
>more clearly define what modes support which form of link monitoring (it
>doesn't seem to me like balance-rr should support can monitoring in it's
>current implementation, but there is no explicit code to check for it in
>the sysfs-layer or bond_check_params).

	Presumably you mean "balance-rr should support ARP monitoring,"
and you're right, the whole "loadbalance" ARP monitor is pretty dodgy in
general (for balance-rr and balance-xor specifically).  Since both of
those modes are intended to interface with etherchannel, the validity of
the ARP monitor's decisions are entirely dependent upon how the switch
balances incoming traffic.  If the switch does a good job and hits all
of the ports, then it'll "work."  There's a comment to this effect in
bond_loadbalance_arp_mon:

                /* note: if switch is in round-robin mode, all links
                 * must tx arp to ensure all links rx an arp - otherwise
                 * links may oscillate or not come up at all; if switch is
                 * in something like xor mode, there is nothing we can
                 * do - all replies will be rx'ed on same link causing slaves
                 * to be unstable during low/no traffic periods

	As an added tidbit, I'm not aware of any switch that has a
round-robin balance policy for its etherchannel implementation.  That
comment predates my involvement in bonding, so maybe back then there
were some 10 Mb/sec switches that did round robin.

	This also might have been useful for one switch configuration
that was used at the time, with multiple switches not running
etherchannel were connected up such that each bonding slave was
connected to a discrete switch.  The switches were not interconnected,
so the only etherchannel was on the bonding hosts, which ran balance-rr.
This is discussed a bit in the bonding.txt, 12.2, complete with ASCII
art.  It was pretty snazzy in the "one packet per interrupt" days, but
badly reorders traffic with modern hardware (anything with packet
coalescing; NAPI probably breaks it, too, now that I think about it).

>> 	As I recall, I had deliberately left acquiring rtnl out of the
>> loadbalance_arp_mon function, since none of the modes that used it
>> required rtnl for failover.
>
>Understood.
>
>Based on your comments, at least something like the following should
>probably be done.

	I agree.

>[PATCH net-next] bonding: prevent sysfs from allowing arp monitoring with alb/tlb
>
>When using module options arp monitoring and balance-alb/balance-tlb
>are mutually exclusive options.  Anytime balance-alb/balance-tlb are
>enabled mii monitoring is forced to 100ms if not set.  When configuring
>via sysfs no checking is currently done.
>
>Handling these cases with sysfs has to be done a bit differently because
>we do not have all configuration information available at once.  This
>patch will not allow a mode change to balance-alb/balance-tlb if
>arp_interval is already non-zero.  It will also not allow the user to
>set a non-zero arp_interval value if the mode is already set to
>balance-alb/balance-tlb.  They are still mutually exclusive on a
>first-come, first serve basis.
>
>Tested with initscripts on Fedora and manual setting via sysfs.
>
>Signed-off-by: Andy Gospodarek <gospo@redhat.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>---
> drivers/net/bonding/bond_sysfs.c |   37 +++++++++++++++++++++++++------------
> 1 files changed, 25 insertions(+), 12 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 1a99764..c311aed 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -313,19 +313,26 @@ static ssize_t bonding_store_mode(struct device *d,
> 		       bond->dev->name, (int)strlen(buf) - 1, buf);
> 		ret = -EINVAL;
> 		goto out;
>-	} else {
>-		if (bond->params.mode == BOND_MODE_8023AD)
>-			bond_unset_master_3ad_flags(bond);
>+	}
>+	if ((new_value == BOND_MODE_ALB ||
>+	     new_value == BOND_MODE_TLB) &&
>+	    bond->params.arp_interval) {
>+		pr_err("%s: %s mode is incompatible with arp monitoring.\n",
>+		       bond->dev->name, bond_mode_tbl[new_value].modename);
>+		ret = -EINVAL;
>+		goto out;
>+	}
>+	if (bond->params.mode == BOND_MODE_8023AD)
>+		bond_unset_master_3ad_flags(bond);
>
>-		if (bond->params.mode == BOND_MODE_ALB)
>-			bond_unset_master_alb_flags(bond);
>+	if (bond->params.mode == BOND_MODE_ALB)
>+		bond_unset_master_alb_flags(bond);
>
>-		bond->params.mode = new_value;
>-		bond_set_mode_ops(bond, bond->params.mode);
>-		pr_info("%s: setting mode to %s (%d).\n",
>-			bond->dev->name, bond_mode_tbl[new_value].modename,
>-		       new_value);
>-	}
>+	bond->params.mode = new_value;
>+	bond_set_mode_ops(bond, bond->params.mode);
>+	pr_info("%s: setting mode to %s (%d).\n",
>+		bond->dev->name, bond_mode_tbl[new_value].modename,
>+		new_value);
> out:
> 	return ret;
> }
>@@ -510,7 +517,13 @@ static ssize_t bonding_store_arp_interval(struct device *d,
> 		ret = -EINVAL;
> 		goto out;
> 	}
>-
>+	if (bond->params.mode == BOND_MODE_ALB ||
>+	    bond->params.mode == BOND_MODE_TLB) {
>+		pr_info("%s: ARP monitoring cannot be used with ALB/TLB. Only MII monitoring is supported on %s.\n",
>+			bond->dev->name, bond->dev->name);
>+		ret = -EINVAL;
>+		goto out;
>+	}
> 	pr_info("%s: Setting ARP monitoring interval to %d.\n",
> 		bond->dev->name, new_value);
> 	bond->params.arp_interval = new_value;
>-- 
>1.7.0.1
>
