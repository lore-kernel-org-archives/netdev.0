From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/6] mac802154: Use netif flow control
Date: Wed, 03 Apr 2013 01:21:39 +0400
Message-ID: <515B4BE3.7060606@cogentembedded.com>
References: <1364928481-1813-1-git-send-email-alan@signal11.us> <1364928481-1813-4-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Ott <alan@signal11.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364928481-1813-4-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/02/2013 10:47 PM, Alan Ott wrote:

> Use netif_stop_queue() and netif_wake_queue() to control the flow of
> packets to mac802154 devices.  Since many IEEE 802.15.4 devices have no
> output buffer, and since the mac802154 xmit() function is designed to
> block, netif_stop_queue() is called after each packet.
>
> Signed-off-by: Alan Ott <alan@signal11.us>
> ---
>   net/mac802154/tx.c | 16 ++++++++++++++++
>   1 file changed, 16 insertions(+)
>
> diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
> index a248246..fe3e02c 100644
> --- a/net/mac802154/tx.c
> +++ b/net/mac802154/tx.c
[...]
> @@ -71,6 +73,12 @@ static void mac802154_xmit_worker(struct work_struct *work)
>   out:
>   	mutex_unlock(&xw->priv->phy->pib_lock);
>   
> +	/* Restart the netif queue on each sub_if_data object. */
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(sdata, &xw->priv->slaves, list) {
> +		netif_wake_queue(sdata->dev);
> +	}


    Are {} really necessary here?

> @@ -108,6 +117,13 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
>   		return NETDEV_TX_BUSY;
>   	}
>   
> +	/* Stop the netif queue on each sub_if_data object. */
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(sdata, &priv->slaves, list) {
> +		netif_stop_queue(sdata->dev);
> +	}

    And here?

WBR, Sergei
