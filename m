From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net] net: dsa: Initialize ds->cpu_port_mask earlier
Date: Wed, 26 Jul 2017 10:13:28 +0800
Message-ID: <1501035208.27236.2.camel@mtkswgap22>
References: <20170724174923.29156-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <davem@davemloft.net>,
        <linux-mediatek@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:29446 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750885AbdGZCNd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 22:13:33 -0400
In-Reply-To: <20170724174923.29156-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Florian

the solution is better and also can fix the problem I originally
reported. Thank for your immediate help :-)

Sean


On Mon, 2017-07-24 at 10:49 -0700, Florian Fainelli wrote:
> The mt7530 driver has its dsa_switch_ops::get_tag_protocol function
> check ds->cpu_port_mask to issue a warning in case the configured CPU
> port is not capable of supporting tags.
> 
> After commit 14be36c2c96c ("net: dsa: Initialize all CPU and enabled
> ports masks in dsa_ds_parse()") we slightly re-arranged the
> initialization such that this was no longer working. Just make sure that
> ds->cpu_port_mask is set prior to the first call to get_tag_protocol,
> thus restoring the expected contract. In case of error, the CPU port bit
> is cleared.
> 
> Fixes: 14be36c2c96c ("net: dsa: Initialize all CPU and enabled ports masks in dsa_ds_parse()")
> Reported-by: Sean Wang <sean.wang@mediatek.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Sean, can you check this does fix the problem you originally reported
> correctly for you? Thanks!
> 
>  net/dsa/dsa2.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
> index 56e46090526b..c442051d5a55 100644
> --- a/net/dsa/dsa2.c
> +++ b/net/dsa/dsa2.c
> @@ -509,21 +509,22 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
>  		dst->cpu_dp->netdev = ethernet_dev;
>  	}
>  
> +	/* Initialize cpu_port_mask now for drv->setup()
> +	 * to have access to a correct value, just like what
> +	 * net/dsa/dsa.c::dsa_switch_setup_one does.
> +	 */
> +	ds->cpu_port_mask |= BIT(index);
> +
>  	tag_protocol = ds->ops->get_tag_protocol(ds);
>  	dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
>  	if (IS_ERR(dst->tag_ops)) {
>  		dev_warn(ds->dev, "No tagger for this switch\n");
> +		ds->cpu_port_mask &= ~BIT(index);
>  		return PTR_ERR(dst->tag_ops);
>  	}
>  
>  	dst->rcv = dst->tag_ops->rcv;
>  
> -	/* Initialize cpu_port_mask now for drv->setup()
> -	 * to have access to a correct value, just like what
> -	 * net/dsa/dsa.c::dsa_switch_setup_one does.
> -	 */
> -	ds->cpu_port_mask |= BIT(index);
> -
>  	return 0;
>  }
>  
