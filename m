From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Mon, 06 Jul 2015 10:46:59 -0600
Message-ID: <559AB103.1070603@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com> <1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com> <559AAEE1.2050105@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, hannes@stressinduktion.org,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, ebiederm@xmission.com, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38870 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752212AbbGFQrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 12:47:01 -0400
Received: by igrv9 with SMTP id v9so120022522igr.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 09:47:01 -0700 (PDT)
In-Reply-To: <559AAEE1.2050105@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/15 10:37 AM, Nikolay Aleksandrov wrote:
>> +static int vrf_add_slave(struct net_device *dev,
>> +			 struct net_device *port_dev)
>> +{
>> +	if (!dev || !port_dev || dev_net(dev) != dev_net(port_dev))
>> +		return -ENODEV;
>> +
>> +	if (!vrf_is_master(port_dev) && !vrf_is_slave(port_dev)) {
>> +		struct slave *s = kzalloc(sizeof(*s), GFP_KERNEL);
>> +		struct net_vrf *vrf = netdev_priv(dev);
>> +		struct slave_queue *queue = &vrf->queue;
>> +		bool is_running = netif_running(port_dev);
>> +		unsigned int flags = port_dev->flags;
>> +		int ret;
>> +
>> +		if (!s)
>> +			return -ENOMEM;
>> +
>> +		s->dev = port_dev;
>> +
>> +		spin_lock_bh(&queue->lock);
>> +		__vrf_insert_slave(queue, s, dev);
>> +		spin_unlock_bh(&queue->lock);
>> +
>> +		port_dev->vrf_ptr = kmalloc(sizeof(*port_dev->vrf_ptr),
>> +					    GFP_KERNEL);
>> +		if (!port_dev->vrf_ptr)
>> +			return -ENOMEM;
>                          ^^^^^^^^^
> I believe you'll have a slave in the list with inconsistent state which could
> even lead to null ptr derefernce if vrf_ptr is used, also __vrf_insert_slave
> does dev_hold so the dev refcnt will be incorrect as well.

Right. Good catch, will fix.

>
>> +
>> +		port_dev->vrf_ptr->ifindex = dev->ifindex;
>> +		port_dev->vrf_ptr->tb_id = vrf->tb_id;
>> +
>> +		/* register the packet handler for slave ports */
>> +		ret = netdev_rx_handler_register(port_dev, vrf_handle_frame,
>> +						 (void *)dev);
>> +		if (ret) {
>> +			netdev_err(port_dev,
>> +				   "Device %s failed to register rx_handler\n",
>> +				   port_dev->name);
>> +			kfree(port_dev->vrf_ptr);
>> +			kfree(s);
>> +			return ret;
>                          ^^^^^^^^^^
> The slave is being freed while on the list here, device's refcnt will be wrong etc.

ack. Will fix.

>
>> +		}
>> +
>> +		if (is_running) {
>> +			ret = dev_change_flags(port_dev, flags & ~IFF_UP);
>> +			if (ret < 0)
>> +				goto out_fail;
>> +		}
>> +
>> +		ret = netdev_master_upper_dev_link(port_dev, dev);
>> +		if (ret < 0)
>> +			goto out_fail;
>> +
>> +		if (is_running) {
>> +			ret = dev_change_flags(port_dev, flags);
>> +			if (ret < 0)
>> +				goto out_fail;
>> +		}
>> +
>> +		port_dev->flags |= IFF_SLAVE;
>> +
>> +		return 0;
>> +
>> +out_fail:
>> +		spin_lock_bh(&queue->lock);
>> +		__vrf_kill_slave(queue, s);
>> +		spin_unlock_bh(&queue->lock);
>
> __vrf_kill_slave() doesn't do upper device unlink and the device can be linked
> if we fail in the dev_change_flags above.

will fix.

>
>> +
>> +		return ret;
>> +	}
>> +
>> +	return -EINVAL;
>> +}
> ^^^^
> In my opinion the structure of the above function should change to something more
> straightforward with proper exit labels and cleanup upon failure, also a level of
> indentation can be avoided.

Sure. The indentation comes after the pointer checks so locals can be 
intialized when declared. Will work on the clean up/simplification for 
next rev.

>
>> +
>> +static int vrf_del_slave(struct net_device *dev,
>> +			 struct net_device *port_dev)
>> +{
>> +	struct net_vrf *vrf = netdev_priv(dev);
>> +	struct slave_queue *queue = &vrf->queue;
>> +	struct slave *slave = __vrf_find_slave_dev(queue, port_dev);
>> +	bool is_running = netif_running(port_dev);
>> +	unsigned int flags = port_dev->flags;
>> +	int ret = 0;
>
> ret seems unused/unchecked in this function

It is used but not checked. I struggled with what to do on the error 
path. Do we want netdev_err() on a failure?

>
>> +
>> +	if (!slave)
>> +		return -EINVAL;
>> +
>> +	if (is_running)
>> +		ret = dev_change_flags(port_dev, flags & ~IFF_UP);
>> +
>> +	spin_lock_bh(&queue->lock);
>> +	__vrf_kill_slave(queue, slave);
>> +	spin_unlock_bh(&queue->lock);
>> +
>> +	netdev_upper_dev_unlink(port_dev, dev);
>> +
>> +	if (is_running)
>> +		ret = dev_change_flags(port_dev, flags);
>> +
>> +	return 0;
>> +}
>> +
>> +static int vrf_dev_init(struct net_device *dev)
>> +{
>> +	struct net_vrf *vrf = netdev_priv(dev);
>> +
>> +	spin_lock_init(&vrf->queue.lock);
>> +	INIT_LIST_HEAD(&vrf->queue.all_slaves);
>> +	vrf->queue.master_dev = dev;
>> +
>> +	dev->dstats = netdev_alloc_pcpu_stats(struct pcpu_dstats);
>> +	dev->flags  =  IFF_MASTER | IFF_NOARP;
>> +	if (!dev->dstats)
>> +		return -ENOMEM;
>          ^^^^^
> nit: I'd suggest moving the check after the allocation

agreed.

David
