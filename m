From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH net 4/4] macvlan: Let passthru macvlan correctly restore
 lower mac address
Date: Fri, 16 Jun 2017 21:35:02 -0700
Message-ID: <95151854-5540-9a68-bdd9-e45c9db70796@oracle.com>
References: <20170616133649.24622-1-vyasevic@redhat.com>
 <20170616133649.24622-5-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23626 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdFQEfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 00:35:54 -0400
In-Reply-To: <20170616133649.24622-5-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, it took sometime to wrap around this patch series since they all change 
one file and at times the same function :).


On 6/16/17 6:36 AM, Vladislav Yasevich wrote:
> Passthru macvlans directly change the mac address of the lower
> level device.  That's OK, but after the macvlan is deleted,
> the lower device is left with changed address and one needs to
> reboot to bring back the origina HW addresses.

s/origina/original/

>
> This scenario is actually quite common with passthru macvtap devices.
>
> This patch attempts to solve this, by storing the mac address
> of the lower device in macvlan_port structure and keeping track of
> it through the changes.
>
> After this patch, any changes to the lower device mac address
> done trough the macvlan device, will be reverted back.  Any
> changes done directly to the lower device mac address will be kept.
>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/macvlan.c | 47 ++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 44 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index eb956ff..c551165 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -40,6 +40,7 @@
>  #define MACVLAN_BC_QUEUE_LEN	1000
>
>  #define MACVLAN_F_PASSTHRU	1
> +#define MACVLAN_F_ADDRCHANGE	2
>
>  struct macvlan_port {
>  	struct net_device	*dev;
> @@ -51,6 +52,7 @@ struct macvlan_port {
>  	int			count;
>  	struct hlist_head	vlan_source_hash[MACVLAN_HASH_SIZE];
>  	DECLARE_BITMAP(mc_filter, MACVLAN_MC_FILTER_SZ);
> +	unsigned char           perm_addr[ETH_ALEN];
>  };
>
>  struct macvlan_source_entry {
> @@ -78,6 +80,21 @@ static inline void macvlan_set_passthru(struct macvlan_port *port)
>  	port->flags |= MACVLAN_F_PASSTHRU;
>  }
>
> +static inline bool macvlan_addr_change(const struct macvlan_port *port)
> +{
> +	return port->flags & MACVLAN_F_ADDRCHANGE;
> +}
> +
> +static inline void macvlan_set_addr_change(struct macvlan_port *port)
> +{
> +	port->flags |= MACVLAN_F_ADDRCHANGE;
> +}
> +
> +static inline void macvlan_clear_addr_change(struct macvlan_port *port)
> +{
> +	port->flags &= ~MACVLAN_F_ADDRCHANGE;
> +}
> +
>  /* Hash Ethernet address */
>  static u32 macvlan_eth_hash(const unsigned char *addr)
>  {
> @@ -193,11 +210,11 @@ static void macvlan_hash_change_addr(struct macvlan_dev *vlan,
>  static bool macvlan_addr_busy(const struct macvlan_port *port,
>  			      const unsigned char *addr)
>  {
> -	/* Test to see if the specified multicast address is
> +	/* Test to see if the specified address is
>  	 * currently in use by the underlying device or
>  	 * another macvlan.
>  	 */
> -	if (!macvlan_passthru(port) &&
> +	if (!macvlan_passthru(port) && !macvlan_addr_change(port) &&
>  	    ether_addr_equal_64bits(port->dev->dev_addr, addr))
>  		return true;
>
> @@ -685,6 +702,7 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
>  {
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  	struct net_device *lowerdev = vlan->lowerdev;
> +	struct macvlan_port *port = vlan->port;
>  	int err;
>
>  	if (!(dev->flags & IFF_UP)) {
> @@ -695,7 +713,7 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
>  		if (macvlan_addr_busy(vlan->port, addr))
>  			return -EBUSY;
>
> -		if (!macvlan_passthru(vlan->port)) {
> +		if (!macvlan_passthru(port)) {
>  			err = dev_uc_add(lowerdev, addr);
>  			if (err)
>  				return err;
> @@ -705,6 +723,15 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
>
>  		macvlan_hash_change_addr(vlan, addr);
>  	}
> +	if (macvlan_passthru(port) && !macvlan_addr_change(port)) {
> +		/* Since addr_change isn't set, we are here due to lower
> +		 * device change.  Save the lower-dev address so we can
> +		 * restore it later.
> +		 */
> +		ether_addr_copy(vlan->port->perm_addr,
> +				dev->dev_addr);

Did you meant to copy `addr' here? Since dev->dev_addr is that of the macvlan 
device whilst `addr' is from the lower parent device.


Thanks,
~Girish
