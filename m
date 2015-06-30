From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] bridge: vlan: flush the dynamically
 learned entries on port vlan delete
Date: Tue, 30 Jun 2015 09:50:11 -0400
Message-ID: <55929E93.90703@gmail.com>
References: <1435062496-14596-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1435062496-14596-1-git-send-email-nikolay@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 06/23/2015 08:28 AM, Nikolay Aleksandrov wrote:
> Add a new argument to br_fdb_delete_by_port which allows to specify a
> vid to match when flushing entries and use it in nbp_vlan_delete() to
> flush the dynamically learned entries of the vlan/port pair when removing
> a vlan from a port. Before this patch only the local mac was being
> removed and the dynamically learned ones were left to expire.
> Note that the do_all argument is still respected and if specified, the
> vid will be ignored.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> note: There are 2 warnings, the C99 comment was already there and the 81
>       char line is the prototype and I think it looks better this way.
>       One unclear thing is about vid 0, I see that it can be passed to
>       nbp_vlan_(add|delete) although the comment says it shouldn't.
>       Adding Vlad to CC list since he has introduced the vlan filtering
>       infrastructure.

sorry, missed this one somewhow...

There is no explicit check inside the nbp_vlan_[add|del] because most checks
are at higher level functions.  It should be impossible to call it with vid of
0.

This code looks fine to me.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> 
>  net/bridge/br_fdb.c      | 7 +++++--
>  net/bridge/br_if.c       | 4 ++--
>  net/bridge/br_private.h  | 2 +-
>  net/bridge/br_stp_if.c   | 2 +-
>  net/bridge/br_sysfs_if.c | 2 +-
>  net/bridge/br_vlan.c     | 1 +
>  6 files changed, 11 insertions(+), 7 deletions(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index be84b7e5a3da..9e9875da0a4f 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -330,9 +330,11 @@ void br_fdb_flush(struct net_bridge *br)
>  
>  /* Flush all entries referring to a specific port.
>   * if do_all is set also flush static entries
> + * if vid is set delete all entries that match the vlan_id
>   */
>  void br_fdb_delete_by_port(struct net_bridge *br,
>  			   const struct net_bridge_port *p,
> +			   u16 vid,
>  			   int do_all)
>  {
>  	int i;
> @@ -347,8 +349,9 @@ void br_fdb_delete_by_port(struct net_bridge *br,
>  			if (f->dst != p)
>  				continue;
>  
> -			if (f->is_static && !do_all)
> -				continue;
> +			if (!do_all)
> +				if (f->is_static || (vid && f->vlan_id != vid))
> +					continue;
>  
>  			if (f->is_local)
>  				fdb_delete_local(br, p, f);
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 1849d96b3c91..a538cb1199a3 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -249,7 +249,7 @@ static void del_nbp(struct net_bridge_port *p)
>  	list_del_rcu(&p->list);
>  
>  	nbp_vlan_flush(p);
> -	br_fdb_delete_by_port(br, p, 1);
> +	br_fdb_delete_by_port(br, p, 0, 1);
>  	nbp_update_port_count(br);
>  
>  	netdev_upper_dev_unlink(dev, br->dev);
> @@ -278,7 +278,7 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
>  		del_nbp(p);
>  	}
>  
> -	br_fdb_delete_by_port(br, NULL, 1);
> +	br_fdb_delete_by_port(br, NULL, 0, 1);
>  
>  	br_vlan_flush(br);
>  	del_timer_sync(&br->gc_timer);
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 5dccced71269..8b21146b24a0 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -387,7 +387,7 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr);
>  void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr);
>  void br_fdb_cleanup(unsigned long arg);
>  void br_fdb_delete_by_port(struct net_bridge *br,
> -			   const struct net_bridge_port *p, int do_all);
> +			   const struct net_bridge_port *p, u16 vid, int do_all);
>  struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
>  					  const unsigned char *addr, __u16 vid);
>  int br_fdb_test_addr(struct net_device *dev, unsigned char *addr);
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index 41146872c1b4..762d490a16f2 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -111,7 +111,7 @@ void br_stp_disable_port(struct net_bridge_port *p)
>  	del_timer(&p->forward_delay_timer);
>  	del_timer(&p->hold_timer);
>  
> -	br_fdb_delete_by_port(br, p, 0);
> +	br_fdb_delete_by_port(br, p, 0, 0);
>  	br_multicast_disable_port(p);
>  
>  	br_configuration_update(br);
> diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
> index 4905845a94e9..efe415ad842a 100644
> --- a/net/bridge/br_sysfs_if.c
> +++ b/net/bridge/br_sysfs_if.c
> @@ -160,7 +160,7 @@ static BRPORT_ATTR(hold_timer, S_IRUGO, show_hold_timer, NULL);
>  
>  static int store_flush(struct net_bridge_port *p, unsigned long v)
>  {
> -	br_fdb_delete_by_port(p->br, p, 0); // Don't delete local entry
> +	br_fdb_delete_by_port(p->br, p, 0, 0); // Don't delete local entry
>  	return 0;
>  }
>  static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 17fc358a5432..9e1b9c1b4880 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -741,6 +741,7 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
>  		return -EINVAL;
>  
>  	br_fdb_find_delete_local(port->br, port, port->dev->dev_addr, vid);
> +	br_fdb_delete_by_port(port->br, port, vid, 0);
>  
>  	return __vlan_del(pv, vid);
>  }
> 
