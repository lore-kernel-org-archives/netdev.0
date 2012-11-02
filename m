From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] sockopt: Change getsockopt() of
 SO_BINDTODEVICE to return an interface name
Date: Fri, 2 Nov 2012 23:34:36 +0000
Message-ID: <1351899276.2703.35.camel@bwh-desktop.uk.solarflarecom.com>
References: <509184D9.8030103@hp.com> <5093940B.6020207@parallels.com>
	 <5093E09A.6000004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22715 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758026Ab2KBXej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 19:34:39 -0400
In-Reply-To: <5093E09A.6000004@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-02 at 11:02 -0400, Brian Haley wrote:
> On 11/02/2012 05:36 AM, Pavel Emelyanov wrote:
> >> +static int sock_getbindtodevice(struct sock *sk, char __user *optval,
> >> +				int __user *optlen, int len)
> >> +{
> >> +	int ret = -ENOPROTOOPT;
> >> +#ifdef CONFIG_NETDEVICES
> >> +	struct net *net = sock_net(sk);
> >> +	struct net_device *dev;
> >> +	char devname[IFNAMSIZ];
> >> +
> >> +	if (sk->sk_bound_dev_if == 0) {
> >> +		len = 0;
> >> +		goto zero;
> >> +	}
> >> +
> >> +	ret = -EINVAL;
> >> +	if (len < IFNAMSIZ)
> >> +		goto out;
> >> +
> >> +	rcu_read_lock();
> >> +	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
> >> +	if (dev)
> >> +		strcpy(devname, dev->name);
> > 
> > This still races with the device name change, potentially providing
> > a name which never existed in the system, doesn't it?
> 
> My only argument here is that SIOCGIFNAME has had this same code forever, and
> noone has ever complained about that returning a garbled name.  Even
> dev_get_by_name() only holds an rcu lock when doing a strncmp().
> 
> We'd need to audit the whole kernel to catch all the places where we potentially
> look at dev->name while it could change.  Is it really worth it?

A net device name can't be changed while the device is up, or while
another task holds the RTNL lock.  I think that covers almost all uses.
I don't know whether it's worth going out to look for exceptions, but we
might as well fix the cases we know about.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
