From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] bonding: make ab_arp select active slaves
	as other modes
Date: Tue, 15 Sep 2009 20:55:24 +0200
Message-ID: <20090915185523.GA3382@psychotron.redhat.com>
References: <20090831210937.GA3152@psychotron.redhat.com> <26579.1252629138@death.nxdomain.ibm.com> <20090915150848.GC6624@psychotron.lab.eng.brq.redhat.com> <30429.1253031653@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bonding-devel@lists.sourceforge.net, nicolas.2p.debian@free.fr
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754518AbZIOSzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 14:55:47 -0400
Content-Disposition: inline
In-Reply-To: <30429.1253031653@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 15, 2009 at 06:20:53PM CEST, fubar@us.ibm.com wrote:
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>>Fri, Sep 11, 2009 at 02:32:18AM CEST, fubar@us.ibm.com wrote:
>>>Jiri Pirko <jpirko@redhat.com> wrote:
>>>
>>>>When I was implementing primary_passive option (formely named primary_lazy) I've
>>>>run into troubles with ab_arp. This is the only mode which is not using
>>>>bond_select_active_slave() function to select active slave and instead it
>>>>selects it itself. This seems to be not the right behaviour and it would be
>>>>better to do it in bond_select_active_slave() for all cases. This patch makes
>>>>this happen. Please review.
>>>
>>>	Sorry for the delay in response; was out of the office.
>>>
>>>	My first question is whether this affect the "current_arp_slave"
>>>behavior, i.e., the round-robining of the ARP probes when no slaves are
>>>active.  Is that something you checked?
>>
>>Yes, according to my tests this behaves the same way as original code.
>>How about your tests?
>
>	Yah, it seems to work like it should.  I just have this nagging
>feeling I'm forgetting something; that there was a reason that the ab
>ARP was doing things differently.  I sure don't remember, though;
>probably just getting old.
>
>	The only nitpicks I see are a couple of changes that appear to
>be just for style ("break" changed to "continue"; some code rearranged
>in bond_find_best_slave, which is noted below) and one locking nit:
>strictly speaking, curr_slave_lock should be held for read when
>inspecting curr_active_slave.  The place it happens, though, already
>holds rtnl, and all changes to curr_active_slave happen under rtnl, so
>it won't actually fail, but it's different than everywhere else.

Well I changed bond_ab_arp_commit to be similar to bond_miimon_commit. Therefor
changing breaks to continues, no curr_active_lock around
bond_select_active_slave etc.

I adjusted bond_find_best_slave to work with slave->link so this could be used
with arp too. I believe changes in this function are correct and my test results
are telling the same.

I hope I cleared all your comments :)

Jirka

>
>	I've been gnawing on getting rid of curr_slave_lock for a while;
>I think it can go away, and be subsumed into the general bond->lock.
>The curr_active_slave is (today, this didn't used to be true) only
>changed under rtnl, but some other code does inspect it outside of rtnl.

I was looking on this several times but I haven't found a courage to actually
eliminate this lock... (and use rculists etc...) Maybe later :)

Jirka

>
>	-J
>
>
>
>>Jirka
>>
>>>
>>>	I'll give this a test tomorrow as well.
>>>
>>>	-J
>>>
>>>---
>>>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>>>
>>>>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>>>
>>>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>>>index 7c0e0bd..6ebd88d 100644
>>>>--- a/drivers/net/bonding/bond_main.c
>>>>+++ b/drivers/net/bonding/bond_main.c
>>>>@@ -1093,15 +1093,8 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
>>>> 			return NULL; /* still no slave, return NULL */
>>>> 	}
>>>>
>>>>-	/*
>>>>-	 * first try the primary link; if arping, a link must tx/rx
>>>>-	 * traffic before it can be considered the curr_active_slave.
>>>>-	 * also, we would skip slaves between the curr_active_slave
>>>>-	 * and primary_slave that may be up and able to arp
>>>>-	 */
>>>> 	if ((bond->primary_slave) &&
>>>>-	    (!bond->params.arp_interval) &&
>>>>-	    (IS_UP(bond->primary_slave->dev))) {
>>>>+	    bond->primary_slave->link == BOND_LINK_UP) {
>>>> 		new_active = bond->primary_slave;
>>>> 	}
>>>>
>>>>@@ -1109,15 +1102,14 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
>>>> 	old_active = new_active;
>>>>
>>>> 	bond_for_each_slave_from(bond, new_active, i, old_active) {
>>>>-		if (IS_UP(new_active->dev)) {
>>>>-			if (new_active->link == BOND_LINK_UP) {
>>>>-				return new_active;
>>>>-			} else if (new_active->link == BOND_LINK_BACK) {
>>>>-				/* link up, but waiting for stabilization */
>>>>-				if (new_active->delay < mintime) {
>>>>-					mintime = new_active->delay;
>>>>-					bestslave = new_active;
>>>>-				}
>>>>+		if (new_active->link == BOND_LINK_UP) {
>>>>+			return new_active;
>>>>+		} else if (new_active->link == BOND_LINK_BACK &&
>>>>+			   IS_UP(new_active->dev)) {
>>>>+			/* link up, but waiting for stabilization */
>>>>+			if (new_active->delay < mintime) {
>>>>+				mintime = new_active->delay;
>>>>+				bestslave = new_active;
>>>
>>>	Is there a functional reason for rearranging this (i.e., did the
>>>use of select_active_slave need this for some reason)?
>>>
>>>
>>>> 			}
>>>> 		}
>>>> 	}
>>>>@@ -2929,18 +2921,6 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
>>>> 		}
>>>> 	}
>>>>
>>>>-	read_lock(&bond->curr_slave_lock);
>>>>-
>>>>-	/*
>>>>-	 * Trigger a commit if the primary option setting has changed.
>>>>-	 */
>>>>-	if (bond->primary_slave &&
>>>>-	    (bond->primary_slave != bond->curr_active_slave) &&
>>>>-	    (bond->primary_slave->link == BOND_LINK_UP))
>>>>-		commit++;
>>>>-
>>>>-	read_unlock(&bond->curr_slave_lock);
>>>>-
>>>> 	return commit;
>>>> }
>>>>
>>>>@@ -2961,90 +2941,58 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
>>>> 			continue;
>>>>
>>>> 		case BOND_LINK_UP:
>>>>-			write_lock_bh(&bond->curr_slave_lock);
>>>>-
>>>>-			if (!bond->curr_active_slave &&
>>>>-			    time_before_eq(jiffies, dev_trans_start(slave->dev) +
>>>>-					   delta_in_ticks)) {
>>>>+			if ((!bond->curr_active_slave &&
>>>>+			     time_before_eq(jiffies,
>>>>+					    dev_trans_start(slave->dev) +
>>>>+					    delta_in_ticks)) ||
>>>>+			    bond->curr_active_slave != slave) {
>>>> 				slave->link = BOND_LINK_UP;
>>>>-				bond_change_active_slave(bond, slave);
>>>> 				bond->current_arp_slave = NULL;
>>>>
>>>> 				pr_info(DRV_NAME
>>>>-				       ": %s: %s is up and now the "
>>>>-				       "active interface\n",
>>>>-				       bond->dev->name, slave->dev->name);
>>>>-
>>>>-			} else if (bond->curr_active_slave != slave) {
>>>>-				/* this slave has just come up but we
>>>>-				 * already have a current slave; this can
>>>>-				 * also happen if bond_enslave adds a new
>>>>-				 * slave that is up while we are searching
>>>>-				 * for a new slave
>>>>-				 */
>>>>-				slave->link = BOND_LINK_UP;
>>>>-				bond_set_slave_inactive_flags(slave);
>>>>-				bond->current_arp_slave = NULL;
>>>>+					": %s: link status definitely "
>>>>+					"up for interface %s.\n",
>>>>+					bond->dev->name, slave->dev->name);
>>>>
>>>>-				pr_info(DRV_NAME
>>>>-				       ": %s: backup interface %s is now up\n",
>>>>-				       bond->dev->name, slave->dev->name);
>>>>-			}
>>>>+				if (!bond->curr_active_slave ||
>>>>+				    (slave == bond->primary_slave))
>>>>+					goto do_failover;
>>>>
>>>>-			write_unlock_bh(&bond->curr_slave_lock);
>>>>+			}
>>>>
>>>>-			break;
>>>>+			continue;
>>>>
>>>> 		case BOND_LINK_DOWN:
>>>> 			if (slave->link_failure_count < UINT_MAX)
>>>> 				slave->link_failure_count++;
>>>>
>>>> 			slave->link = BOND_LINK_DOWN;
>>>>+			bond_set_slave_inactive_flags(slave);
>>>>
>>>>-			if (slave == bond->curr_active_slave) {
>>>>-				pr_info(DRV_NAME
>>>>-				       ": %s: link status down for active "
>>>>-				       "interface %s, disabling it\n",
>>>>-				       bond->dev->name, slave->dev->name);
>>>>-
>>>>-				bond_set_slave_inactive_flags(slave);
>>>>-
>>>>-				write_lock_bh(&bond->curr_slave_lock);
>>>>-
>>>>-				bond_select_active_slave(bond);
>>>>-				if (bond->curr_active_slave)
>>>>-					bond->curr_active_slave->jiffies =
>>>>-						jiffies;
>>>>-
>>>>-				write_unlock_bh(&bond->curr_slave_lock);
>>>>+			pr_info(DRV_NAME
>>>>+				": %s: link status definitely down for "
>>>>+				"interface %s, disabling it\n",
>>>>+				bond->dev->name, slave->dev->name);
>>>>
>>>>+			if (slave == bond->curr_active_slave) {
>>>> 				bond->current_arp_slave = NULL;
>>>>-
>>>>-			} else if (slave->state == BOND_STATE_BACKUP) {
>>>>-				pr_info(DRV_NAME
>>>>-				       ": %s: backup interface %s is now down\n",
>>>>-				       bond->dev->name, slave->dev->name);
>>>>-
>>>>-				bond_set_slave_inactive_flags(slave);
>>>>+				goto do_failover;
>>>> 			}
>>>>-			break;
>>>>+
>>>>+			continue;
>>>>
>>>> 		default:
>>>> 			pr_err(DRV_NAME
>>>> 			       ": %s: impossible: new_link %d on slave %s\n",
>>>> 			       bond->dev->name, slave->new_link,
>>>> 			       slave->dev->name);
>>>>+			continue;
>>>> 		}
>>>>-	}
>>>>
>>>>-	/*
>>>>-	 * No race with changes to primary via sysfs, as we hold rtnl.
>>>>-	 */
>>>>-	if (bond->primary_slave &&
>>>>-	    (bond->primary_slave != bond->curr_active_slave) &&
>>>>-	    (bond->primary_slave->link == BOND_LINK_UP)) {
>>>>+do_failover:
>>>>+		ASSERT_RTNL();
>>>> 		write_lock_bh(&bond->curr_slave_lock);
>>>>-		bond_change_active_slave(bond, bond->primary_slave);
>>>>+		bond_select_active_slave(bond);
>>>> 		write_unlock_bh(&bond->curr_slave_lock);
>>>> 	}
>>>>
>>>>--
>>>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>>the body of a message to majordomo@vger.kernel.org
>>>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>>
