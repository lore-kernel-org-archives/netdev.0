From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH][6/12][RFC/v1] Add IPoIB (IP-over-InfiniBand) driver
Date: Thu, 18 Nov 2004 20:00:18 +0000
Message-ID: <20041118200017.GA26976@infradead.org>
References: <200411181046.6Dz1IPtDKfpgSXN9@topspin.com> <200411181046.Jj0jsF5E2KmiGN8f@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roland Dreier <roland@topspin.com>
Content-Disposition: inline
In-Reply-To: <200411181046.Jj0jsF5E2KmiGN8f@topspin.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-bk/drivers/infiniband/ulp/ipoib/Makefile	2004-11-18 10:43:32.592783399 -0800
> @@ -0,0 +1,14 @@
> +EXTRA_CFLAGS += -Idrivers/infiniband/include

Please avoid -I statements for kernel code wherever possible.  Just
put the Infiniband Kernel Internal API into $(TOPDIR)/include/infiniband/

> +obj-$(CONFIG_INFINIBAND_IPOIB) += ib_ipoib.o
> +
> +ib_ipoib-objs := \
> +    ipoib_main.o \
> +    ipoib_ib.o \
> +    ipoib_multicast.o \
> +    ipoib_verbs.o \
> +    ipoib_vlan.o
> +
> +ifeq ($(CONFIG_INFINIBAND_IPOIB_DEBUG),y)
> +    ib_ipoib-objs += ipoib_fs.o
> +endif

This should read more like:

ib_ipoib-y					+= ipoib_main.o ipoib_ib.o \
						   ipoib_multicast.o \
						   ipoib_verbs.o ipoib_vlan.o
ib_ipoib-$(CONFIG_INFINIBAND_IPOIB_DEBUG)	+= ipoib_fs.o

obj-$(CONFIG_INFINIBAND_IPOIB)			+= ib_ipoib.o

Also ib_ipoib is a rather strange name, the double ib doesn't make
much sense.

> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available at
> + * <http://www.fsf.org/copyleft/gpl.html>, or the OpenIB.org BSD
> + * license, available in the LICENSE.TXT file accompanying this
> + * software.  These details are also available at
> + * <http://openib.org/license.html>.

Please don't refer to licenses at urls as they can changed easily.
There's a toplevel COPYING file you can reference, and if you want
additional license bits I'd suggets to keep them simple enough to
be in the file header.  Or better just stop the dual-licensing sillyness -
you'll copy code from other parts of the kernel sooner or later that
are GPL-only.

> +#define IPOIB_PATH(neigh) (*(struct ipoib_path **) ((neigh)->ha + 24))

Please make this and inline so you have proper typechecking.
(And give it a less shouting name)

> 
> +
> +extern struct workqueue_struct *ipoib_workqueue;
> +
> +/* list of IPoIB network devices */
> +extern struct semaphore ipoib_device_mutex;
> +extern struct list_head ipoib_device_list;

Please try to avoid global lists.  Looking at the code this is used
in two places:

 (1) the debugging pseudo fs
 (2) ipoib_remove_one

the latter would be much better served with a per ib_device list anyway,
and for (1) there must be a better way than the global list either.

> +			pci_unmap_single(priv->ca->dma_device,
> +					 pci_unmap_addr(&priv->rx_ring[wr_id],
> +							mapping),
> +					 IPOIB_BUF_SIZE,
> +					 PCI_DMA_FROMDEVICE);

Please don't use PCI dma calls in highlevel protocol handlers.  At least
use the dma_* calls or even better restructure the code to avoid dma
mapping outside the HCA driver.
