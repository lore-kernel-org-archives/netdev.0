From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next V3 5/6] net: introduce NETDEV_CHANGE_TX_QUEUE_LEN
Date: Wed, 29 Jun 2016 21:56:27 -0700
Message-ID: <5774A67B.1060802@gmail.com>
References: <1467258779-3539-1-git-send-email-jasowang@redhat.com>
 <1467258779-3539-6-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	eric.dumazet@gmail.com, brouer@redhat.com
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1467258779-3539-6-git-send-email-jasowang@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-06-29 08:52 PM, Jason Wang wrote:
> This patch introduces a new event - NETDEV_CHANGE_TX_QUEUE_LEN, this
> will be triggered when tx_queue_len. It could be used by net device
> who want to do some processing at that time. An example is tun who may
> want to resize tx array when tx_queue_len is changed.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  include/linux/netdevice.h |  1 +
>  net/core/net-sysfs.c      | 15 ++++++++++++++-
>  2 files changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index e84d9d2..7dc2ec7 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2237,6 +2237,7 @@ struct netdev_lag_lower_state_info {
>  #define NETDEV_PRECHANGEUPPER	0x001A
>  #define NETDEV_CHANGELOWERSTATE	0x001B
>  #define NETDEV_UDP_TUNNEL_PUSH_INFO	0x001C
> +#define NETDEV_CHANGE_TX_QUEUE_LEN	0x001E
>  
>  int register_netdevice_notifier(struct notifier_block *nb);
>  int unregister_netdevice_notifier(struct notifier_block *nb);
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 7a0b616..6e4f347 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -322,7 +322,20 @@ NETDEVICE_SHOW_RW(flags, fmt_hex);
>  
>  static int change_tx_queue_len(struct net_device *dev, unsigned long new_len)
>  {
> -	dev->tx_queue_len = new_len;
> +	int res, orig_len = dev->tx_queue_len;
> +
> +	if (new_len != orig_len) {
> +		dev->tx_queue_len = new_len;
> +		res = call_netdevice_notifiers(NETDEV_CHANGE_TX_QUEUE_LEN, dev);
> +		res = notifier_to_errno(res);
> +		if (res) {
> +			netdev_err(dev,
> +				   "refused to change device tx_queue_len\n");
> +			dev->tx_queue_len = orig_len;
> +			return -EFAULT;
> +		}
> +	}
> +
>  	return 0;
>  }
>  
> 

Acked-by: John Fastabend <john.r.fastabend@intel.com>

Great timing I was just looking into this because I need it for the
qdisc side.

It looks like this covers the sysfs change but the tx_queue_len can
also be changed via rtnetlink as well. So we need another patch for
that path right?

        if (tb[IFLA_TXQLEN]) {
                unsigned long value = nla_get_u32(tb[IFLA_TXQLEN]);

                if (dev->tx_queue_len ^ value)
                        status |= DO_SETLINK_NOTIFY;

                dev->tx_queue_len = value;
        }

Thanks,
John

