From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] allow setting wiphy.perm_addr after driver probe
Date: Mon, 11 Aug 2014 13:25:40 -0700
Message-ID: <54DF22CF-59D7-4633-A625-896F58C26A64@holtmann.org>
References: <1407780269.28221.63.camel@chimera>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org Wireless"
	<linux-wireless@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407780269.28221.63.camel@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

> On embedded devices, often the BSSID of an access point must be set from
> userspace during the boot process. This provides a relatively clean way
> of doing that without major side effects.
> 
> Signed-off-by: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
> --- 
> --- a/net/wireless/sysfs.c	2014-04-19 08:36:52.048511623 -0700
> +++ b/net/wireless/sysfs.c	2014-04-19 08:38:09.196894176 -0700
> @@ -24,18 +24,30 @@
> 	return container_of(dev, struct cfg80211_registered_device, wiphy.dev);
> }
> 
> -#define SHOW_FMT(name, fmt, member)					\
> +#define SHOW_FMT(name, fmt, member, perm)				\
> static ssize_t name ## _show(struct device *dev,			\
> 			      struct device_attribute *attr,		\
> 			      char *buf)				\
> {									\
> 	return sprintf(buf, fmt "\n", dev_to_rdev(dev)->member);	\
> }									\
> -static DEVICE_ATTR_RO(name)
> +static DEVICE_ATTR_ ## perm(name)
> 
> -SHOW_FMT(index, "%d", wiphy_idx);
> -SHOW_FMT(macaddress, "%pM", wiphy.perm_addr);
> -SHOW_FMT(address_mask, "%pM", wiphy.addr_mask);
> +static ssize_t macaddress_store(struct device *dev,
> +			      struct device_attribute *attr,
> +			      const char *buf, size_t count)
> +{
> +	u8 temp[ETH_ALEN];
> +
> +	if (sscanf(buf, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", temp, temp + 1,
> +			temp + 2, temp + 3, temp + 4, temp + 5) == ETH_ALEN)
> +		memcpy(dev_to_rdev(dev)->wiphy.perm_addr, temp, ETH_ALEN);
> +	return count;
> +}
> +
> +SHOW_FMT(index, "%d", wiphy_idx, RO);
> +SHOW_FMT(macaddress, "%pM", wiphy.perm_addr, RW);
> +SHOW_FMT(address_mask, "%pM", wiphy.addr_mask, RO);

isn't this dangerous to just allow writing to wiphy.perm_addr via sysfs. We ran into the same issue with Bluetooth and ROM only devices that have to unique address. Doing this via sysfs seems the wrong approach. It is messy and full of potential race conditions. I clearly opted against the sysfs solution for Bluetooth. Instead we build an infrastructure that allowed doing it cleanly via the Bluetooth mgmt API. Controllers that have no unique address are brought up as unconfigured and userspace clearly knows that it has to take steps to get an address programmed into the controller.

And I think something similar should be done for WiFi. It might be better to not create the initial wlan0 netdev interface if the hardware has not a single unique address available. That way the supplicant can just either get one from the flash filesystem or make up a proper random one before creating the netdev interface.

Regards

Marcel
