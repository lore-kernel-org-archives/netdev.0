From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next V2 3/3] tun: add eBPF based queue selection
 method
Date: Tue, 31 Oct 2017 18:45:44 +0200
Message-ID: <20171031184002-mutt-send-email-mst@kernel.org>
References: <1509445938-4345-1-git-send-email-jasowang@redhat.com>
 <1509445938-4345-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        willemdebruijn.kernel@gmail.com, tom@herbertland.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52694 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753841AbdJaQpp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 12:45:45 -0400
Content-Disposition: inline
In-Reply-To: <1509445938-4345-4-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 06:32:18PM +0800, Jason Wang wrote:
> This patch introduces an eBPF based queue selection method based on
> the flow steering policy ops. Userspace could load an eBPF program
> through TUNSETSTEERINGEBPF. This gives much more flexibility compare
> to simple but hard coded policy in kernel.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/tun.c           | 79 ++++++++++++++++++++++++++++++++++++++++++++-
>  include/uapi/linux/if_tun.h |  2 ++
>  2 files changed, 80 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index ab109ff..4bdde21 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -191,6 +191,20 @@ struct tun_steering_ops {
>  			 u32 data);
>  };
>  
> +void tun_steering_xmit_nop(struct tun_struct *tun, struct sk_buff *skb)
> +{
> +}
> +
> +u32 tun_steering_pre_rx_nop(struct tun_struct *tun, struct sk_buff *skb)
> +{
> +	return 0;
> +}
> +
> +void tun_steering_post_rx_nop(struct tun_struct *tun, struct tun_file *tfile,
> +			      u32 data)
> +{
> +}
> +
>  struct tun_flow_entry {
>  	struct hlist_node hash_link;
>  	struct rcu_head rcu;
> @@ -241,6 +255,7 @@ struct tun_struct {
>  	u32 rx_batched;
>  	struct tun_pcpu_stats __percpu *pcpu_stats;
>  	struct bpf_prog __rcu *xdp_prog;
> +	struct bpf_prog __rcu *steering_prog;
>  	struct tun_steering_ops *steering_ops;
>  };
>  
> @@ -576,6 +591,19 @@ static u16 tun_automq_select_queue(struct tun_struct *tun, struct sk_buff *skb)
>  	return txq;
>  }
>  
> +static u16 tun_ebpf_select_queue(struct tun_struct *tun, struct sk_buff *skb)
> +{
> +	struct bpf_prog *prog;
> +	u16 ret = 0;
> +
> +	rcu_read_lock();
> +	prog = rcu_dereference(tun->steering_prog);
> +	if (prog)
> +		ret = bpf_prog_run_clear_cb(prog, skb);
> +	rcu_read_unlock();
> +
> +	return ret % tun->numqueues;
> +}
>  static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb,
>  			    void *accel_priv, select_queue_fallback_t fallback)
>  {
> @@ -2017,6 +2045,20 @@ static ssize_t tun_chr_read_iter(struct kiocb *iocb, struct iov_iter *to)
>  	return ret;
>  }
>  
> +static void __tun_set_steering_ebpf(struct tun_struct *tun,
> +				    struct bpf_prog *new)
> +{
> +	struct bpf_prog *old;
> +
> +	old = rtnl_dereference(tun->steering_prog);
> +	rcu_assign_pointer(tun->steering_prog, new);
> +
> +	if (old) {
> +		synchronize_net();
> +		bpf_prog_destroy(old);
> +	}
> +}
> +

Is this really called under rtnl? If no then rtnl_dereference
is wrong. If yes I'm not sure you can call synchronize_net
under rtnl.

>  static void tun_free_netdev(struct net_device *dev)
>  {
>  	struct tun_struct *tun = netdev_priv(dev);
> @@ -2025,6 +2067,7 @@ static void tun_free_netdev(struct net_device *dev)
>  	free_percpu(tun->pcpu_stats);
>  	tun_flow_uninit(tun);
>  	security_tun_dev_free_security(tun->security);
> +	__tun_set_steering_ebpf(tun, NULL);
>  }
>  
>  static void tun_setup(struct net_device *dev)
> @@ -2159,6 +2202,13 @@ static struct tun_steering_ops tun_automq_ops = {
>  	.post_rx = tun_automq_post_rx,
>  };
>  
> +static struct tun_steering_ops tun_ebpf_ops = {
> +	.select_queue = tun_ebpf_select_queue,
> +	.xmit = tun_steering_xmit_nop,
> +	.pre_rx = tun_steering_pre_rx_nop,
> +	.post_rx = tun_steering_post_rx_nop,
> +};
> +
>  static int tun_flags(struct tun_struct *tun)
>  {
>  	return tun->flags & (TUN_FEATURES | IFF_PERSIST | IFF_TUN | IFF_TAP);
> @@ -2311,6 +2361,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		tun->filter_attached = false;
>  		tun->sndbuf = tfile->socket.sk->sk_sndbuf;
>  		tun->rx_batched = 0;
> +		RCU_INIT_POINTER(tun->steering_prog, NULL);
>  
>  		tun->pcpu_stats = netdev_alloc_pcpu_stats(struct tun_pcpu_stats);
>  		if (!tun->pcpu_stats) {
> @@ -2503,6 +2554,23 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
>  	return ret;
>  }
>  
> +static int tun_set_steering_ebpf(struct tun_struct *tun, void __user *data)
> +{
> +	struct bpf_prog *prog;
> +	u32 fd;
> +
> +	if (copy_from_user(&fd, data, sizeof(fd)))
> +		return -EFAULT;
> +
> +	prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_SOCKET_FILTER);
> +	if (IS_ERR(prog))
> +		return PTR_ERR(prog);
> +
> +	__tun_set_steering_ebpf(tun, prog);
> +
> +	return 0;
> +}
> +
>  static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>  			    unsigned long arg, int ifreq_len)
>  {
> @@ -2785,6 +2853,9 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>  		case TUN_STEERING_AUTOMQ:
>  			tun->steering_ops = &tun_automq_ops;
>  			break;
> +		case TUN_STEERING_EBPF:
> +			tun->steering_ops = &tun_ebpf_ops;
> +			break;
>  		default:
>  			ret = -EFAULT;
>  		}
> @@ -2794,6 +2865,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>  		ret = 0;
>  		if (tun->steering_ops == &tun_automq_ops)
>  			steering = TUN_STEERING_AUTOMQ;
> +		else if (tun->steering_ops == &tun_ebpf_ops)
> +			steering = TUN_STEERING_EBPF;
>  		else
>  			BUG();
>  		if (copy_to_user(argp, &steering, sizeof(steering)))
> @@ -2802,11 +2875,15 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>  
>  	case TUNGETSTEERINGFEATURES:
>  		ret = 0;
> -		steering = TUN_STEERING_AUTOMQ;
> +		steering = TUN_STEERING_AUTOMQ | TUN_STEERING_EBPF;
>  		if (copy_to_user(argp, &steering, sizeof(steering)))
>  			ret = -EFAULT;
>  		break;
>  
> +	case TUNSETSTEERINGEBPF:
> +		ret = tun_set_steering_ebpf(tun, argp);
> +		break;
> +
>  	default:
>  		ret = -EINVAL;
>  		break;
> diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
> index 109760e..927f7e4 100644
> --- a/include/uapi/linux/if_tun.h
> +++ b/include/uapi/linux/if_tun.h
> @@ -59,6 +59,7 @@
>  #define TUNSETSTEERING _IOW('T', 224, unsigned int)
>  #define TUNGETSTEERING _IOR('T', 225, unsigned int)
>  #define TUNGETSTEERINGFEATURES _IOR('T', 226, unsigned int)
> +#define TUNSETSTEERINGEBPF _IOR('T', 227, int)
>  
>  /* TUNSETIFF ifr flags */
>  #define IFF_TUN		0x0001
> @@ -112,5 +113,6 @@ struct tun_filter {
>  };
>  
>  #define TUN_STEERING_AUTOMQ 0x01 /* Automatic flow steering */
> +#define TUN_STEERING_EBPF   0x02 /* eBPF based flow steering */
>  
>  #endif /* _UAPI__IF_TUN_H */
> -- 
> 2.7.4
