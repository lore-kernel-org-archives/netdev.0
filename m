From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Mon, 5 Dec 2011 20:42:25 +0000
Message-ID: <1323117745.2887.31.camel@bwh-desktop>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-12-05 at 16:59 +0800, Jason Wang wrote:
> In order to let the packets of a flow to be passed to the desired
> guest cpu, we can co-operate with devices through programming the flow
> director which was just a hash to queue table.
> 
> This kinds of co-operation is done through the accelerate RFS support,
> a device specific flow sterring method virtnet_fd() is used to modify
> the flow director based on rfs mapping. The desired queue were
> calculated through reverse mapping of the irq affinity table. In order
> to parallelize the ingress path, irq affinity of rx queue were also
> provides by the driver.
> 
> In addition to accelerate RFS, we can also use the guest scheduler to
> balance the load of TX and reduce the lock contention on egress path,
> so the processor_id() were used to tx queue selection.
[...]
> +#ifdef CONFIG_RFS_ACCEL
> +
> +int virtnet_fd(struct net_device *net_dev, const struct sk_buff *skb,
> +	       u16 rxq_index, u32 flow_id)
> +{
> +	struct virtnet_info *vi = netdev_priv(net_dev);
> +	u16 *table = NULL;
> +
> +	if (skb->protocol != htons(ETH_P_IP) || !skb->rxhash)
> +		return -EPROTONOSUPPORT;

Why only IPv4?

> +	table = kmap_atomic(vi->fd_page);
> +	table[skb->rxhash & TAP_HASH_MASK] = rxq_index;
> +	kunmap_atomic(table);
> +
> +	return 0;
> +}
> +#endif

This is not a proper implementation of ndo_rx_flow_steer.  If you steer
a flow by changing the RSS table this can easily cause packet reordering
in other flows.  The filtering should be more precise, ideally matching
exactly a single flow by e.g. VID and IP 5-tuple.

I think you need to add a second hash table which records exactly which
flow is supposed to be steered.  Also, you must call
rps_may_expire_flow() to check whether an entry in this table may be
replaced; otherwise you can cause packet reordering in the flow that was
previously being steered.

Finally, this function must return the table index it assigned, so that
rps_may_expire_flow() works.

> +static u16 virtnet_select_queue(struct net_device *dev, struct sk_buff *skb)
> +{
> +	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
> +					       smp_processor_id();
> +
> +	/* As we make use of the accelerate rfs which let the scheduler to
> +	 * balance the load, it make sense to choose the tx queue also based on
> +	 * theprocessor id?
> +	 */
> +	while (unlikely(txq >= dev->real_num_tx_queues))
> +		txq -= dev->real_num_tx_queues;
> +	return txq;
> +}
[...]

Don't do this, let XPS handle it.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
