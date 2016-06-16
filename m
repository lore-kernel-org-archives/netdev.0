From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Thu, 16 Jun 2016 10:55:39 -0700
Message-ID: <20160616175539.lt7iqjrlixagwfbh@f1.synalogic.ca>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aliguori@amazon.com, antoine.tenart@free-electrons.com,
	Ben Hutchings <ben@decadent.org.uk>
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/06/13 11:46, Netanel Belgazal wrote:
[...]
> +
> +static int ena_set_coalesce(struct net_device *net_dev,
> +			    struct ethtool_coalesce *coalesce)
> +{
> +	struct ena_adapter *adapter = netdev_priv(net_dev);
> +	struct ena_com_dev *ena_dev = adapter->ena_dev;
> +	int rc;
> +
> +	if (!ena_com_interrupt_moderation_supported(ena_dev)) {
> +		/* the devie doesn't support interrupt moderation */
> +		return -EOPNOTSUPP;
> +	}
> +
> +	/* Note, adaptive coalescing settings are updated through sysfs */

I believe the usual approach is to use ethtool for these kinds of
settings, extending the interface if necessary.

> +	if (coalesce->rx_coalesce_usecs_irq ||
> +	    coalesce->rx_max_coalesced_frames ||
> +	    coalesce->rx_max_coalesced_frames_irq ||
> +	    coalesce->tx_coalesce_usecs_irq ||
> +	    coalesce->tx_max_coalesced_frames ||
> +	    coalesce->tx_max_coalesced_frames_irq ||
> +	    coalesce->stats_block_coalesce_usecs ||
> +	    coalesce->use_adaptive_tx_coalesce ||
> +	    coalesce->pkt_rate_low ||
> +	    coalesce->rx_coalesce_usecs_low ||
> +	    coalesce->rx_max_coalesced_frames_low ||
> +	    coalesce->tx_coalesce_usecs_low ||
> +	    coalesce->tx_max_coalesced_frames_low ||
> +	    coalesce->pkt_rate_high ||
> +	    coalesce->rx_coalesce_usecs_high ||
> +	    coalesce->rx_max_coalesced_frames_high ||
> +	    coalesce->tx_coalesce_usecs_high ||
> +	    coalesce->tx_max_coalesced_frames_high ||
> +	    coalesce->rate_sample_interval)
> +		return -EINVAL;
> +

[...]

> +
> +static ssize_t ena_store_small_copy_len(struct device *dev,
> +					struct device_attribute *attr,
> +					const char *buf, size_t len)
> +{
> +	struct ena_adapter *adapter = dev_get_drvdata(dev);
> +	unsigned long small_copy_len;
> +	struct ena_ring *rx_ring;
> +	int err, i;
> +
> +	err = kstrtoul(buf, 10, &small_copy_len);
> +	if (err < 0)
> +		return err;
> +
> +	err = ena_validate_small_copy_len(adapter, small_copy_len);
> +	if (err)
> +		return err;
> +
> +	rtnl_lock();
> +	adapter->small_copy_len = small_copy_len;
> +
> +	for (i = 0; i < adapter->num_queues; i++) {
> +		rx_ring = &adapter->rx_ring[i];
> +		rx_ring->rx_small_copy_len = small_copy_len;
> +	}
> +	rtnl_unlock();
> +
> +	return len;
> +}
> +
> +static ssize_t ena_show_small_copy_len(struct device *dev,
> +				       struct device_attribute *attr, char *buf)
> +{
> +	struct ena_adapter *adapter = dev_get_drvdata(dev);
> +
> +	return sprintf(buf, "%d\n", adapter->small_copy_len);
> +}
> +
> +static DEVICE_ATTR(small_copy_len, S_IRUGO | S_IWUSR, ena_show_small_copy_len,
> +		   ena_store_small_copy_len);

This is what many other drivers call (rx_)copybreak. Perhaps it's time
to add it to ethtool as well?
