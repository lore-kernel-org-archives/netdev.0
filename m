From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH 2/2] ppp: implement rtnetlink device handling
Date: Mon, 25 Jan 2016 12:09:34 +0100
Message-ID: <56A6026E.4020709@bfs.de>
References: <cover.1450900138.git.g.nault@alphalink.fr> <c5f53cba74321e0b9fc5e03fd5c55bdc8c1bc4bf.1450900138.git.g.nault@alphalink.fr>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <c5f53cba74321e0b9fc5e03fd5c55bdc8c1bc4bf.1450900138.git.g.nault@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 23.12.2015 21:04, schrieb Guillaume Nault:
> Define PPP device handler for use with rtnetlink.
> 
> The only PPP specific attribute is IFLA_PPP_DEV_FD. It is mandatory and
> contains the file descriptor of the associated /dev/ppp instance (the
> file descriptor which would have been used for ioctl(PPPIOCNEWUNIT) in
> the ioctl-based API).
> 
> PPP devices created with the rtnetlink API behave like the ones created
> with ioctl(PPPIOCNEWUNIT). In particular existing ioctls still apply to
> PPP units created with the rtnetlink API.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> ---
>  drivers/net/ppp/ppp_generic.c | 109 ++++++++++++++++++++++++++++++++++++++++--
>  include/uapi/linux/if_link.h  |   8 ++++
>  2 files changed, 113 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> index bc24537..19476d6 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -46,6 +46,7 @@
>  #include <linux/device.h>
>  #include <linux/mutex.h>
>  #include <linux/slab.h>
> +#include <linux/file.h>
>  #include <asm/unaligned.h>
>  #include <net/slhc_vj.h>
>  #include <linux/atomic.h>
> @@ -185,7 +186,9 @@ struct channel {
>  
>  struct ppp_config {
>  	struct file *file;
> +	s32 fd;
>  	s32 unit;
> +	bool ifname_is_set;
>  };
>  
>  /*
> @@ -286,6 +289,7 @@ static int unit_get(struct idr *p, void *ptr);
>  static int unit_set(struct idr *p, void *ptr, int n);
>  static void unit_put(struct idr *p, int n);
>  static void *unit_find(struct idr *p, int n);
> +static void ppp_setup(struct net_device *dev);
>  
>  static const struct net_device_ops ppp_netdev_ops;
>  
> @@ -954,7 +958,7 @@ static struct pernet_operations ppp_net_ops = {
>  	.size = sizeof(struct ppp_net),
>  };
>  
> -static int ppp_unit_register(struct ppp *ppp, int unit)
> +static int ppp_unit_register(struct ppp *ppp, int unit, bool ifname_is_set)
>  {
>  	struct ppp_net *pn = ppp_pernet(ppp->ppp_net);
>  	int ret;
> @@ -984,7 +988,8 @@ static int ppp_unit_register(struct ppp *ppp, int unit)
>  
>  	ppp->file.index = ret;
>  
> -	snprintf(ppp->dev->name, IFNAMSIZ, "ppp%i", ppp->file.index);
> +	if (!ifname_is_set)
> +		snprintf(ppp->dev->name, IFNAMSIZ, "ppp%i", ppp->file.index);
>  
>  	ret = register_netdevice(ppp->dev);
>  	if (ret)
> @@ -1012,7 +1017,24 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
>  	int indx;
>  	int err;
>  
> -	file = conf->file;
> +	if (conf->fd >= 0) {
> +		file = fget(conf->fd);
> +		if (file) {
> +			if (file->f_op != &ppp_device_fops) {
> +				fput(file);
> +				return -EBADF;
> +			}
> +
> +			/* Don't hold reference on file: ppp_release() is
> +			 * responsible for safely freeing the associated
> +			 * resources upon release. So file won't go away
> +			 * from under us.
> +			 */
> +			fput(file);
> +		}
> +	} else {
> +		file = conf->file;
> +	}
>  	if (!file)
>  		return -EBADF;


I would write that a bid different to reduce indent
und improve readability

(note: totaly untested just reviewing)

if (conf->fd < 0) {
	file = conf->file;
	if (!file)
  		return -EBADF;
}
else
{
file = fget(conf->fd);
if (!file)
  	return -EBADF;

fput(file);
if (file->f_op != &ppp_device_fops) {		
		return -EBADF;
	}

}


just my 2 cents

re,
 wh

>  	if (file->private_data)
> @@ -1040,7 +1062,7 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
>  	ppp->mru = PPP_MRU;
>  	ppp->ppp_net = src_net;
>  
> -	err = ppp_unit_register(ppp, conf->unit);
> +	err = ppp_unit_register(ppp, conf->unit, conf->ifname_is_set);
>  	if (err < 0)
>  		return err;
>  
> @@ -1049,6 +1071,73 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
>  	return 0;
>  }
>  
> +static const struct nla_policy ppp_nl_policy[IFLA_PPP_MAX + 1] = {
> +	[IFLA_PPP_DEV_FD]	= { .type = NLA_S32 },
> +};
> +
> +static int ppp_nl_validate(struct nlattr *tb[], struct nlattr *data[])
> +{
> +	if (!data)
> +		return -EINVAL;
> +
> +	if (!data[IFLA_PPP_DEV_FD])
> +		return -EINVAL;
> +	if (nla_get_s32(data[IFLA_PPP_DEV_FD]) < 0)
> +		return -EBADF;
> +
> +	return 0;
> +}
> +
> +static int ppp_nl_newlink(struct net *src_net, struct net_device *dev,
> +			  struct nlattr *tb[], struct nlattr *data[])
> +{
> +	struct ppp_config conf = {
> +		.file = NULL,
> +		.unit = -1,
> +		.ifname_is_set = true,
> +	};
> +
> +	conf.fd = nla_get_s32(data[IFLA_PPP_DEV_FD]);
> +
> +	return ppp_dev_configure(src_net, dev, &conf);
> +}
> +
> +static void ppp_nl_dellink(struct net_device *dev, struct list_head *head)
> +{
> +	unregister_netdevice_queue(dev, head);
> +}
> +
> +static size_t ppp_nl_get_size(const struct net_device *dev)
> +{
> +	return 0;
> +}
> +
> +static int ppp_nl_fill_info(struct sk_buff *skb, const struct net_device *dev)
> +{
> +	return 0;
> +}
> +
> +static struct net *ppp_nl_get_link_net(const struct net_device *dev)
> +{
> +	struct ppp *ppp = netdev_priv(dev);
> +
> +	return ppp->ppp_net;
> +}
> +
> +static struct rtnl_link_ops ppp_link_ops __read_mostly = {
> +	.kind		= "ppp",
> +	.maxtype	= IFLA_PPP_MAX,
> +	.policy		= ppp_nl_policy,
> +	.priv_size	= sizeof(struct ppp),
> +	.setup		= ppp_setup,
> +	.validate	= ppp_nl_validate,
> +	.newlink	= ppp_nl_newlink,
> +	.dellink	= ppp_nl_dellink,
> +	.get_size	= ppp_nl_get_size,
> +	.fill_info	= ppp_nl_fill_info,
> +	.get_link_net	= ppp_nl_get_link_net,
> +};
> +
>  #define PPP_MAJOR	108
>  
>  /* Called at boot time if ppp is compiled into the kernel,
> @@ -1077,11 +1166,19 @@ static int __init ppp_init(void)
>  		goto out_chrdev;
>  	}
>  
> +	err = rtnl_link_register(&ppp_link_ops);
> +	if (err) {
> +		pr_err("Failed to register RT netlink PPP handler\n");
> +		goto out_class;
> +	}
> +
>  	/* not a big deal if we fail here :-) */
>  	device_create(ppp_class, NULL, MKDEV(PPP_MAJOR, 0), NULL, "ppp");
>  
>  	return 0;
>  
> +out_class:
> +	class_destroy(ppp_class);
>  out_chrdev:
>  	unregister_chrdev(PPP_MAJOR, "ppp");
>  out_net:
> @@ -2821,7 +2918,9 @@ static int ppp_create_interface(struct net *net, int *unit, struct file *file)
>  {
>  	struct ppp_config conf = {
>  		.file = file,
> +		.fd = -1,
>  		.unit = *unit,
> +		.ifname_is_set = false,
>  	};
>  	struct net_device *dev;
>  	struct ppp *ppp;
> @@ -3038,6 +3137,7 @@ static void __exit ppp_cleanup(void)
>  	/* should never happen */
>  	if (atomic_read(&ppp_unit_count) || atomic_read(&channel_count))
>  		pr_err("PPP: removing module but units remain!\n");
> +	rtnl_link_unregister(&ppp_link_ops);
>  	unregister_chrdev(PPP_MAJOR, "ppp");
>  	device_destroy(ppp_class, MKDEV(PPP_MAJOR, 0));
>  	class_destroy(ppp_class);
> @@ -3096,4 +3196,5 @@ EXPORT_SYMBOL(ppp_register_compressor);
>  EXPORT_SYMBOL(ppp_unregister_compressor);
>  MODULE_LICENSE("GPL");
>  MODULE_ALIAS_CHARDEV(PPP_MAJOR, 0);
> +MODULE_ALIAS_RTNL_LINK("ppp");
>  MODULE_ALIAS("devname:ppp");
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index a30b780..72b0213 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -470,6 +470,14 @@ enum {
>  };
>  #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
>  
> +/* PPP section */
> +enum {
> +	IFLA_PPP_UNSPEC,
> +	IFLA_PPP_DEV_FD,
> +	__IFLA_PPP_MAX,
> +};
> +#define IFLA_PPP_MAX (__IFLA_PPP_MAX - 1)
> +
>  /* Bonding section */
>  
>  enum {
