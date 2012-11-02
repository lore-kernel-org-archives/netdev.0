From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next] sockopt: Change getsockopt() of SO_BINDTODEVICE
 to return an interface name
Date: Fri, 02 Nov 2012 13:36:11 +0400
Message-ID: <5093940B.6020207@parallels.com>
References: <509184D9.8030103@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:6909 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932799Ab2KBJga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2012 05:36:30 -0400
In-Reply-To: <509184D9.8030103@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int sock_getbindtodevice(struct sock *sk, char __user *optval,
> +				int __user *optlen, int len)
> +{
> +	int ret = -ENOPROTOOPT;
> +#ifdef CONFIG_NETDEVICES
> +	struct net *net = sock_net(sk);
> +	struct net_device *dev;
> +	char devname[IFNAMSIZ];
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
> +	rcu_read_lock();
> +	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
> +	if (dev)
> +		strcpy(devname, dev->name);

This still races with the device name change, potentially providing
a name which never existed in the system, doesn't it?

> +	rcu_read_unlock();
> +	ret = -ENODEV;
> +	if (!dev)
> +		goto out;
> +
> +	len = strlen(devname) + 1;
> +
> +	ret = -EFAULT;
> +	if (copy_to_user(optval, devname, len))
> +		goto out;
> +
> +zero:
> +	ret = -EFAULT;
> +	if (put_user(len, optlen))
> +		goto out;
> +
> +	ret = 0;
> +
> +out:
> +#endif
> +
> +	return ret;
> +}

Thanks,
Pavel
