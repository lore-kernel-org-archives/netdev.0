From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] Increase limit of macvtap queues
Date: Sun, 14 Jun 2015 10:42:40 +0200
Message-ID: <20150614103209-mutt-send-email-mst@redhat.com>
References: <1434115828-9461-1-git-send-email-pagupta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, jasowang@redhat.com,
	vyasevic@redhat.com, bhutchings@solarflare.com,
	therbert@google.com, viro@zeniv.linux.org.uk
To: Pankaj Gupta <pagupta@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1434115828-9461-1-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 12, 2015 at 07:00:28PM +0530, Pankaj Gupta wrote:
> Macvtap should be compatible with tuntap for maximum number
> of queues. '1059590254fa9dce9cafc4f07d1103dbec415e76' removes
> the limitation and increases number of queues in tuntap.
> Now, Its safe to increase number of queues in Macvtap as well.
> 
> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>

It's a good idea, but this might be a problem:

static void macvtap_del_queues(struct net_device *dev)
{
        struct macvlan_dev *vlan = netdev_priv(dev);
        struct macvtap_queue *q, *tmp, *qlist[MAX_MACVTAP_QUEUES];

...
}

by itself, this will use 2K on stack, which seems too much.

You need to rework this function to use a linked list + list_move
instead of an array + list_del_init.

> ---
>  include/linux/if_macvlan.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
> index 6f6929e..a4ccc31 100644
> --- a/include/linux/if_macvlan.h
> +++ b/include/linux/if_macvlan.h
> @@ -29,7 +29,7 @@ struct macvtap_queue;
>   * Maximum times a macvtap device can be opened. This can be used to
>   * configure the number of receive queue, e.g. for multiqueue virtio.
>   */
> -#define MAX_MACVTAP_QUEUES     16
> +#define MAX_MACVTAP_QUEUES     256
> 
>  #define MACVLAN_MC_FILTER_BITS 8
>  #define MACVLAN_MC_FILTER_SZ   (1 << MACVLAN_MC_FILTER_BITS)
> --
> 1.7.1
