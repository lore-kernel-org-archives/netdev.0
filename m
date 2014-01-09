From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net 1/2] macvlan: forbid L2 fowarding offload for macvtap
Date: Thu, 09 Jan 2014 16:55:07 +0800
Message-ID: <52CE63EB.5000109@redhat.com>
References: <52CA5CDA.1020503@gmail.com> <52CA612D.2000902@redhat.com> <20140106122628.GA24280@hmsreliant.think-freely.org> <52CB7009.2030903@redhat.com> <52CB8D54.9090506@gmail.com> <52CB9D1A.1050101@redhat.com> <52CBAC2A.90005@intel.com> <52CBC22D.3050002@redhat.com> <20140108125528.GC14741@redhat.com> <52CDA186.1080601@gmail.com> <20140109071721.GD19559@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140109071721.GD19559@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/2014 03:17 PM, Michael S. Tsirkin wrote:
> On Wed, Jan 08, 2014 at 11:05:42AM -0800, John Fastabend wrote:
>> [...]
>>
>>>>> OK I think I'm finally putting all the pieces together thanks.
>>>>>
>>>>> Do you know why macvtap is setting dev->tx_queue_len by default? If you
>>>>> zero this then the noqueue_qdisc is used and the q->enqueue check in
>>>>> dev_queue_xmit will fail.
>>>> It was introduced in commit 8a35747a5d13b99e076b0222729e0caa48cb69b6
>>>> ("macvtap: Limit packet queue length") to limit the length of socket
>>>> receive queue of macvtap. But I'm not sure whether the qdisc is a
>>>> byproduct of this commit, maybe we can switch to use another name
>>>> instead of just reuse dev->tx_queue_length.
>>> You mean tx_queue_len really, right?
>>>
>>> Problem is tx_queue_len can be accessed using netlink sysfs or ioctl,
>>> so if someone uses these to control or check the # of packets that
>>> can be queued by device, this will break.
>>>
>>> How about adding ndo_set_tx_queue_len then?
>>>
>>> At some point we wanted to decouple queue length from tx_queue_length
>>> for tun as well, so that would be benefitial there as well.
>> On the receive side we need to limit the receive queue and the
>> dev->tx_queue_len value was used to do this.
>>
>> However on the tx side when dev->tx_queue_len is set the default
>> qdisc pfifo_fast or mq is used depending on if there is multiqueue
>> or not. Unless the user specifies some numtxqueues when creating
>> the macvtap device then it will be a single queue device and use
>> the pfifo_fast qdisc.
>>
>> This is the default behaviour users could zero txqueuelen when
>> they create the device because it is a stacked device with
>> NETIF_F_LLTX using the lower devices qdisc makes sense but this
>> would appear (from code inspection) to break macvtap_forward()?
>>
>>         if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
>>                 goto drop;
>>
>> I'm not sure any of this is a problem other than its a bit
>> confusing to overload tx_queue_len for the rx_queue_len but the
>> precedent has been there for sometime.
> So how about ndo ops to access tx_queue_len then?
> This way we can set tx_queue_len to 0 and use some
> other field to store the rx_queue_len without users noticing.
> Along the lines of the below (it's a partial patch just
> to give you the idea):
>
> diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
> index 5b7d0e1..e526b46 100644
> --- a/net/core/dev_ioctl.c
> +++ b/net/core/dev_ioctl.c
> @@ -167,7 +167,10 @@ static int dev_ifsioc_locked(struct net *net, struct ifreq *ifr, unsigned int cm
>  		return 0;
>  
>  	case SIOCGIFTXQLEN:
> -		ifr->ifr_qlen = dev->tx_queue_len;
> +		if (dev->netdev_ops->ndo_get_tx_queue_len)
> +			ifr->ifr_qlen = dev->netdev_ops->ndo_get_tx_queue_len(dev);
> +		else
> +			ifr->ifr_qlen = dev->tx_queue_len;
>  		return 0;
>  
>  	default:
> @@ -296,7 +299,10 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
>  	case SIOCSIFTXQLEN:
>  		if (ifr->ifr_qlen < 0)
>  			return -EINVAL;
> -		dev->tx_queue_len = ifr->ifr_qlen;
> +		if (dev->netdev_ops->ndo_set_tx_queue_len)
> +			dev->netdev_ops->ndo_set_tx_queue_len(dev, ifr->ifr_qlen);
> +		else
> +			dev->tx_queue_len = ifr->ifr_qlen;
>  		return 0;
>  
>  	case SIOCSIFNAME:
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index d954b56..f2fd9d5 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -280,10 +280,31 @@ NETDEVICE_SHOW_RW(flags, fmt_hex);
>  
>  static int change_tx_queue_len(struct net_device *net, unsigned long new_len)
>  {
> -	net->tx_queue_len = new_len;
> +	if (dev->netdev_ops->ndo_set_tx_queue_len)
> +		dev->netdev_ops->ndo_set_tx_queue_len(dev, new_len);
> +	else
> +		dev->tx_queue_len = new_len;
>  	return 0;
>  }
>  
> +static ssize_t format_tx_queue_len(const struct net_device *net, char *buf)
> +{
> +	unsigned long tx_queue_len;
> +
> +	if (dev->netdev_ops->ndo_get_tx_queue_len)
> +		tx_queue_len = dev->netdev_ops->ndo_get_tx_queue_len(dev);
> +	else
> +		tx_queue_len = dev->tx_queue_len;
> +
> +	return sprintf(buf, fmt_ulong, tx_queue_len);
> +}
> +
> +static ssize_t tx_queue_len_show(struct device *dev,
> +				 struct device_attribute *attr, char *buf)
> +{
> +	return netdev_show(dev, attr, buf, format_tx_queue_len);
> +}
> +
>  static ssize_t tx_queue_len_store(struct device *dev,
>  				  struct device_attribute *attr,
>  				  const char *buf, size_t len)
> @@ -293,7 +314,7 @@ static ssize_t tx_queue_len_store(struct device *dev,
>  
>  	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
>  }
> -NETDEVICE_SHOW_RW(tx_queue_len, fmt_ulong);
> +DEVICE_ATTR_RW(tx_queue_len);
>  
>  static ssize_t ifalias_store(struct device *dev, struct device_attribute *attr,
>  			     const char *buf, size_t len)
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 2a0e21d..9276e17 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -876,6 +876,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  	struct nlattr *attr, *af_spec;
>  	struct rtnl_af_ops *af_ops;
>  	struct net_device *upper_dev = netdev_master_upper_dev_get(dev);
> +	unsigned long tx_queue_len;
>  
>  	ASSERT_RTNL();
>  	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
> @@ -890,8 +891,13 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  	ifm->ifi_flags = dev_get_flags(dev);
>  	ifm->ifi_change = change;
>  
> +	if (dev->netdev_ops->ndo_get_tx_queue_len)
> +		tx_queue_len = dev->netdev_ops->ndo_get_tx_queue_len(dev);
> +	else
> +		tx_queue_len = dev->tx_queue_len;
> +
>  	if (nla_put_string(skb, IFLA_IFNAME, dev->name) ||
> -	    nla_put_u32(skb, IFLA_TXQLEN, dev->tx_queue_len) ||
> +	    nla_put_u32(skb, IFLA_TXQLEN, tx_queue_len) ||
>  	    nla_put_u8(skb, IFLA_OPERSTATE,
>  		       netif_running(dev) ? dev->operstate : IF_OPER_DOWN) ||
>  	    nla_put_u8(skb, IFLA_LINKMODE, dev->link_mode) ||
> @@ -1453,8 +1459,14 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  		modified = 1;
>  	}
>  
> -	if (tb[IFLA_TXQLEN])
> -		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
> +	if (tb[IFLA_TXQLEN]) {
> +		u32 new_len = nla_get_u32(tb[IFLA_TXQLEN]);
> +
> +		if (dev->netdev_ops->ndo_set_tx_queue_len)
> +			dev->netdev_ops->ndo_set_tx_queue_len(dev, new_len);
> +		else
> +			dev->tx_queue_len = new_len;
> +	}
>  
>  	if (tb[IFLA_OPERSTATE])
>  		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
> @@ -1692,8 +1704,14 @@ struct net_device *rtnl_create_link(struct net *net,
>  	if (tb[IFLA_BROADCAST])
>  		memcpy(dev->broadcast, nla_data(tb[IFLA_BROADCAST]),
>  				nla_len(tb[IFLA_BROADCAST]));
> -	if (tb[IFLA_TXQLEN])
> -		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
> +	if (tb[IFLA_TXQLEN]) {
> +		u32 new_len = nla_get_u32(tb[IFLA_TXQLEN]);
> +
> +		if (dev->netdev_ops->ndo_set_tx_queue_len)
> +			dev->netdev_ops->ndo_set_tx_queue_len(dev, new_len);
> +		else
> +			dev->tx_queue_len = new_len;
> +	}
>  	if (tb[IFLA_OPERSTATE])
>  		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
>  	if (tb[IFLA_LINKMODE])
>
> Anyone objects?

What if use do want a qdisc and want to change the its queue length for
tun/macvlan? And the the name tx_queue_length is misleading. For tun it
may make sense since it was used in transmission path. For macvtap it
was not. So maybe what we need is just a new ioctl for both tun/macvtap
and a new feature flag. If user create the device with new feature flag,
the socket receive queue length could be changed by ioctl instead of
dev->tx_queue_length. If not, the old behaviour could be kept.
>> It is a change in behaviour
>> though in net-next. Previously dev_queue_xmit() was not used so
>> the qdisc layer was never hit on the macvtap device. Now with
>> dev_queue_xmit() if the user attaches multiple macvlan queues to a
>> single qdisc queue this should still work but wont be optimal. Ideally
>> the user should create as many qdisc queues at creation time via
>> numtxqueues as macvtap queues will be used during runtime so that there
>> is a 1:1 mapping or use some heuristic to avoid cases where there
>> is a many to 1 mapping.
>>
>> From my perspective it would be OK to push this configuration/policy
>> to the management layer. After all it is the entity that knows how
>> to distribute system resources amongst the objects running over the
>> macvtap devices. The relevance for me is I defaulted the l2 offloaded
>> macvlans to single queue devices and wanted to note in net-next this
>> is the same policy used in the non-offloaded case.
>>
>> Bit long-winded there.
>>
>> Thanks,
>> John
> I think it's a real problem you are pointing out - a performance
> regression for multiqueue devices.
> If we really think no qdisc is typically the right thing to do, 
> we should just make it the default I think, but I agree
> just making tx_queue_len 0 doesn't work without other changes.
>
> What do others think about extra ndo ops so devices can decouple
> the internal tx_queue_len from the userspace-visible value?
>
>
