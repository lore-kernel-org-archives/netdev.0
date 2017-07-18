From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next 2/2] liquidio: Add support to create management
 interface
Date: Tue, 18 Jul 2017 09:47:02 +0300
Message-ID: <20170718064702.GK3259@mtr-leonro.local>
References: <20170717195046.GA1191@felix-thinkpad.cavium.com>
 <20170717195217.GA1222@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="GyRA7555PLgSTuth"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, veerasenareddy.burru@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33974 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751338AbdGRGrG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 02:47:06 -0400
Content-Disposition: inline
In-Reply-To: <20170717195217.GA1222@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GyRA7555PLgSTuth
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 17, 2017 at 12:52:17PM -0700, Felix Manlunas wrote:
> From: VSR Burru <veerasenareddy.burru@cavium.com>
>
> This patch adds support to create a virtual ethernet interface to
> communicate with Linux on LiquidIO adapter for management.
>
> Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
> Signed-off-by: Srinivasa Jampala <Srinivasa.Jampala@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> ---
>  drivers/net/ethernet/cavium/liquidio/Makefile      |   1 +
>  drivers/net/ethernet/cavium/liquidio/lio_main.c    |   6 +
>  .../net/ethernet/cavium/liquidio/liquidio_common.h |   4 +
>  .../net/ethernet/cavium/liquidio/liquidio_mgmt.c   | 397 +++++++++++++++++++++
>  .../net/ethernet/cavium/liquidio/octeon_device.h   |   2 +
>  drivers/net/ethernet/cavium/liquidio/octeon_main.h |   9 +
>  6 files changed, 419 insertions(+)
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/liquidio_mgmt.c
>
> diff --git a/drivers/net/ethernet/cavium/liquidio/Makefile b/drivers/net/ethernet/cavium/liquidio/Makefile
> index c4d411d..2064157 100644
> --- a/drivers/net/ethernet/cavium/liquidio/Makefile
> +++ b/drivers/net/ethernet/cavium/liquidio/Makefile
> @@ -15,6 +15,7 @@ liquidio-$(CONFIG_LIQUIDIO) += lio_ethtool.o \
>  			octeon_mailbox.o   \
>  			octeon_mem_ops.o   \
>  			octeon_droq.o      \
> +			liquidio_mgmt.o      \
>  			octeon_nic.o
>
>  liquidio-objs := lio_main.o octeon_console.o $(liquidio-y)
> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
> index 1508b18..844d7aa 100644
> --- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
> +++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
> @@ -1776,6 +1776,9 @@ static void liquidio_remove(struct pci_dev *pdev)
>
>  	dev_dbg(&oct_dev->pci_dev->dev, "Stopping device\n");
>
> +	if (oct_dev->fw_info.app_cap_flags & LIQUIDIO_MGMT_INTF_CAP)
> +		lio_mgmt_exit(oct_dev);
> +
>  	if (oct_dev->watchdog_task)
>  		kthread_stop(oct_dev->watchdog_task);
>
> @@ -4408,6 +4411,9 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
>  		goto octnet_init_failure;
>  	}
>
> +	if (oct->fw_info.app_cap_flags & LIQUIDIO_MGMT_INTF_CAP)
> +		lio_mgmt_init(oct);
> +
>  	liquidio_ptp_init(oct);
>
>  	dev_dbg(&oct->pci_dev->dev, "Network interfaces ready\n");
> diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
> index fc59eda..a479383 100644
> --- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
> +++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
> @@ -63,6 +63,8 @@ enum octeon_tag_type {
>   */
>  #define OPCODE_CORE 0           /* used for generic core operations */
>  #define OPCODE_NIC  1           /* used for NIC operations */
> +#define OPCODE_MGMT 2           /* used for MGMT operations */
> +
>  /* Subcodes are used by host driver/apps to identify the sub-operation
>   * for the core. They only need to by unique for a given subsystem.
>   */
> @@ -106,6 +108,8 @@ enum octeon_tag_type {
>  #define MAX_IOQ_INTERRUPTS_PER_PF   (64 * 2)
>  #define MAX_IOQ_INTERRUPTS_PER_VF   (8 * 2)
>
> +/* App specific capabilities from firmware to pf driver */
> +#define LIQUIDIO_MGMT_INTF_CAP 0x1
>
>  static inline u32 incr_index(u32 index, u32 count, u32 max)
>  {
> diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_mgmt.c b/drivers/net/ethernet/cavium/liquidio/liquidio_mgmt.c
> new file mode 100644
> index 0000000..b471c21
> --- /dev/null
> +++ b/drivers/net/ethernet/cavium/liquidio/liquidio_mgmt.c
> @@ -0,0 +1,397 @@
> +/**********************************************************************
> + * Author: Cavium, Inc.
> + *
> + * Contact: support@cavium.com
> + *          Please include "LiquidIO" in the subject.
> + *

Does anyone actually follow it? :)

> + * Copyright (c) 2003-2017 Cavium, Inc.
> + *
> + * This file is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License, Version 2, as
> + * published by the Free Software Foundation.
> + *
> + * This file is distributed in the hope that it will be useful, but
> + * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
> + * NONINFRINGEMENT.  See the GNU General Public License for more details.
> + ***********************************************************************/
> +#include <linux/version.h>
> +#include <linux/module.h>
> +#include <linux/crc32.h>
> +#include <linux/dma-mapping.h>
> +#include <linux/pci.h>
> +#include <linux/pci_ids.h>
> +#include <linux/ip.h>
> +#include <net/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/net_tstamp.h>
> +#include <linux/if_vlan.h>
> +#include <linux/firmware.h>
> +#include <linux/ethtool.h>
> +#include <linux/types.h>
> +#include <linux/list.h>
> +#include <linux/workqueue.h>
> +#include <linux/interrupt.h>
> +#include "octeon_config.h"
> +#include "liquidio_common.h"
> +#include "octeon_droq.h"
> +#include "octeon_iq.h"
> +#include "response_manager.h"
> +#include "octeon_device.h"
> +#include "octeon_nic.h"
> +#include "octeon_main.h"
> +#include "octeon_network.h"
> +
> +#define OPCODE_MGMT_PKT_DATA   0x10
> +
> +struct lio_mgmt {
> +	atomic_t ifstate;
> +	struct net_device *parent_netdev;
> +	struct octeon_device *oct_dev;
> +	struct net_device *netdev;
> +	u64 dev_capability;
> +	struct oct_link_info linfo;
> +	u32 intf_open;
> +};
> +
> +struct lio_mgmt_rx_pkt {
> +	struct list_head list;
> +	struct sk_buff *skb;
> +};
> +
> +#define LIO_MGMT_SIZE (sizeof(struct lio_mgmt))
> +#define GET_LIO_MGMT(netdev)  ((struct lio_mgmt *)netdev_priv(netdev))
> +
> +/**
> + * \brief Stop Tx queues
> + * @param netdev network device
> + */
> +static inline void txqs_stop(struct net_device *netdev)
> +{

No inline functions in *.c files please.

> +	if (netif_is_multiqueue(netdev)) {
> +		int i;
> +
> +		for (i = 0; i < netdev->num_tx_queues; i++)
> +			netif_stop_subqueue(netdev, i);
> +	} else {
> +		netif_stop_queue(netdev);
> +	}
> +}
> +
> +/**
> + * \brief Start Tx queues
> + * @param netdev network device
> + */
> +static inline void txqs_start(struct net_device *netdev)
> +{

As above.

> +	if (netif_is_multiqueue(netdev)) {
> +		int i;
> +
> +		for (i = 0; i < netdev->num_tx_queues; i++)
> +			netif_start_subqueue(netdev, i);
> +	} else {
> +		netif_start_queue(netdev);
> +	}
> +}
> +
> +/**
> + * \brief Stop Tx queue
> + * @param netdev network device
> + */
> +static void stop_txq(struct net_device *netdev)
> +{
> +	txqs_stop(netdev);
> +}
> +

The function above and below are useless.

> +/**
> + * \brief Start Tx queue
> + * @param netdev network device
> + */
> +static void start_txq(struct net_device *netdev)
> +{
> +	txqs_start(netdev);
> +}
> +
> +static int lio_mgmt_open(struct net_device *netdev)
> +{
> +	struct lio_mgmt *lio_mgmt = GET_LIO_MGMT(netdev);
> +
> +	ifstate_set((struct lio *)lio_mgmt, LIO_IFSTATE_RUNNING);
> +	netif_carrier_on(netdev);
> +
> +	start_txq(netdev);
> +
> +	/* Ready for link status updates */
> +	lio_mgmt->intf_open = 1;
> +
> +	return 0;
> +}
> +
> +/**
> + * \brief Net device stop for LiquidIO
> + * @param netdev network device
> + */
> +static int lio_mgmt_stop(struct net_device *netdev)
> +{
> +	struct lio_mgmt *lio_mgmt = GET_LIO_MGMT(netdev);
> +
> +	ifstate_reset((struct lio *)lio_mgmt, LIO_IFSTATE_RUNNING);
> +
> +	netif_tx_disable(netdev);
> +
> +	/* Inform that netif carrier is down */
> +	netif_carrier_off(netdev);
> +	lio_mgmt->intf_open = 0;
> +
> +	return 0;
> +}
> +
> +static void packet_sent_callback(struct octeon_device *oct,
> +				 u32 status, void *buf)
> +{
> +	struct octeon_soft_command *sc = (struct octeon_soft_command *)buf;
> +	struct sk_buff *skb = sc->ctxptr;
> +
> +	dma_unmap_single(&oct->pci_dev->dev, sc->dmadptr,
> +			 sc->datasize, DMA_TO_DEVICE);
> +	dev_kfree_skb_any(skb);
> +	kfree(sc);
> +}
> +
> +/** \brief Transmit networks packets to the Octeon interface
> + * @param skbuff   skbuff struct to be passed to network layer.
> + * @param netdev    pointer to network device
> + * @returns whether the packet was transmitted to the device okay or not
> + *             (NETDEV_TX_OK or NETDEV_TX_BUSY)
> + */
> +static int lio_mgmt_xmit(struct sk_buff *skb, struct net_device *netdev)
> +{
> +	struct octeon_soft_command *sc = NULL;
> +	struct octeon_instr_pki_ih3 *pki_ih3;
> +	struct lio_mgmt *lio_mgmt;
> +	struct lio *parent_lio;
> +	int status;
> +
> +	lio_mgmt = GET_LIO_MGMT(netdev);
> +	parent_lio = GET_LIO(lio_mgmt->parent_netdev);
> +
> +	/* Check for all conditions in which the current packet cannot be
> +	 * transmitted.
> +	 */
> +	if (!(atomic_read(&lio_mgmt->ifstate) & LIO_IFSTATE_RUNNING) ||
> +	    (skb->len <= 0) || (skb->len > OCTNET_DEFAULT_FRM_SIZE)) {
> +		goto lio_xmit_failed;
> +	}

It is worth to revise the check above, skb->len is unsigned int and it
can't be below zero.

> +
> +	if (octnet_iq_is_full(lio_mgmt->oct_dev, parent_lio->txq)) {
> +		/* defer sending if queue is full */
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	if (skb_shinfo(skb)->nr_frags == 0) {

No need to write explicitly 0.

> +		sc = kzalloc(sizeof(*sc), GFP_ATOMIC);
> +		if (!sc)
> +			goto lio_xmit_failed;

I see that you are kfree it in case of error, but who will release it in
case of success?

> +
> +		sc->dmadptr = dma_map_single(&lio_mgmt->oct_dev->pci_dev->dev,
> +					     skb->data,
> +					     skb->len, DMA_TO_DEVICE);
> +		if (dma_mapping_error
> +		    (&lio_mgmt->oct_dev->pci_dev->dev, sc->dmadptr)) {
> +			kfree(sc);
> +			return NETDEV_TX_BUSY;
> +		}
> +		sc->virtdptr = skb->data;
> +		sc->datasize = skb->len;
> +		sc->ctxptr = skb;	/* to be freed in sent callback */
> +		sc->dmarptr = 0;
> +		sc->rdatasize = 0;
> +		sc->iq_no = parent_lio->txq;	/* default input queue */
> +		octeon_prepare_soft_command(lio_mgmt->oct_dev, sc, OPCODE_MGMT,
> +					    OPCODE_MGMT_PKT_DATA, 0, 0,
> +					    0);
> +
> +		/*prepare softcommand uses ATOMIC TAG, change it to ORDERED */
> +		pki_ih3 = (struct octeon_instr_pki_ih3 *)&sc->cmd.cmd3.pki_ih3;
> +		pki_ih3->tag = LIO_DATA((lio_mgmt->oct_dev->instr_queue
> +					[sc->iq_no]->txpciq.s.port));
> +		pki_ih3->tagtype = ORDERED_TAG;
> +
> +		sc->callback = packet_sent_callback;
> +		sc->callback_arg = sc;
> +		status = octeon_send_soft_command(lio_mgmt->oct_dev, sc);
> +		if (status == IQ_SEND_FAILED) {
> +			dma_unmap_single(&lio_mgmt->oct_dev->pci_dev->dev,
> +					 sc->dmadptr, sc->datasize,
> +					 DMA_TO_DEVICE);
> +			kfree(sc);
> +			goto lio_xmit_failed;
> +		}
> +
> +		if (status == IQ_SEND_STOP)
> +			stop_txq(netdev);
> +	} else {
> +		goto lio_xmit_failed;
> +	}
> +
> +	netdev->stats.tx_packets++;
> +	netdev->stats.tx_bytes += skb->len;
> +
> +	return NETDEV_TX_OK;
> +
> +lio_xmit_failed:
> +	netdev->stats.tx_dropped++;
> +	dev_kfree_skb_any(skb);
> +	return NETDEV_TX_OK;
> +}
> +
> +static int lio_mgmt_rx(struct octeon_recv_info *recv_info, void *arg)
> +{
> +	struct octeon_device *octdev = (struct octeon_device *)arg;
> +	struct octeon_recv_pkt *recv_pkt = recv_info->recv_pkt;
> +	struct lio_mgmt *lio_mgmt;
> +	struct net_device *netdev;
> +	unsigned int pkt_size = 0;
> +	unsigned char *pkt_ptr;
> +	struct sk_buff *skb;
> +	int i;
> +
> +	netdev = (struct net_device *)octdev->mgmt_ctx;
> +	lio_mgmt = GET_LIO_MGMT(netdev);
> +	/* Do not proceed if the interface is not in RUNNING state. */
> +	if (!ifstate_check((struct lio *)lio_mgmt, LIO_IFSTATE_RUNNING))
> +		goto fail;
> +
> +	/* Not handling more than one buffer */
> +	if (recv_pkt->buffer_count > 1)
> +		goto fail;
> +
> +	pkt_size = recv_pkt->buffer_size[0] - OCT_DROQ_INFO_SIZE;
> +	pkt_ptr = get_rbd(recv_pkt->buffer_ptr[0]) + OCT_DROQ_INFO_SIZE;
> +
> +	skb = netdev_alloc_skb_ip_align(netdev, pkt_size);
> +	if (!skb)
> +		goto fail;
> +
> +	skb_copy_to_linear_data(skb, pkt_ptr, pkt_size);
> +
> +	skb_put(skb, pkt_size);
> +	netdev->stats.rx_packets++;
> +	netdev->stats.rx_bytes += skb->len;
> +
> +	skb->dev = netdev;
> +	skb->protocol = eth_type_trans(skb, skb->dev);
> +	netif_receive_skb(skb);
> +
> +fail:
> +	for (i = 0; i < recv_pkt->buffer_count; i++)
> +		recv_buffer_free(recv_pkt->buffer_ptr[i]);
> +
> +	octeon_free_recv_info(recv_info);
> +
> +	return 0;
> +}
> +
> +const struct net_device_ops liocomdevops = {
> +	.ndo_open = lio_mgmt_open,
> +	.ndo_stop = lio_mgmt_stop,
> +	.ndo_start_xmit = lio_mgmt_xmit,
> +};
> +
> +static int __lio_mgmt_init(struct octeon_device *octdev)
> +{
> +	struct lio_mgmt *lio_mgmt = NULL;
> +	struct net_device *netdev;
> +	struct lio *parent_lio;
> +
> +	/* Register netdev only for pf 0 */
> +	if (octdev->pf_num == 0) {
> +		netdev = alloc_etherdev(LIO_MGMT_SIZE);
> +		if (!netdev) {
> +			dev_err(&octdev->pci_dev->dev, "Mgmt: Device allocation failed\n");
> +			goto nic_dev_fail;
> +		}
> +
> +		/* SET_NETDEV_DEV(netdev, &octdev->pci_dev->dev); */
> +		netdev->netdev_ops = &liocomdevops;
> +
> +		lio_mgmt = GET_LIO_MGMT(netdev);
> +		memset(lio_mgmt, 0, LIO_MGMT_SIZE);
> +		lio_mgmt->oct_dev = octdev;
> +
> +		/*use ifidx zero of pf */
> +		lio_mgmt->parent_netdev = octdev->props[0].netdev;
> +		parent_lio = GET_LIO(lio_mgmt->parent_netdev);
> +
> +		lio_mgmt->dev_capability = NETIF_F_HIGHDMA;
> +
> +		netdev->vlan_features = lio_mgmt->dev_capability;
> +		netdev->features = lio_mgmt->dev_capability;
> +		netdev->hw_features = lio_mgmt->dev_capability;
> +
> +		lio_mgmt->linfo = parent_lio->linfo;
> +		eth_hw_addr_random(netdev);
> +
> +		/* Register the network device with the OS */
> +		if (register_netdev(netdev)) {
> +			dev_err(&octdev->pci_dev->dev, "Mgmt: Device registration failed\n");
> +			goto nic_dev_fail;
> +		}
> +
> +		netif_carrier_on(netdev);
> +		ifstate_set((struct lio *)lio_mgmt, LIO_IFSTATE_REGISTERED);
> +		/*  Register RX dispatch function */
> +		if (octeon_register_dispatch_fn(octdev, OPCODE_MGMT,
> +						OPCODE_MGMT_PKT_DATA,
> +						lio_mgmt_rx, octdev)) {
> +			goto nic_dev_fail;
> +		}
> +		octdev->mgmt_ctx = (void *)netdev;
> +	}
> +
> +	return 0;
> +
> +nic_dev_fail:
> +	if (netdev) {
> +		struct lio_mgmt *lio_mgmt = GET_LIO_MGMT(netdev);
> +
> +		if (atomic_read(&lio_mgmt->ifstate) &
> +		    LIO_IFSTATE_REGISTERED)
> +			unregister_netdev(netdev);
> +
> +		free_netdev(netdev);
> +	}
> +
> +	return -ENOMEM;
> +}
> +
> +static void __lio_mgmt_exit(struct octeon_device *octdev)
> +{
> +	struct net_device *netdev = (struct net_device *)octdev->mgmt_ctx;
> +	struct lio_mgmt *lio_mgmt;
> +
> +	if (netdev) {
> +		lio_mgmt = GET_LIO_MGMT(netdev);
> +
> +		if (atomic_read(&lio_mgmt->ifstate) & LIO_IFSTATE_RUNNING)
> +			txqs_stop(netdev);
> +
> +		if (atomic_read(&lio_mgmt->ifstate) &
> +		    LIO_IFSTATE_REGISTERED)
> +			unregister_netdev(netdev);
> +
> +		free_netdev(netdev);
> +		octdev->mgmt_ctx = NULL;
> +	}
> +	pr_info("LiquidIO management module is now unloaded\n");
> +}
> +
> +int lio_mgmt_init(struct octeon_device *octdev)
> +{
> +	return __lio_mgmt_init(octdev);
> +}
> +
> +void lio_mgmt_exit(struct octeon_device *octdev)
> +{
> +	__lio_mgmt_exit(octdev);
> +}

Those function are pointless too. There is no need to create almost
empty functions.

> diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
> index c90ed48..3737e47d 100644
> --- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
> +++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
> @@ -552,6 +552,8 @@ struct octeon_device {
>  	} loc;
>
>  	atomic_t *adapter_refcount; /* reference count of adapter */
> +
> +	void *mgmt_ctx; /* pointer to management context */
>  };
>
>  #define  OCT_DRV_ONLINE 1
> diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
> index 7ccffbb..e29190a 100644
> --- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
> +++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
> @@ -198,4 +198,13 @@ sleep_timeout_cond(wait_queue_head_t *wait_queue,
>  #define ROUNDUP128(val) (((val) + 127) & 0xffffff80)
>  #endif
>
> +/* Initializes the LiquidIO management interface module
> + * @param octdev - octeon device pointer
> + * @returns 0 if init is success, -1 otherwise
> + */
> +int lio_mgmt_init(struct octeon_device *octdev);
> +
> +/* De-initializes the LiquidIO management interface module */
> +void lio_mgmt_exit(struct octeon_device *octdev);
> +

You are not calling to this functions outside octeon_main.c file and
hence no need to put it it header file.

>  #endif /* _OCTEON_MAIN_H_ */
> --
> 2.9.0
>

--GyRA7555PLgSTuth
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlltruYACgkQ5GN7iDZy
WKc/yQ//eQmlWzCixGBskN1otl/Ekv2TLxZsqk738m+odgtTvAPnyZ/wywRVYj4j
dmbBJ25XMPLxE1Dtsb62y2sJWA7DQoxN0Ht35DF5//EdYSoWGZkAZkI7cboTW6bu
2SI81W79KMFofkk25TplA7JP8+rOx9nNfVLYLcB7oiy+J4M+ervHrFk6YQWtPJyF
V6/IlZOfKNCWF7r+5PT+zd1eLonnr7lMc8SBuq29X6VaL/OSyXZNRplri3/Q3lKg
jPh0V2M0GWQ8GsczCaPsLyGAiITDmTLrm3yZbbVyo6TC1MzoK7JCSN8+fUFltDcf
xreHII3p0PgqviEfXtuepfW7enrcAyaMbNSwdJYNN/sMimnXLrwvhyDIB8pws3kH
2v4xFdzUFyZc3oSF9wzcSGH4tKHY3en5aYOoKbktzDTx5eG1MPHb/vXgWEoyQnYt
h0p5O1Gsm1fNQzKItGCnmrsNc9bHjlPmOs0lTD0HWRVuSpzEWoFSHV3I/6CEBrWb
lloQPLEaKyKHlXW9hZgCkJh5N0Wd3gwmEf4HXAdaInbUICqdevCYCzUrHa0KsVMf
PwoSseTEcLr5IF4DEiWFMkoIoLAr/4ORHFLk/JnPQbsgZgNKu53OdkgUFZxKOKRS
uIfp99KLThIy58YeMIzD5dxI0I12PY5F7Z4Cz1WXeEzZNt3ef34=
=rFfL
-----END PGP SIGNATURE-----

--GyRA7555PLgSTuth--
