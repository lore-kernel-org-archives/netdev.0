From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH, resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0
 to gigabit ethernet adapter driver
Date: Thu, 7 Feb 2013 20:02:55 +0000
Message-ID: <1360267375.3605.32.camel@bwh-desktop.uk.solarflarecom.com>
References: <1360244360-2700-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Freddy Xin <freddy@asix.com.tw>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360244360-2700-1-git-send-email-freddy@asix.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-02-07 at 21:39 +0800, Freddy Xin wrote:
> From: Freddy Xin <freddy@asix.com.tw>
> 
> This is a resubmission.
> Added "const" to ethtool_ops structure and fixed the coding style of AX88179_BULKIN_SIZE array.
> Fixed the issue that the default MTU is not 1500.
> Added ax88179_change_mtu function and enabled the hardware jumbo frame function to support an
> MTU higher than 1500.
> Fixed indentation and empty line coding style errors.
> The _nopm version usb functions were added to access register in suspend and resume functions.
> Serveral variables allocted dynamically were removed and replaced by stack variables.
> ax88179_get_eeprom were modified from asix_get_eeprom in asix_common.
> 
> This patch adds a driver for ASIX's AX88179 family of USB 3.0/2.0
> to gigabit ethernet adapters. It's based on the AX88xxx driver but
> the usb commands used to access registers for AX88179 are completely different.
> This driver had been verified on x86 system with AX88179/AX88178A and
> Sitcomm LN-032 USB dongles.
> 
> Signed-off-by: Freddy Xin <freddy@asix.com.tw>
[...]
> --- /dev/null
> +++ b/drivers/net/usb/ax88179_178a.c
[...]
> +struct ax88179_data {
> +       u16 rxctl;
> +};

Should also be declared __packed, as on some architectures it may be
padded to 4 bytes.

rxctl is presumably required to be little-endian (__le16)?

> +struct ax88179_int_data {
> +       u16 res1;
> +       u8 link;
> +       u16 res2;
> +       u8 status;
> +       u16 res3;
> +} __packed;

Same here, the u16 fields are presumably little-endian?

[...]
> +struct ax88179_rx_pkt_header {
> +	u8	l4_csum_err:1,
> +		l3_csum_err:1,
> +		l4_type:3,
> +		l3_type:2,
> +		ce:1;
> +
> +	u8	vlan_ind:3,
> +		rx_ok:1,
> +		pri:3,
> +		bmc:1;
> +
> +	u16	len:13,
> +		crc:1,
> +		mii:1,
> +		drop:1;
> +} __packed;

This won't work on both big-endian systems (assuming this works on x86).
You apparently try to convert the structure in-place in
ax88179_rx_fixup() by calling le32_to_cpus(); that may work if you
define all the bitfields to be part of a u32 but it won't work with the
current definition.

[...]
> +static int
> +ax88179_set_features(struct net_device *net, netdev_features_t features)
> +{
> +	u8 tmp;
> +	struct usbnet *dev = netdev_priv(net);
> +	netdev_features_t changed = net->features ^ features;
> +
> +	if (changed & NETIF_F_TSO)
> +		net->features ^= NETIF_F_TSO;
> +
> +	if (changed & NETIF_F_SG)
> +		net->features ^= NETIF_F_SG;

Don't change net->features; the caller will do that for you.

> +       if (changed & NETIF_F_IP_CSUM) {
> +               ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_TXCOE_CTL, 1, 1, &tmp);
> +               tmp ^= AX_TXCOE_TCP | AX_TXCOE_UDP;
> +               ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_TXCOE_CTL, 1, 1, &tmp);
> +
> +               net->features ^= NETIF_F_IP_CSUM;
> +       }
[...]

Isn't tmp going to be in little-endian byte order, so this doesn't work
correctly on a big-endian system?

There are a lot of reads and writes of 16-bit registers using
ax88179_{read,write}_cmd(); maybe you should add
ax88179_{read,write}_le16() to handle this specific case.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
