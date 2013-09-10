From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH -net v2 2/2] bonding: fix bond_arp_rcv setting and arp
 validate desync state
Date: Tue, 10 Sep 2013 11:48:48 -0300
Message-ID: <522F3150.2090708@redhat.com>
References: <1378504826-18855-1-git-send-email-nikolay@redhat.com> <1378504826-18855-3-git-send-email-nikolay@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45926 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207Ab3IJOwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 10:52:31 -0400
In-Reply-To: <1378504826-18855-3-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 06-09-2013 19:00, Nikolay Aleksandrov escreveu:
> We make bond_arp_rcv global so it can be used in bond_sysfs if the bond
> interface is up and arp_interval is being changed to a positive value
> and cleared otherwise as per Jay's suggestion.
> This also fixes a problem where bond_arp_rcv was set even though
> arp_validate was disabled while the bond was up by unsetting recv_probe
> in bond_store_arp_validate and respectively setting it if enabled.
>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>

> ---
> v2: fix the mode check in store_arp_validate
> I've intentionally left the prototype line >80 chars, let me know if I
> should break it.
>
>   drivers/net/bonding/bond_main.c  |  4 ++--
>   drivers/net/bonding/bond_sysfs.c | 19 ++++++++++++++++---
>   drivers/net/bonding/bonding.h    |  1 +
>   3 files changed, 19 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 39e5b1c..72df399 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2404,8 +2404,8 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
>   	slave->target_last_arp_rx[i] = jiffies;
>   }
>
> -static int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
> -			struct slave *slave)
> +int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
> +		 struct slave *slave)
>   {
>   	struct arphdr *arp = (struct arphdr *)skb->data;
>   	unsigned char *arp_ptr;
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
> index 4e38683..eeab40b 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -349,6 +349,8 @@ static ssize_t bonding_store_mode(struct device *d,
>   		goto out;
>   	}
>
> +	/* don't cache arp_validate between modes */
> +	bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
>   	bond->params.mode = new_value;
>   	bond_set_mode_ops(bond, bond->params.mode);
>   	pr_info("%s: setting mode to %s (%d).\n",
> @@ -419,8 +421,8 @@ static ssize_t bonding_store_arp_validate(struct device *d,
>   					  struct device_attribute *attr,
>   					  const char *buf, size_t count)
>   {
> -	int new_value, ret = count;
>   	struct bonding *bond = to_bond(d);
> +	int new_value, ret = count;
>
>   	if (!rtnl_trylock())
>   		return restart_syscall();
> @@ -431,7 +433,7 @@ static ssize_t bonding_store_arp_validate(struct device *d,
>   		ret = -EINVAL;
>   		goto out;
>   	}
> -	if (new_value && (bond->params.mode != BOND_MODE_ACTIVEBACKUP)) {
> +	if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
>   		pr_err("%s: arp_validate only supported in active-backup mode.\n",
>   		       bond->dev->name);
>   		ret = -EINVAL;
> @@ -441,6 +443,12 @@ static ssize_t bonding_store_arp_validate(struct device *d,
>   		bond->dev->name, arp_validate_tbl[new_value].modename,
>   		new_value);
>
> +	if (bond->dev->flags & IFF_UP) {
> +		if (!new_value)
> +			bond->recv_probe = NULL;
> +		else if (bond->params.arp_interval)
> +			bond->recv_probe = bond_arp_rcv;
> +	}
>   	bond->params.arp_validate = new_value;
>   out:
>   	rtnl_unlock();
> @@ -561,8 +569,8 @@ static ssize_t bonding_store_arp_interval(struct device *d,
>   					  struct device_attribute *attr,
>   					  const char *buf, size_t count)
>   {
> -	int new_value, ret = count;
>   	struct bonding *bond = to_bond(d);
> +	int new_value, ret = count;
>
>   	if (!rtnl_trylock())
>   		return restart_syscall();
> @@ -605,8 +613,13 @@ static ssize_t bonding_store_arp_interval(struct device *d,
>   		 * is called.
>   		 */
>   		if (!new_value) {
> +			if (bond->params.arp_validate)
> +				bond->recv_probe = NULL;
>   			cancel_delayed_work_sync(&bond->arp_work);
>   		} else {
> +			/* arp_validate can be set only in active-backup mode */
> +			if (bond->params.arp_validate)
> +				bond->recv_probe = bond_arp_rcv;
>   			cancel_delayed_work_sync(&bond->mii_work);
>   			queue_delayed_work(bond->wq, &bond->arp_work, 0);
>   		}
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index f7ab161..7ad8bd5 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -430,6 +430,7 @@ static inline bool slave_can_tx(struct slave *slave)
>
>   struct bond_net;
>
> +int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond, struct slave *slave);
>   struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
>   int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
>   void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id);
>
