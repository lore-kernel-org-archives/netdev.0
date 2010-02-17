From: "Tadepalli, Hari K" <hari.k.tadepalli@intel.com>
Subject: IxGbE: Node Aware Descriptor (Ring) Allocation
Date: Tue, 16 Feb 2010 21:28:03 -0700
Message-ID: <41885A88D9043444B138491FB10E15420476DD180E@azsmsx506.amr.corp.intel.com>
References: <41885A88D9043444B138491FB10E15420476DD1805@azsmsx506.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17136 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934020Ab0BQE2I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 23:28:08 -0500
In-Reply-To: <41885A88D9043444B138491FB10E15420476DD1805@azsmsx506.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings! This is my first post to this list. So please bear with any protocol violations. 

I am looking for hints on NUMA node-aware packet descriptor ring allocation in the IxGbE driver for Intel 82599 (10Gb) NICs, with multi queue feature enabled. 

There are three places in the IxGbE source where we need node aware allocation (shown below for TX only; analogous code for RX assumed): 

(i) tx_ring, rx_ring control structures of tx/rx rings:
	tx_ring->tx_buffer_info = vmalloc_node(size, tx_ring->numa_node);

(ii) descriptor rings in the DMA region: tx_ring->dma, rx_ring->dma
	tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size, &tx_ring->dma);

(iii) packet buffers:
	struct sk_buff *skb = netdev_alloc_skb(adapter->netdev,bufsz);

(i) and (iii) are able take a node parameter and accordingly return with node-aware allocation (on x86_64/NUMA enabled kernel with SLUB allocator). But, the same is not true of (ii) for descriptor ring allocation. Adding a node_id parameter to pdev structure with set_dev_node() call has no effect - presumably because the underlying dma_alloc_coherent() call has no node awareness. 

I have, hacked pci_alloc_consistent to ingest a node parameter & allocate with dma_generic_alloc_coherent(), which seems to allocate with alloc_pages_node() after stripping node parameter from the pdev->dev object. But, this did not work - I can dump TXD/RXD base addresses with ethregs tool & observe that all allocations are coming from only one of the two nodes present in Nehalem (Xeon 55xx) platforms. 

What is the status of node-aware DMA region allocation for IO devices on x86_64 platforms? Any known fixes?

Thanks, 

Hari
------------------------------------
Intel/Embedded Comms/Chandler/AZ
