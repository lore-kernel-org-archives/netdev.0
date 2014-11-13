From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: Optimization for RX excess judgement
Date: Fri, 14 Nov 2014 01:27:51 +0300
Message-ID: <54653067.8040608@cogentembedded.com>
References: <1415862031-27925-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1415862031-27925-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2014 10:00 AM, Yoshihiro Kaneko wrote:

> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>

> Both of 'boguscnt' and 'quota' have nearly meaning as the condition of
> the reception loop.
> In order to cut down redundant processing, this patch changes excess judgement.

> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> ---

> This patch is based on net tree.

>   drivers/net/ethernet/renesas/sh_eth.c | 15 +++++++++------
>   1 file changed, 9 insertions(+), 6 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 60e9c2c..7d46326 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1394,10 +1394,15 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
>
>   	int entry = mdp->cur_rx % mdp->num_rx_ring;
>   	int boguscnt = (mdp->dirty_rx + mdp->num_rx_ring) - mdp->cur_rx;
> +	int limit = boguscnt;
>   	struct sk_buff *skb;
>   	u16 pkt_len = 0;
>   	u32 desc_status;
>
> +	if (quota) {
> +		boguscnt = min(boguscnt, *quota);
> +		limit = boguscnt;
> +	}
>   	rxdesc = &mdp->rx_ring[entry];
>   	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT))) {
>   		desc_status = edmac_to_cpu(mdp, rxdesc->status);
[...]
> @@ -1501,7 +1501,10 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
>   		sh_eth_write(ndev, EDRRR_R, EDRRR);
>   	}
>
> -	return *quota <= 0;
> +	if (quota)
> +		*quota -= limit - (++boguscnt);

    Just 'limit - boguscnt + 1'.

> +
> +	return (boguscnt <= 0);

    Hm... why change the *return* statement at all? I'm not sure this is at 
all correct.

WBR, Sergei

