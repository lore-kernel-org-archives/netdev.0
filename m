From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] bonding: make ab_arp select active slaves as other modes
Date: Wed, 16 Sep 2009 17:02:45 -0700
Message-ID: <30814.1253145765@death.nxdomain.ibm.com>
References: <20090831210937.GA3152@psychotron.redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bonding-devel@lists.sourceforge.net, nicolas.2p.debian@free.fr
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:50210 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755509AbZIQACs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 20:02:48 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8H00vRg019939
	for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 18:00:57 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8H02oZi225884
	for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 18:02:50 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8H02ncj020358
	for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 18:02:50 -0600
In-reply-to: <20090831210937.GA3152@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>When I was implementing primary_passive option (formely named primary_lazy) I've
>run into troubles with ab_arp. This is the only mode which is not using
>bond_select_active_slave() function to select active slave and instead it
>selects it itself. This seems to be not the right behaviour and it would be
>better to do it in bond_select_active_slave() for all cases. This patch makes
>this happen. Please review.
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>

	I tried to break this, and couldn't.  Tested with regular
ethernet interfaces, as well as VLANs, and it does the right thing.

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 7c0e0bd..6ebd88d 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1093,15 +1093,8 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
> 			return NULL; /* still no slave, return NULL */
> 	}
>
>-	/*
>-	 * first try the primary link; if arping, a link must tx/rx
>-	 * traffic before it can be considered the curr_active_slave.
>-	 * also, we would skip slaves between the curr_active_slave
>-	 * and primary_slave that may be up and able to arp
>-	 */
> 	if ((bond->primary_slave) &&
>-	    (!bond->params.arp_interval) &&
>-	    (IS_UP(bond->primary_slave->dev))) {
>+	    bond->primary_slave->link == BOND_LINK_UP) {
> 		new_active = bond->primary_slave;
> 	}
>
>@@ -1109,15 +1102,14 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
> 	old_active = new_active;
>
> 	bond_for_each_slave_from(bond, new_active, i, old_active) {
>-		if (IS_UP(new_active->dev)) {
>-			if (new_active->link == BOND_LINK_UP) {
>-				return new_active;
>-			} else if (new_active->link == BOND_LINK_BACK) {
>-				/* link up, but waiting for stabilization */
>-				if (new_active->delay < mintime) {
>-					mintime = new_active->delay;
>-					bestslave = new_active;
>-				}
>+		if (new_active->link == BOND_LINK_UP) {
>+			return new_active;
>+		} else if (new_active->link == BOND_LINK_BACK &&
>+			   IS_UP(new_active->dev)) {
>+			/* link up, but waiting for stabilization */
>+			if (new_active->delay < mintime) {
>+				mintime = new_active->delay;
>+				bestslave = new_active;
> 			}
> 		}
> 	}
>@@ -2929,18 +2921,6 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
> 		}
> 	}
>
>-	read_lock(&bond->curr_slave_lock);
>-
>-	/*
>-	 * Trigger a commit if the primary option setting has changed.
>-	 */
>-	if (bond->primary_slave &&
>-	    (bond->primary_slave != bond->curr_active_slave) &&
>-	    (bond->primary_slave->link == BOND_LINK_UP))
>-		commit++;
>-
>-	read_unlock(&bond->curr_slave_lock);
>-
> 	return commit;
> }
>
>@@ -2961,90 +2941,58 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
> 			continue;
>
> 		case BOND_LINK_UP:
>-			write_lock_bh(&bond->curr_slave_lock);
>-
>-			if (!bond->curr_active_slave &&
>-			    time_before_eq(jiffies, dev_trans_start(slave->dev) +
>-					   delta_in_ticks)) {
>+			if ((!bond->curr_active_slave &&
>+			     time_before_eq(jiffies,
>+					    dev_trans_start(slave->dev) +
>+					    delta_in_ticks)) ||
>+			    bond->curr_active_slave != slave) {
> 				slave->link = BOND_LINK_UP;
>-				bond_change_active_slave(bond, slave);
> 				bond->current_arp_slave = NULL;
>
> 				pr_info(DRV_NAME
>-				       ": %s: %s is up and now the "
>-				       "active interface\n",
>-				       bond->dev->name, slave->dev->name);
>-
>-			} else if (bond->curr_active_slave != slave) {
>-				/* this slave has just come up but we
>-				 * already have a current slave; this can
>-				 * also happen if bond_enslave adds a new
>-				 * slave that is up while we are searching
>-				 * for a new slave
>-				 */
>-				slave->link = BOND_LINK_UP;
>-				bond_set_slave_inactive_flags(slave);
>-				bond->current_arp_slave = NULL;
>+					": %s: link status definitely "
>+					"up for interface %s.\n",
>+					bond->dev->name, slave->dev->name);
>
>-				pr_info(DRV_NAME
>-				       ": %s: backup interface %s is now up\n",
>-				       bond->dev->name, slave->dev->name);
>-			}
>+				if (!bond->curr_active_slave ||
>+				    (slave == bond->primary_slave))
>+					goto do_failover;
>
>-			write_unlock_bh(&bond->curr_slave_lock);
>+			}
>
>-			break;
>+			continue;
>
> 		case BOND_LINK_DOWN:
> 			if (slave->link_failure_count < UINT_MAX)
> 				slave->link_failure_count++;
>
> 			slave->link = BOND_LINK_DOWN;
>+			bond_set_slave_inactive_flags(slave);
>
>-			if (slave == bond->curr_active_slave) {
>-				pr_info(DRV_NAME
>-				       ": %s: link status down for active "
>-				       "interface %s, disabling it\n",
>-				       bond->dev->name, slave->dev->name);
>-
>-				bond_set_slave_inactive_flags(slave);
>-
>-				write_lock_bh(&bond->curr_slave_lock);
>-
>-				bond_select_active_slave(bond);
>-				if (bond->curr_active_slave)
>-					bond->curr_active_slave->jiffies =
>-						jiffies;
>-
>-				write_unlock_bh(&bond->curr_slave_lock);
>+			pr_info(DRV_NAME
>+				": %s: link status definitely down for "
>+				"interface %s, disabling it\n",
>+				bond->dev->name, slave->dev->name);
>
>+			if (slave == bond->curr_active_slave) {
> 				bond->current_arp_slave = NULL;
>-
>-			} else if (slave->state == BOND_STATE_BACKUP) {
>-				pr_info(DRV_NAME
>-				       ": %s: backup interface %s is now down\n",
>-				       bond->dev->name, slave->dev->name);
>-
>-				bond_set_slave_inactive_flags(slave);
>+				goto do_failover;
> 			}
>-			break;
>+
>+			continue;
>
> 		default:
> 			pr_err(DRV_NAME
> 			       ": %s: impossible: new_link %d on slave %s\n",
> 			       bond->dev->name, slave->new_link,
> 			       slave->dev->name);
>+			continue;
> 		}
>-	}
>
>-	/*
>-	 * No race with changes to primary via sysfs, as we hold rtnl.
>-	 */
>-	if (bond->primary_slave &&
>-	    (bond->primary_slave != bond->curr_active_slave) &&
>-	    (bond->primary_slave->link == BOND_LINK_UP)) {
>+do_failover:
>+		ASSERT_RTNL();
> 		write_lock_bh(&bond->curr_slave_lock);
>-		bond_change_active_slave(bond, bond->primary_slave);
>+		bond_select_active_slave(bond);
> 		write_unlock_bh(&bond->curr_slave_lock);
> 	}
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
