From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v2 4/9] bridge: Change local fdb entries whenever
 mac address of bridge device changes
Date: Tue, 17 Dec 2013 11:22:46 -0500
Message-ID: <52B07A56.9070005@redhat.com>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <1387281821-21342-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4284 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752452Ab3LQQWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 11:22:52 -0500
In-Reply-To: <1387281821-21342-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 07:03 AM, Toshiaki Makita wrote:
> Vlan code may need fdb change when changing mac address of bridge device
> even if it is caused by the mac address changing of a bridge port.
> 
> Example configuration:
>   ip link set eth0 address 12:34:56:78:90:ab
>   ip link set eth1 address aa:bb:cc:dd:ee:ff
>   brctl addif br0 eth0
>   brctl addif br0 eth1 # br0 will have mac address 12:34:56:78:90:ab
>   bridge vlan add dev br0 vid 10 self
>   bridge vlan add dev eth0 vid 10
> We will have fdb entry such that f->dst == NULL, f->vlan_id == 10 and
> f->addr == 12:34:56:78:90:ab at this time.
> Next, change the mac address of eth0 to greater value.
>   ip link set eth0 address ee:ff:12:34:56:78
> Then, mac address of br0 will be recalculated and set to aa:bb:cc:dd:ee:ff.
> However, an entry aa:bb:cc:dd:ee:ff will not be created and we will be not
> able to communicate using br0 on vlan 10.
> 
> Address this issue by deleting and adding local entries whenever
> changing the mac address of the bridge device.
> 
> If there already exists an entry that has the same address, for example,
> in case that br_fdb_changeaddr() has already inserted it,
> br_fdb_change_mac_address() will simply fail to insert it and no
> duplicated entry will be made, as it was.
> 
> This approach also needs br_add_if() to call br_fdb_insert() before
> br_stp_recalculate_bridge_id() so that we don't create an entry whose
> dst == NULL in this function to preserve previous behavior.

Aren't we still creating this entry even with this change?

Looking at br_fdb_change_mac_address(), it will always add
an fdb with NULL port.

May be we can update br_fdb_change_mac_address() to not add
a new entry if we have a local fdb already for the address.

-vlad

> 
> Note that this is a slight change in behavior where the bridge device can
> receive the traffic to the new address before calling
> br_stp_recalculate_bridge_id() in br_add_if().
> However, it is not a problem because we have already the address on the
> new port and such a way to insert new one before recalculating bridge id
> is taken in br_device_event() as well.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>  net/bridge/br_device.c | 1 -
>  net/bridge/br_if.c     | 6 +++---
>  net/bridge/br_stp_if.c | 2 ++
>  3 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index d967773..1cbdbf1 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -187,7 +187,6 @@ static int br_set_mac_address(struct net_device *dev, void *p)
>  
>  	spin_lock_bh(&br->lock);
>  	if (!ether_addr_equal(dev->dev_addr, addr->sa_data)) {
> -		br_fdb_change_mac_address(br, addr->sa_data);
>  		/* Mac address will be changed in br_stp_change_bridge_id(). */
>  		br_stp_change_bridge_id(br, addr->sa_data);
>  	}
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 4bf02ad..779d91c 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -389,6 +389,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  	if (br->dev->needed_headroom < dev->needed_headroom)
>  		br->dev->needed_headroom = dev->needed_headroom;
>  
> +	if (br_fdb_insert(br, p, dev->dev_addr, 0))
> +		netdev_err(dev, "failed insert local address bridge forwarding table\n");
> +
>  	spin_lock_bh(&br->lock);
>  	changed_addr = br_stp_recalculate_bridge_id(br);
>  
> @@ -404,9 +407,6 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  
>  	dev_set_mtu(br->dev, br_min_mtu(br));
>  
> -	if (br_fdb_insert(br, p, dev->dev_addr, 0))
> -		netdev_err(dev, "failed insert local address bridge forwarding table\n");
> -
>  	kobject_uevent(&p->kobj, KOBJ_ADD);
>  
>  	return 0;
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index 656a6f3..189ba1e 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -194,6 +194,8 @@ void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *addr)
>  
>  	wasroot = br_is_root_bridge(br);
>  
> +	br_fdb_change_mac_address(br, addr);
> +
>  	memcpy(oldaddr, br->bridge_id.addr, ETH_ALEN);
>  	memcpy(br->bridge_id.addr, addr, ETH_ALEN);
>  	memcpy(br->dev->dev_addr, addr, ETH_ALEN);
> 
