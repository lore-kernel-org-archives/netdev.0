From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next] sky2: use random address if EEPROM is bad
Date: Tue, 11 Aug 2015 10:01:32 -0700
Message-ID: <20150811100132.49229f86@urahara>
References: <55C2AB51.1040409@gmail.com>
	<1439303756-30333-1-git-send-email-Liviu.Dudau@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Mirko Lindner <mlindner@marvell.com>,
	Ryan Harkin <ryan.harkin@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Liviu Dudau <Liviu.Dudau@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439303756-30333-1-git-send-email-Liviu.Dudau@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Aug 2015 15:35:56 +0100
Liviu Dudau <Liviu.Dudau@arm.com> wrote:

> On some embedded systems the EEPROM does not contain a valid MAC address.
> In that case it is better to fallback to a generated mac address and
> let init scripts fix the value later.
> 
> Reported-by: Liviu Dudau <Liviu.Dudau@arm.com>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> [Changed handcoded setup to use eth_hw_addr_random() instead]
> Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>
> ---
> I have tested this on my Juno platform and I can successfully do an nfsroot boot.
> 
> Best regards,
> Liviu
> 
>  drivers/net/ethernet/marvell/sky2.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index d9f4498..c309879 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
> @@ -4819,6 +4819,13 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
>  		memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8,
>  			      ETH_ALEN);
>  
> +	/* if the address is invalid, use a random value */
> +	if (!is_valid_ether_addr(dev->dev_addr)) {
> +		netdev_warn(dev,
> +			"Invalid MAC address, defaulting to random\n");
> +		eth_hw_addr_random(dev);
> +	}
> +
>  	return dev;
>  }
>  

This is not enough, you need to program the hardware with the new random MAC
address. The easiest way is calling sky2_set_mac_address, but you need to convert
the address from array back to sockaddr.
