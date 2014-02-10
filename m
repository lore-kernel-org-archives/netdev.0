From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v3 net 5/9] bridge: Fix the way to check if a local fdb
 entry can be deleted
Date: Mon, 10 Feb 2014 12:22:52 -0500
Message-ID: <52F90AEC.70906@redhat.com>
References: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <1391759306-24956-6-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213AbaBJRW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 12:22:58 -0500
In-Reply-To: <1391759306-24956-6-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2014 02:48 AM, Toshiaki Makita wrote:
> We should take into account the followings when deleting a local fdb
> entry.
> 
> - nbp_vlan_find() can be used only when vid != 0 to check if an entry is
>   deletable, because a fdb entry with vid 0 can exist at any time while
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
> This approach is especially useful when we want to share the code with
> deleting vlan in which the bridge device might want such an entry regardless
> of addr_assign_type, and makes things easy because we don't have to consider
> if mac address of the bridge device will be changed or not at the time we
> delete a local entry of a port, which means fdb code will not be bothered
> even if the bridge id calculating logic is changed in the future.
> 
> Also, this change reduces inconsistent state, where frames whose dst is the
> mac address of the bridge, can't reach the bridge because of premature fdb
> entry deletion. This change reduces the possibility that the bridge device
> replies unreachable mac address to arp requests, which could occur during
> the short window between calling del_nbp() and br_stp_recalculate_bridge_id()
> in br_del_if(). This will effective after br_fdb_delete_by_port() starts to
> use the same code by following patch.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad

> ---
>  net/bridge/br_fdb.c     | 10 +++++++++-
>  net/bridge/br_private.h |  6 ++++++
>  net/bridge/br_vlan.c    | 19 +++++++++++++++++++
>  3 files changed, 34 insertions(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 96ab1d1..b4005f5 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -114,12 +114,20 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
>  					if (op != p &&
>  					    ether_addr_equal(op->dev->dev_addr,
>  							     f->addr.addr) &&
> -					    nbp_vlan_find(op, vid)) {
> +					    (!vid || nbp_vlan_find(op, vid))) {
>  						f->dst = op;
>  						goto skip_delete;
>  					}
>  				}
>  
> +				/* maybe bridge device has same hw addr? */
> +				if (ether_addr_equal(br->dev->dev_addr,
> +						     f->addr.addr) &&
> +				    (!vid || br_vlan_find(br, vid))) {
> +					f->dst = NULL;
> +					goto skip_delete;
> +				}
> +
>  				/* delete old one */
>  				fdb_delete(br, f);
>  skip_delete:
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 939a59e..f91e1d9 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -585,6 +585,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
>  int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
>  int br_vlan_delete(struct net_bridge *br, u16 vid);
>  void br_vlan_flush(struct net_bridge *br);
> +bool br_vlan_find(struct net_bridge *br, u16 vid);
>  int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
>  int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
>  int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
> @@ -666,6 +667,11 @@ static inline void br_vlan_flush(struct net_bridge *br)
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
> index 4ca4d0a..233ec1c 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -295,6 +295,25 @@ void br_vlan_flush(struct net_bridge *br)
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
