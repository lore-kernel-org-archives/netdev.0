From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/2] r8152: use eth_hw_addr_random
Date: Tue, 02 Sep 2014 16:53:20 +0400
Message-ID: <5405BDC0.6060508@cogentembedded.com>
References: <1394712342-15778-26-Taiwan-albertk@realtek.com> <1394712342-15778-28-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-28-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/2/2014 1:55 PM, Hayes Wang wrote:

> If the hw doesn't have a valid MAC address, give a random one and
> set it to the hw.

> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>   drivers/net/usb/r8152.c | 39 ++++++++++++++++++++++++---------------
>   1 file changed, 24 insertions(+), 15 deletions(-)

> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index b5ff933..2bc1b8d 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -992,32 +992,41 @@ static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
>   	return 0;
>   }
>
> -static inline void set_ethernet_addr(struct r8152 *tp)
> +static int set_ethernet_addr(struct r8152 *tp)
>   {
>   	struct net_device *dev = tp->netdev;
> +	struct sockaddr sa;
>   	int ret;
> -	u8 node_id[8] = {0};
>
>   	if (tp->version == RTL_VER_01)
> -		ret = pla_ocp_read(tp, PLA_IDR, sizeof(node_id), node_id);
> +		ret = pla_ocp_read(tp, PLA_IDR, 8, sa.sa_data);
>   	else
> -		ret = pla_ocp_read(tp, PLA_BACKUP, sizeof(node_id), node_id);
> +		ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
>
>   	if (ret < 0) {
> -		netif_notice(tp, probe, dev, "inet addr fail\n");
> +		netif_err(tp, probe, dev, "Get ether addr fail\n");
> +	} else if (!is_valid_ether_addr(sa.sa_data)) {
> +		netif_err(tp, probe, dev,
> +			  "Invalid ether addr %02x:%02x:%02x:%02x:%02x:%02x\n",

   There's now "%pM" format specifier for printing a MAC address.

> +			  sa.sa_data[0], sa.sa_data[1], sa.sa_data[2],
> +			  sa.sa_data[3], sa.sa_data[4], sa.sa_data[5]);
> +		eth_hw_addr_random(dev);
> +		ether_addr_copy(sa.sa_data, dev->dev_addr);
> +		ret = rtl8152_set_mac_address(dev, &sa);
> +		netif_info(tp, probe, dev,
> +			   "Random ether addr %02x:%02x:%02x:%02x:%02x:%02x\n",

    Likewise.

WBR, Sergei
