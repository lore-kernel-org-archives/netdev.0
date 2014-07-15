From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 1/3] bonding: get rid of
 bond_option_active_slave_get()
Date: Tue, 15 Jul 2014 12:24:41 +0200
Message-ID: <20140715102441.GB28235@mikrodark.usersys.redhat.com>
References: <1405417604-7828-1-git-send-email-edumazet@google.com>
 <1405417604-7828-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:64827 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758038AbaGOK1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 06:27:39 -0400
Received: by mail-wg0-f49.google.com with SMTP id k14so4749770wgh.32
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 03:27:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405417604-7828-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 02:46:42AM -0700, Eric Dumazet wrote:
>Only keep bond_option_active_slave_get_rcu() helper.
>
>bond_fill_info() uses a new bond_option_active_slave_get_ifindex()
>helper.
>
>Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Veaceslav Falico <vfalico@gmail.com>

>---
> drivers/net/bonding/bond_netlink.c | 21 ++++++++++++++++-----
> drivers/net/bonding/bond_options.c |  5 -----
> drivers/net/bonding/bonding.h      |  1 -
> 3 files changed, 16 insertions(+), 11 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
>index 5ab3c1847e67..4d97e23eb497 100644
>--- a/drivers/net/bonding/bond_netlink.c
>+++ b/drivers/net/bonding/bond_netlink.c
>@@ -398,20 +398,31 @@ static size_t bond_get_size(const struct net_device *bond_dev)
> 		0;
> }
>
>+static int bond_option_active_slave_get_ifindex(struct bonding *bond)
>+{
>+	const struct net_device *slave;
>+	int ifindex;
>+
>+	rcu_read_lock();
>+	slave = bond_option_active_slave_get_rcu(bond);
>+	ifindex = slave ? slave->ifindex : 0;
>+	rcu_read_unlock();
>+	return ifindex;
>+}
>+
> static int bond_fill_info(struct sk_buff *skb,
> 			  const struct net_device *bond_dev)
> {
> 	struct bonding *bond = netdev_priv(bond_dev);
>-	struct net_device *slave_dev = bond_option_active_slave_get(bond);
>-	struct nlattr *targets;
> 	unsigned int packets_per_slave;
>-	int i, targets_added;
>+	int ifindex, i, targets_added;
>+	struct nlattr *targets;
>
> 	if (nla_put_u8(skb, IFLA_BOND_MODE, BOND_MODE(bond)))
> 		goto nla_put_failure;
>
>-	if (slave_dev &&
>-	    nla_put_u32(skb, IFLA_BOND_ACTIVE_SLAVE, slave_dev->ifindex))
>+	ifindex = bond_option_active_slave_get_ifindex(bond);
>+	if (ifindex && nla_put_u32(skb, IFLA_BOND_ACTIVE_SLAVE, ifindex))
> 		goto nla_put_failure;
>
> 	if (nla_put_u32(skb, IFLA_BOND_MIIMON, bond->params.miimon))
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index 540e0167bf24..b26271fd7b09 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -704,11 +704,6 @@ struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond)
> 	return __bond_option_active_slave_get(bond, slave);
> }
>
>-struct net_device *bond_option_active_slave_get(struct bonding *bond)
>-{
>-	return __bond_option_active_slave_get(bond, bond->curr_active_slave);
>-}
>-
> static int bond_option_active_slave_set(struct bonding *bond,
> 					const struct bond_opt_value *newval)
> {
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 0b4d9cde0b05..713e2a99c661 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -514,7 +514,6 @@ unsigned int bond_get_num_tx_queues(void);
> int bond_netlink_init(void);
> void bond_netlink_fini(void);
> struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
>-struct net_device *bond_option_active_slave_get(struct bonding *bond);
> const char *bond_slave_link_status(s8 link);
> bool bond_verify_device_path(struct net_device *start_dev,
> 			     struct net_device *end_dev,
>-- 
>2.0.0.526.g5318336
>
