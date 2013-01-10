From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v5 01/14] vlan: wrap hw-acceleration
 calls in separate functions.
Date: Thu, 10 Jan 2013 10:25:25 -0800
Message-ID: <20130110102525.2ff40c12@nehalam.linuxnetplumber.net>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
	<1357751882-8619-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	davem@davemloft.net
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1357751882-8619-2-git-send-email-vyasevic@redhat.com>
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

On Wed,  9 Jan 2013 12:17:48 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

>  
>  /**
> + * vlan_hw_buggy - Check to see if VLAN hw acceleration is supported.
> + * @dev: netdevice of the lowerdev/hw nic
> + *
> + * Checks to see if HW and driver report VLAN acceleration correctly.
> + */
> +static inline bool vlan_hw_buggy(const struct net_device *dev)
> +{
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +
> +	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
> +	    (!ops->ndo_vlan_rx_add_vid || !ops->ndo_vlan_rx_kill_vid))
> +		return true;
> +
> +	return false;
> +}
> +
> +/**
> + * vlan_vid_add_hw - Add the VLAN vid to the HW filter
> + * @dev: netdevice of the lowerdev/hw nic
> + * @vid: vlan id.
> + *
> + * Inserts the vid into the HW vlan filter table if hw supports it.
> + */
> +static inline int vlan_vid_add_hw(struct net_device *dev,
> +				  unsigned short vid)
> +{
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +	int err = 0;
> +
> +	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
> +	    ops->ndo_vlan_rx_add_vid)
> +		err = ops->ndo_vlan_rx_add_vid(dev, vid);
> +
> +	return err;
> +}
> +
> +/**
> + * vlan_vid_del_hw - Delete the VLAN vid from the HW filter
> + * @dev: netdevice of the lowerdev/hw nic
> + * @vid: vlan id.
> + *
> + * Delete the vid from the HW vlan filter table if hw supports it.
> + */
> +static inline int vlan_vid_del_hw(struct net_device *dev,
> +				  unsigned short vid)
> +{
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +	int err = 0;
> +
> +	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
> +	    ops->ndo_vlan_rx_kill_vid)
> +		err = ops->ndo_vlan_rx_add_vid(dev, vid);
> +
> +	return err;
> +}
> +

I would rather not have all these inline's. This isn't performance critical.
Also, the check for buggy devices should be done inside the vlan code,
not repeated in the functions using the add/remove API. When device is
registered the flag and add/kill should be checked, and if the device driver
is buggy it should fail the register_netdevice.
