From: Pradeep Dalvi <pradeep@linsyssoft.com>
Subject: Re: [PATCH 4/9] Resending NetXen 1G/10G NIC driver patch
Date: Fri, 26 May 2006 14:18:53 +0000
Message-ID: <1148653134.3453.106.camel@arya.linsyssoft.com>
References: <Pine.LNX.4.33.0605250352170.5844-100000@unmsrvr>
Reply-To: pradeep@linsyssoft.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sanjeev Jorapur <sanjeev@netxen.com>,
	UNM Project Staff <unmproj@linsyssoft.com>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:11370 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP
	id S1750820AbWEZOfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 10:35:18 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.33.0605250352170.5844-100000@unmsrvr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.16.18/drivers/net/netxen/netxen_nic_hw.c
linux-2.6.16.18/drivers/net/netxen/netxen_nic_hw.c
--- linux-2.6.16.18/drivers/net/netxen/netxen_nic_hw.c  2006-05-25
02:43:22.000000000 -0700
+++ linux-2.6.16.18/drivers/net/netxen/netxen_nic_hw.c  2006-05-26
04:05:34.000000000 -0700
@@ -61,7 +61,6 @@

        DPRINTK(INFO, "valid ether addr\n");
        memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-       memcpy(port->hw.mac_addr, addr->sa_data, netdev->addr_len);

        netxen_nic_macaddr_set(port, addr->sa_data);

@@ -102,7 +101,6 @@

        netxen_nic_set_mtu(port, new_mtu);
        netdev->mtu = new_mtu;
-       port->hw.mtu = new_mtu;

        return 0;
 }
@@ -628,8 +626,9 @@
        return val;
 }

+/* Change the window to 0, write and change back to window 1. */
 void netxen_nic_write_w0(struct netxen_adapter *adapter, u32 index, u32
value)
-{                              /* Change the window to 0, write and
change back to window 1. */
+{
        unsigned long flags;
        void *addr;

@@ -641,8 +640,9 @@
        write_unlock_irqrestore(&adapter->adapter_lock, flags);
 }

+/* Change the window to 0, read and change back to window 1. */
 void netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index, u32
* value)
-{                              /* Change the window to 0, read and
change back to window 1. */
+{
        unsigned long flags;
        void *addr;

@@ -1188,7 +1188,6 @@

NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
                                        (netxen_crbword_t *) & status)
== 0) {
                        if (status.link) {
-                               port->state = 1;
                                switch (status.speed) {
                                case 0:
                                        port->link_speed = SPEED_10;
@@ -1224,7 +1223,6 @@
                                goto link_down;
                } else {
                      link_down:
-                       port->state = -1;
                        port->link_speed = -1;
                        port->link_duplex = -1;
                }

On Thu, 2006-05-25 at 03:53 -0700, Linsys Contractor Amit S. Kale wrote:
> diff -Naru linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic_hw.c linux-2.6.16.18/drivers/net/netxen/netxen_nic_hw.c
> --- linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic_hw.c	1969-12-31 16:00:00.000000000 -0800
> +++ linux-2.6.16.18/drivers/net/netxen/netxen_nic_hw.c	2006-05-25 02:43:22.000000000 -0700
> @@ -0,0 +1,1289 @@
> +/*
> + * Copyright (C) 2003 - 2006 NetXen, Inc.
> + * All rights reserved.
> + * 
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License, or (at your option) any later version.
> + *                            
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *                                   
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
> + * MA  02111-1307, USA.
> + * 
> + * The full GNU General Public License is included in this distribution
> + * in the file called LICENSE.
> + * 
> + * Contact Information:
> + *    info@netxen.com
> + * NetXen,
> + * 3965 Freedom Circle, Fourth floor,
> + * Santa Clara, CA 95054
> + *
> + *
> + * Source file for NIC routines to access the Phantom hardware
> + *
> + */
> +
> +#include <linux/delay.h>
> +#include <linux/netdevice.h>
> +#include <linux/ethtool.h>
> +#include <linux/version.h>
> +#include "netxen_nic.h"
> +#include "netxen_nic_hw.h"
> +#include "netxen_nic_phan_reg.h"
> +
> +/*  PCI Windowing for DDR regions.  */
> +
> +#define ADDR_IN_RANGE(addr, low, high)	\
> +	(((addr) <= (high)) && ((addr) >= (low)))
> +
> +static unsigned long netxen_nic_pci_set_window(unsigned long long pci_base,
> +					       unsigned long long addr);
> +void netxen_free_hw_resources(struct netxen_adapter *adapter);
> +
> +int netxen_nic_set_mac(struct net_device *netdev, void *p)
> +{
> +	struct netxen_port *port = netdev_priv(netdev);
> +	struct sockaddr *addr = p;
> +
> +	if (netif_running(netdev))
> +		return -EBUSY;
> +
> +	if (!is_valid_ether_addr(addr->sa_data))
> +		return -EADDRNOTAVAIL;
> +
> +	DPRINTK(INFO, "valid ether addr\n");
> +	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
> +	memcpy(port->hw.mac_addr, addr->sa_data, netdev->addr_len);
> +
> +	netxen_nic_macaddr_set(port, addr->sa_data);
> +
> +	return 0;
> +}
> +
> +/**
> + * netxen_nic_set_multi - Multicast
> + **/
> +void netxen_nic_set_multi(struct net_device *netdev)
> +{
> +	struct netxen_port *port = netdev_priv(netdev);
> +	struct dev_mc_list *mc_ptr;
> +
> +	mc_ptr = netdev->mc_list;
> +	if (netdev->flags & IFF_PROMISC)
> +		netxen_nic_set_promisc_mode(port);
> +	else
> +		netxen_nic_unset_promisc_mode(port);
> +}
> +
> +/*
> + * netxen_nic_change_mtu - Change the Maximum Transfer Unit
> + * @returns 0 on success, negative on failure
> + */
> +int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu)
> +{
> +	struct netxen_port *port = netdev_priv(netdev);
> +
> +	if (new_mtu & 0xffff0000)
> +		return -EINVAL;
> +
> +	if (new_mtu > 8000) {
> +		printk(KERN_ERR "%s: %s MTU > 8000 is not supported\n",
> +		       netxen_nic_driver_name, netdev->name);
> +		return -EINVAL;
> +	}
> +
> +	netxen_nic_set_mtu(port, new_mtu);
> +	netdev->mtu = new_mtu;
> +	port->hw.mtu = new_mtu;
> +
> +	return 0;
> +}
> +
> +/*
> + * check if the firmware has been downloaded and ready to run  and
> + * setup the address for the descriptors in the adapter
> + */
> +int netxen_nic_hw_resources(struct netxen_adapter *adapter)
> +{
> +	struct netxen_hardware_context *hw = &adapter->ahw;
> +	int i;
> +	u32 state = 0;
> +	void *addr;
> +	int loops = 0, err = 0;
> +	int ctx, ring;
> +	u32 card_cmdring = 0;
> +	struct netxen_rcv_desc_crb *rcv_desc_crb = NULL;
> +	struct netxen_recv_context *recv_ctx;
> +	struct netxen_rcv_desc_ctx *rcv_desc;
> +	struct cmd_desc_type0_t *pcmd;
> +
> +	DPRINTK(INFO, "pci_base: %lx\n", adapter->ahw.pci_base);
> +	DPRINTK(INFO, "crb_base: %lx %lx", NETXEN_PCI_CRBSPACE,
> +		adapter->ahw.pci_base + NETXEN_PCI_CRBSPACE);
> +	DPRINTK(INFO, "cam base: %lx %lx", NETXEN_CRB_CAM,
> +		adapter->ahw.pci_base + NETXEN_CRB_CAM);
> +	DPRINTK(INFO, "cam RAM: %lx %lx", NETXEN_CAM_RAM_BASE,
> +		adapter->ahw.pci_base + NETXEN_CAM_RAM_BASE);
> +	DPRINTK(INFO, "NIC base:%lx %lx\n", NIC_CRB_BASE_PORT1,
> +		adapter->ahw.pci_base + NIC_CRB_BASE_PORT1);
> +
> +	/* Window 1 call */
> +	read_lock(&adapter->adapter_lock);
> +	card_cmdring = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_CMDRING));
> +	read_unlock(&adapter->adapter_lock);
> +
> +	DPRINTK(INFO, "Command Peg sends 0x%x for cmdring base\n",
> +		card_cmdring);
> +
> +	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
> +		DPRINTK(INFO, "Command Peg ready..waiting for rcv peg\n");
> +		loops = 0;
> +		state = 0;
> +		/* Window 1 call */
> +		read_lock(&adapter->adapter_lock);
> +		state = readl(NETXEN_CRB_NORMALIZE(adapter,
> +						   recv_crb_registers[ctx].
> +						   crb_rcvpeg_state));
> +		read_unlock(&adapter->adapter_lock);
> +
> +		while (state != PHAN_PEG_RCV_INITIALIZED && loops < 20) {
> +			udelay(100);
> +			/* Window 1 call */
> +			read_lock(&adapter->adapter_lock);
> +			state = readl(NETXEN_CRB_NORMALIZE(adapter,
> +							   recv_crb_registers
> +							   [ctx].
> +							   crb_rcvpeg_state));
> +			read_unlock(&adapter->adapter_lock);
> +
> +			loops++;
> +		}
> +		if (loops >= 20) {
> +			printk(KERN_ERR "Rcv Peg initialization not complete:"
> +			       "%x.\n", state);
> +			err = -EIO;
> +			return err;
> +		}
> +	}
> +	DPRINTK(INFO, "Recieve Peg ready too. starting stuff\n");
> +
> +	addr = pci_alloc_consistent(adapter->ahw.pdev,
> +				    sizeof(struct cmd_desc_type0_t) *
> +				    adapter->max_tx_desc_count,
> +				    (dma_addr_t *) & hw->cmd_desc_phys_addr);
> +	if (addr == NULL) {
> +		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
> +		err = -ENOMEM;
> +		return err;
> +	}
> +
> +	/* we need to prelink all of the cmd descriptors */
> +	pcmd = (struct cmd_desc_type0_t *)addr;
> +	for (i = 1; i < adapter->max_tx_desc_count; i++) {
> +		pcmd->netxen_next =
> +		    (card_cmdring + i * sizeof(struct cmd_desc_type0_t));
> +		pcmd++;
> +	}
> +	/* fill in last link (point to first) */
> +	pcmd->netxen_next = card_cmdring;
> +
> +	hw->cmd_desc_head = (struct cmd_desc_type0_t *)addr;
> +
> +	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
> +		recv_ctx = &adapter->recv_ctx[ctx];
> +
> +		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
> +			rcv_desc = &recv_ctx->rcv_desc[ring];
> +			addr = pci_alloc_consistent(adapter->ahw.pdev,
> +						    RCV_DESC_RINGSIZE,
> +						    (dma_addr_t *)
> +						    & rcv_desc->phys_addr);
> +			if (addr == NULL) {
> +				DPRINTK(ERR, "bad return from "
> +					"pci_alloc_consistent\n");
> +				netxen_free_hw_resources(adapter);
> +				err = -ENOMEM;
> +				return err;
> +			}
> +			rcv_desc->desc_head = (struct rcv_desc_t *)addr;
> +		}
> +
> +		addr = pci_alloc_consistent(adapter->ahw.pdev,
> +					    STATUS_DESC_RINGSIZE, (dma_addr_t *)
> +					    & recv_ctx->
> +					    rcv_status_desc_phys_addr);
> +		if (addr == NULL) {
> +			DPRINTK(ERR, "bad return from"
> +				" pci_alloc_consistent\n");
> +			netxen_free_hw_resources(adapter);
> +			err = -ENOMEM;
> +			return err;
> +		}
> +		recv_ctx->rcv_status_desc_head = (struct status_desc_t *)addr;
> +
> +		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
> +			rcv_desc = &recv_ctx->rcv_desc[ring];
> +			rcv_desc_crb =
> +			    &recv_crb_registers[ctx].rcv_desc_crb[ring];
> +			DPRINTK(INFO, "ring #%d crb global ring reg 0x%x\n",
> +				ring, rcv_desc_crb->crb_globalrcv_ring);
> +			/* Window = 1 */
> +			read_lock(&adapter->adapter_lock);
> +			writel(rcv_desc->phys_addr,
> +			       NETXEN_CRB_NORMALIZE(adapter,
> +						    rcv_desc_crb->
> +						    crb_globalrcv_ring));
> +			read_unlock(&adapter->adapter_lock);
> +
> +			DPRINTK(INFO, "GLOBAL_RCV_RING ctx %d, addr 0x%x"
> +				" val 0x%x,"
> +				" virt %p\n", ctx,
> +				rcv_desc_crb->crb_globalrcv_ring,
> +				rcv_desc->phys_addr, rcv_desc->desc_head);
> +		}
> +
> +		/* Window = 1 */
> +		read_lock(&adapter->adapter_lock);
> +		writel(recv_ctx->rcv_status_desc_phys_addr,
> +		       NETXEN_CRB_NORMALIZE(adapter,
> +					    recv_crb_registers[ctx].
> +					    crb_rcvstatus_ring));
> +		read_unlock(&adapter->adapter_lock);
> +
> +		DPRINTK(INFO, "RCVSTATUS_RING, ctx %d, addr 0x%x,"
> +			" val 0x%x,virt%p\n",
> +			ctx,
> +			recv_crb_registers[ctx].crb_rcvstatus_ring,
> +			recv_ctx->rcv_status_desc_phys_addr,
> +			recv_ctx->rcv_status_desc_head);
> +	}
> +	/* Window = 1 */
> +	read_lock(&adapter->adapter_lock);
> +	writel(hw->cmd_desc_phys_addr,
> +	       NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_LO));
> +
> +	read_unlock(&adapter->adapter_lock);
> +
> +	return err;
> +}
> +
> +void netxen_free_hw_resources(struct netxen_adapter *adapter)
> +{
> +	struct netxen_recv_context *recv_ctx;
> +	struct netxen_rcv_desc_ctx *rcv_desc;
> +	int ctx, ring;
> +
> +	if (adapter->ahw.cmd_desc_head != NULL) {
> +		pci_free_consistent(adapter->ahw.pdev,
> +				    sizeof(struct cmd_desc_type0_t) *
> +				    adapter->max_tx_desc_count,
> +				    adapter->ahw.cmd_desc_head,
> +				    adapter->ahw.cmd_desc_phys_addr);
> +		adapter->ahw.cmd_desc_head = NULL;
> +	}
> +
> +	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
> +		recv_ctx = &adapter->recv_ctx[ctx];
> +		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
> +			rcv_desc = &recv_ctx->rcv_desc[ring];
> +
> +			if (rcv_desc->desc_head != NULL) {
> +				pci_free_consistent(adapter->ahw.pdev,
> +						    RCV_DESC_RINGSIZE,
> +						    rcv_desc->desc_head,
> +						    rcv_desc->phys_addr);
> +				rcv_desc->desc_head = NULL;
> +			}
> +		}
> +
> +		if (recv_ctx->rcv_status_desc_head != NULL) {
> +			pci_free_consistent(adapter->ahw.pdev,
> +					    STATUS_DESC_RINGSIZE,
> +					    recv_ctx->rcv_status_desc_head,
> +					    recv_ctx->
> +					    rcv_status_desc_phys_addr);
> +			recv_ctx->rcv_status_desc_head = NULL;
> +		}
> +	}
> +}
> +
> +void netxen_tso_check(struct netxen_adapter *adapter,
> +		      struct cmd_desc_type0_t *desc, struct sk_buff *skb)
> +{
> +	if (desc->mss) {
> +		desc->total_hdr_length = sizeof(struct ethhdr) +
> +		    ((skb->nh.iph)->ihl * sizeof(u32)) +
> +		    ((skb->h.th)->doff * sizeof(u32));
> +		desc->opcode = TX_TCP_LSO;
> +	} else if (skb->ip_summed == CHECKSUM_HW) {
> +		if (skb->nh.iph->protocol == IPPROTO_TCP) {
> +			desc->opcode = TX_TCP_PKT;
> +		} else if (skb->nh.iph->protocol == IPPROTO_UDP) {
> +			desc->opcode = TX_UDP_PKT;
> +		} else {
> +			return;
> +		}
> +	}
> +	desc->tcp_hdr_offset = skb->h.raw - skb->data;
> +	desc->ip_hdr_offset = skb->nh.raw - skb->data;
> +	adapter->stats.xmitcsummed++;
> +}
> +
> +int is_flash_supported(struct netxen_adapter *adapter)
> +{
> +	int locs[] = { 0, 0x4, 0x100, 0x4000, 0x4128 };
> +	int addr, val01, val02, i, j;
> +
> +	/* if the flash size less than 4Mb, make huge war cry and die */
> +	for (j = 1; j < 4; j++) {
> +		addr = j * 0x100000;
> +		for (i = 0; i < (sizeof(locs) / sizeof(locs[0])); i++) {
> +			if (netxen_rom_fast_read(adapter, locs[i], &val01) == 0
> +			    && netxen_rom_fast_read(adapter, (addr + locs[i]),
> +						    &val02) == 0) {
> +				if (val01 == val02)
> +					return -1;
> +			} else
> +				return -1;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static int netxen_get_flash_block(struct netxen_adapter *adapter, int base,
> +				  int size, u32 * buf)
> +{
> +	int i, addr;
> +	u32 *ptr32;
> +
> +	addr = base;
> +	ptr32 = buf;
> +	for (i = 0; i < size / sizeof(u32); i++) {
> +		if (netxen_rom_fast_read(adapter, addr, ptr32) == -1)
> +			return -1;
> +		ptr32++;
> +		addr += sizeof(u32);
> +	}
> +	if ((char *)buf + size > (char *)ptr32) {
> +		u32 local;
> +
> +		if (netxen_rom_fast_read(adapter, addr, &local) == -1)
> +			return -1;
> +		memcpy(ptr32, &local, (char *)buf + size - (char *)ptr32);
> +	}
> +
> +	return 0;
> +}
> +
> +int get_flash_mac_addr(struct netxen_adapter *adapter, u64 mac[])
> +{
> +	u32 *pmac = (u32 *) & mac[0];
> +
> +	if (netxen_get_flash_block(adapter,
> +				   USER_START +
> +				   offsetof(struct netxen_new_user_info,
> +					    mac_addr),
> +				   FLASH_NUM_PORTS * sizeof(u64), pmac) == -1) {
> +		return -1;
> +	}
> +	if (*mac == ~0ULL) {
> +		if (netxen_get_flash_block(adapter,
> +					   USER_START_OLD +
> +					   offsetof(struct netxen_user_info,
> +						    mac_addr),
> +					   FLASH_NUM_PORTS * sizeof(u64),
> +					   pmac) == -1)
> +			return -1;
> +		if (*mac == ~0ULL)
> +			return -1;
> +	}
> +
> +	return 0;
> +}
> +
> +/*
> + * Changes the CRB window to the specified window.
> + */
> +void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw)
> +{
> +	struct netxen_pcix_crb_window window;
> +	unsigned long offset;
> +	u32 tmp;
> +
> +	if (adapter->curr_window == wndw)
> +		return;
> +
> +	/*
> +	 * Move the CRB window.
> +	 * We need to write to the "direct access" region of PCI
> +	 * to avoid a race condition where the window register has
> +	 * not been successfully written across CRB before the target
> +	 * register address is received by PCI. The direct region bypasses
> +	 * the CRB bus.
> +	 */
> +	offset = adapter->ahw.pci_base + NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW);
> +
> +	*(netxen_crbword_t *) & window = 0;
> +	window.addrbit = wndw;
> +	writel(*(unsigned int *)&window, (void *)(offset));
> +
> +	/* MUST make sure window is set before we forge on... */
> +	while ((tmp = readl((void *)offset)) != *(u32 *) & window)
> +		printk(KERN_WARNING "%s: %s WARNING: CRB window value not "
> +		       "registered properly: 0x%08x.\n",
> +		       netxen_nic_driver_name, __FUNCTION__, tmp);
> +
> +	adapter->curr_window = wndw;
> +}
> +
> +/*
> + * Set the CRB window based on the offset.
> + */
> +static inline unsigned long
> +netxen_nic_pci_set_crbwindow(struct netxen_adapter *adapter, u64 off)
> +{
> +	/*
> +	 * See if we are currently pointing to the region we want to use next.
> +	 */
> +
> +	if ((off >= NETXEN_CRB_PCIX_HOST) && (off < NETXEN_CRB_DDR_NET)) {
> +		/*
> +		 * No need to change window. PCIX and PCIE regs are in both
> +		 * windows.
> +		 */
> +		return off;
> +	}
> +
> +	if ((off >= NETXEN_CRB_PCIX_HOST) && (off < NETXEN_CRB_PCIX_HOST2)) {
> +		/* We are in first CRB window */
> +		if (adapter->curr_window != 0)
> +			netxen_nic_pci_change_crbwindow(adapter, 0);
> +
> +		return off;
> +	}
> +
> +	if ((off > NETXEN_CRB_PCIX_HOST2) && (off < NETXEN_CRB_MAX)) {
> +		/* We are in second CRB window */
> +		off = off - NETXEN_CRB_PCIX_HOST2 + NETXEN_CRB_PCIX_HOST;
> +
> +		if (adapter->curr_window != 1)
> +			netxen_nic_pci_change_crbwindow(adapter, 1);
> +
> +		return off;
> +	}
> +
> +	if ((off >= NETXEN_PCI_DIRECT_CRB) && (off < NETXEN_PCI_CAMQM_MAX)) {
> +		/*
> +		 * We are in the QM or direct access register region - do
> +		 * nothing
> +		 */
> +		return off;
> +	}
> +
> +	/* strange address given */
> +	dump_stack();
> +	printk(KERN_WARNING
> +	       "%s: Warning: netxen_nic_pci_set_crbwindow called with"
> +	       " an unknown address(%llx)\n", netxen_nic_driver_name, off);
> +
> +	return off;
> +}
> +
> +int
> +netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off, void *data,
> +		       int len)
> +{
> +	void *addr;
> +	unsigned long flags = 0;
> +
> +	if (ADDR_IN_WINDOW1(off)) {
> +		addr = NETXEN_CRB_NORMALIZE(adapter, off);
> +		read_lock(&adapter->adapter_lock);
> +	} else {		/* Window 0 */
> +		addr = (void *)(ptrdiff_t) (adapter->ahw.pci_base + off);
> +		write_lock_irqsave(&adapter->adapter_lock, flags);
> +		netxen_nic_pci_change_crbwindow(adapter, 0);
> +	}
> +
> +	DPRINTK(INFO, "writing to base %lx offset %llx addr %p"
> +		" data %llx len %d\n",
> +		adapter->ahw.pci_base, off, addr,
> +		*(unsigned long long *)data, len);
> +	switch (len) {
> +	case 1:
> +		writeb(*(u8 *) data, addr);
> +		break;
> +	case 2:
> +		writew(*(u16 *) data, addr);
> +		break;
> +	case 4:
> +		writel(*(u32 *) data, addr);
> +		break;
> +	case 8:
> +		writeq(*(u64 *) data, addr);
> +		break;
> +	default:
> +		DPRINTK(INFO,
> +			"writing data %lx to offset %llx, num words=%d\n",
> +			*(unsigned long *)data, off, (len >> 3));
> +
> +		NETXEN_NIC_HW_BLOCK_WRITE_64(data, addr, (len >> 3));
> +		break;
> +	}
> +	if (ADDR_IN_WINDOW1(off))
> +		read_unlock(&adapter->adapter_lock);
> +	else {			/* Window 0 */
> +		netxen_nic_pci_change_crbwindow(adapter, 1);
> +		write_unlock_irqrestore(&adapter->adapter_lock, flags);
> +	}
> +
> +	return 0;
> +}
> +
> +int
> +netxen_nic_hw_read_wx(struct netxen_adapter *adapter, u64 off, void *data,
> +		      int len)
> +{
> +	void *addr;
> +	unsigned long flags = 0;
> +
> +	if (ADDR_IN_WINDOW1(off)) {	/* Window 1 */
> +		addr = NETXEN_CRB_NORMALIZE(adapter, off);
> +		read_lock(&adapter->adapter_lock);
> +	} else {		/* Window 0 */
> +		addr = (void *)(ptrdiff_t) (adapter->ahw.pci_base + off);
> +		write_lock_irqsave(&adapter->adapter_lock, flags);
> +		netxen_nic_pci_change_crbwindow(adapter, 0);
> +	}
> +
> +	DPRINTK(INFO, "reading from base %lx offset %llx addr %p\n",
> +		adapter->ahw.pci_base, off, addr);
> +	switch (len) {
> +	case 1:
> +		*(u8 *) data = readb(addr);
> +		break;
> +	case 2:
> +		*(u16 *) data = readw(addr);
> +		break;
> +	case 4:
> +		*(u32 *) data = readl(addr);
> +		break;
> +	case 8:
> +		*(u64 *) data = readq(addr);
> +		break;
> +	default:
> +		NETXEN_NIC_HW_BLOCK_READ_64(data, addr, (len >> 3));
> +		break;
> +	}
> +	DPRINTK(INFO, "read %lx\n", *(unsigned long *)data);
> +
> +	if (ADDR_IN_WINDOW1(off))
> +		read_unlock(&adapter->adapter_lock);
> +	else {			/* Window 0 */
> +		netxen_nic_pci_change_crbwindow(adapter, 1);
> +		write_unlock_irqrestore(&adapter->adapter_lock, flags);
> +	}
> +
> +	return 0;
> +}
> +
> +void netxen_nic_reg_write(struct netxen_adapter *adapter, u64 off, u32 val)
> +{				/* Only for window 1 */
> +	void *addr;
> +
> +	read_lock(&adapter->adapter_lock);
> +
> +	if (adapter->curr_window != 1)
> +		netxen_nic_pci_change_crbwindow(adapter, 1);
> +	addr = NETXEN_CRB_NORMALIZE(adapter, off);
> +	DPRINTK(INFO, "writing to base %lx offset %llx addr %p data %x\n",
> +		adapter->ahw.pci_base, off, addr, val);
> +	writel(val, addr);
> +
> +	read_unlock(&adapter->adapter_lock);
> +}
> +
> +int netxen_nic_reg_read(struct netxen_adapter *adapter, u64 off)
> +{				/* Only for window 1 */
> +	void *addr;
> +	int val;
> +
> +	read_lock(&adapter->adapter_lock);
> +	addr = NETXEN_CRB_NORMALIZE(adapter, off);
> +	DPRINTK(INFO, "reading from base %lx offset %llx addr %p\n",
> +		adapter->ahw.pci_base, off, addr);
> +	val = readl(addr);
> +	writel(val, addr);
> +	read_unlock(&adapter->adapter_lock);
> +
> +	return val;
> +}
> +
> +void netxen_nic_write_w0(struct netxen_adapter *adapter, u32 index, u32 value)
> +{				/* Change the window to 0, write and change back to window 1. */
> +	unsigned long flags;
> +	void *addr;
> +
> +	write_lock_irqsave(&adapter->adapter_lock, flags);
> +	netxen_nic_pci_change_crbwindow(adapter, 0);
> +	addr = (void *)(adapter->ahw.pci_base + index);
> +	writel(value, addr);
> +	netxen_nic_pci_change_crbwindow(adapter, 1);
> +	write_unlock_irqrestore(&adapter->adapter_lock, flags);
> +}
> +
> +void netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index, u32 * value)
> +{				/* Change the window to 0, read and change back to window 1. */
> +	unsigned long flags;
> +	void *addr;
> +
> +	addr = (void *)(adapter->ahw.pci_base + index);
> +
> +	write_lock_irqsave(&adapter->adapter_lock, flags);
> +	netxen_nic_pci_change_crbwindow(adapter, 0);
> +	*value = readl(addr);
> +	netxen_nic_pci_change_crbwindow(adapter, 1);
> +	write_unlock_irqrestore(&adapter->adapter_lock, flags);
> +}
> +
> +int netxen_pci_set_window_warning_count = 0;
> +
> +static unsigned long
> +netxen_nic_pci_set_window(unsigned long long pci_base, unsigned long long addr)
> +{
> +	static int ddr_mn_window = -1;
> +	static int qdr_sn_window = -1;
> +	int window;
> +
> +	if (ADDR_IN_RANGE(addr, NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX)) {
> +		/* DDR network side */
> +		addr -= NETXEN_ADDR_DDR_NET;
> +		window = (addr >> 25) & 0x3ff;
> +		if (ddr_mn_window != window) {
> +			ddr_mn_window = window;
> +			writel(window, (void *)(ptrdiff_t) (pci_base +
> +							    NETXEN_PCIX_PH_REG
> +							    (PCIX_MN_WINDOW)));
> +			/* MUST make sure window is set before we forge on... */
> +			readl((void *)(ptrdiff_t) (pci_base +
> +						   NETXEN_PCIX_PH_REG
> +						   (PCIX_MN_WINDOW)));
> +		}
> +		addr -= (window * 0x2000000);
> +		addr += NETXEN_PCI_DDR_NET;
> +	} else if (ADDR_IN_RANGE(addr, NETXEN_ADDR_OCM0, NETXEN_ADDR_OCM0_MAX)) {
> +		addr -= NETXEN_ADDR_OCM0;
> +		addr += NETXEN_PCI_OCM0;
> +	} else if (ADDR_IN_RANGE(addr, NETXEN_ADDR_OCM1, NETXEN_ADDR_OCM1_MAX)) {
> +		addr -= NETXEN_ADDR_OCM1;
> +		addr += NETXEN_PCI_OCM1;
> +	} else
> +	    if (ADDR_IN_RANGE
> +		(addr, NETXEN_ADDR_QDR_NET, NETXEN_ADDR_QDR_NET_MAX)) {
> +		/* QDR network side */
> +		addr -= NETXEN_ADDR_QDR_NET;
> +		window = (addr >> 22) & 0x3f;
> +		if (qdr_sn_window != window) {
> +			qdr_sn_window = window;
> +			writel((window << 22),
> +			       (void *)(ptrdiff_t) (pci_base +
> +						    NETXEN_PCIX_PH_REG
> +						    (PCIX_SN_WINDOW)));
> +			/* MUST make sure window is set before we forge on... */
> +			readl((void *)(ptrdiff_t) (pci_base +
> +						   NETXEN_PCIX_PH_REG
> +						   (PCIX_SN_WINDOW)));
> +		}
> +		addr -= (window * 0x400000);
> +		addr += NETXEN_PCI_QDR_NET;
> +	} else {
> +		/*
> +		 * peg gdb frequently accesses memory that doesn't exist,
> +		 * this limits the chit chat so debugging isn't slowed down.
> +		 */
> +		if ((netxen_pci_set_window_warning_count++ < 8)
> +		    || (netxen_pci_set_window_warning_count % 64 == 0))
> +			printk("%s: Warning:netxen_nic_pci_set_window()"
> +			       " Unknown address range!\n",
> +			       netxen_nic_driver_name);
> +
> +	}
> +	return addr;
> +}
> +
> +/* read num_words from hardware (num_words in 64 bits    */
> +void
> +netxen_nic_mem_block_read(struct netxen_adapter *adapter, u64 off,
> +			  void *data, int num_words)
> +{
> +	void *addr;
> +	unsigned long flags;
> +
> +	write_lock_irqsave(&adapter->adapter_lock, flags);
> +	off = netxen_nic_pci_set_window(adapter->ahw.pci_base, off);
> +	addr = (void *)(ptrdiff_t) (adapter->ahw.pci_base + off);
> +	DPRINTK(INFO, "reading from base %lx offset %lx addr %p\n",
> +		adapter->ahw.pci_base, (unsigned long)off, addr);
> +	NETXEN_NIC_HW_BLOCK_READ_64(data, addr, num_words);
> +	write_unlock_irqrestore(&adapter->adapter_lock, flags);
> +}
> +
> +int
> +netxen_nic_pci_mem_write(struct netxen_adapter *adapter, u64 off,
> +			 void *data, int size)
> +{
> +	unsigned long flags;
> +	void *addr;
> +	int ret = 0;
> +
> +	write_lock_irqsave(&adapter->adapter_lock, flags);
> +	off = netxen_nic_pci_set_window(adapter->ahw.pci_base, off);
> +	addr = (void *)(ptrdiff_t) (adapter->ahw.pci_base + off);
> +	DPRINTK(INFO, "writing data %llx to offset %llx\n",
> +		*(unsigned long long *)data, off);
> +	switch (size) {
> +	case 1:
> +		writeb(*(u8 *) data, addr);
> +		break;
> +	case 2:
> +		writew(*(u16 *) data, addr);
> +		break;
> +	case 4:
> +		writel(*(u32 *) data, addr);
> +		break;
> +	case 8:
> +		writeq(*(u64 *) data, addr);
> +		break;
> +	default:
> +		ret = 1;
> +		break;
> +	}
> +	write_unlock_irqrestore(&adapter->adapter_lock, flags);
> +	DPRINTK(INFO, "wrote %llx\n", *(unsigned long long *)data);
> +
> +	return ret;
> +}
> +
> +int
> +netxen_nic_pci_mem_read(struct netxen_adapter *adapter,
> +			u64 off, void *data, int size)
> +{
> +	unsigned long flags;
> +	void *addr;
> +	int ret = 0;
> +
> +	if (data == NULL || off > NETXEN_MEMADDR_MAX) {
> +		printk(KERN_ERR "data: %p off:%llx\n", data, off);
> +		return 1;
> +	}
> +	write_lock_irqsave(&adapter->adapter_lock, flags);
> +	off = netxen_nic_pci_set_window(adapter->ahw.pci_base, off);
> +	addr = (void *)(ptrdiff_t) (adapter->ahw.pci_base + off);
> +	switch (size) {
> +	case 1:
> +		*(u8 *) data = readb(addr);
> +		break;
> +	case 2:
> +		*(u16 *) data = readw(addr);
> +		break;
> +	case 4:
> +		*(u32 *) data = readl(addr);
> +		break;
> +	case 8:
> +		*(u64 *) data = readq(addr);
> +		break;
> +	default:
> +		ret = 1;
> +		break;
> +	}
> +	write_unlock_irqrestore(&adapter->adapter_lock, flags);
> +	DPRINTK(INFO, "read %llx\n", *(unsigned long long *)data);
> +
> +	return ret;
> +}
> +
> +int netxen_nic_get_board_info(struct netxen_adapter *adapter)
> +{
> +	int rv = 0;
> +	int addr = BRDCFG_START;
> +	struct netxen_board_info *boardinfo;
> +	int index;
> +	u32 *ptr32;
> +
> +	boardinfo = &adapter->ahw.boardcfg;
> +	ptr32 = (u32 *) boardinfo;
> +
> +	for (index = 0; index < sizeof(struct netxen_board_info) / sizeof(u32);
> +	     index++) {
> +		if (netxen_rom_fast_read(adapter, addr, ptr32) == -1) {
> +			rv = -1;
> +			return rv;
> +		}
> +		ptr32++;
> +		addr += sizeof(u32);
> +	}
> +	if (boardinfo->magic != NETXEN_BDINFO_MAGIC) {
> +		printk("%s: ERROR reading %s board config."
> +		       " Read %x, expected %x\n", netxen_nic_driver_name,
> +		       netxen_nic_driver_name,
> +		       boardinfo->magic, NETXEN_BDINFO_MAGIC);
> +		rv = -1;
> +	}
> +	if (boardinfo->header_version != NETXEN_BDINFO_VERSION) {
> +		printk("%s: Unknown board config version."
> +		       " Read %x, expected %x\n", netxen_nic_driver_name,
> +		       boardinfo->header_version, NETXEN_BDINFO_VERSION);
> +		rv = -1;
> +	}
> +
> +	DPRINTK(INFO, "Discovered board type:0x%x  ", boardinfo->board_type);
> +	switch ((netxen_brdtype_t) boardinfo->board_type) {
> +	case NETXEN_BRDTYPE_P2_SB35_4G:
> +		adapter->ahw.board_type = NETXEN_NIC_GBE;
> +		break;
> +	case NETXEN_BRDTYPE_P2_SB31_10G:
> +	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
> +	case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
> +	case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
> +		adapter->ahw.board_type = NETXEN_NIC_XGBE;
> +		break;
> +	case NETXEN_BRDTYPE_P1_BD:
> +	case NETXEN_BRDTYPE_P1_SB:
> +	case NETXEN_BRDTYPE_P1_SMAX:
> +	case NETXEN_BRDTYPE_P1_SOCK:
> +		adapter->ahw.board_type = NETXEN_NIC_GBE;
> +		break;
> +	default:
> +		printk("%s: Unknown(%x)\n", netxen_nic_driver_name,
> +		       boardinfo->board_type);
> +		break;
> +	}
> +
> +	return rv;
> +}
> +
> +inline int netxen_nic_get_board_num(struct netxen_adapter *adapter)
> +{
> +	return adapter->ahw.boardcfg.board_num;
> +}
> +
> +/* NIU access sections */
> +
> +/* Set the MAC address for a port */
> +int netxen_nic_macaddr_set(struct netxen_port *port, u8 * addr)
> +{
> +	struct netxen_adapter *adapter = port->adapter;
> +	int phy = port->portnum, ret = 0;
> +
> +	if ((phy < 0) || (phy > 3))
> +		return -1;
> +
> +	switch (adapter->ahw.board_type) {
> +	case NETXEN_NIC_GBE:
> +		ret = netxen_niu_macaddr_set(adapter, phy, addr);
> +		break;
> +
> +	case NETXEN_NIC_XGBE:
> +		ret = netxen_niu_xg_macaddr_set(adapter, phy, addr);
> +		break;
> +
> +	default:
> +		dump_stack();
> +		printk(KERN_ERR "%s: Unknown board type\n",
> +		       netxen_nic_driver_name);
> +		ret = -1;
> +	}
> +
> +	return ret;
> +}
> +
> +/* Return the current MAC address of the given port. */
> +int netxen_nic_macaddr_get(struct netxen_port *port, u8 ** addr)
> +{
> +	struct netxen_adapter *adapter = port->adapter;
> +	int phy = port->portnum;
> +	int ret = 0;
> +
> +	if (addr == NULL)
> +		return -1;
> +	if ((phy < 0) || (phy > 3))
> +		return -1;
> +
> +	switch (adapter->ahw.board_type) {
> +	case NETXEN_NIC_GBE:
> +		ret = netxen_niu_macaddr_get(adapter, phy,
> +					     (netxen_ethernet_macaddr_t *) *
> +					     addr);
> +		break;
> +
> +	case NETXEN_NIC_XGBE:
> +		printk(KERN_ERR "%s: Function %s is not implemented for XG\n",
> +		       netxen_nic_driver_name, __FUNCTION__);
> +		break;
> +
> +	default:
> +		printk(KERN_ERR "%s: Unknown board type\n",
> +		       netxen_nic_driver_name);
> +		ret = -1;
> +	}
> +
> +	return ret;
> +}
> +
> +int netxen_nic_set_mtu(struct netxen_port *port, int new_mtu)
> +{
> +	struct netxen_adapter *adapter = port->adapter;
> +	int ret = 0;
> +
> +	switch (adapter->ahw.board_type) {
> +	case NETXEN_NIC_GBE:
> +		netxen_nic_write_w0(adapter,
> +				    NETXEN_NIU_GB_MAX_FRAME_SIZE(port->portnum),
> +				    new_mtu);
> +
> +		break;
> +
> +	case NETXEN_NIC_XGBE:
> +		new_mtu += 100;	/* so that MAC accepts frames > MTU */
> +		netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE,
> +				    new_mtu);
> +		break;
> +
> +	default:
> +		printk(KERN_ERR "%s: Unknown board type\n",
> +		       netxen_nic_driver_name);
> +		ret = -1;
> +	}
> +
> +	return ret;
> +}
> +
> +int netxen_nic_set_promisc_mode(struct netxen_port *port)
> +{
> +	struct netxen_adapter *adapter = port->adapter;
> +	int phy = port->portnum;
> +	int ret = 0;
> +
> +	if ((phy < 0) || (phy > 3))
> +		return -1;
> +
> +	switch (adapter->ahw.board_type) {
> +	case NETXEN_NIC_GBE:
> +		ret = netxen_niu_set_promiscuous_mode(adapter, phy,
> +						      NETXEN_NIU_PROMISCOUS_MODE);
> +		break;
> +
> +	case NETXEN_NIC_XGBE:
> +		ret = netxen_niu_xg_set_promiscuous_mode(adapter, phy,
> +							 NETXEN_NIU_PROMISCOUS_MODE);
> +
> +		break;
> +
> +	default:
> +		printk(KERN_ERR "%s: Unknown board type\n",
> +		       netxen_nic_driver_name);
> +		ret = -1;
> +	}
> +
> +	return ret;
> +}
> +
> +int netxen_nic_unset_promisc_mode(struct netxen_port *port)
> +{
> +	struct netxen_adapter *adapter = port->adapter;
> +	int phy = port->portnum;
> +	int ret = 0;
> +
> +	if ((phy < 0) || (phy > 3))
> +		return -1;
> +
> +	switch (adapter->ahw.board_type) {
> +	case NETXEN_NIC_GBE:
> +		ret = netxen_niu_set_promiscuous_mode(adapter, phy,
> +						      NETXEN_NIU_NON_PROMISCOUS_MODE);
> +		break;
> +
> +	case NETXEN_NIC_XGBE:
> +		ret = netxen_niu_xg_set_promiscuous_mode(adapter, phy,
> +							 NETXEN_NIU_NON_PROMISCOUS_MODE);
> +
> +		break;
> +
> +	default:
> +		printk(KERN_ERR "%s: Unknown board type\n",
> +		       netxen_nic_driver_name);
> +		ret = -1;
> +	}
> +
> +	return ret;
> +}
> +
> +long
> +netxen_nic_phy_read(struct netxen_adapter *adapter, long phy, long reg,
> +		    u32 * readval)
> +{
> +	long ret = 0;
> +
> +	switch (adapter->ahw.board_type) {
> +	case NETXEN_NIC_GBE:
> +		ret = netxen_niu_gbe_phy_read(adapter, phy, reg, readval);
> +		break;
> +
> +	case NETXEN_NIC_XGBE:
> +		printk(KERN_ERR "%s: Function %s is not implemented for XG\n",
> +		       netxen_nic_driver_name, __FUNCTION__);
> +		break;
> +
> +	default:
> +		printk(KERN_ERR "%s: Unknown board type\n",
> +		       netxen_nic_driver_name);
> +		ret = -1;
> +	}
> +
> +	return ret;
> +}
> +
> +long netxen_nic_phy_write(struct netxen_adapter *adapter, long phy, long reg,
> +			  u32 val)
> +{
> +	long ret = 0;
> +
> +	switch (adapter->ahw.board_type) {
> +	case NETXEN_NIC_GBE:
> +		ret = netxen_niu_gbe_phy_write(adapter, phy, reg, val);
> +		break;
> +
> +	case NETXEN_NIC_XGBE:
> +		printk(KERN_ERR "%s: Function %s is not implemented for XG\n",
> +		       netxen_nic_driver_name, __FUNCTION__);
> +		break;
> +
> +	default:
> +		printk(KERN_ERR "%s: Unknown board type\n",
> +		       netxen_nic_driver_name);
> +		ret = -1;
> +	}
> +
> +	return ret;
> +}
> +
> +long netxen_nic_init_port(struct netxen_port *port)
> +{
> +	struct netxen_adapter *adapter = port->adapter;
> +	long portnum = port->portnum;
> +	long ret = 0;
> +
> +	switch (adapter->ahw.board_type) {
> +	case NETXEN_NIC_GBE:
> +		netxen_nic_disable_phy_interrupts(adapter, portnum);
> +		udelay(20000);
> +		netxen_niu_gbe_init_port(adapter, portnum);
> +
> +		break;
> +
> +	case NETXEN_NIC_XGBE:
> +		/* Nothing to be done for XG */
> +		break;
> +
> +	default:
> +		printk(KERN_ERR "%s: Unknown board type\n",
> +		       netxen_nic_driver_name);
> +		ret = -1;
> +	}
> +
> +	return ret;
> +}
> +
> +void netxen_nic_init_niu(struct netxen_adapter *adapter)
> +{
> +	int portno;
> +
> +	switch (adapter->ahw.board_type) {
> +	case NETXEN_NIC_GBE:
> +		for (portno = 0; portno < NETXEN_NIU_MAX_GBE_PORTS; portno++)
> +			netxen_niu_gbe_init_port(adapter, portno);
> +		break;
> +
> +	case NETXEN_NIC_XGBE:
> +		/* Do nothing */
> +		break;
> +
> +	default:
> +		printk(KERN_ERR "%s: Unknown board type\n",
> +		       netxen_nic_driver_name);
> +	}
> +}
> +
> +void netxen_nic_stop_port(struct netxen_port *port)
> +{
> +	long portnum = port->portnum;
> +	struct netxen_adapter *adapter = port->adapter;
> +
> +	switch (adapter->ahw.board_type) {
> +	case NETXEN_NIC_GBE:
> +		netxen_niu_disable_gbe_port(adapter, portnum);
> +		break;
> +
> +	case NETXEN_NIC_XGBE:
> +		netxen_niu_disable_xg_port(adapter, portnum);
> +		break;
> +
> +	default:
> +		printk(KERN_ERR "%s: Unknown board type\n",
> +		       netxen_nic_driver_name);
> +	}
> +}
> +
> +void netxen_nic_stop_all_ports(struct netxen_adapter *adapter)
> +{
> +	int port_nr;
> +	struct netxen_port *port;
> +
> +	for (port_nr = 0; port_nr < adapter->ahw.max_ports; port_nr++) {
> +		port = adapter->port[port_nr];
> +		netxen_nic_stop_port(port);
> +	}
> +}
> +
> +void
> +netxen_crb_writelit_adapter(struct netxen_adapter *adapter, unsigned long off,
> +			    int data)
> +{
> +	unsigned long flags;
> +	void *addr;
> +
> +	if (ADDR_IN_WINDOW1(off)) {
> +		read_lock(&adapter->adapter_lock);
> +		writel(data, NETXEN_CRB_NORMALIZE(adapter, off));
> +		read_unlock(&adapter->adapter_lock);
> +	} else {
> +		write_lock_irqsave(&adapter->adapter_lock, flags);
> +		netxen_nic_pci_change_crbwindow(adapter, 0);
> +		addr = (void *)(adapter->ahw.pci_base + off);
> +		writel(data, addr);
> +		netxen_nic_pci_change_crbwindow(adapter, 1);
> +		write_unlock_irqrestore(&adapter->adapter_lock, flags);
> +	}
> +}
> +
> +void netxen_nic_set_link_parameters(struct netxen_port *port)
> +{
> +	struct netxen_adapter *adapter = port->adapter;
> +	struct netxen_niu_phy_status status;
> +	u16 autoneg;
> +	struct netxen_niu_control mode;
> +
> +	netxen_nic_read_w0(adapter, NETXEN_NIU_MODE, (u32 *) & mode);
> +	if (mode.enable_ge) {	/* Gb 10/100/1000 Mbps mode */
> +		if (netxen_nic_phy_read(port->adapter, port->portnum,
> +					NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
> +					(netxen_crbword_t *) & status) == 0) {
> +			if (status.link) {
> +				port->state = 1;
> +				switch (status.speed) {
> +				case 0:
> +					port->link_speed = SPEED_10;
> +					break;
> +				case 1:
> +					port->link_speed = SPEED_100;
> +					break;
> +				case 2:
> +					port->link_speed = SPEED_1000;
> +					break;
> +				default:
> +					port->link_speed = -1;	/* unknown speed */
> +					break;
> +				}
> +				switch (status.duplex) {
> +				case 0:
> +					port->link_duplex = DUPLEX_HALF;
> +					break;
> +				case 1:
> +					port->link_duplex = DUPLEX_FULL;
> +					break;
> +				default:
> +					port->link_duplex = -1;	/* unknown mode */
> +					break;
> +				}
> +				if (netxen_nic_phy_read(port->adapter,
> +							port->portnum,
> +							NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
> +							(netxen_crbword_t *) &
> +							autoneg) != 0)
> +					port->link_autoneg = autoneg;
> +			} else
> +				goto link_down;
> +		} else {
> +		      link_down:
> +			port->state = -1;
> +			port->link_speed = -1;
> +			port->link_duplex = -1;
> +		}
> +	}
> +}
> +
> +void netxen_nic_flash_print(struct netxen_adapter *adapter)
> +{
> +	int valid = 1;
> +	u32 fw_major = 0;
> +	u32 fw_minor = 0;
> +	u32 fw_build = 0;
> +
> +	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
> +	if (board_info->magic != NETXEN_BDINFO_MAGIC) {
> +		printk
> +		    ("NetXen Unknown board config, Read 0x%x expected as 0x%x\n",
> +		     board_info->magic, NETXEN_BDINFO_MAGIC);
> +		valid = 0;
> +	}
> +	if (board_info->header_version != NETXEN_BDINFO_VERSION) {
> +		printk("NetXen Unknown board config version."
> +		       " Read %x, expected %x\n",
> +		       board_info->header_version, NETXEN_BDINFO_VERSION);
> +		valid = 0;
> +	}
> +	if (valid) {
> +		printk("NetXen %s Board #%d, Chip id 0x%x\n",
> +		       board_info->board_type == 0x0b ? "XGB" : "GBE",
> +		       board_info->board_num, board_info->chip_id);
> +		read_lock(&adapter->adapter_lock);
> +		fw_major = readl(NETXEN_CRB_NORMALIZE(adapter,
> +						      NETXEN_FW_VERSION_MAJOR));
> +		fw_minor = readl(NETXEN_CRB_NORMALIZE(adapter,
> +						      NETXEN_FW_VERSION_MINOR));
> +		fw_build =
> +		    readl(NETXEN_CRB_NORMALIZE(adapter, NETXEN_FW_VERSION_SUB));
> +		read_unlock(&adapter->adapter_lock);
> +
> +		printk("NetXen Firmware version %d.%d.%d\n", fw_major, fw_minor,
> +		       fw_build);
> +	}
> +	if (fw_major != _NETXEN_NIC_LINUX_MAJOR) {
> +		printk(KERN_ERR "The mismatch in driver version and firmware "
> +		       "version major number\n"
> +		       "Driver version major number = %d \t"
> +		       "Firmware version major number = %d \n",
> +		       _NETXEN_NIC_LINUX_MAJOR, fw_major);
> +		adapter->driver_mismatch = 1;
> +	}
> +	if (fw_minor != _NETXEN_NIC_LINUX_MINOR) {
> +		printk(KERN_ERR "The mismatch in driver version and firmware "
> +		       "version minor number\n"
> +		       "Driver version minor number = %d \t"
> +		       "Firmware version minor number = %d \n",
> +		       _NETXEN_NIC_LINUX_MINOR, fw_minor);
> +		adapter->driver_mismatch = 1;
> +	}
> +	if (adapter->driver_mismatch)
> +		printk(KERN_INFO "Use the driver with version no %d.%d.xxx\n",
> +		       fw_major, fw_minor);
> +}
> 
> 
> 
-- 
pradeep

