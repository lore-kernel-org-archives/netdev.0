From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH net-next] net/usb: new driver for RTL8152
Date: Fri, 26 Apr 2013 13:56:52 +0200
Message-ID: <5873028.qC8hWx1N8T@linux-5eaq.site>
References: <1366965948-1805-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366965948-1805-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 26 April 2013 16:45:48 Hayes Wang wrote:

> +static u16 r8152_mdio_read(struct r8152 *tp, u32 reg_addr)
> +{
> +	u32	ocp_data;
> +	int	i;
> +
> +	ocp_data = (reg_addr & 0x1f) << 16;
> +	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_PHYAR, ocp_data);
> +
> +	for (i = 20; i > 0; i--) {
> +		udelay(25);
> +		ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_PHYAR);
> +		if (ocp_data & PHYAR_FLAG)
> +			break;
> +	}
> +	udelay(20);
> +
> +	return (u16)(ocp_data & 0xffff);
> +}

Unfortunately this can fail, as it is physical IO and you throw away errors.

> +static int read_mii_word(struct net_device *netdev, int phy_id, int reg)
> +{
> +	struct r8152 *tp = netdev_priv(netdev);
> +
> +	if (phy_id != R8152_PHY_ID)
> +		return -1;
> +
> +	return r8152_mdio_read(tp, reg);
> +}
> +
> +static
> +void write_mii_word(struct net_device *netdev, int phy_id, int reg, int val)
> +{
> +	struct r8152 *tp = netdev_priv(netdev);
> +
> +	if (phy_id != R8152_PHY_ID)
> +		return;
> +
> +	r8152_mdio_write(tp, reg, val);
> +}
> +
> +static void ocp_reg_write(struct r8152 *tp, u16 addr, u16 data)
> +{
> +	u16 ocp_base, ocp_index;
> +
> +	ocp_base = addr & 0xf000;
> +	if (ocp_base != tp->ocp_base) {
> +		ocp_write_word(tp, MCU_TYPE_PLA, PLA_OCP_GPHY_BASE, ocp_base);
> +		tp->ocp_base = ocp_base;
> +	}
> +
> +	ocp_index = (addr & 0x0fff) | 0xb000;
> +	ocp_write_word(tp, MCU_TYPE_PLA, ocp_index, data);
> +}
> +
> +static inline void set_ethernet_addr(struct r8152 *tp)
> +{
> +	struct net_device *dev = tp->netdev;
> +	u8 node_id[8] = {0};
> +
> +	if (pla_ocp_read(tp, PLA_IDR, sizeof(node_id), node_id) < 0)

DMA coherency rules. No buffers on the stack.

> +		netif_notice(tp, probe, dev, "inet addr fail\n");
> +	else {
> +		memcpy(dev->dev_addr, node_id, sizeof(node_id));
> +		memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
> +	}
> +}






> +static void _rtl8152_set_rx_mode(struct net_device *netdev)
> +{
> +	struct r8152 *tp = netdev_priv(netdev);
> +	u32 tmp, mc_filter[2];	/* Multicast hash filter */
> +	u32 ocp_data;
> +
> +	clear_bit(RTL8152_SET_RX_MODE, &tp->flags);
> +	netif_stop_queue(netdev);
> +	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
> +	ocp_data &= ~RCR_ACPT_ALL;
> +	ocp_data |= RCR_AB | RCR_APM;
> +
> +	if (netdev->flags & IFF_PROMISC) {
> +		/* Unconditionally log net taps. */
> +		netif_notice(tp, link, netdev, "Promiscuous mode enabled\n");
> +		ocp_data |= RCR_AM | RCR_AAP;
> +		mc_filter[1] = mc_filter[0] = 0xffffffff;
> +	} else if ((netdev_mc_count(netdev) > multicast_filter_limit) ||
> +		   (netdev->flags & IFF_ALLMULTI)) {
> +		/* Too many to filter perfectly -- accept all multicasts. */
> +		ocp_data |= RCR_AM;
> +		mc_filter[1] = mc_filter[0] = 0xffffffff;
> +	} else {
> +		struct netdev_hw_addr *ha;
> +
> +		mc_filter[1] = mc_filter[0] = 0;
> +		netdev_for_each_mc_addr(ha, netdev) {
> +			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
> +			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
> +			ocp_data |= RCR_AM;
> +		}
> +	}
> +
> +	tmp = mc_filter[0];
> +	mc_filter[0] = __cpu_to_le32(swab32(mc_filter[1]));
> +	mc_filter[1] = __cpu_to_le32(swab32(tmp));
> +
> +	pla_ocp_write(tp, PLA_MAR, BYTE_EN_DWORD, sizeof(mc_filter), mc_filter);

This looks like a violation of the DMA coherency rules.
You cannot use buffers on the stack.

> +	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
> +	netif_wake_queue(netdev);
> +}
> +






> +static void rtl_work_func_t(struct work_struct *work)
> +{
> +	struct r8152 *tp = container_of(work, struct r8152, schedule.work);
> +
> +	if (!netif_running(tp->netdev))
> +		goto out1;
> +
> +	if (test_bit(RTL8152_UNPLUG, &tp->flags))
> +		goto out1;
> +
> +	set_carrier(tp);
> +
> +	if (test_bit(RTL8152_SET_RX_MODE, &tp->flags))
> +		_rtl8152_set_rx_mode(tp->netdev);
> +
> +	schedule_delayed_work(&tp->schedule, HZ);

Why does this need to run permanently?

> +
> +out1:
> +	return;
> +}
> +
> +static int rtl8152_open(struct net_device *netdev)
> +{
> +	struct r8152 *tp = netdev_priv(netdev);
> +	int res = 0;
> +
> +	tp->speed = rtl8152_get_speed(tp);
> +	if (tp->speed & LINK_STATUS) {
> +		res = rtl8152_enable(tp);
> +		netif_carrier_on(netdev);

And you leave it on in the error case?

> +	} else {
> +		netif_stop_queue(netdev);
> +		netif_carrier_off(netdev);
> +	}
> +
> +	if (res) {
> +		if (res == -ENODEV)
> +			netif_device_detach(tp->netdev);
> +
> +		netif_warn(tp, rx_err, netdev,
> +			   "rx_urb submit failed: %d\n", res);
> +		return res;
> +	}
> +
> +	rtl8152_set_speed(tp, AUTONEG_ENABLE, SPEED_100, DUPLEX_FULL);
> +	netif_start_queue(netdev);
> +	schedule_delayed_work(&tp->schedule, 0);
> +
> +	return res;
> +}
> +
> +static int rtl8152_close(struct net_device *netdev)
> +{
> +	struct r8152 *tp = netdev_priv(netdev);
> +	int res = 0;
> +
> +	cancel_delayed_work_sync(&tp->schedule);

Looks like a race. What makes sure the work isn't rescheduled?

> +	netif_stop_queue(netdev);
> +	rtl8152_disable(tp);
> +
> +	return res;
> +}

> +static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
> +{
> +	struct r8152 *tp = usb_get_intfdata(intf);
> +
> +	netif_device_detach(tp->netdev);
> +
> +	if (netif_running(tp->netdev))
> +		cancel_delayed_work_sync(&tp->schedule);

This looks like a race. What makes sure that the work isn't rescheduled?

> +
> +	rtl8152_down(tp);
> +
> +	return 0;
> +}
> +
> +static int rtl8152_resume(struct usb_interface *intf)
> +{
> +	struct r8152 *tp = usb_get_intfdata(intf);
> +
> +	r8152b_init(tp);
> +	netif_device_attach(tp->netdev);
> +	if (netif_running(tp->netdev)) {
> +		rtl8152_enable(tp);
> +		rtl8152_set_speed(tp, AUTONEG_ENABLE, SPEED_100, DUPLEX_FULL);

But this may not be the speed that was selected before the device
was suspended.

> +		set_bit(RTL8152_SET_RX_MODE, &tp->flags);
> +		schedule_delayed_work(&tp->schedule, 0);
> +	}
> +
> +	return 0;
> +}




> +static void rtl8152_unload(struct r8152 *tp)
> +{
> +	u32	ocp_data;
> +
> +	if (tp->version != RTL_VER_01) {
> +		ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_UPS_CTRL);
> +		ocp_data |= POWER_CUT;
> +		ocp_write_word(tp, MCU_TYPE_USB, USB_UPS_CTRL, ocp_data);
> +	}
> +
> +	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS);
> +	ocp_data &= ~RWSUME_INDICATE;
> +	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
> +}
> +
> +static void rtl8152_disconnect(struct usb_interface *intf)
> +{
> +	struct r8152 *tp = usb_get_intfdata(intf);
> +
> +	usb_set_intfdata(intf, NULL);
> +	if (tp) {
> +		set_bit(RTL8152_UNPLUG, &tp->flags);
> +		tasklet_kill(&tp->tl);

This looks like a race condition. What prevents the tasklet from being
scheduled here in case of a soft disconnect?

> +		unregister_netdev(tp->netdev);
> +		rtl8152_unload(tp);
> +		free_all_urbs(tp);
> +		if (tp->rx_skb)
> +			dev_kfree_skb(tp->rx_skb);
> +		free_netdev(tp->netdev);
> +	}
> +}

	Regards
		Oliver
