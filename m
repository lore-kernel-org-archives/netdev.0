From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2/4 v3] bonding: make sure tx and rx hash tables stay in sync when using alb mode
Date: Mon, 28 Sep 2009 15:09:54 -0700
Message-ID: <1915.1254175794@death.nxdomain.ibm.com>
References: <20090911211112.GR8515@gospo.rdu.redhat.com> <27763.1253144169@death.nxdomain.ibm.com> <20090918153622.GX8515@gospo.rdu.redhat.com> <20090918155645.GB4436@gospo.rdu.redhat.com> <20090928220020.GC4436@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:42166 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753362AbZI1WJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2009 18:09:56 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8SM38fs015420
	for <netdev@vger.kernel.org>; Mon, 28 Sep 2009 18:03:08 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8SMA09q237684
	for <netdev@vger.kernel.org>; Mon, 28 Sep 2009 18:10:00 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8SM9xLt001195
	for <netdev@vger.kernel.org>; Mon, 28 Sep 2009 18:10:00 -0400
In-reply-to: <20090928220020.GC4436@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>On Fri, Sep 18, 2009 at 11:56:45AM -0400, Andy Gospodarek wrote:
>> On Fri, Sep 18, 2009 at 11:36:22AM -0400, Andy Gospodarek wrote:
>> > On Wed, Sep 16, 2009 at 04:36:09PM -0700, Jay Vosburgh wrote:
>> > > Andy Gospodarek <andy@greyhouse.net> wrote:
>> > > 
>> > > >
>> > > >Subject: [PATCH] bonding: make sure tx and rx hash tables stay in sync when using alb mode
>> > > 
>> > > 	When testing this, I'm getting a lockdep warning.  It appears to
>> > > be unhappy that tlb_choose_channel acquires the tx / rx hash table locks
>> > > in the order tx then rx, but rlb_choose_channel -> alb_get_best_slave
>> > > acquires the locks in the other order.  I applied all four patches, but
>> > > it looks like the change that trips lockdep is in this patch (#2).
>> > > 
>> > > 	I haven't gotten an actual deadlock from this, although it seems
>> > > plausible if there are two cpus in bond_alb_xmit at the same time, and
>> > > one of them is sending an ARP.
>> > > 
>> > > 	One fairly straightforward fix would be to combine the rx and tx
>> > > hash table locks into a single lock.  I suspect that wouldn't have any
>> > > real performance penalty, since the rx hash table lock is generally not
>> > > acquired very often (unlike the tx lock, which is taken for every packet
>> > > that goes out).
>> > > 
>> > > 	Also, FYI, two of the four patches had trailing whitespace.  I
>> > > believe it was #2 and #4.
>> > > 
>> > > 	Thoughts?
>> > 
>> > Jay,
>> > 
>> > This patch should address both the the deadlock and whitespace conerns.
>> > I ran a kernel with LOCKDEP enabled and saw no warnings while passing
>> > traffic on the bond while pulling cables and while removing the module.
>> > Here it is....
>> > 
>> 
>> Adding the version and signed-off-by lines might be nice, eh?
>> 
>> [PATCH v3] bonding: make sure tx and rx hash tables stay in sync when using alb mode
>> 
>> I noticed that it was easy for alb (mode 6) bonding to get into a state
>> where the tx hash-table and rx hash-table are out of sync (there is
>> really nothing to keep them synchronized), and we will transmit traffic
>> destined for a host on one slave and send ARP frames to the same slave
>> from another interface using a different source MAC.
>> 
>> There is no compelling reason to do this, so this patch makes sure the
>> rx hash-table changes whenever the tx hash-table is updated based on
>> device load.  This patch also drops the code that does rlb re-balancing
>> since the balancing will not be controlled by the tx hash-table based on

	In addition to my response in the other thread, I changed the
"not" above to "now," which I suspect is what you meant.

>> transmit load.  In order to address an issue found with the initial
>> patch, I have also combined the rx and tx hash table lock into a single
>> lock.  This will facilitate moving these into a single table at some
>> point.
>> 
>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>> 
>> ---
>>  drivers/net/bonding/bond_alb.c |  203 +++++++++++++++-------------------------
>>  drivers/net/bonding/bond_alb.h |    3 +-
>>  2 files changed, 75 insertions(+), 131 deletions(-)
>> 
>> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>> index bcf25c6..04b7055 100644
>> --- a/drivers/net/bonding/bond_alb.c
>> +++ b/drivers/net/bonding/bond_alb.c
>> @@ -111,6 +111,7 @@ static inline struct arp_pkt *arp_pkt(const struct sk_buff *skb)
>>  
>>  /* Forward declaration */
>>  static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[]);
>> +static struct slave *alb_get_best_slave(struct bonding *bond, u32 hash_index);
>>  
>>  static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
>>  {
>> @@ -124,18 +125,18 @@ static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
>>  	return hash;
>>  }
>>  
>> -/*********************** tlb specific functions ***************************/
>> -
>> -static inline void _lock_tx_hashtbl(struct bonding *bond)
>> +/********************* hash table lock functions *************************/
>> +static inline void _lock_hashtbl(struct bonding *bond)
>>  {
>> -	spin_lock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
>> +	spin_lock_bh(&(BOND_ALB_INFO(bond).hashtbl_lock));
>>  }
>>  
>> -static inline void _unlock_tx_hashtbl(struct bonding *bond)
>> +static inline void _unlock_hashtbl(struct bonding *bond)
>>  {
>> -	spin_unlock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
>> +	spin_unlock_bh(&(BOND_ALB_INFO(bond).hashtbl_lock));
>>  }
>>  
>> +/*********************** tlb specific functions ***************************/
>>  /* Caller must hold tx_hashtbl lock */
>>  static inline void tlb_init_table_entry(struct tlb_client_info *entry, int save_load)
>>  {
>> @@ -163,7 +164,7 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
>>  	struct tlb_client_info *tx_hash_table;
>>  	u32 index;
>>  
>> -	_lock_tx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	/* clear slave from tx_hashtbl */
>>  	tx_hash_table = BOND_ALB_INFO(bond).tx_hashtbl;
>> @@ -180,7 +181,7 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
>>  
>>  	tlb_init_slave(slave);
>>  
>> -	_unlock_tx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  }
>>  
>>  /* Must be called before starting the monitor timer */
>> @@ -191,7 +192,7 @@ static int tlb_initialize(struct bonding *bond)
>>  	struct tlb_client_info *new_hashtbl;
>>  	int i;
>>  
>> -	spin_lock_init(&(bond_info->tx_hashtbl_lock));
>> +	spin_lock_init(&(bond_info->hashtbl_lock));
>>  
>>  	new_hashtbl = kzalloc(size, GFP_KERNEL);
>>  	if (!new_hashtbl) {
>> @@ -200,7 +201,7 @@ static int tlb_initialize(struct bonding *bond)
>>  		       bond->dev->name);
>>  		return -1;
>>  	}
>> -	_lock_tx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	bond_info->tx_hashtbl = new_hashtbl;
>>  
>> @@ -208,7 +209,7 @@ static int tlb_initialize(struct bonding *bond)
>>  		tlb_init_table_entry(&bond_info->tx_hashtbl[i], 1);
>>  	}
>>  
>> -	_unlock_tx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  
>>  	return 0;
>>  }
>> @@ -218,12 +219,12 @@ static void tlb_deinitialize(struct bonding *bond)
>>  {
>>  	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>>  
>> -	_lock_tx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	kfree(bond_info->tx_hashtbl);
>>  	bond_info->tx_hashtbl = NULL;
>>  
>> -	_unlock_tx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  }
>>  
>>  /* Caller must hold bond lock for read */
>> @@ -264,24 +265,6 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
>>  	return least_loaded;
>>  }
>>  
>> -/* Caller must hold bond lock for read and hashtbl lock */
>> -static struct slave *tlb_get_best_slave(struct bonding *bond, u32 hash_index)
>> -{
>> -	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>> -	struct tlb_client_info *tx_hash_table = bond_info->tx_hashtbl;
>> -	struct slave *last_slave = tx_hash_table[hash_index].last_slave;
>> -	struct slave *next_slave = NULL;
>> -
>> -	if (last_slave && SLAVE_IS_OK(last_slave)) {
>> -		/* Use the last slave listed in the tx hashtbl if:
>> -		   the last slave currently is essentially unloaded. */
>> -		if (SLAVE_TLB_INFO(last_slave).load < 10)
>> -			next_slave = last_slave;
>> -	}
>> -
>> -	return next_slave ? next_slave : tlb_get_least_loaded_slave(bond);
>> -}
>> -
>>  /* Caller must hold bond lock for read */
>>  static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u32 skb_len)
>>  {
>> @@ -289,13 +272,12 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
>>  	struct tlb_client_info *hash_table;
>>  	struct slave *assigned_slave;
>>  
>> -	_lock_tx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	hash_table = bond_info->tx_hashtbl;
>>  	assigned_slave = hash_table[hash_index].tx_slave;
>>  	if (!assigned_slave) {
>> -		assigned_slave = tlb_get_best_slave(bond, hash_index);
>> -
>> +		assigned_slave = alb_get_best_slave(bond, hash_index);
>>  		if (assigned_slave) {
>>  			struct tlb_slave_info *slave_info =
>>  				&(SLAVE_TLB_INFO(assigned_slave));
>> @@ -319,20 +301,52 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
>>  		hash_table[hash_index].tx_bytes += skb_len;
>>  	}
>>  
>> -	_unlock_tx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  
>>  	return assigned_slave;
>>  }
>>  
>>  /*********************** rlb specific functions ***************************/
>> -static inline void _lock_rx_hashtbl(struct bonding *bond)
>> +
>> +/* Caller must hold bond lock for read and hashtbl lock */
>> +static struct slave *rlb_update_rx_table(struct bonding *bond, struct slave *next_slave, u32 hash_index)
>>  {
>> -	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
>> +	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>> +
>> +	/* check rlb table and correct it if wrong */
>> +	if (bond_info->rlb_enabled) {
>> +		struct rlb_client_info *rx_client_info = &(bond_info->rx_hashtbl[hash_index]);
>> +
>> +		/* if the new slave computed by tlb checks doesn't match rlb, stop rlb from using it */
>> +		if (next_slave && (next_slave != rx_client_info->slave))
>> +			rx_client_info->slave = next_slave;
>> +	}
>> +	return next_slave;
>>  }
>>  
>> -static inline void _unlock_rx_hashtbl(struct bonding *bond)
>> +/* Caller must hold bond lock for read and hashtbl lock */
>> +static struct slave *alb_get_best_slave(struct bonding *bond, u32 hash_index)
>>  {
>> -	spin_unlock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
>> +	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>> +	struct tlb_client_info *tx_hash_table = bond_info->tx_hashtbl;
>> +	struct slave *last_slave = tx_hash_table[hash_index].last_slave;
>> +	struct slave *next_slave = NULL;
>> +
>> +	/* presume the next slave will be the least loaded one */
>> +	next_slave = tlb_get_least_loaded_slave(bond);
>> +
>> +	if (last_slave && SLAVE_IS_OK(last_slave)) {
>> +		/* Use the last slave listed in the tx hashtbl if:
>> +		   the last slave currently is essentially unloaded. */
>> +		if (SLAVE_TLB_INFO(last_slave).load < 10)
>> +			next_slave = last_slave;
>> +	}
>> +
>> +	/* update the rlb hashtbl if there was a previous entry */
>> +	if (bond_info->rlb_enabled)
>> +		rlb_update_rx_table(bond, next_slave, hash_index);
>> +
>> +	return next_slave;
>>  }
>>  
>>  /* when an ARP REPLY is received from a client update its info
>> @@ -344,7 +358,7 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
>>  	struct rlb_client_info *client_info;
>>  	u32 hash_index;
>>  
>> -	_lock_rx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	hash_index = _simple_hash((u8*)&(arp->ip_src), sizeof(arp->ip_src));
>>  	client_info = &(bond_info->rx_hashtbl[hash_index]);
>> @@ -358,7 +372,7 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
>>  		bond_info->rx_ntt = 1;
>>  	}
>>  
>> -	_unlock_rx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  }
>>  
>>  static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct packet_type *ptype, struct net_device *orig_dev)
>> @@ -402,38 +416,6 @@ out:
>>  	return res;
>>  }
>>  
>> -/* Caller must hold bond lock for read */
>> -static struct slave *rlb_next_rx_slave(struct bonding *bond)
>> -{
>> -	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>> -	struct slave *rx_slave, *slave, *start_at;
>> -	int i = 0;
>> -
>> -	if (bond_info->next_rx_slave) {
>> -		start_at = bond_info->next_rx_slave;
>> -	} else {
>> -		start_at = bond->first_slave;
>> -	}
>> -
>> -	rx_slave = NULL;
>> -
>> -	bond_for_each_slave_from(bond, slave, i, start_at) {
>> -		if (SLAVE_IS_OK(slave)) {
>> -			if (!rx_slave) {
>> -				rx_slave = slave;
>> -			} else if (slave->speed > rx_slave->speed) {
>> -				rx_slave = slave;
>> -			}
>> -		}
>> -	}
>> -
>> -	if (rx_slave) {
>> -		bond_info->next_rx_slave = rx_slave->next;
>> -	}
>> -
>> -	return rx_slave;
>> -}
>> -
>>  /* teach the switch the mac of a disabled slave
>>   * on the primary for fault tolerance
>>   *
>> @@ -468,14 +450,14 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
>>  	u32 index, next_index;
>>  
>>  	/* clear slave from rx_hashtbl */
>> -	_lock_rx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	rx_hash_table = bond_info->rx_hashtbl;
>>  	index = bond_info->rx_hashtbl_head;
>>  	for (; index != RLB_NULL_INDEX; index = next_index) {
>>  		next_index = rx_hash_table[index].next;
>>  		if (rx_hash_table[index].slave == slave) {
>> -			struct slave *assigned_slave = rlb_next_rx_slave(bond);
>> +			struct slave *assigned_slave = alb_get_best_slave(bond, index);
>>  
>>  			if (assigned_slave) {
>>  				rx_hash_table[index].slave = assigned_slave;
>> @@ -499,7 +481,7 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
>>  		}
>>  	}
>>  
>> -	_unlock_rx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  
>>  	write_lock_bh(&bond->curr_slave_lock);
>>  
>> @@ -558,7 +540,7 @@ static void rlb_update_rx_clients(struct bonding *bond)
>>  	struct rlb_client_info *client_info;
>>  	u32 hash_index;
>>  
>> -	_lock_rx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	hash_index = bond_info->rx_hashtbl_head;
>>  	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
>> @@ -576,7 +558,7 @@ static void rlb_update_rx_clients(struct bonding *bond)
>>  	 */
>>  	bond_info->rlb_update_delay_counter = RLB_UPDATE_DELAY;
>>  
>> -	_unlock_rx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  }
>>  
>>  /* The slave was assigned a new mac address - update the clients */
>> @@ -587,7 +569,7 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
>>  	int ntt = 0;
>>  	u32 hash_index;
>>  
>> -	_lock_rx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	hash_index = bond_info->rx_hashtbl_head;
>>  	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
>> @@ -607,7 +589,7 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
>>  		bond_info->rlb_update_retry_counter = RLB_UPDATE_RETRY;
>>  	}
>>  
>> -	_unlock_rx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  }
>>  
>>  /* mark all clients using src_ip to be updated */
>> @@ -617,7 +599,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
>>  	struct rlb_client_info *client_info;
>>  	u32 hash_index;
>>  
>> -	_lock_rx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	hash_index = bond_info->rx_hashtbl_head;
>>  	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
>> @@ -643,7 +625,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
>>  		}
>>  	}
>>  
>> -	_unlock_rx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  }
>>  
>>  /* Caller must hold both bond and ptr locks for read */
>> @@ -655,7 +637,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
>>  	struct rlb_client_info *client_info;
>>  	u32 hash_index = 0;
>>  
>> -	_lock_rx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_src));
>>  	client_info = &(bond_info->rx_hashtbl[hash_index]);
>> @@ -671,7 +653,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
>>  
>>  			assigned_slave = client_info->slave;
>>  			if (assigned_slave) {
>> -				_unlock_rx_hashtbl(bond);
>> +				_unlock_hashtbl(bond);
>>  				return assigned_slave;
>>  			}
>>  		} else {
>> @@ -687,7 +669,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
>>  		}
>>  	}
>>  	/* assign a new slave */
>> -	assigned_slave = rlb_next_rx_slave(bond);
>> +	assigned_slave = alb_get_best_slave(bond, hash_index);
>>  
>>  	if (assigned_slave) {
>>  		client_info->ip_src = arp->ip_src;
>> @@ -723,7 +705,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
>>  		}
>>  	}
>>  
>> -	_unlock_rx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  
>>  	return assigned_slave;
>>  }
>> @@ -771,36 +753,6 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
>>  	return tx_slave;
>>  }
>>  
>> -/* Caller must hold bond lock for read */
>> -static void rlb_rebalance(struct bonding *bond)
>> -{
>> -	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>> -	struct slave *assigned_slave;
>> -	struct rlb_client_info *client_info;
>> -	int ntt;
>> -	u32 hash_index;
>> -
>> -	_lock_rx_hashtbl(bond);
>> -
>> -	ntt = 0;
>> -	hash_index = bond_info->rx_hashtbl_head;
>> -	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
>> -		client_info = &(bond_info->rx_hashtbl[hash_index]);
>> -		assigned_slave = rlb_next_rx_slave(bond);
>> -		if (assigned_slave && (client_info->slave != assigned_slave)) {
>> -			client_info->slave = assigned_slave;
>> -			client_info->ntt = 1;
>> -			ntt = 1;
>> -		}
>> -	}
>> -
>> -	/* update the team's flag only after the whole iteration */
>> -	if (ntt) {
>> -		bond_info->rx_ntt = 1;
>> -	}
>> -	_unlock_rx_hashtbl(bond);
>> -}
>> -
>>  /* Caller must hold rx_hashtbl lock */
>>  static void rlb_init_table_entry(struct rlb_client_info *entry)
>>  {
>> @@ -817,8 +769,6 @@ static int rlb_initialize(struct bonding *bond)
>>  	int size = RLB_HASH_TABLE_SIZE * sizeof(struct rlb_client_info);
>>  	int i;
>>  
>> -	spin_lock_init(&(bond_info->rx_hashtbl_lock));
>> -
>>  	new_hashtbl = kmalloc(size, GFP_KERNEL);
>>  	if (!new_hashtbl) {
>>  		printk(KERN_ERR DRV_NAME
>> @@ -826,7 +776,7 @@ static int rlb_initialize(struct bonding *bond)
>>  		       bond->dev->name);
>>  		return -1;
>>  	}
>> -	_lock_rx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	bond_info->rx_hashtbl = new_hashtbl;
>>  
>> @@ -836,7 +786,7 @@ static int rlb_initialize(struct bonding *bond)
>>  		rlb_init_table_entry(bond_info->rx_hashtbl + i);
>>  	}
>>  
>> -	_unlock_rx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  
>>  	/*initialize packet type*/
>>  	pk_type->type = cpu_to_be16(ETH_P_ARP);
>> @@ -855,13 +805,13 @@ static void rlb_deinitialize(struct bonding *bond)
>>  
>>  	dev_remove_pack(&(bond_info->rlb_pkt_type));
>>  
>> -	_lock_rx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	kfree(bond_info->rx_hashtbl);
>>  	bond_info->rx_hashtbl = NULL;
>>  	bond_info->rx_hashtbl_head = RLB_NULL_INDEX;
>>  
>> -	_unlock_rx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  }
>>  
>>  static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
>> @@ -869,7 +819,7 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
>>  	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>>  	u32 curr_index;
>>  
>> -	_lock_rx_hashtbl(bond);
>> +	_lock_hashtbl(bond);
>>  
>>  	curr_index = bond_info->rx_hashtbl_head;
>>  	while (curr_index != RLB_NULL_INDEX) {
>> @@ -894,7 +844,7 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
>>  		curr_index = next_index;
>>  	}
>>  
>> -	_unlock_rx_hashtbl(bond);
>> +	_unlock_hashtbl(bond);
>>  }
>>  
>>  /*********************** tlb/rlb shared functions *********************/
>> @@ -1521,11 +1471,6 @@ void bond_alb_monitor(struct work_struct *work)
>>  			read_lock(&bond->lock);
>>  		}
>>  
>> -		if (bond_info->rlb_rebalance) {
>> -			bond_info->rlb_rebalance = 0;
>> -			rlb_rebalance(bond);
>> -		}
>> -
>>  		/* check if clients need updating */
>>  		if (bond_info->rx_ntt) {
>>  			if (bond_info->rlb_update_delay_counter) {
>> diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
>> index b65fd29..09d755a 100644
>> --- a/drivers/net/bonding/bond_alb.h
>> +++ b/drivers/net/bonding/bond_alb.h
>> @@ -90,7 +90,7 @@ struct tlb_slave_info {
>>  struct alb_bond_info {
>>  	struct timer_list	alb_timer;
>>  	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
>> -	spinlock_t		tx_hashtbl_lock;
>> +	spinlock_t		hashtbl_lock; /* lock for both tables */
>>  	u32			unbalanced_load;
>>  	int			tx_rebalance_counter;
>>  	int			lp_counter;
>> @@ -98,7 +98,6 @@ struct alb_bond_info {
>>  	int rlb_enabled;
>>  	struct packet_type	rlb_pkt_type;
>>  	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
>> -	spinlock_t		rx_hashtbl_lock;
>>  	u32			rx_hashtbl_head;
>>  	u8			rx_ntt;	/* flag - need to transmit
>>  					 * to all rx clients
>
>Any thoughts on this, Jay?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
