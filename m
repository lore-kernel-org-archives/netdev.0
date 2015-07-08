From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Wed, 08 Jul 2015 10:38:13 -0600
Message-ID: <559D51F5.4000602@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com> <1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com> <559CED1B.7090008@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	hadi@mojatatu.com, ebiederm@xmission.com, davem@davemloft.net
To: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37161 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934176AbbGHQiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 12:38:16 -0400
Received: by igau2 with SMTP id u2so67725668iga.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 09:38:15 -0700 (PDT)
In-Reply-To: <559CED1B.7090008@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/8/15 3:27 AM, Nicolas Dichtel wrote:
>> +
>> +struct pcpu_dstats {
>> +    u64            tx_pkts;
>> +    u64            tx_bytes;
>> +    u64            tx_drps;
>> +    u64            rx_pkts;
>> +    u64            rx_bytes;
>> +    struct u64_stats_sync    syncp;
>> +};
> Why not using 'struct pcpu_sw_netstats' (dev->tstats), like most virtual
> interfaces? Not sure that it's really needed to have tx_drps per cpu (and
> I don't see anyone using it into this patch).

Alex asked the same question on the first RFC. Shrijeet had opinions on 
why this version versus netdev's. Shrijeet?

-----8<-----

>> +/* queue->lock must be held */
>> +static void __vrf_insert_slave(struct slave_queue *queue, struct
>> slave *slave,
>> +                   struct net_device *master)
>> +{
>> +    struct slave *duplicate_slave = NULL;
>> +
>> +    duplicate_slave = __vrf_find_slave_dev(queue, slave->dev);
>> +    if (duplicate_slave)
>> +        __vrf_kill_slave(queue, duplicate_slave);
> I miss the point here. Why removing the slave if it is already there?

not sure. I'll investigate.

>
>> +
>> +    dev_hold(slave->dev);
>> +    list_add(&slave->list, &queue->all_slaves);
>> +    queue->num_slaves++;
>> +}
>> +
>> +/* netlink lock is assumed here */
> ASSERT_RTNL()?

done.

>
>> +static int vrf_add_slave(struct net_device *dev,
>> +             struct net_device *port_dev)
>> +{
>> +    if (!dev || !port_dev || dev_net(dev) != dev_net(port_dev))
>> +        return -ENODEV;
>> +
>> +    if (!vrf_is_master(port_dev) && !vrf_is_slave(port_dev)) {
>> +        struct slave *s = kzalloc(sizeof(*s), GFP_KERNEL);
>> +        struct net_vrf *vrf = netdev_priv(dev);
>> +        struct slave_queue *queue = &vrf->queue;
>> +        bool is_running = netif_running(port_dev);
>> +        unsigned int flags = port_dev->flags;
>> +        int ret;
>> +
>> +        if (!s)
>> +            return -ENOMEM;
>> +
>> +        s->dev = port_dev;
>> +
>> +        spin_lock_bh(&queue->lock);
>> +        __vrf_insert_slave(queue, s, dev);
>> +        spin_unlock_bh(&queue->lock);
>> +
>> +        port_dev->vrf_ptr = kmalloc(sizeof(*port_dev->vrf_ptr),
>> +                        GFP_KERNEL);
>> +        if (!port_dev->vrf_ptr)
>> +            return -ENOMEM;
>> +
>> +        port_dev->vrf_ptr->ifindex = dev->ifindex;
>> +        port_dev->vrf_ptr->tb_id = vrf->tb_id;
>> +
>> +        /* register the packet handler for slave ports */
>> +        ret = netdev_rx_handler_register(port_dev, vrf_handle_frame,
>> +                         (void *)dev);
> So, it won't be possible to add a slave which already has a
> macvlan or ipvlan (or team?) interface registered.
>

Shrijeet, thoughts?

-----8<-----

>> +
>> +static struct rtnl_link_ops vrf_link_ops __read_mostly = {
>> +    .kind        = DRV_NAME,
>> +    .priv_size      = sizeof(struct net_vrf),
> nit: tabs         ^^^^^^
>> +
>> +    .get_size       = vrf_nl_getsize,
> nit: tabs        ^^^^^^^
>> +    .policy         = vrf_nl_policy,
> nit: tabs      ^^^^^^^^^
>> +    .validate    = vrf_validate,
>> +    .fill_info      = vrf_fillinfo,
> nit: tabs         ^^^^^^
>> +
>> +    .newlink        = vrf_newlink,
> nit: tabs       ^^^^^^^^
>> +    .dellink        = vrf_dellink,
> nit: tabs       ^^^^^^^^
>> +    .setup        = vrf_setup,
>> +    .maxtype        = IFLA_VRF_MAX,
> nit: tabs       ^^^^^^^^
>> +};

ACK on all tab comments; fixed. Ditto for bool on is_tx_frame.

-----8<-----

>> +#if IS_ENABLED(CONFIG_NET_VRF)
>> +static inline int vrf_master_dev_idx(const struct net_device *dev)
>> +{
>> +    int idx = 0;
>> +
>> +    if (dev && dev->vrf_ptr)
>> +        idx = dev->vrf_ptr->ifindex;
>> +
>> +    return idx;
>> +}
>> +
>> +static inline int vrf_get_master_dev_idx(struct net *net, int idx)
> ifindex instead idx for the whole file?

done.

Thanks for the review.

David

PS. comments addressed while consuming a croque-monsieur (my daughter 
just returned from a European trip; loves the sandwich)
