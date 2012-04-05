From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [net-next 3/3] ixgbe: add syfs interface for to export read only
 driver information
Date: Thu, 05 Apr 2012 14:19:32 +0200
Message-ID: <4F7D8DD4.5080205@openwrt.org>
References: <1333622878-3855-1-git-send-email-jeffrey.t.kirsher@intel.com> <1333622878-3855-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Don Skidmore <donald.c.skidmore@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	bhutchings@solarflare.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61296 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582Ab2DEMUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 08:20:51 -0400
Received: by bkcik5 with SMTP id ik5so1308448bkc.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 05:20:49 -0700 (PDT)
In-Reply-To: <1333622878-3855-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Le 04/05/12 12:47, Jeff Kirsher a =C3=A9crit :
> From: Don Skidmore<donald.c.skidmore@intel.com>
>
> This patch exports non-thermal (which was done via hwmon in an earlie=
r
> patch) data to syfs.  All of the fields are read only as this interfa=
ce
> is to only export driver data.
>
> Signed-off-by: Don Skidmore<donald.c.skidmore@intel.com>
> Tested-by: Stephen Ko<stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> ---

I only looked briefly at the exported attributes, but most of them can=20
already be queried using ethtool, can't they?

Also, if you want to go that way, you might want to make the sysfs=20
interface configurable through a Kconfig knob, and use one or several=20
macros to define attributes accessors and reduce the amount of lines of=
=20
code.

>   drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |  774 +++++++++++++=
++++++++++-
>   1 files changed, 769 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers=
/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
> index 0882fd5..ddcec9f 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
> @@ -41,6 +41,762 @@
>    * This file provides a sysfs interface to export information from =
the
>    * driver.  The information presented is READ-ONLY.
>    */
> +
> +static struct net_device_stats *sysfs_get_stats(struct net_device *n=
etdev)
> +{
> +	if (netdev =3D=3D NULL)
> +		return NULL;
> +
> +	/* only return the current stats */
> +	return&netdev->stats;
> +}
> +
> +static struct net_device *ixgbe_get_netdev(struct kobject *kobj)
> +{
> +	struct net_device *netdev;
> +	struct kobject *parent =3D kobj->parent;
> +	struct device *device_info_kobj;
> +
> +	if (kobj =3D=3D NULL)
> +		return NULL;
> +
> +	device_info_kobj =3D container_of(parent, struct device, kobj);
> +	if (device_info_kobj =3D=3D NULL)
> +		return NULL;
> +
> +	netdev =3D container_of(device_info_kobj, struct net_device, dev);
> +	return netdev;
> +}
> +
> +static struct ixgbe_adapter *ixgbe_get_adapter(struct kobject *kobj)
> +{
> +	struct ixgbe_adapter *adapter;
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return NULL;
> +
> +	adapter =3D netdev_priv(netdev);
> +	return adapter;
> +}
> +
> +static ssize_t ixgbe_fwbanner(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +	int nvm_track_id;
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	nvm_track_id =3D (adapter->eeprom_verh<<  16) | adapter->eeprom_ver=
l;
> +
> +	return snprintf(buf, PAGE_SIZE, "0x%08x\n", nvm_track_id);
> +}
> +
> +static ssize_t ixgbe_porttype(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n",
> +			test_bit(__IXGBE_DOWN,&adapter->state));
> +}
> +
> +static ssize_t ixgbe_portspeed(struct kobject *kobj,
> +			       struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +	int speed =3D 0;
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	switch (adapter->link_speed) {
> +	case IXGBE_LINK_SPEED_100_FULL:
> +		speed =3D 1;
> +		break;
> +	case IXGBE_LINK_SPEED_1GB_FULL:
> +		speed =3D 10;
> +		break;
> +	case IXGBE_LINK_SPEED_10GB_FULL:
> +		speed =3D 100;
> +		break;
> +	}
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", speed);
> +}
> +
> +static ssize_t ixgbe_wqlflag(struct kobject *kobj,
> +			     struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->wol);
> +}
> +
> +static ssize_t ixgbe_xflowctl(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +	struct ixgbe_hw *hw;
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", hw->fc.current_mode);
> +}
> +
> +static ssize_t ixgbe_rxdrops(struct kobject *kobj,
> +			     struct kobj_attribute *attr, char *buf)
> +{
> +	struct net_device_stats *net_stats;
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
> +
> +	net_stats  =3D sysfs_get_stats(netdev);
> +	if (net_stats =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%lu\n",
> +			net_stats->rx_dropped);
> +}
> +
> +static ssize_t ixgbe_rxerrors(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct net_device_stats *net_stats;
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
> +
> +	net_stats  =3D sysfs_get_stats(netdev);
> +	if (net_stats =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->rx_errors);
> +}
> +
> +static ssize_t ixgbe_rxupacks(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_hw *hw;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_TP=
R));
> +}
> +
> +static ssize_t ixgbe_rxmpacks(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_hw *hw;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_MP=
RC));
> +}
> +
> +static ssize_t ixgbe_rxbpacks(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_hw *hw;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_BP=
RC));
> +}
> +
> +static ssize_t ixgbe_txupacks(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_hw *hw;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_TP=
T));
> +}
> +
> +static ssize_t ixgbe_txmpacks(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_hw *hw;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_MP=
TC));
> +}
> +
> +static ssize_t ixgbe_txbpacks(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_hw *hw;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", IXGBE_READ_REG(hw, IXGBE_BP=
TC));
> +}
> +
> +static ssize_t ixgbe_txerrors(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct net_device_stats *net_stats;
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
> +
> +	net_stats  =3D sysfs_get_stats(netdev);
> +	if (net_stats =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->tx_errors);
> +}
> +
> +static ssize_t ixgbe_txdrops(struct kobject *kobj,
> +			     struct kobj_attribute *attr, char *buf)
> +{
> +	struct net_device_stats *net_stats;
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
> +
> +	net_stats  =3D sysfs_get_stats(netdev);
> +	if (net_stats =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->tx_dropped);
> +}
> +
> +static ssize_t ixgbe_rxframes(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct net_device_stats *net_stats;
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
> +
> +	net_stats  =3D sysfs_get_stats(netdev);
> +	if (net_stats =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->rx_packets);
> +}
> +
> +static ssize_t ixgbe_rxbytes(struct kobject *kobj,
> +			     struct kobj_attribute *attr, char *buf)
> +{
> +	struct net_device_stats *net_stats;
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
> +
> +	net_stats  =3D sysfs_get_stats(netdev);
> +	if (net_stats =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->rx_bytes);
> +}
> +
> +static ssize_t ixgbe_txframes(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct net_device_stats *net_stats;
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
> +
> +	net_stats  =3D sysfs_get_stats(netdev);
> +	if (net_stats =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->tx_packets);
> +}
> +
> +static ssize_t ixgbe_txbytes(struct kobject *kobj,
> +			     struct kobj_attribute *attr, char *buf)
> +{
> +	struct net_device_stats *net_stats;
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
> +
> +	net_stats  =3D sysfs_get_stats(netdev);
> +	if (net_stats =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net stats\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%lu\n", net_stats->tx_bytes);
> +}
> +
> +static ssize_t ixgbe_linkstat(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	u32 link_speed;
> +	bool link_up =3D false;
> +	int bitmask =3D 0;
> +	struct ixgbe_hw *hw;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	if (test_bit(__IXGBE_DOWN,&adapter->state))
> +		bitmask |=3D 1;
> +
> +	if (hw->mac.ops.check_link)
> +		hw->mac.ops.check_link(hw,&link_speed,&link_up, false);
> +	else
> +		/* always assume link is up, if no check link function */
> +		link_up =3D true;
> +
> +	if (link_up)
> +		bitmask |=3D 2;
> +
> +	return snprintf(buf, PAGE_SIZE, "0x%X\n", bitmask);
> +}
> +
> +static ssize_t ixgbe_funcid(struct kobject *kobj,
> +			    struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +	struct ixgbe_hw *hw;
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "0x%X\n", hw->bus.func);
> +}
> +
> +static ssize_t ixgbe_funcvers(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	return snprintf(buf, PAGE_SIZE, "%s\n", ixgbe_driver_version);
> +}
> +
> +static ssize_t ixgbe_macburn(struct kobject *kobj,
> +			     struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_hw *hw;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "0x%X%X%X%X%X%X\n",
> +			(unsigned int)hw->mac.perm_addr[0],
> +			(unsigned int)hw->mac.perm_addr[1],
> +			(unsigned int)hw->mac.perm_addr[2],
> +			(unsigned int)hw->mac.perm_addr[3],
> +			(unsigned int)hw->mac.perm_addr[4],
> +			(unsigned int)hw->mac.perm_addr[5]);
> +}
> +
> +static ssize_t ixgbe_macadmn(struct kobject *kobj,
> +			     struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_hw *hw;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "0x%X%X%X%X%X%X\n",
> +			(unsigned int)hw->mac.addr[0],
> +			(unsigned int)hw->mac.addr[1],
> +			(unsigned int)hw->mac.addr[2],
> +			(unsigned int)hw->mac.addr[3],
> +			(unsigned int)hw->mac.addr[4],
> +			(unsigned int)hw->mac.addr[5]);
> +}
> +
> +static ssize_t ixgbe_maclla1(struct kobject *kobj,
> +			     struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_hw *hw;
> +	u16 eeprom_buff[6];
> +	int first_word =3D 0x37;
> +	int word_count =3D 6;
> +	int rc;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	hw =3D&adapter->hw;
> +	if (hw =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no hw data\n");
> +
> +	rc =3D hw->eeprom.ops.read_buffer(hw, first_word, word_count,
> +					eeprom_buff);
> +	if (rc)
> +		return snprintf(buf, PAGE_SIZE, "error: reading buffer\n");
> +
> +	switch (hw->bus.func) {
> +	case 0:
> +		return snprintf(buf, PAGE_SIZE, "0x%04X%04X%04X\n",
> +				eeprom_buff[0],
> +				eeprom_buff[1],
> +				eeprom_buff[2]);
> +	case 1:
> +		return snprintf(buf, PAGE_SIZE, "0x%04X%04X%04X\n",
> +				eeprom_buff[3],
> +				eeprom_buff[4],
> +				eeprom_buff[5]);
> +	}
> +
> +	return snprintf(buf, PAGE_SIZE, "unexpected port %d\n", hw->bus.fun=
c);
> +}
> +
> +static ssize_t ixgbe_mtusize(struct kobject *kobj,
> +			     struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", netdev->mtu);
> +}
> +
> +static ssize_t ixgbe_featflag(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	int bitmask =3D 0;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	if (netdev->features&  NETIF_F_RXCSUM)
> +		bitmask |=3D 1;
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", bitmask);
> +}
> +
> +static ssize_t ixgbe_lsominct(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	return snprintf(buf, PAGE_SIZE, "%d\n", 1);
> +}
> +
> +static ssize_t ixgbe_prommode(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct net_device *netdev =3D ixgbe_get_netdev(kobj);
> +
> +	if (netdev =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no net device\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", netdev->flags&  IFF_PROMISC=
);
> +}
> +
> +static ssize_t ixgbe_txdscqsz(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->tx_ring[0]->count)=
;
> +}
> +
> +static ssize_t ixgbe_rxdscqsz(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->rx_ring[0]->count)=
;
> +}
> +
> +static ssize_t ixgbe_rxqavg(struct kobject *kobj,
> +			    struct kobj_attribute *attr, char *buf)
> +{
> +	int index;
> +	int diff =3D 0;
> +	u16 ntc;
> +	u16 ntu;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	for (index =3D 0; index<  adapter->num_rx_queues; index++) {
> +		ntc =3D adapter->rx_ring[index]->next_to_clean;
> +		ntu =3D adapter->rx_ring[index]->next_to_use;
> +
> +		if (ntc>=3D ntu)
> +			diff +=3D (ntc - ntu);
> +		else
> +			diff +=3D (adapter->rx_ring[index]->count - ntu + ntc);
> +	}
> +
> +	if (adapter->num_rx_queues<=3D 0)
> +		return snprintf(buf, PAGE_SIZE,
> +				"can't calculate, number of queues %d\n",
> +				adapter->num_rx_queues);
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", diff/adapter->num_rx_queues=
);
> +}
> +
> +static ssize_t ixgbe_txqavg(struct kobject *kobj,
> +			    struct kobj_attribute *attr, char *buf)
> +{
> +	int index;
> +	int diff =3D 0;
> +	u16 ntc;
> +	u16 ntu;
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	for (index =3D 0; index<  adapter->num_tx_queues; index++) {
> +		ntc =3D adapter->tx_ring[index]->next_to_clean;
> +		ntu =3D adapter->tx_ring[index]->next_to_use;
> +
> +		if (ntc>=3D ntu)
> +			diff +=3D (ntc - ntu);
> +		else
> +			diff +=3D (adapter->tx_ring[index]->count - ntu + ntc);
> +	}
> +
> +	if (adapter->num_tx_queues<=3D 0)
> +		return snprintf(buf, PAGE_SIZE,
> +				"can't calculate, number of queues %d\n",
> +				adapter->num_tx_queues);
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", diff/adapter->num_tx_queues=
);
> +}
> +
> +static ssize_t ixgbe_iovotype(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	return snprintf(buf, PAGE_SIZE, "2\n");
> +}
> +
> +static ssize_t ixgbe_funcnbr(struct kobject *kobj,
> +			     struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->num_vfs);
> +}
> +
> +static ssize_t ixgbe_pciebnbr(struct kobject *kobj,
> +			      struct kobj_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter =3D ixgbe_get_adapter(kobj);
> +
> +	if (adapter =3D=3D NULL)
> +		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
> +
> +	return snprintf(buf, PAGE_SIZE, "%d\n", adapter->pdev->bus->number)=
;
> +}
> +
> +/* Initialize the attributes */
> +static struct kobj_attribute ixgbe_sysfs_fwbanner_attr =3D
> +	__ATTR(fwbanner, 0444, ixgbe_fwbanner, NULL);
> +static struct kobj_attribute ixgbe_sysfs_porttype_attr =3D
> +	__ATTR(porttype, 0444, ixgbe_porttype, NULL);
> +static struct kobj_attribute ixgbe_sysfs_portspeed_attr =3D
> +	__ATTR(portspeed, 0444, ixgbe_portspeed, NULL);
> +static struct kobj_attribute ixgbe_sysfs_wqlflag_attr =3D
> +	__ATTR(wqlflag, 0444, ixgbe_wqlflag, NULL);
> +static struct kobj_attribute ixgbe_sysfs_xflowctl_attr =3D
> +	__ATTR(xflowctl, 0444, ixgbe_xflowctl, NULL);
> +static struct kobj_attribute ixgbe_sysfs_rxdrops_attr =3D
> +	__ATTR(rxdrops, 0444, ixgbe_rxdrops, NULL);
> +static struct kobj_attribute ixgbe_sysfs_rxerrors_attr =3D
> +	__ATTR(rxerrors, 0444, ixgbe_rxerrors, NULL);
> +static struct kobj_attribute ixgbe_sysfs_rxupacks_attr =3D
> +	__ATTR(rxupacks, 0444, ixgbe_rxupacks, NULL);
> +static struct kobj_attribute ixgbe_sysfs_rxmpacks_attr =3D
> +	__ATTR(rxmpacks, 0444, ixgbe_rxmpacks, NULL);
> +static struct kobj_attribute ixgbe_sysfs_rxbpacks_attr =3D
> +	__ATTR(rxbpacks, 0444, ixgbe_rxbpacks, NULL);
> +static struct kobj_attribute ixgbe_sysfs_txupacks_attr =3D
> +	__ATTR(txupacks, 0444, ixgbe_txupacks, NULL);
> +static struct kobj_attribute ixgbe_sysfs_txmpacks_attr =3D
> +	__ATTR(txmpacks, 0444, ixgbe_txmpacks, NULL);
> +static struct kobj_attribute ixgbe_sysfs_txbpacks_attr =3D
> +	__ATTR(txbpacks, 0444, ixgbe_txbpacks, NULL);
> +static struct kobj_attribute ixgbe_sysfs_txerrors_attr =3D
> +	__ATTR(txerrors, 0444, ixgbe_txerrors, NULL);
> +static struct kobj_attribute ixgbe_sysfs_txdrops_attr =3D
> +	__ATTR(txdrops, 0444, ixgbe_txdrops, NULL);
> +static struct kobj_attribute ixgbe_sysfs_rxframes_attr =3D
> +	__ATTR(rxframes, 0444, ixgbe_rxframes, NULL);
> +static struct kobj_attribute ixgbe_sysfs_rxbytes_attr =3D
> +	__ATTR(rxbytes, 0444, ixgbe_rxbytes, NULL);
> +static struct kobj_attribute ixgbe_sysfs_txframes_attr =3D
> +	__ATTR(txframes, 0444, ixgbe_txframes, NULL);
> +static struct kobj_attribute ixgbe_sysfs_txbytes_attr =3D
> +	__ATTR(txbytes, 0444, ixgbe_txbytes, NULL);
> +static struct kobj_attribute ixgbe_sysfs_linkstat_attr =3D
> +	__ATTR(linkstat, 0444, ixgbe_linkstat, NULL);
> +static struct kobj_attribute ixgbe_sysfs_funcid_attr =3D
> +	__ATTR(funcid, 0444, ixgbe_funcid, NULL);
> +static struct kobj_attribute ixgbe_sysfs_funvers_attr =3D
> +	__ATTR(funcvers, 0444, ixgbe_funcvers, NULL);
> +static struct kobj_attribute ixgbe_sysfs_macburn_attr =3D
> +	__ATTR(macburn, 0444, ixgbe_macburn, NULL);
> +static struct kobj_attribute ixgbe_sysfs_macadmn_attr =3D
> +	__ATTR(macadmn, 0444, ixgbe_macadmn, NULL);
> +static struct kobj_attribute ixgbe_sysfs_maclla1_attr =3D
> +	__ATTR(maclla1, 0444, ixgbe_maclla1, NULL);
> +static struct kobj_attribute ixgbe_sysfs_mtusize_attr =3D
> +	__ATTR(mtusize, 0444, ixgbe_mtusize, NULL);
> +static struct kobj_attribute ixgbe_sysfs_featflag_attr =3D
> +	__ATTR(featflag, 0444, ixgbe_featflag, NULL);
> +static struct kobj_attribute ixgbe_sysfs_lsominct_attr =3D
> +	__ATTR(lsominct, 0444, ixgbe_lsominct, NULL);
> +static struct kobj_attribute ixgbe_sysfs_prommode_attr =3D
> +	__ATTR(prommode, 0444, ixgbe_prommode, NULL);
> +static struct kobj_attribute ixgbe_sysfs_txdscqsz_attr =3D
> +	__ATTR(txdscqsz, 0444, ixgbe_txdscqsz, NULL);
> +static struct kobj_attribute ixgbe_sysfs_rxdscqsz_attr =3D
> +	__ATTR(rxdscqsz, 0444, ixgbe_rxdscqsz, NULL);
> +static struct kobj_attribute ixgbe_sysfs_txqavg_attr =3D
> +	__ATTR(txqavg, 0444, ixgbe_txqavg, NULL);
> +static struct kobj_attribute ixgbe_sysfs_rxqavg_attr =3D
> +	__ATTR(rxqavg, 0444, ixgbe_rxqavg, NULL);
> +static struct kobj_attribute ixgbe_sysfs_iovotype_attr =3D
> +	__ATTR(iovotype, 0444, ixgbe_iovotype, NULL);
> +static struct kobj_attribute ixgbe_sysfs_funcnbr_attr =3D
> +	__ATTR(funcnbr, 0444, ixgbe_funcnbr, NULL);
> +static struct kobj_attribute ixgbe_sysfs_pciebnbr_attr =3D
> +	__ATTR(pciebnbr, 0444, ixgbe_pciebnbr, NULL);
> +
> +static struct attribute *attrs[] =3D {
> +	&ixgbe_sysfs_fwbanner_attr.attr,
> +	&ixgbe_sysfs_porttype_attr.attr,
> +	&ixgbe_sysfs_portspeed_attr.attr,
> +	&ixgbe_sysfs_wqlflag_attr.attr,
> +	&ixgbe_sysfs_xflowctl_attr.attr,
> +	&ixgbe_sysfs_rxdrops_attr.attr,
> +	&ixgbe_sysfs_rxerrors_attr.attr,
> +	&ixgbe_sysfs_rxupacks_attr.attr,
> +	&ixgbe_sysfs_rxmpacks_attr.attr,
> +	&ixgbe_sysfs_rxbpacks_attr.attr,
> +	&ixgbe_sysfs_txdrops_attr.attr,
> +	&ixgbe_sysfs_txerrors_attr.attr,
> +	&ixgbe_sysfs_txupacks_attr.attr,
> +	&ixgbe_sysfs_txmpacks_attr.attr,
> +	&ixgbe_sysfs_txbpacks_attr.attr,
> +	&ixgbe_sysfs_rxframes_attr.attr,
> +	&ixgbe_sysfs_rxbytes_attr.attr,
> +	&ixgbe_sysfs_txframes_attr.attr,
> +	&ixgbe_sysfs_txbytes_attr.attr,
> +	&ixgbe_sysfs_linkstat_attr.attr,
> +	&ixgbe_sysfs_funcid_attr.attr,
> +	&ixgbe_sysfs_funvers_attr.attr,
> +	&ixgbe_sysfs_macburn_attr.attr,
> +	&ixgbe_sysfs_macadmn_attr.attr,
> +	&ixgbe_sysfs_maclla1_attr.attr,
> +	&ixgbe_sysfs_mtusize_attr.attr,
> +	&ixgbe_sysfs_featflag_attr.attr,
> +	&ixgbe_sysfs_lsominct_attr.attr,
> +	&ixgbe_sysfs_prommode_attr.attr,
> +	&ixgbe_sysfs_txdscqsz_attr.attr,
> +	&ixgbe_sysfs_rxdscqsz_attr.attr,
> +	&ixgbe_sysfs_txqavg_attr.attr,
> +	&ixgbe_sysfs_rxqavg_attr.attr,
> +	&ixgbe_sysfs_iovotype_attr.attr,
> +	&ixgbe_sysfs_funcnbr_attr.attr,
> +	&ixgbe_sysfs_pciebnbr_attr.attr,
> +	NULL
> +};
> +
> +/* add attributes to a group */
> +static struct attribute_group attr_group =3D {
> +	.attrs =3D attrs,
> +};
> +
>   #ifdef CONFIG_IXGBE_HWMON
>
>   /* hwmon callback functions */
> @@ -185,8 +941,11 @@ static void ixgbe_sysfs_del_adapter(struct ixgbe=
_adapter *adapter)
>   		hwmon_device_unregister(adapter->ixgbe_hwmon_buff.device);
>   #endif /* CONFIG_IXGBE_HWMON */
>
> -	if (adapter->info_kobj !=3D NULL)
> +	if (adapter->info_kobj !=3D NULL) {
> +		sysfs_remove_group(adapter->info_kobj,&attr_group);
>   		kobject_put(adapter->info_kobj);
> +		adapter->info_kobj =3D NULL;
> +	}
>   }
>
>   /* called from ixgbe_main.c */
> @@ -213,17 +972,22 @@ int ixgbe_sysfs_init(struct ixgbe_adapter *adap=
ter)
>   		goto err;
>   	}
>
> +	rc =3D sysfs_create_group(adapter->info_kobj,&attr_group);
> +	if (rc)
> +		goto err;
> +
>   #ifdef CONFIG_IXGBE_HWMON
>   	/* If this method isn't defined we don't support thermals */
>   	if (adapter->hw.mac.ops.init_thermal_sensor_thresh =3D=3D NULL) {
> -		rc =3D -EPERM;
> -		goto err;
> +		goto exit;
>   	}
>
>   	/* Don't create thermal hwmon interface if no sensors present */
>   	rc =3D adapter->hw.mac.ops.init_thermal_sensor_thresh(&adapter->hw=
);
> -	if (rc)
> -		goto err;
> +	if (rc) {
> +		rc =3D 0;
> +		goto exit;
> +	}
>
>   	/*
>   	 * Allocation space for max attributs
