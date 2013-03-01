From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0
 to gigabit ethernet adapter driver
Date: Fri, 01 Mar 2013 16:15:45 -0500 (EST)
Message-ID: <20130301.161545.241432708115902321.davem@davemloft.net>
References: <1361966518-3755-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, louis@asix.com.tw
To: freddy@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361966518-3755-1-git-send-email-freddy@asix.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Freddy Xin <freddy@asix.com.tw>
Date: Wed, 27 Feb 2013 20:01:58 +0800

> +	eeprom_buff = kmalloc(sizeof(u16) * (last_word - first_word + 1),
> +			      GFP_KERNEL);
> +	if (!eeprom_buff)
> +		return -ENOMEM;
> +
> +	/* ax88179/178A returns 2 bytes from eeprom on read */
> +	for (i = first_word; i <= last_word; i++) {
> +		ret = __ax88179_read_cmd(dev, AX_ACCESS_EEPROM, i, 1, 2,
> +					 &eeprom_buff[i - first_word],
> +					 0);
> +		if (ret < 0)
> +			return -EIO;

In this -EIO error path we will leak eeprom_buff, you must free it in
all possible exit cases of this function after the allocation succeeds.

> +	data->rxctl = (__force __le16)(AX_RX_CTL_START | AX_RX_CTL_AB |
> +				       AX_RX_CTL_IPE);

You're not storying a __le16 in data->rxctl, you're storing the bits
in cpu endianness.  So make it a plain u16 instead and get rid of
these pointless casts.

> +static int __init asix_init(void)
> +{
> +	return usb_register(&asix_driver);
> +}
> +module_init(asix_init);
> +
> +static void __exit asix_exit(void)
> +{
> +	usb_deregister(&asix_driver);
> +}
> +module_exit(asix_exit);

You can replace all of this with a simple:

module_usb_driver(asix_driver);
