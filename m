From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [PATCH v5 4/6] ipv6: addrconf: fix 48 bit 6lowpan
 autoconfiguration
Date: Sun, 26 Feb 2017 07:38:38 +0100
Message-ID: <973f0299-54ee-3625-6c96-98fa0daeba1b@pengutronix.de>
References: <20170224121440.32269-1-luiz.dentz@gmail.com>
 <20170224121440.32269-5-luiz.dentz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, patrik.flykt@linux.intel.com,
        jukka.rissanen@linux.intel.com, stefan@osg.samsung.com,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:58493 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751567AbdBZGjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 01:39:00 -0500
In-Reply-To: <20170224121440.32269-5-luiz.dentz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

okay now I am finally confused.

On 02/24/2017 01:14 PM, Luiz Augusto von Dentz wrote:
> From: Alexander Aring <aar@pengutronix.de>
> 
> This patch adds support for 48 bit 6LoWPAN address length
> autoconfiguration which is the case for BTLE 6LoWPAN.
> 
> Signed-off-by: Alexander Aring <aar@pengutronix.de>
> Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
> Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
> ---
>  net/ipv6/addrconf.c | 17 ++++++++++++-----
>  1 file changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 3a2025f..7756640 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2052,12 +2052,19 @@ static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
>  	__ipv6_dev_ac_dec(ifp->idev, &addr);
>  }
>  
> -static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
> +static int addrconf_ifid_6lowpan(u8 *eui, struct net_device *dev)
>  {
> -	if (dev->addr_len != EUI64_ADDR_LEN)
> +	switch (dev->addr_len) {
> +	case ETH_ALEN:
> +		return addrconf_ifid_eui48(eui, dev);

You need to make the same thing here like what we discusss in antoher
mail.

   In the figure, letter 'b' represents a bit from the
   Bluetooth device address, copied as is without any changes on any
   bit.  This means that no bit in the IID indicates whether the
   underlying Bluetooth device address is public or random.

   |0              1|1              3|3              4|4              6|
   |0              5|6              1|2              7|8              3|
   +----------------+----------------+----------------+----------------+
   |bbbbbbbbbbbbbbbb|bbbbbbbb11111111|11111110bbbbbbbb|bbbbbbbbbbbbbbbb|
   +----------------+----------------+----------------+----------------+

The function addrconf_ifid_eui48 will do a u/l bitflip. You need to change
that otherwise transparent 6lowpan adaptiation will not match on your
local address.

Making u/l bit here, but not in IPHC code -> will not work together.

---

btw: That's why I think we should provide some function _once_ to
generate the IID for iphc code and ipv6. Then such mistakes will not
happen.

So we don't want to have some module dependency of 6lowpan in ipv6.
My first idea is to make a callback in 6lowpan private data of
netdevice. :-/

- Alex
