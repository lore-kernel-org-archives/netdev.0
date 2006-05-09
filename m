From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual network
	device driver.
Date: Tue, 9 May 2006 13:25:56 -0700
Message-ID: <20060509132556.76deaa91@localhost.localdomain>
References: <20060509084945.373541000@sous-sol.org>
	<20060509085201.446830000@sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, Ian Pratt <ian.pratt@xensource.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
Return-path: <xen-devel-bounces@lists.xensource.com>
To: Chris Wright <chrisw@sous-sol.org>
In-Reply-To: <20060509085201.446830000@sous-sol.org>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

> +static int setup_device(struct xenbus_device *dev, struct
> netfront_info *info) +{
> +	struct netif_tx_sring *txs;
> +	struct netif_rx_sring *rxs;
> +	int err;
> +	struct net_device *netdev = info->netdev;
> +
> +	info->tx_ring_ref = GRANT_INVALID_REF;
> +	info->rx_ring_ref = GRANT_INVALID_REF;
> +	info->rx.sring = NULL;
> +	info->tx.sring = NULL;
> +	info->irq = 0;
> +
> +	txs = (struct netif_tx_sring *)get_zeroed_page(GFP_KERNEL);
> +	if (!txs) {
> +		err = -ENOMEM;
> +		xenbus_dev_fatal(dev, err, "allocating tx ring
> page");
> +		goto fail;
> +	}
> +	rxs = (struct netif_rx_sring *)get_zeroed_page(GFP_KERNEL);
> +	if (!rxs) {
> +		err = -ENOMEM;
> +		xenbus_dev_fatal(dev, err, "allocating rx ring
> page");
> +		free_page((unsigned long)txs);
> +		goto fail;
> +	}
> +	info->backend_state = BEST_DISCONNECTED;
> +
> +	SHARED_RING_INIT(txs);
> +	FRONT_RING_INIT(&info->tx, txs, PAGE_SIZE);
> +
> +	SHARED_RING_INIT(rxs);
> +	FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE);
> +
> +	err = xenbus_grant_ring(dev, virt_to_mfn(txs));
> +	if (err < 0)
> +		goto fail;
> +	info->tx_ring_ref = err;
> +
> +	err = xenbus_grant_ring(dev, virt_to_mfn(rxs));
> +	if (err < 0)
> +		goto fail;
> +	info->rx_ring_ref = err;
> +
> +	err = xenbus_alloc_evtchn(dev, &info->evtchn);
> +	if (err)
> +		goto fail;
> +
> +	memcpy(netdev->dev_addr, info->mac, ETH_ALEN);
> +	network_connect(netdev);
> +	info->irq = bind_evtchn_to_irqhandler(
> +		info->evtchn, netif_int, SA_SAMPLE_RANDOM,
> netdev->name,
> 

This doesn't look like a real random entropy source. packets
arriving from another domain are easily timed.
