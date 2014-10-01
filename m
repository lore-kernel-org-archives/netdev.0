From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH v2 net 3/3] bridge: Add filtering support for
	default_pvid
Date: Wed, 01 Oct 2014 15:54:32 +0900
Message-ID: <542BA528.3040908@lab.ntt.co.jp>
References: <1412105462-340-1-git-send-email-vyasevic@redhat.com>
	<1412105462-340-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1412105462-340-4-git-send-email-vyasevic@redhat.com>
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

On 2014/10/01 4:31, Vladislav Yasevich wrote:
> Currently when vlan filtering is turned on on the bridge, the bridge
> will drop all traffic untill the user configures the filter.  This
> isn't very nice for ports that don't care about vlans and just
> want untagged traffic.
> 
> A concept of a default_pvid was recently introduced.  This patch
> adds filtering support for default_pvid.   Now, ports that don't
> care about vlans and don't define there own filter will belong
> to the VLAN of the default_pvid and continue to receive untagged
> traffic.
> 
> This filtering can be disabled by setting default_pvid to 0.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
...
> @@ -500,6 +500,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  	if (br_fdb_insert(br, p, dev->dev_addr, 0))
>  		netdev_err(dev, "failed insert local address bridge forwarding table\n");
>  
> +	nbp_vlan_init(p);
> +

The return value of nbp_vlan_init() is not handled.
How about logging in the same way as fdb-inserting?

>  	spin_lock_bh(&br->lock);
>  	changed_addr = br_stp_recalculate_bridge_id(br);
>  
...
> +static void br_vlan_disable_default_pvid(struct net_bridge *br)
> +{
> +	struct net_bridge_port *p;
> +	unsigned short pvid = br->default_pvid;

u16 will be better than "unsigned short".

> +
> +	/* This function runs under RTNL with vlan filter disabled.
> +	 * It is safe to directly access rcu pointers.

Is this OK with sparse?
(This isn't the same case as commit f9586f79bf61 "vlan: add
rtnl_dereference() annotations"?)

> +	 *
> +	 * Disable default_pvid on all ports where it is still
> +	 * configured.
> +	 */
> +	if (pvid == br_get_pvid(br_get_vlan_info(br)) &&
> +	    test_bit(pvid, br->vlan_info->untagged_bitmap))
> +		br_vlan_delete(br, pvid);
> +
> +	list_for_each_entry(p, &br->port_list, list) {
> +		if (pvid == br_get_pvid(nbp_get_vlan_info(p)) &&
> +		    test_bit(pvid, p->vlan_info->untagged_bitmap))
> +			nbp_vlan_delete(p, pvid);
> +	}
> +
> +	br->default_pvid = 0;
> +}
> +
> +static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
> +{
> +	struct net_bridge_port *p;
> +	u16 old_pvid;
> +	int err;
> +	DECLARE_BITMAP(changed, BR_MAX_PORTS);
> +
> +	bitmap_zero(changed, BR_MAX_PORTS);
> +
> +	/* This function runs with filtering turned off so we can
> +	 * remove the old pvid configuration and add the new one after
> +	 * without impacting traffic.
> +	 */
> +
> +	old_pvid = br->default_pvid;
> +
> +	/* If the user has set a different PVID or if the new default pvid
> +	 * conflicts with user configuration, do not modify the configuration.
> +	 */
> +	if (old_pvid != br_get_pvid(br_get_vlan_info(br)) ||
> +	    br_vlan_find(br, pvid))
> +		goto do_ports;

Should check untagged_bitmap for old_pvid as well?

> +
> +	set_bit(0, changed);
> +	br_vlan_delete(br, old_pvid);
> +	err = br_vlan_add(br, pvid,
> +			  BRIDGE_VLAN_INFO_PVID | BRIDGE_VLAN_INFO_UNTAGGED);

br_vlan_add() should be done before br_vlan_delete()?
br_vlan_delete() might free vlan_info which will be immediately
allocated by following br_vlan_add().

Thanks,
Toshiaki Makita
