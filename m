From: Bert Vermeulen <bert@biot.com>
Subject: Re: [PATCH net-next 3/3] net: phy: mdio-gpio: Handle phy_ignore_ta_mask
Date: Wed, 13 May 2015 13:17:06 +0200
Message-ID: <555332B2.7020704@biot.com>
References: <1431442563-10218-1-git-send-email-bert@biot.com> <1431452006-3219-1-git-send-email-f.fainelli@gmail.com> <1431452006-3219-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jogo@openwrt.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kiutl.biot.com ([31.172.244.210]:37843 "EHLO kiutl.biot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933665AbbEMLRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 07:17:24 -0400
Received: from spamd by kiutl.biot.com with sa-checked (Exim 4.83)
	(envelope-from <bert@biot.com>)
	id 1YsUf4-0003Kl-EM
	for netdev@vger.kernel.org; Wed, 13 May 2015 13:17:14 +0200
In-Reply-To: <1431452006-3219-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/2015 07:33 PM, Florian Fainelli wrote:
> Update mdiobb_read() to read whether the PHY has a broken turn-around,
> and if it does, ignore it to make the read succeeed.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/phy/mdio-bitbang.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
> index daec9b05d168..61a543c788cc 100644
> --- a/drivers/net/phy/mdio-bitbang.c
> +++ b/drivers/net/phy/mdio-bitbang.c
> @@ -165,8 +165,11 @@ static int mdiobb_read(struct mii_bus *bus, int phy, int reg)
>  
>  	ctrl->ops->set_mdio_dir(ctrl, 0);
>  
> -	/* check the turnaround bit: the PHY should be driving it to zero */
> -	if (mdiobb_get_bit(ctrl) != 0) {
> +	/* check the turnaround bit: the PHY should be driving it to zero, if this
> +	 * PHY is listed in phy_ignore_ta_mask as having broken TA, skip that
> +	 */
> +	if (mdiobb_get_bit(ctrl) != 0 &&
> +	    !(bus->phy_ignore_ta_mask & (1 << phy))) {
>  		/* PHY didn't drive TA low -- flush any bits it
>  		 * may be trying to send.
>  		 */
> 

Note that this means a PHY with a broken TA is marked with a 1 bit here,
which is exactly the reverse of the mii_bus.phy_mask field -- where a 0 bit
means ignore the PHY when probing.

For the record I think it's the phy_mask usage that doesn't make sense here,
but the inconsistency is unfortunate.


-- 
Bert Vermeulen        bert@biot.com          email/xmpp
