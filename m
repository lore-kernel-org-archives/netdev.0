From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v2 8/9] bridge: Properly check if local fdb entry
 can be deleted when deleting vlan
Date: Tue, 17 Dec 2013 14:34:53 -0500
Message-ID: <52B0A75D.90609@redhat.com>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <1387281821-21342-9-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44103 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332Ab3LQTfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 14:35:14 -0500
In-Reply-To: <1387281821-21342-9-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 07:03 AM, Toshiaki Makita wrote:
> Vlan codes unconditionally delete local fdb entries.
> We should consider the possibility that other ports have the same
> address and vlan.
> 
> Example of problematic case:
>   ip link set eth0 address 12:34:56:78:90:ab
>   ip link set eth1 address aa:bb:cc:dd:ee:ff
>   brctl addif br0 eth0
>   brctl addif br0 eth1 # br0 will have mac address 12:34:56:78:90:ab
>   bridge vlan add dev eth0 vid 10
>   bridge vlan add dev eth1 vid 10
>   bridge vlan add dev br0 vid 10 self
> We will have fdb entry such that f->dst == eth0, f->vlan_id == 10 and
> f->addr == 12:34:56:78:90:ab at this time.
> Next, delete eth0 vlan 10.
>   bridge vlan del dev eth0 vid 10
> In this case, we still need the entry for br0, but it will be deleted.
> 
> Note that br0 needs the entry even though its mac address is not set
> manually. To delete the entry with proper condition checking,
> fdb_delete_local() is suitable to use.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

Note: All these special cases are begging for something in the fdb
to track if this fdb refers to multiple ports or not.  May be
a list of pointers to ports?  Then we can simply check to see if
the list is not empty and assign to the first one in the list..

-vlad

> ---
>  net/bridge/br_fdb.c     | 20 ++++++++++++++++++--
>  net/bridge/br_private.h |  4 +++-
>  net/bridge/br_vlan.c    |  8 ++------
>  3 files changed, 23 insertions(+), 9 deletions(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index bd43cb1..38cd29d 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -27,6 +27,9 @@
>  #include "br_private.h"
>  
>  static struct kmem_cache *br_fdb_cache __read_mostly;
> +static struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
> +					     const unsigned char *addr,
> +					     __u16 vid);
>  static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
>  		      const unsigned char *addr, u16 vid);
>  static void fdb_notify(struct net_bridge *br,
> @@ -119,6 +122,20 @@ static void fdb_delete_local(struct net_bridge *br,
>  	fdb_delete(br, f);
>  }
>  
> +void br_fdb_find_delete_local(struct net_bridge *br,
> +			      const struct net_bridge_port *p,
> +			      const unsigned char *addr, u16 vid)
> +{
> +	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
> +	struct net_bridge_fdb_entry *f;
> +
> +	spin_lock_bh(&br->hash_lock);
> +	f = fdb_find(head, addr, vid);
> +	if (f && f->is_local && !f->added_by_user && f->dst == p)
> +		fdb_delete_local(br, p, f);
> +	spin_unlock_bh(&br->hash_lock);
> +}
> +
>  void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
>  {
>  	struct net_bridge *br = p->br;
> @@ -766,8 +783,7 @@ out:
>  	return err;
>  }
>  
> -int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr,
> -		       u16 vlan)
> +static int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr, u16 vlan)
>  {
>  	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan)];
>  	struct net_bridge_fdb_entry *fdb;
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 868c059..14c74c2 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -379,6 +379,9 @@ static inline void br_netpoll_disable(struct net_bridge_port *p)
>  int br_fdb_init(void);
>  void br_fdb_fini(void);
>  void br_fdb_flush(struct net_bridge *br);
> +void br_fdb_find_delete_local(struct net_bridge *br,
> +			      const struct net_bridge_port *p,
> +			      const unsigned char *addr, u16 vid);
>  void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr);
>  void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr);
>  void br_fdb_cleanup(unsigned long arg);
> @@ -393,7 +396,6 @@ int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
>  		  const unsigned char *addr, u16 vid);
>  void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
>  		   const unsigned char *addr, u16 vid);
> -int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr, u16 vid);
>  
>  int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
>  		  struct net_device *dev, const unsigned char *addr);
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index f87ab88f..24db71d 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -296,9 +296,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
>  	if (!pv)
>  		return -EINVAL;
>  
> -	spin_lock_bh(&br->hash_lock);
> -	fdb_delete_by_addr(br, br->dev->dev_addr, vid);
> -	spin_unlock_bh(&br->hash_lock);
> +	br_fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
>  
>  	__vlan_del(pv, vid);
>  	return 0;
> @@ -399,9 +397,7 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
>  	if (!pv)
>  		return -EINVAL;
>  
> -	spin_lock_bh(&port->br->hash_lock);
> -	fdb_delete_by_addr(port->br, port->dev->dev_addr, vid);
> -	spin_unlock_bh(&port->br->hash_lock);
> +	br_fdb_find_delete_local(port->br, port, port->dev->dev_addr, vid);
>  
>  	return __vlan_del(pv, vid);
>  }
> 
