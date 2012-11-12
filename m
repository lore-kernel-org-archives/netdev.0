From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next v5 6/7] tuntap: add ioctl to attach or detach a file
 form tuntap device
Date: Mon, 12 Nov 2012 17:11:54 +0200
Message-ID: <20121112151154.GA16484@redhat.com>
References: <1351748762-3455-1-git-send-email-jasowang@redhat.com>
 <1351748762-3455-7-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, maxk@qti.qualcomm.com,
	edumazet@google.com, krkumar2@in.ibm.com,
	ernesto.martin@viasat.com, haixiao@juniper.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1351748762-3455-7-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 01, 2012 at 01:46:01PM +0800, Jason Wang wrote:
> Sometimes usespace may need to active/deactive a queue, this could be done by
> detaching and attaching a file from tuntap device.
> 
> This patch introduces a new ioctls - TUNSETQUEUE which could be used to do
> this. Flag IFF_ATTACH_QUEUE were introduced to do attaching while
> IFF_DETACH_QUEUE were introduced to do the detaching.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/tun.c           |   56 ++++++++++++++++++++++++++++++++++++------
>  include/uapi/linux/if_tun.h |    3 ++
>  2 files changed, 51 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 2762c55..79b6f9e 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -195,6 +195,15 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
>  	return txq;
>  }
>  
> +static inline bool tun_not_capable(struct tun_struct *tun)
> +{
> +	const struct cred *cred = current_cred();
> +
> +	return ((uid_valid(tun->owner) && !uid_eq(cred->euid, tun->owner)) ||
> +		  (gid_valid(tun->group) && !in_egroup_p(tun->group))) &&
> +		!capable(CAP_NET_ADMIN);
> +}
> +
>  static void tun_set_real_num_queues(struct tun_struct *tun)
>  {
>  	netif_set_real_num_tx_queues(tun->dev, tun->numqueues);
> @@ -1310,8 +1319,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  
>  	dev = __dev_get_by_name(net, ifr->ifr_name);
>  	if (dev) {
> -		const struct cred *cred = current_cred();
> -
>  		if (ifr->ifr_flags & IFF_TUN_EXCL)
>  			return -EBUSY;
>  		if ((ifr->ifr_flags & IFF_TUN) && dev->netdev_ops == &tun_netdev_ops)
> @@ -1321,9 +1328,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		else
>  			return -EINVAL;
>  
> -		if (((uid_valid(tun->owner) && !uid_eq(cred->euid, tun->owner)) ||
> -		     (gid_valid(tun->group) && !in_egroup_p(tun->group))) &&
> -		    !capable(CAP_NET_ADMIN))
> +		if (tun_not_capable(tun))
>  			return -EPERM;
>  		err = security_tun_dev_attach(tfile->socket.sk);
>  		if (err < 0)
> @@ -1530,6 +1535,40 @@ static void tun_set_sndbuf(struct tun_struct *tun)
>  	}
>  }
>  
> +static int tun_set_queue(struct file *file, struct ifreq *ifr)
> +{
> +	struct tun_file *tfile = file->private_data;
> +	struct tun_struct *tun;
> +	struct net_device *dev;
> +	int ret = 0;
> +
> +	rtnl_lock();
> +
> +	if (ifr->ifr_flags & IFF_ATTACH_QUEUE) {
> +		dev = __dev_get_by_name(tfile->net, ifr->ifr_name);
> +		if (!dev) {
> +			ret = -EINVAL;
> +			goto unlock;
> +		}
> +
> +		tun = netdev_priv(dev);
> +		if (dev->netdev_ops != &tap_netdev_ops &&
> +			dev->netdev_ops != &tun_netdev_ops)
> +			ret = -EINVAL;
> +		else if (tun_not_capable(tun))
> +			ret = -EPERM;
> +		else
> +			ret = tun_attach(tun, file);

looks like we need to check 
security_tun_dev_attach here as well.
As the patch is in net-next now we need a patch on top for that.



> +	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE)
> +		__tun_detach(tfile, false);
> +	else
> +		ret = -EINVAL;
> +
> +unlock:
> +	rtnl_unlock();
> +	return ret;
> +}
> +
>  static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>  			    unsigned long arg, int ifreq_len)
>  {
> @@ -1543,7 +1582,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>  	int vnet_hdr_sz;
>  	int ret;
>  
> -	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89) {
> +	if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == 0x89) {
>  		if (copy_from_user(&ifr, argp, ifreq_len))
>  			return -EFAULT;
>  	} else {
> @@ -1554,9 +1593,10 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>  		 * This is needed because we never checked for invalid flags on
>  		 * TUNSETIFF. */
>  		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
> -				IFF_VNET_HDR,
> +				IFF_VNET_HDR | IFF_MULTI_QUEUE,
>  				(unsigned int __user*)argp);
> -	}
> +	} else if (cmd == TUNSETQUEUE)
> +		return tun_set_queue(file, &ifr);
>  
>  	ret = 0;
>  	rtnl_lock();
> diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
> index 8ef3a87..958497a 100644
> --- a/include/uapi/linux/if_tun.h
> +++ b/include/uapi/linux/if_tun.h
> @@ -54,6 +54,7 @@
>  #define TUNDETACHFILTER _IOW('T', 214, struct sock_fprog)
>  #define TUNGETVNETHDRSZ _IOR('T', 215, int)
>  #define TUNSETVNETHDRSZ _IOW('T', 216, int)
> +#define TUNSETQUEUE  _IOW('T', 217, int)
>  
>  /* TUNSETIFF ifr flags */
>  #define IFF_TUN		0x0001
> @@ -63,6 +64,8 @@
>  #define IFF_VNET_HDR	0x4000
>  #define IFF_TUN_EXCL	0x8000
>  #define IFF_MULTI_QUEUE 0x0100
> +#define IFF_ATTACH_QUEUE 0x0200
> +#define IFF_DETACH_QUEUE 0x0400
>  
>  /* Features for GSO (TUNSETOFFLOAD). */
>  #define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
> -- 
> 1.7.1
