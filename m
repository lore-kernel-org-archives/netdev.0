From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 6/6] bonding: use RCU protection for alb xmit
 path
Date: Tue, 03 Sep 2013 12:22:13 +0200
Message-ID: <5225B855.6080101@redhat.com>
References: <52206E54.4040001@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8229 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759710Ab3ICKZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 06:25:55 -0400
In-Reply-To: <52206E54.4040001@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2013 12:05 PM, Ding Tianhong wrote:
> The commit 278b20837511776dc9d5f6ee1c7fabd5479838bb
> (bonding: initial RCU conversion) has convert the roundrobin, active-backup,
> broadcast and xor xmit path to rcu protection, the performance will be better
> for these mode, so this time, convert xmit path for alb mode.
> 
> Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> Cc: Nikolay Aleksandrov <nikolay@redhat.com>
> Cc: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_alb.c | 20 +++++++++-----------
>  drivers/net/bonding/bonding.h  |  2 +-
>  2 files changed, 10 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index d266c56..e94a5d0 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -229,7 +229,7 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
>  	max_gap = LLONG_MIN;
>  
>  	/* Find the slave with the largest gap */
> -	bond_for_each_slave(bond, slave) {
> +	bond_for_each_slave_rcu(bond, slave) {
>  		if (SLAVE_IS_OK(slave)) {
>  			long long gap = compute_gap(slave);
>  
> @@ -625,10 +625,12 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
>  {
>  	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>  	struct arp_pkt *arp = arp_pkt(skb);
> -	struct slave *assigned_slave;
> +	struct slave *assigned_slave, *curr_active_slave;
>  	struct rlb_client_info *client_info;
>  	u32 hash_index = 0;
>  
> +	curr_active_slave = rcu_dereference(bond->curr_active_slave);
> +
I think this code is prone to a race condition with the slave removal, because
without the lock __bond_release_one() may think that it has done the LB release
(bond_alb_deinit_slave) and cleared the slave while you may set it after locking.
I guess you should move the dereference after the lock so to make sure that the
LB release hasn't passed (or it has and it'll be different).

>  	_lock_rx_hashtbl(bond);
>  
>  	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_dst));
> @@ -654,9 +656,9 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
>  			 * move the old client to primary (curr_active_slave) so
>  			 * that the new client can be assigned to this entry.
>  			 */
> -			if (bond->curr_active_slave &&
> -			    client_info->slave != bond->curr_active_slave) {
> -				client_info->slave = bond->curr_active_slave;
> +			if (curr_active_slave &&
> +			    client_info->slave != curr_active_slave) {
> +				client_info->slave = curr_active_slave;
>  				rlb_update_client(client_info);
>  			}
>  		}
> @@ -1336,8 +1338,6 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>  
>  	/* make sure that the curr_active_slave do not change during tx
>  	 */
> -	read_lock(&bond->lock);
> -	read_lock(&bond->curr_slave_lock);
>  
>  	switch (ntohs(skb->protocol)) {
>  	case ETH_P_IP: {
> @@ -1420,12 +1420,12 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>  
>  	if (!tx_slave) {
>  		/* unbalanced or unassigned, send through primary */
> -		tx_slave = bond->curr_active_slave;
> +		tx_slave = rcu_dereference(bond->curr_active_slave);
>  		bond_info->unbalanced_load += skb->len;
>  	}
>  
>  	if (tx_slave && SLAVE_IS_OK(tx_slave)) {
> -		if (tx_slave != bond->curr_active_slave) {
> +		if (tx_slave != rcu_dereference(bond->curr_active_slave)) {
>  			memcpy(eth_data->h_source,
>  			       tx_slave->dev->dev_addr,
>  			       ETH_ALEN);
> @@ -1440,8 +1440,6 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>  		}
>  	}
>  
> -	read_unlock(&bond->curr_slave_lock);
> -	read_unlock(&bond->lock);
>  	if (res) {
>  		/* no suitable interface, frame not sent */
>  		kfree_skb(skb);
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index a3ab47f..9bc3af0 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -536,7 +536,7 @@ static inline struct slave *bond_slave_has_mac(struct bonding *bond,
>  {
>  	struct slave *tmp;
>  
> -	bond_for_each_slave(bond, tmp)
> +	bond_for_each_slave_rcu(bond, tmp)
>  		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
>  			return tmp;
>  
> 
