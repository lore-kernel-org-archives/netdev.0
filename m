From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 05/11] Phonet: Netlink interface
Date: Tue, 23 Sep 2008 14:10:02 +0200
Message-ID: <20080923121002.GQ20815@postel.suug.ch>
References: <200809221845.54736.remi.denis-courmont@nokia.com> <1222098445-26175-5-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:45389 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178AbYIWMJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 08:09:41 -0400
Content-Disposition: inline
In-Reply-To: <1222098445-26175-5-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

* R?mi Denis-Courmont <remi.denis-courmont@nokia.com> 2008-09-22 18:47
> +static int newaddr_doit(struct sk_buff *skb, struct nlmsghdr *nlm, void *attr)
> +{
> +	struct rtattr **rta = attr;
> +	struct ifaddrmsg *ifm = NLMSG_DATA(nlm);
> +	struct net_device *dev;
> +	int err;
> +	u8 pnaddr;
> +
> +	if (!capable(CAP_SYS_ADMIN))
> +		return -EPERM;
> +
> +	ASSERT_RTNL();
> +
> +	if (rta[IFA_LOCAL - 1] == NULL)
> +		return -EINVAL;

Please do not use the old attribute buffer anymore. It's use is racy
ever since we started dropping the rtnl semaphore in order to load
modules. It would be safe in this particular case but it shouldn't be
used for new code.

Take a look at rtnl_setlink() for an example on how to use the interface
correctly.

> +	memcpy(&pnaddr, RTA_DATA(rta[IFA_LOCAL - 1]), 1);

This is not safe, the attribute payload needs to be verified before its
use.

Please use the new netlink interface, all functions named RTA_ or rattr_
are deprecated. The new interface provides a trivial method to validate
attributes while they are being parsed.

> +static int fill_addr(struct sk_buff *skb, struct net_device *dev, u8 addr,
> +			u32 pid, u32 seq, int event)
> +{
> +	struct ifaddrmsg *ifm;
> +	struct nlmsghdr *nlh;
> +	unsigned int orig_len = skb->len;
> +
> +	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(struct ifaddrmsg));
> +	ifm = NLMSG_DATA(nlh);

Please use nlmsg_put() and nlmsg_data()

> +	ifm->ifa_family = AF_PHONET;
> +	ifm->ifa_prefixlen = 0;
> +	ifm->ifa_flags = IFA_F_PERMANENT;
> +	ifm->ifa_scope = RT_SCOPE_HOST;
> +	ifm->ifa_index = dev->ifindex;
> +	RTA_PUT(skb, IFA_LOCAL, 1, &addr);
> +	nlh->nlmsg_len = skb->len - orig_len;

See rtnl_fill_ifinfo() for an example.
