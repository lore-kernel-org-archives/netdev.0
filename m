From: Yan Burman <yanb@mellanox.com>
Subject: Re: [PATCH net-next 7/9] net/mlx4_en: Manage hash of MAC addresses
 per port
Date: Tue, 5 Feb 2013 16:14:49 +0200
Message-ID: <511113D9.3000301@mellanox.com>
References: <1360063716-13415-1-git-send-email-amirv@mellanox.com>  <1360063716-13415-8-git-send-email-amirv@mellanox.com> <1360072063.28557.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:37810 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751901Ab3BEOPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 09:15:11 -0500
In-Reply-To: <1360072063.28557.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05-Feb-13 15:47, Eric Dumazet wrote:
> On Tue, 2013-02-05 at 13:28 +0200, Amir Vadai wrote:
>> From: Yan Burman <yanb@mellanox.com>
>>
>> As a preparation step for supporting multiple unicast addresses, store MAC addresses in hash table.
>> Remove the radix tree for MAC addresses per QP, as it's not in use.
>>
>> Signed-off-by: Yan Burman <yanb@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   89 +++++++++++++++---------
>>   drivers/net/ethernet/mellanox/mlx4/en_rx.c     |   23 +++++-
>>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    6 ++-
>>   3 files changed, 80 insertions(+), 38 deletions(-)
>>
> ...
>
>>
>>   alloc_err:
>>   	mlx4_en_uc_steer_release(priv, priv->dev->dev_addr, *qpn, reg_id);
>> @@ -568,7 +565,6 @@ static void mlx4_en_put_qp(struct mlx4_en_priv *priv)
>>   {
>>   	struct mlx4_en_dev *mdev = priv->mdev;
>>   	struct mlx4_dev *dev = mdev->dev;
>> -	struct mlx4_mac_entry *entry;
>>   	int qpn = priv->base_qpn;
>>   	u64 mac = mlx4_en_mac_to_u64(priv->dev->dev_addr);
>>
>> @@ -577,15 +573,27 @@ static void mlx4_en_put_qp(struct mlx4_en_priv *priv)
>>   	mlx4_unregister_mac(dev, priv->port, mac);
>>
>>   	if (dev->caps.steering_mode != MLX4_STEERING_MODE_A0) {
>> -		entry = radix_tree_lookup(&priv->mac_tree, qpn);
>> -		if (entry) {
>> -			en_dbg(DRV, priv, "Releasing qp: port %d, MAC %pM, qpn %d\n",
>> -			       priv->port, entry->mac, qpn);
>> -			mlx4_en_uc_steer_release(priv, entry->mac,
>> -						 qpn, entry->reg_id);
>> -			mlx4_qp_release_range(dev, qpn, 1);
>> -			radix_tree_delete(&priv->mac_tree, qpn);
>> -			kfree(entry);
>> +		struct mlx4_mac_entry *entry;
>> +		struct hlist_node *n, *tmp;
>> +		struct hlist_head *bucket;
>> +		unsigned int mac_hash;
>> +
>> +		mac_hash = priv->dev->dev_addr[MLX4_EN_MAC_HASH_IDX];
>> +		bucket = &priv->mac_hash[mac_hash];
>> +		hlist_for_each_entry_safe(entry, n, tmp, bucket, hlist) {
>> +			if (ether_addr_equal_64bits(entry->mac,
>> +						    priv->dev->dev_addr)) {
>> +				en_dbg(DRV, priv, "Releasing qp: port %d, MAC %pM, qpn %d\n",
>> +				       priv->port, priv->dev->dev_addr, qpn);
>> +				mlx4_en_uc_steer_release(priv, entry->mac,
>> +							 qpn, entry->reg_id);
>> +				mlx4_qp_release_range(dev, qpn, 1);
>> +
>> +				hlist_del_rcu(&entry->hlist);
>> +				synchronize_rcu();
> Please use kfree_rcu()

Ok, will do

>
>> +				kfree(entry);
>> +				break;
>> +			}
>>   		}
>>   	}
>>   }
>> @@ -595,26 +603,39 @@ static int mlx4_en_replace_mac(struct mlx4_en_priv *priv, int qpn,
>>   {
>>   	struct mlx4_en_dev *mdev = priv->mdev;
>>   	struct mlx4_dev *dev = mdev->dev;
>> -	struct mlx4_mac_entry *entry;
>>   	int err = 0;
>>   	u64 new_mac_u64 = mlx4_en_mac_to_u64(new_mac);
>>
>>   	if (dev->caps.steering_mode != MLX4_STEERING_MODE_A0) {
>> -		u64 prev_mac_u64;
>> -
>> -		entry = radix_tree_lookup(&priv->mac_tree, qpn);
>> -		if (!entry)
>> -			return -EINVAL;
>> -		prev_mac_u64 = mlx4_en_mac_to_u64(entry->mac);
>> -		mlx4_en_uc_steer_release(priv, entry->mac,
>> -					 qpn, entry->reg_id);
>> -		mlx4_unregister_mac(dev, priv->port, prev_mac_u64);
>> -		memcpy(entry->mac, new_mac, ETH_ALEN);
>> -		entry->reg_id = 0;
>> -		mlx4_register_mac(dev, priv->port, new_mac_u64);
>> -		err = mlx4_en_uc_steer_add(priv, new_mac,
>> -					   &qpn, &entry->reg_id);
>> -		return err;
>> +		struct hlist_head *bucket;
>> +		unsigned int mac_hash;
>> +		struct mlx4_mac_entry *entry;
>> +		struct hlist_node *n, *tmp;
>> +		u64 prev_mac_u64 = mlx4_en_mac_to_u64(prev_mac);
>> +
>> +		bucket = &priv->mac_hash[prev_mac[MLX4_EN_MAC_HASH_IDX]];
>> +		hlist_for_each_entry_safe(entry, n, tmp, bucket, hlist) {
>> +			if (ether_addr_equal_64bits(entry->mac, prev_mac)) {
>> +				mlx4_en_uc_steer_release(priv, entry->mac,
>> +							 qpn, entry->reg_id);
>> +				mlx4_unregister_mac(dev, priv->port,
>> +						    prev_mac_u64);
>> +				hlist_del_rcu(&entry->hlist);
>> +				synchronize_rcu();
>> +				memcpy(entry->mac, new_mac, ETH_ALEN);
>> +				entry->reg_id = 0;
>> +				mac_hash = new_mac[MLX4_EN_MAC_HASH_IDX];
>> +				hlist_add_head_rcu(&entry->hlist,
>> +						   &priv->mac_hash[mac_hash]);
>> +				synchronize_rcu();
> Why is this synchronize_rcu() is needed ?

You are right. The second synchronize_rcu()  is not required.
