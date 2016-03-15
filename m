From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH] net: ena: Add a driver for Amazon Elastic Network
 Adapters (ENA)
Date: Tue, 15 Mar 2016 10:41:34 -0700
Message-ID: <20160315174133.GA23388@u54ee753d2d1854bda401.ant.amazon.com>
References: <1458039006-19956-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zorik@annapurnalabs.com, saeed@annapurnalabs.com,
	alex@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, antoine.tenart@free-electrons.com
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1458039006-19956-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2016 at 12:50:06PM +0200, Netanel Belgazal wrote:
[...]
> diff --git a/drivers/net/ethernet/amazon/Kconfig b/drivers/net/ethernet/amazon/Kconfig
> new file mode 100644
> index 0000000..bc4f240d
> --- /dev/null
> +++ b/drivers/net/ethernet/amazon/Kconfig
> @@ -0,0 +1,27 @@
> +#
> +# Amazon network device configuration
> +#
> +
> +config NET_VENDOR_AMAZON
> +	bool "Amazon Devices"
> +	default y
> +	---help---
> +	  If you have a network (Ethernet) device belonging to this class, say Y.
> +
> +	  Note that the answer to this question doesn't directly affect the
> +	  kernel: saying N will just cause the configurator to skip all
> +	  the questions about amazon devices. If you say Y, you will be asked
> +	  for your specific device in the following questions.
> +
> +if NET_VENDOR_AMAZON
> +
> +config ENA_ETHERNET
> +	tristate "Elastic Network Adapter (ENA) support"
> +	depends on (PCI_MSI && X86) || COMPILE_TEST

Remove COMPILE_TEST so that the kbuild-all robot won't complain. I
imagine that the drier should work on other systems that have MSI-X...

> +	---help---
> +	  This driver supports Elastic Network Adapter (ENA) adapter"
> +
> +	  To compile this driver as a module, choose M here.
> +	  The module will be called ena.
> +
> +endif #NET_VENDOR_AMAZON

[...]

> diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
> new file mode 100644
> index 0000000..41d7265
> --- /dev/null
> +++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c

[...]

> +static int ena_init_rx_cpu_rmap(struct ena_adapter *adapter)
> +{
> +	u32 i;
> +	int rc;
> +
> +	adapter->netdev->rx_cpu_rmap = alloc_irq_cpu_rmap(adapter->num_queues);
> +	if (!adapter->netdev->rx_cpu_rmap)
> +		return -ENOMEM;
> +	for (i = 0; i < adapter->num_queues; i++) {
> +		int irq_idx = ENA_IO_IRQ_IDX(i);
> +
> +		rc = irq_cpu_rmap_add(adapter->netdev->rx_cpu_rmap,
> +				      adapter->msix_entries[irq_idx].vector);
> +		if (rc) {
> +			free_irq_cpu_rmap(adapter->netdev->rx_cpu_rmap);
> +			adapter->netdev->rx_cpu_rmap = NULL;
> +			return rc;
> +		}
> +	}
> +	return 0;
> +}

This should be in #ifdef CONFIG_RSS_ACCEL (and elsewhere where
netdev->rx_cpu_rmap is touched).

--msw
