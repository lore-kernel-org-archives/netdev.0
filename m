From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: vxlan: use custom ndo_change_mtu handler
Date: Tue, 17 Dec 2013 19:18:09 +0100
Message-ID: <52B09561.8040404@redhat.com>
References: <1387286409-1783-1-git-send-email-dborkman@redhat.com> <20131217093640.63220542@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shahed.shaikh@qlogic.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755993Ab3LQSSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 13:18:21 -0500
In-Reply-To: <20131217093640.63220542@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 06:36 PM, Stephen Hemminger wrote:
> On Tue, 17 Dec 2013 14:20:09 +0100
> Daniel Borkmann <dborkman@redhat.com> wrote:
>
>> +static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
>> +{
>> +	struct net *net = current->nsproxy->net_ns;
>> +	struct vxlan_dev *vxlan = netdev_priv(dev);
>> +	struct vxlan_rdst *dst = &vxlan->default_dst;
>> +	bool is_ipv6 = dst->remote_ip.sa.sa_family == AF_INET6;
>> +	int hroom = is_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM;
>> +	struct net_device *lowerdev;
>> +
>> +	lowerdev = dev_get_by_index(net, dst->remote_ifindex);
>> +	if (lowerdev == NULL)
>> +		return eth_change_mtu(dev, new_mtu);
>> +
>> +	if (new_mtu == lowerdev->mtu)
>> +		new_mtu = lowerdev->mtu - hroom;
>> +	if (new_mtu < 68 || new_mtu > lowerdev->mtu - hroom) {
>> +		dev_put(lowerdev);
>> +		return -EINVAL;
>> +	}
>> +
>> +	dev->mtu = new_mtu;
>> +
>> +	dev_put(lowerdev);
>> +	return 0;
>> +}
>> +
>
> The *net should just be devnet(dev).
>
> Don't need ref here, called under RTNL.
>
> You can't arbitrarly shrink user's requested mtu
>
> Minor nit picking: I don't like adding more local flag variables.
> To me it is clearer.

Ok, will send a v2 with your feedback incorporated.

Thanks a lot Stephen!

> The resulting function is:
>
>
> static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
> {
> 	struct vxlan_dev *vxlan = netdev_priv(dev);
> 	int maxmtu;
> 	struct net_device *lowerdev;
>
> 	lowerdev = __dev_get_by_index(devnet(dev),
> 				      vxlan->default_dst.remote_ifindex);
> 	if (lowerdev == NULL)
> 		return eth_change_mtu(dev, new_mtu);
>
> 	if (dst->remote_ip.sa.sa_family == AF_INET6)
> 		maxmtu = lowerdev->mtu - VXLAN6_HEADROOM;
> 	else
> 		maxmtu = lowerdev->mtu - VXLAN_HEADROOM;
>
> 	if (new_mtu < 68 || new_mtu > maxmtu)
> 		return -EINVAL;
>
> 	dev->mtu = new_mtu;
> 	return 0;
> }
>
>
