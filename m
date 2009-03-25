From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-2.6 PATCH 7/10] Neterion: New driver: Main entry points
Date: Wed, 25 Mar 2009 08:30:08 -0700
Message-ID: <20090325083008.0179381d@nehalam>
References: <1237968795.1655.271.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39277 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755430AbZCYPa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 11:30:26 -0400
In-Reply-To: <1237968795.1655.271.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 Mar 2009 00:13:33 -0800
Ramkrishna Vepa <ram.vepa@neterion.com> wrote:

> This patch implements all the driver entry point functions.
> - Definition of all module loadable paramters.
> - Implementation of all driver entry point functions.
> - Changes from previous submission -
>  - Incorporated following review comments from Ben Hutchings
> 	- NAPI is always enabled (no option to turn it OFF).
> 	- Loadable parameters
> 	 rx_steering_type: This loadable option is removed. 
> 	 ring_blocks: This loadable option is removed.
> 	 The driver default settings work well in most if not all cases. 
> 	 Another patch to configure these parameters with ethtool will be
> 	 released in the future.
>  - LRO has been deprecated in favour of GRO - Bill Fink & Dave Miller's comment
>  - Fixed sparse warnings - Reported by Andi Kleen
>  - Removed unused variables 
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -Nurp patch_6/drivers/net/vxge/vxge-main.c patch_7/drivers/net/vxge/vxge-main.c
> --- patch_6/drivers/net/vxge/vxge-main.c	1969-12-31 16:00:00.000000000 -0800
> +++ patch_7/drivers/net/vxge/vxge-main.c	2009-03-24 13:34:33.000000000 -0700
> @@ -0,0 +1,4844 @@
> +/******************************************************************************
> +* This software may be used and distributed according to the terms of
> +* the GNU General Public License (GPL), incorporated herein by reference.
> +* Drivers based on or derived from this code fall under the GPL and must
> +* retain the authorship, copyright and license notice.  This file is not
> +* a complete program and may only be used when the entire operating
> +* system is licensed under the GPL.
> +* See the file COPYING in this distribution for more information.
> +*
> +* vxge-main.c: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
> +*              Virtualized Server Adapter.
> +* Copyright(c) 2002-2009 Neterion Inc.
> +*
> +* The module loadable parameters that are supported by the driver and a brief
> +* explanation of all the variables:
> +* vlan_tag_strip:
> +*	Strip VLAN Tag enable/disable. Instructs the device to remove
> +*	the VLAN tag from all received tagged frames that are not
> +*	replicated at the internal L2 switch.
> +*		0 - Do not strip the VLAN tag.
> +*		1 - Strip the VLAN tag.
> +*
> +* addr_learn_en:
> +*	Enable Receive Traffic Steering using MAC destination address.
> +*		0 - DISABLE
> +*		1 - ENABLE
> +*
> +* gro:
> +*	Enable Generic Receive Offload (GRO)
> +*		0 - DISABLE
> +*		1 - ENABLE
> +*
> +* max_config_port:
> +*	Maximum number of port to be supported.
> +*		MIN -1 and MAX - 2
> +*
> +* fifo_indicate_max_pkts:
> +*	Sets the maximum number of transmit frames to be processed within
> +*	single interrupt.
> +*		MIN - 1 and MAX - 65536
> +*
> +* ring_indicate_max_pkts:
> +*	Sets the maximum number of received frames to be processed within
> +*	single interrupt.
> +*		MIN - 1 and MAX - 65536
> +*
> +* max_config_vpath:
> +*	This configures the maximum no of VPATH configures for each
> +* 	device function.
> +*		MIN - 1 and MAX - 17
> +*
> +* max_config_dev:
> +*	This configures maximum no of Device function to be enabled.
> +*		MIN - 1 and MAX - 17
> +*
> +* intr_type:
> +*	This configures the type of interrupt.
> +*		0 - INTA
> +*		1 - Reserved
> +*		2 - MSIX
> +*		3 - EMULATED_INTA
> +*
> +* exec_mode:
> +*	This is set make enable the debug mode by default.
> +*		0 - DISABLE
> +*		1 - ENABLE
> +*
> +* tx_steering_type:
> +* 	This parameter is for configuring the transmit steering.
> +*		0 - No steering
> +*		1 - Priority steering
> +*		2 - Vlan steering
> +*		3 - Multiqueue steering
> +*		4 - Port steering (default)
> +*
> +* tx_pause_enable:
> +*	This parameter enables pause frame generation.
> +*		0 - Disable
> +*		1 - Enable
> +*
> +* rx_pause_enable:
> +*	This parameter enables response to received pause frames
> +*		0 - Disable
> +*		1 - Enable.
> +*
> +************************************

Module parameters are a method of last resort. Module parameters are
a pain for customers because they are hard to configure, and only work
on one device driver. They should not be used if anything else is available.

Therefore the following can be replaced by existing ethtool hooks
	gro	    -> ethtool_get_gro, ethtool_set_gro
        tx/rx_pause -> ethtool_get_pauseparm, ethtool_set_pauseparm

I would like to see the following added to ethtool, go ahead and propose
some additions to ethtool that do what you need for addr_learn_en and
tx_steering_type.

Not sure what exec_mode does but why not call it 'debug'

The intr_type parameter should be unnecessary, assuming the driver does
the right thing based on bus methods.  If you are worried about buggy MSIX
hardware, then please do a simulated irq to test IRQ routing.
        
Most drivers just use the NAPI weight to control the parameter you
are setting with ring_indicate_max_pkts. The weight value is changeable
at runtime with sysfs.
