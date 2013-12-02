From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 4/7] bridge: Fix the way checking if a local fdb entry
 can be deleted
Date: Mon, 02 Dec 2013 12:07:45 -0500
Message-ID: <529CBE61.8030402@redhat.com>
References: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <1385966439-26526-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589Ab3LBRHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Dec 2013 12:07:51 -0500
In-Reply-To: <1385966439-26526-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2013 01:40 AM, Toshiaki Makita wrote:
> We should take into account the followings when deleting a local fdb entry.
> 
> - nbp_vlan_find() can be used only when vid != 0 to check if an entry is
>   deletable, because a fdb entry with vid 0 can exist at any time but
>   nbp_vlan_find() always return false with vid 0.
> 
>   Example of problematic case:
>     ip link set eth0 address 12:34:56:78:90:ab
>     ip link set eth1 address 12:34:56:78:90:ab
>     brctl addif br0 eth0
>     brctl addif br0 eth1
>     ip link set eth0 address aa:bb:cc:dd:ee:ff
>   Then, the fdb entry 12:34:56:78:90:ab will be deleted even though the
>   bridge port eth1 still has that address.
> 
> - The port to which the bridge device is attached might needs a local entry
>   if its mac address is set manually.
> 
>   Example of problematic case:
>     ip link set eth0 address 12:34:56:78:90:ab
>     brctl addif br0 eth0
>     ip link set br0 address 12:34:56:78:90:ab
>     ip link set eth0 address aa:bb:cc:dd:ee:ff
>   Then, the fdb still must have the entry 12:34:56:78:90:ab, but it will be
>   deleted.
> 
> We can use br->dev->addr_assign_type to check if the address is manually
> set or not, but I propose another approach.
> 
> Since we delete and insert local entries whenever changing mac address
> of the bridge device, we can change dst of the entry to NULL regardless of
> addr_assign_type when deleting an entry associated with a certain port,
> and if it is found to be unnecessary later, then delete it.
> That is, if changing mac address of a port, the entry might be changed
> to its dst being NULL first, but is eventually deleted when recalculating
> and changing bridge id.
> 
> This approach is useful when we want to share the code with deleting
> vlan in which the bridge device might want such an entry regardless of
> addr_assign_type, and makes things easy because we don't have to consider
> if mac address of the bridge device will be changed or not at
> fdb_delete_local().

This is a nifty approach, but it does have one side-effect that I am not
sure is correct.  In the case where bridge mac address is not manually
set, a fdb entry for the removed address survives past the
synchronize_net() call.  This would result in a behavioral change where
packets that always used to flood, would now sometimes be delivered
only to the bridge.

-vlad


> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>  net/bridge/br_fdb.c     |  9 ++++++++-
>  net/bridge/br_private.h |  6 ++++++
>  net/bridge/br_vlan.c    | 19 +++++++++++++++++++
>  3 files changed, 33 insertions(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index d29e184..2c79b1b 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -108,12 +108,19 @@ static void fdb_delete_local(struct net_bridge *br,
>  	/* Maybe another port has same hw addr? */
>  	list_for_each_entry(op, &br->port_list, list) {
>  		if (op != p && ether_addr_equal(op->dev->dev_addr, addr) &&
> -		    nbp_vlan_find(op, vid)) {
> +		    (!vid || nbp_vlan_find(op, vid))) {
>  			f->dst = op;
>  			return;
>  		}
>  	}
>  
> +	/* Maybe bridge device has same hw addr? */
> +	if (p && ether_addr_equal(br->dev->dev_addr, addr) &&
> +	    (!vid || br_vlan_find(br, vid))) {
> +		f->dst = NULL;
> +		return;
> +	}
> +
>  	fdb_delete(br, f);
>  }
>  
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 0902658..673ef9d 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -584,6 +584,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
>  int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
>  int br_vlan_delete(struct net_bridge *br, u16 vid);
>  void br_vlan_flush(struct net_bridge *br);
> +bool br_vlan_find(struct net_bridge *br, u16 vid);
>  int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
>  int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
>  int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
> @@ -665,6 +666,11 @@ static inline void br_vlan_flush(struct net_bridge *br)
>  {
>  }
>  
> +static inline bool br_vlan_find(struct net_bridge *br, u16 vid)
> +{
> +	return false;
> +}
> +
>  static inline int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
>  {
>  	return -EOPNOTSUPP;
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index af5ebd1..f87ab88f 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -316,6 +316,25 @@ void br_vlan_flush(struct net_bridge *br)
>  	__vlan_flush(pv);
>  }
>  
> +bool br_vlan_find(struct net_bridge *br, u16 vid)
> +{
> +	struct net_port_vlans *pv;
> +	bool found = false;
> +
> +	rcu_read_lock();
> +	pv = rcu_dereference(br->vlan_info);
> +
> +	if (!pv)
> +		goto out;
> +
> +	if (test_bit(vid, pv->vlan_bitmap))
> +		found = true;
> +
> +out:
> +	rcu_read_unlock();
> +	return found;
> +}
> +
>  int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
>  {
>  	if (!rtnl_trylock())
> 
