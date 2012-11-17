From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH v2 net-next] sockopt: Change getsockopt() of SO_BINDTODEVICE
 to return an interface name
Date: Sat, 17 Nov 2012 09:06:24 +0400
Message-ID: <50A71B50.3030603@parallels.com>
References: <50A6A8FB.3050901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47641 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750728Ab2KQFGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Nov 2012 00:06:50 -0500
In-Reply-To: <50A6A8FB.3050901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -4165,6 +4180,8 @@ static int dev_ifname(struct net *net, struct ifreq __user
> *arg)
> 
>  	strcpy(ifr.ifr_name, dev->name);
>  	rcu_read_unlock();
> +	if (read_seqretry(&devnet_rename_seq, seq))
> +		goto retry;

I believe it makes sense to make the seqcount protection as a separate patch
with description of what may happen.

> 
>  	if (copy_to_user(arg, &ifr, sizeof(struct ifreq)))
>  		return -EFAULT;

> @@ -562,6 +563,59 @@ out:
>  	return ret;
>  }
> 
> +static int sock_getbindtodevice(struct sock *sk, char __user *optval,
> +				int __user *optlen, int len)
> +{
> +	int ret = -ENOPROTOOPT;
> +#ifdef CONFIG_NETDEVICES
> +	struct net *net = sock_net(sk);
> +	struct net_device *dev;
> +	char devname[IFNAMSIZ];
> +	unsigned seq;
> +
> +	if (sk->sk_bound_dev_if == 0) {
> +		len = 0;
> +		goto zero;
> +	}
> +
> +	ret = -EINVAL;
> +	if (len < IFNAMSIZ)
> +		goto out;
> +
> +retry:
> +	seq = read_seqbegin(&devnet_rename_seq);
> +	rcu_read_lock();
> +	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);

The sk->sk_bound_dev_if might have changed to 0 while we did read_seqretry (or
did the len check above, but the race window is smaller) and this code will
report -ENODEV instead of zero lenght.

Other than this, the intention looks OK to me.

> +	ret = -ENODEV;
> +	if (!dev) {
> +		rcu_read_unlock();
> +		goto out;
> +	}
> +
> +	strcpy(devname, dev->name);
> +	rcu_read_unlock();
> +	if (read_seqretry(&devnet_rename_seq, seq))
> +		goto retry;
> +
> +	len = strlen(devname) + 1;
> +
> +	ret = -EFAULT;
> +	if (copy_to_user(optval, devname, len))
> +		goto out;
> +

Thanks,
Pavel
