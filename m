From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next] sockopt: Change getsockopt() of SO_BINDTODEVICE
 to return an interface name
Date: Fri, 02 Nov 2012 11:02:50 -0400
Message-ID: <5093E09A.6000004@hp.com>
References: <509184D9.8030103@hp.com> <5093940B.6020207@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:26670 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806Ab2KBPC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 11:02:57 -0400
In-Reply-To: <5093940B.6020207@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/2012 05:36 AM, Pavel Emelyanov wrote:
>> +static int sock_getbindtodevice(struct sock *sk, char __user *optval,
>> +				int __user *optlen, int len)
>> +{
>> +	int ret = -ENOPROTOOPT;
>> +#ifdef CONFIG_NETDEVICES
>> +	struct net *net = sock_net(sk);
>> +	struct net_device *dev;
>> +	char devname[IFNAMSIZ];
>> +
>> +	if (sk->sk_bound_dev_if == 0) {
>> +		len = 0;
>> +		goto zero;
>> +	}
>> +
>> +	ret = -EINVAL;
>> +	if (len < IFNAMSIZ)
>> +		goto out;
>> +
>> +	rcu_read_lock();
>> +	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
>> +	if (dev)
>> +		strcpy(devname, dev->name);
> 
> This still races with the device name change, potentially providing
> a name which never existed in the system, doesn't it?

My only argument here is that SIOCGIFNAME has had this same code forever, and
noone has ever complained about that returning a garbled name.  Even
dev_get_by_name() only holds an rcu lock when doing a strncmp().

We'd need to audit the whole kernel to catch all the places where we potentially
look at dev->name while it could change.  Is it really worth it?

-Brian
