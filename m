From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net-next 1/5] bonding: keep bond interface carrier off until at least one active member
Date: Mon, 19 Jan 2015 13:16:53 -0800
Message-ID: <20956.1421702213@famine>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com> <1421423848-414-2-git-send-email-jtoppins@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45774 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbASVRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 16:17:05 -0500
In-reply-to: <1421423848-414-2-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Toppins <jtoppins@cumulusnetworks.com> wrote:

>From: Scott Feldman <sfeldma@cumulusnetworks.com>
>
>Bonding driver parameter min_links is now used to signal upper-level
>protocols of bond status. The way it works is if the total number of
>active members in slaves drops below min_links, the bond link carrier
>will go down, signaling upper levels that bond is inactive.  When active
>members returns to >= min_links, bond link carrier will go up (RUNNING),
>and protocols can resume.  When bond is carrier down, member ports are
>in stp fwd state blocked (rather than normal disabled state), so
>low-level ctrl protocols (LACP) can still get in and be processed by
>bonding driver.

	Presuming that "stp" is Spanning Tree, is the last sentence
above actually describing the behavior of a bridge port when a bond is
the member of the bridge?  I'm not sure I understand what "member ports"
refers to (bridge ports or bonding slaves).

	One code comment, below...

>LACP will still do it's job while bond is carrier off, and if bond members
>become active, bond carrier will be turned back on, signaling higher-level
>protocols that bond is viable.
>
>Suggested setting of min_links is 1, rather than the default of zero.
>Using min_links=1 says that at least 1 slave must be active within bond
>for bond to be carrier on.
>
>Finally, when min_links bonding option is changed update carrier status.
>
>Cc: Scott Feldman <sfeldma@gmail.com>
>Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
>Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
>---
> drivers/net/bonding/bond_3ad.c     |   18 ++++++++++++++----
> drivers/net/bonding/bond_main.c    |    2 +-
> drivers/net/bonding/bond_options.c |    1 +
> include/net/bonding.h              |    1 +
> 4 files changed, 17 insertions(+), 5 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index 8baa87d..e9b706f 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -189,6 +189,7 @@ static inline int __agg_has_partner(struct aggregator *agg)
> static inline void __disable_port(struct port *port)
> {
> 	bond_set_slave_inactive_flags(port->slave, BOND_SLAVE_NOTIFY_LATER);
>+	bond_3ad_set_carrier(port->slave->bond);
> }
> 
> /**
>@@ -199,8 +200,10 @@ static inline void __enable_port(struct port *port)
> {
> 	struct slave *slave = port->slave;
> 
>-	if ((slave->link == BOND_LINK_UP) && bond_slave_is_up(slave))
>+	if ((slave->link == BOND_LINK_UP) && bond_slave_is_up(slave)) {
> 		bond_set_slave_active_flags(slave, BOND_SLAVE_NOTIFY_LATER);
>+		bond_3ad_set_carrier(slave->bond);
>+	}
> }
> 
> /**
>@@ -2372,8 +2375,10 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
> int bond_3ad_set_carrier(struct bonding *bond)
> {
> 	struct aggregator *active;
>-	struct slave *first_slave;
>+	struct slave *first_slave, *slave;
>+	struct list_head *iter;
> 	int ret = 1;
>+	int active_slaves = 0;
> 
> 	rcu_read_lock();
> 	first_slave = bond_first_slave_rcu(bond);
>@@ -2381,10 +2386,15 @@ int bond_3ad_set_carrier(struct bonding *bond)
> 		ret = 0;
> 		goto out;
> 	}
>+
>+	bond_for_each_slave_rcu(bond, slave, iter)
>+		if (SLAVE_AD_INFO(slave)->aggregator.is_active)
>+			active_slaves++;
>+
> 	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave)->aggregator));
>-	if (active) {
>+	if (active && __agg_has_partner(active)) {

	Why "__agg_has_partner"?  Since the "else" of this clause is:

        } else if (netif_carrier_ok(bond->dev)) {
                netif_carrier_off(bond->dev);
        }

	I'm wondering if this will do the right thing for the case that
there are no LACP partners at all (e.g., the switch ports do not have
LACP enabled), in which case the active aggregator should be a single
"individual" port as a fallback, but will not have a partner.

	-J


> 		/* are enough slaves available to consider link up? */
>-		if (active->num_of_ports < bond->params.min_links) {
>+		if (active_slaves < bond->params.min_links) {
> 			if (netif_carrier_ok(bond->dev)) {
> 				netif_carrier_off(bond->dev);
> 				goto out;
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 0dceba1..02ffedb 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -334,7 +334,7 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
>  *
>  * Returns zero if carrier state does not change, nonzero if it does.
>  */
>-static int bond_set_carrier(struct bonding *bond)
>+int bond_set_carrier(struct bonding *bond)
> {
> 	struct list_head *iter;
> 	struct slave *slave;
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index 9bd538d4..4df2894 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -1181,6 +1181,7 @@ static int bond_option_min_links_set(struct bonding *bond,
> 	netdev_info(bond->dev, "Setting min links value to %llu\n",
> 		    newval->value);
> 	bond->params.min_links = newval->value;
>+	bond_set_carrier(bond);
> 
> 	return 0;
> }
>diff --git a/include/net/bonding.h b/include/net/bonding.h
>index 983a94b..29f53ea 100644
>--- a/include/net/bonding.h
>+++ b/include/net/bonding.h
>@@ -525,6 +525,7 @@ void bond_sysfs_slave_del(struct slave *slave);
> int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
> int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
> u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb);
>+int bond_set_carrier(struct bonding *bond);
> void bond_select_active_slave(struct bonding *bond);
> void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
> void bond_create_debugfs(void);
>-- 
>1.7.10.4

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
