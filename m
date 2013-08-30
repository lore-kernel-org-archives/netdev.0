From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 5/5] bonding: use RCU protection for alb xmit path
Date: Fri, 30 Aug 2013 11:39:28 +0800
Message-ID: <522013F0.8070001@huawei.com>
References: <521D7ACC.5010000@huawei.com> <521F5C19.2050506@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:48575 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab3H3Dj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:39:57 -0400
In-Reply-To: <521F5C19.2050506@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/29 22:35, Nikolay Aleksandrov wrote:
> On 08/28/2013 06:21 AM, Ding Tianhong wrote:
>> The commit 278b20837511776dc9d5f6ee1c7fabd5479838bb
>> (bonding: initial RCU conversion) has convert the roundrobin, active-backup,
>> broadcast and xor xmit path to rcu protection, the performance will be better
>> for these mode, so this time, convert xmit path for alb mode.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>> Cc: Nikolay Aleksandrov <nikolay@redhat.com>
>> Cc: Veaceslav Falico <vfalico@redhat.com>
>> ---
>>  drivers/net/bonding/bond_alb.c | 20 +++++++++-----------
>>  1 file changed, 9 insertions(+), 11 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>> index d266c56..e94a5d0 100644
>> --- a/drivers/net/bonding/bond_alb.c
>> +++ b/drivers/net/bonding/bond_alb.c
>> @@ -229,7 +229,7 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
>>  	max_gap = LLONG_MIN;
>>  
>>  	/* Find the slave with the largest gap */
>> -	bond_for_each_slave(bond, slave) {
>> +	bond_for_each_slave_rcu(bond, slave) {
>>  		if (SLAVE_IS_OK(slave)) {
>>  			long long gap = compute_gap(slave);
>>  
>> @@ -625,10 +625,12 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
>>  {
>>  	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>>  	struct arp_pkt *arp = arp_pkt(skb);
>> -	struct slave *assigned_slave;
>> +	struct slave *assigned_slave, *curr_active_slave;
>>  	struct rlb_client_info *client_info;
>>  	u32 hash_index = 0;
>>  
>> +	curr_active_slave = rcu_dereference(bond->curr_active_slave);
>> +
>>  	_lock_rx_hashtbl(bond);
>>  
>>  	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_dst));
>> @@ -654,9 +656,9 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
>>  			 * move the old client to primary (curr_active_slave) so
>>  			 * that the new client can be assigned to this entry.
>>  			 */
>> -			if (bond->curr_active_slave &&
>> -			    client_info->slave != bond->curr_active_slave) {
>> -				client_info->slave = bond->curr_active_slave;
>> +			if (curr_active_slave &&
>> +			    client_info->slave != curr_active_slave) {
>> +				client_info->slave = curr_active_slave;
>>  				rlb_update_client(client_info);
>>  			}
>>  		}
>> @@ -1336,8 +1338,6 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>>  
> In bond_alb_xmit we may call rlb_arp_xmit which calls bond_slave_has_mac() which
> is not using RCU primitives to traverse the list.
> 

yes, I miss the func bond_slave_has_mac(), I will add it in next version, thanks for review the code.

>>  	/* make sure that the curr_active_slave do not change during tx
>>  	 */
>> -	read_lock(&bond->lock);
>> -	read_lock(&bond->curr_slave_lock);
>>  
>>  	switch (ntohs(skb->protocol)) {
>>  	case ETH_P_IP: {
>> @@ -1420,12 +1420,12 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>>  
>>  	if (!tx_slave) {
>>  		/* unbalanced or unassigned, send through primary */
>> -		tx_slave = bond->curr_active_slave;
>> +		tx_slave = rcu_dereference(bond->curr_active_slave);
>>  		bond_info->unbalanced_load += skb->len;
>>  	}
>>  
>>  	if (tx_slave && SLAVE_IS_OK(tx_slave)) {
>> -		if (tx_slave != bond->curr_active_slave) {
>> +		if (tx_slave != rcu_dereference(bond->curr_active_slave)) {
>>  			memcpy(eth_data->h_source,
>>  			       tx_slave->dev->dev_addr,
>>  			       ETH_ALEN);
>> @@ -1440,8 +1440,6 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>>  		}
>>  	}
>>  
>> -	read_unlock(&bond->curr_slave_lock);
>> -	read_unlock(&bond->lock);
>>  	if (res) {
>>  		/* no suitable interface, frame not sent */
>>  		kfree_skb(skb);
>>
> 
> 
> .
> 
