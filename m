From: Ben Greear <greearb@candelatech.com>
Subject: Re: VLAN regression caused by: e1000: do vlan cleanup
	(799d531).
Date: Mon, 19 Mar 2012 16:24:04 -0700
Message-ID: <4F67C014.1090500@candelatech.com>
References: <4F5E3DCF.6010307@candelatech.com>
	<20120313095942.GC2239@minipsycho.brq.redhat.com>
	<4F5F9582.60501@candelatech.com>
	<20120319130836.GD2192@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel list <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120319130836.GD2192@minipsycho.brq.redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 03/19/2012 06:08 AM, Jiri Pirko wrote:
> Tue, Mar 13, 2012 at 07:44:18PM CET, greearb@candelatech.com wrote:

>>> I have suspition that vlan filter must be on/offed along with vlan
>>> accel.
>>
>> Ok, if I disable rx-vlan-hw-parse on both NICs, traffic starts working.
>>
>> And, if I re-enable rx-vlan-hw-parse on both NICs, it continues to work.
>>
>> Maybe the initialization logic needs some fixing?
>
> Could you please try following patch?

That patches fixes the problem for me.  Only lightly tested
at this point, but I have verified VLAN traffic works as desired.

Thanks,
Ben

>
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 6419a88..b06c31c 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -164,6 +164,8 @@ static int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
>   static bool e1000_vlan_used(struct e1000_adapter *adapter);
>   static void e1000_vlan_mode(struct net_device *netdev,
>   			    netdev_features_t features);
> +static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
> +				     bool filter_on);
>   static int e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
>   static int e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
>   static void e1000_restore_vlan(struct e1000_adapter *adapter);
> @@ -1214,7 +1216,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
>   	if (err)
>   		goto err_register;
>
> -	e1000_vlan_mode(netdev, netdev->features);
> +	e1000_vlan_filter_on_off(adapter, false);
>
>   	/* print bus type/speed/width info */
>   	e_info(probe, "(PCI%s:%dMHz:%d-bit) %pM\n",
> @@ -4772,6 +4774,22 @@ static bool e1000_vlan_used(struct e1000_adapter *adapter)
>   	return false;
>   }
>
> +static void __e1000_vlan_mode(struct e1000_adapter *adapter,
> +			      netdev_features_t features)
> +{
> +	struct e1000_hw *hw =&adapter->hw;
> +	u32 ctrl;
> +
> +	ctrl = er32(CTRL);
> +	if (features&  NETIF_F_HW_VLAN_RX) {
> +		/* enable VLAN tag insert/strip */
> +		ctrl |= E1000_CTRL_VME;
> +	} else {
> +		/* disable VLAN tag insert/strip */
> +		ctrl&= ~E1000_CTRL_VME;
> +	}
> +	ew32(CTRL, ctrl);
> +}
>   static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
>   				     bool filter_on)
>   {
> @@ -4781,6 +4799,7 @@ static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
>   	if (!test_bit(__E1000_DOWN,&adapter->flags))
>   		e1000_irq_disable(adapter);
>
> +	__e1000_vlan_mode(adapter, adapter->netdev->features);
>   	if (filter_on) {
>   		/* enable VLAN receive filtering */
>   		rctl = er32(RCTL);
> @@ -4801,24 +4820,14 @@ static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
>   }
>
>   static void e1000_vlan_mode(struct net_device *netdev,
> -	netdev_features_t features)
> +			    netdev_features_t features)
>   {
>   	struct e1000_adapter *adapter = netdev_priv(netdev);
> -	struct e1000_hw *hw =&adapter->hw;
> -	u32 ctrl;
>
>   	if (!test_bit(__E1000_DOWN,&adapter->flags))
>   		e1000_irq_disable(adapter);
>
> -	ctrl = er32(CTRL);
> -	if (features&  NETIF_F_HW_VLAN_RX) {
> -		/* enable VLAN tag insert/strip */
> -		ctrl |= E1000_CTRL_VME;
> -	} else {
> -		/* disable VLAN tag insert/strip */
> -		ctrl&= ~E1000_CTRL_VME;
> -	}
> -	ew32(CTRL, ctrl);
> +	__e1000_vlan_mode(adapter, features);
>
>   	if (!test_bit(__E1000_DOWN,&adapter->flags))
>   		e1000_irq_enable(adapter);


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
