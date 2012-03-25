From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next PATCH v0 2/5] net: addr_list: add exclusive dev_uc_add
Date: Sun, 25 Mar 2012 06:07:45 -0700
Message-ID: <CB9466B1.49E3C%roprabhu@cisco.com>
References: <20120319065157.10959.32215.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mst@redhat.com>, <chrisw@redhat.com>,
	<gregory.v.rose@intel.com>, <kvm@vger.kernel.org>,
	<sri@us.ibm.com>, <chealy@imsco-us.com>
To: John Fastabend <john.r.fastabend@intel.com>, <jhs@mojatatu.com>,
	<shemminger@vyatta.com>, <bhutchings@solarflare.com>,
	<davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120319065157.10959.32215.stgit@jf-dev1-dcblab>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 3/18/12 11:51 PM, "John Fastabend" <john.r.fastabend@intel.com> wrote:

> This adds a dev_uc_add_excl() call similar to the original
> dev_uc_add() except it sets the global bit. With this
> change the reference count will not be bumped and -EEXIST
> will be returned if a duplicate address exists.
> 
> This is useful for drivers that support SR-IOV and want
> to manage the unicast lists.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  include/linux/netdevice.h |    1 +
>  net/core/dev_addr_lists.c |   19 +++++++++++++++++++
>  2 files changed, 20 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 4208901..5e43cec 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2571,6 +2571,7 @@ extern int dev_addr_init(struct net_device *dev);
>  
>  /* Functions used for unicast addresses handling */
>  extern int dev_uc_add(struct net_device *dev, unsigned char *addr);
> +extern int dev_uc_add_excl(struct net_device *dev, unsigned char *addr);
>  extern int dev_uc_del(struct net_device *dev, unsigned char *addr);
>  extern int dev_uc_sync(struct net_device *to, struct net_device *from);
>  extern void dev_uc_unsync(struct net_device *to, struct net_device *from);
> diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
> index 29c07fe..c7d27ad 100644
> --- a/net/core/dev_addr_lists.c
> +++ b/net/core/dev_addr_lists.c
> @@ -377,6 +377,25 @@ EXPORT_SYMBOL(dev_addr_del_multiple);
>   */
>  
>  /**
> + * dev_uc_add_excl - Add a global secondary unicast address
> + * @dev: device
> + * @addr: address to add
> + */
> +int dev_uc_add_excl(struct net_device *dev, unsigned char *addr)
> +{
> + int err;
> +
> + netif_addr_lock_bh(dev);
> + err = __hw_addr_add_ex(&dev->uc, addr, dev->addr_len,
> +          NETDEV_HW_ADDR_T_UNICAST, true);
> + if (!err)
> +  __dev_set_rx_mode(dev);
> + netif_addr_unlock_bh(dev);
> + return err;
> +}
> +EXPORT_SYMBOL(dev_uc_add_excl);
> +
> +/**

ACK.
We will need a similar function for multicast as well ?. Macvlan could use
it.

Thanks,
Roopa



